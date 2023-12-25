CREATE DATABASE Ispit_2
GO
USE Ispit_2

--REDOSLIJED IZVRŠAVANJA JE VAŽAN RADI POVEZIVANJA TABELA, IDE: a,b,d,c

--2 a)
CREATE TABLE Izdavaci
(
	IzdavacID CHAR(4) CONSTRAINT PK_Izdavaci PRIMARY KEY,
	Naziv VARCHAR(40),
	Grad VARCHAR(20),
	Drzava VARCHAR(40),
	DodatneInformacije TEXT
)

--2 b)
CREATE TABLE Naslovi
(
	NaslovID VARCHAR(6) CONSTRAINT PK_Naslovi PRIMARY KEY,
	Naslov VARCHAR(80) NOT NULL,
	Tip CHAR(12) NOT NULL,
	Cijena MONEY,
	IzdavacID CHAR(4) NOT NULL CONSTRAINT FK_Naslovi_Izdavaci FOREIGN KEY REFERENCES Izdavaci(IzdavacID)
)

--2 d)
CREATE TABLE Prodavnice
(
	ProdavnicaID CHAR(4) CONSTRAINT PK_Prodavnice PRIMARY KEY,
	NazivProdavnice VARCHAR(40),
	Grad VARCHAR(40)
)

--2 c)
CREATE TABLE Prodaja
(
	ProdavnicaID CHAR(4) CONSTRAINT FK_Prodaja_Prodavnice FOREIGN KEY REFERENCES Prodavnice(ProdavnicaID),
	BrojNarudzbe VARCHAR(20),
	NaslovID VARCHAR(6) CONSTRAINT FK_Prodaja_Naslovi FOREIGN KEY REFERENCES Naslovi(NaslovID),
	DatumNarudzbe DATETIME NOT NULL,
	Kolicina SMALLINT NOT NULL
	CONSTRAINT PK_Prodaja PRIMARY KEY(ProdavnicaID,BrojNarudzbe,NaslovID)
)

--REDOSLIJED IZVRŠAVANJA JE VAŽAN RADI VEZA IZMEĐU TABELA, IDE: a,b,d,c

--3 a)
INSERT INTO Izdavaci(IzdavacID,Naziv,Grad,Drzava,DodatneInformacije)
SELECT P.pub_id,P.pub_name,P.city,P.country,PI.pr_info
FROM pubs.dbo.publishers AS P
INNER JOIN pubs.dbo.pub_info AS PI
ON PI.pub_id=P.pub_id

--3 b)
INSERT INTO Naslovi(NaslovID,Naslov,Tip,Cijena,IzdavacID)
SELECT T.title_id,T.title,T.type,T.price,T.pub_id
FROM pubs.dbo.titles AS T

--3 d)
INSERT INTO Prodavnice(ProdavnicaID,NazivProdavnice,Grad)
SELECT S.stor_id,S.stor_name,S.city
FROM pubs.dbo.stores AS S

--3 c)
INSERT INTO Prodaja(ProdavnicaID,BrojNarudzbe,NaslovID,DatumNarudzbe,Kolicina)
SELECT S.stor_id,S.ord_num,S.title_id,S.ord_date,S.qty
FROM pubs.dbo.sales AS S

--4 a)
GO
CREATE PROCEDURE sp_edit_izdavac
(
	@IzdavacID CHAR(4),
	@Naziv VARCHAR(40)=NULL,
	@Grad VARCHAR(20)=NULL,
	@Drzava VARCHAR(40)=NULL,
	@DodatneInformacije TEXT=NULL
)
AS
BEGIN
	UPDATE Izdavaci
	SET Naziv=ISNULL(@Naziv,Naziv),
		Grad=ISNULL(@Grad,Grad),
		Drzava=ISNULL(@Drzava,Drzava),
		DodatneInformacije=ISNULL(@DodatneInformacije,DodatneInformacije)
	WHERE IzdavacID LIKE @IzdavacID
END

SELECT *
FROM Izdavaci

EXEC sp_edit_izdavac @IzdavacID='0736', @Naziv='ProceduraTest'


SELECT *
FROM Izdavaci

--4 b)
CREATE TABLE Prodavnice_log2
(
	LogID INT CONSTRAINT PK_LogID PRIMARY KEY IDENTITY(1,1),
	ProdavnicaID CHAR(4),
	Naziv VARCHAR(40),
	Grad VARCHAR(40),
	Datum DATETIME,
	Opis VARCHAR(10)	
)

--4 c)
GO
CREATE OR ALTER TRIGGER t_del_Prodavnice
ON Prodavnice
AFTER DELETE
AS
BEGIN
	INSERT INTO Prodavnice_log2(ProdavnicaID,Naziv,Grad,Datum,Opis)
	SELECT ProdavnicaID, NazivProdavnice,Grad,GETDATE(),'DELETE'
	FROM deleted
END

INSERT INTO Prodavnice
VALUES (1,'TestZaDelete','Livno')

SELECT *
FROM Prodavnice

SELECT *
FROM Prodavnice_log2

DELETE
FROM Prodavnice
WHERE ProdavnicaID LIKE '1'

SELECT *
FROM Prodavnice

SELECT *
FROM Prodavnice_log2

--4 d)

USE pubs

SELECT TOP 10 WITH TIES S.ord_num, T.title, S.ord_date, S.qty
FROM pubs.dbo.sales AS S
INNER JOIN pubs.dbo.titles AS T
ON S.title_id=T.title_id
ORDER BY 4 DESC

--4 e)
USE Northwind

SELECT OD.OrderID, SUM(OD.Quantity) 'Ukupno proizvoda', ROUND(SUM(OD.Quantity*OD.UnitPrice),2) 'Bez popusta',
ROUND(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),2) 'Sa popustom'
FROM Northwind.dbo.[Order Details] AS OD
INNER JOIN Northwind.dbo.Orders AS O
ON O.OrderID=OD.OrderID
WHERE DATEDIFF(DAY, O.OrderDate,O.ShippedDate)<=7 AND O.ShipCity IN ('München', 'Seattle', 'Madrid')
GROUP BY OD.OrderID
ORDER BY 2 DESC


--4 f)
USE prihodi

SELECT O.Ime, O.PrezIme, P.Naziv, TRP.NazivRedovnogPrihoda, RP.Neto, RP.Godina
FROM prihodi.dbo.Osoba AS O
INNER JOIN prihodi.dbo.Poslodavac AS P
ON P.PoslodavacID=O.PoslodavacID
INNER JOIN prihodi.dbo.RedovniPrihodi AS RP
ON RP.OsobaID=O.OsobaID
INNER JOIN prihodi.dbo.TipRedovnogPrihoda AS TRP
ON TRP.TipRedovnogPrihodaID=RP.TipRedovnogPrihodaID
LEFT JOIN prihodi.dbo.VanredniPrihodi AS VP
ON VP.OsobaID=O.OsobaID
WHERE O.Spol LIKE 'F' AND VP.VanredniPrihodiID IS NULL
ORDER BY 6 DESC, 4 ASC, 5 DESC

-- TEST 1 => Prezime Fullager se nalazi u tabeli RP(ima redovne prihode)
SELECT *
FROM prihodi.dbo.Osoba AS O
INNER JOIN prihodi.dbo.RedovniPrihodi AS RP
ON RP.OsobaID=O.OsobaID
WHERE O.PrezIme LIKE 'Fullager'

-- TEST 2 => Prezime Fullager se nalazi u tabeli VP(ima vanredne prihode)
SELECT *
FROM prihodi.dbo.Osoba AS O
LEFT JOIN prihodi.dbo.VanredniPrihodi AS VP
ON VP.OsobaID=O.OsobaID
WHERE O.PrezIme LIKE 'Fullager' AND VP.VanredniPrihodiID IS NOT NULL

-- TEST 3 => Prezime Fullager se NE nalazi u tabeli jer ima redovni i vanredni prihod (uslov zadatka je da ima samo RP a VP nema)
SELECT *
FROM prihodi.dbo.Osoba AS O
INNER JOIN prihodi.dbo.RedovniPrihodi AS RP
ON RP.OsobaID=O.OsobaID
LEFT JOIN prihodi.dbo.VanredniPrihodi AS VP
ON VP.OsobaID=O.OsobaID
WHERE VP.VanredniPrihodiID IS NULL AND O.Spol LIKE 'F' AND O.PrezIme LIKE 'Fullager'


--5 a)

USE AdventureWorks2017




SELECT TOP 1 D.Name, COUNT(E.BusinessEntityID) 'Broj uposlenika'
FROM AdventureWorks2017.HumanResources.Department AS D
INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS EDH
ON EDH.DepartmentID=D.DepartmentID
INNER JOIN AdventureWorks2017.HumanResources.Employee AS E
ON E.BusinessEntityID=EDH.BusinessEntityID
WHERE DATEDIFF(YEAR,E.BirthDate,GETDATE())>65
GROUP BY D.Name
ORDER BY 2 DESC


--5 b)
SELECT TOP 1 P.Name, SUM(SOD.OrderQty) 'Prodana kolicina'
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH
ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN AdventureWorks2017.Production.Product AS P
ON P.ProductID=SOD.ProductID
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC
ON PSC.ProductSubcategoryID=P.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
ON PC.ProductCategoryID=PSC.ProductCategoryID
WHERE YEAR(SOH.OrderDate)=2011 AND PC.Name LIKE '%Component%'
GROUP BY P.Name
ORDER BY 2 DESC

--5 c)
SELECT AVG(PODQ.Broj)
FROM(
SELECT SP.BusinessEntityID, COUNT(SOH.SalesOrderID)'Broj'
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
INNER JOIN AdventureWorks2017.Sales.SalesPerson AS SP			-- PODUPIT KOJI RADI AVG BROJA NARUDŽBI
ON SP.BusinessEntityID=SOH.SalesPersonID
GROUP BY SP.BusinessEntityID
) AS PODQ

SELECT P.FirstName,P.LastName, DATEDIFF(YEAR,E.HireDate,GETDATE())'Staz', COUNT(SOH.SalesOrderID) 'Broj narudzbi',
	IIF(COUNT(SOH.SalesOrderID)>(SELECT AVG(PODQ.Broj)					--
	FROM(																--
	SELECT SP.BusinessEntityID, COUNT(SOH.SalesOrderID)'Broj'			--
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH				-- PODUPIT COPY PASTE OD IZNAD, samo ubačeno u IIF da poredi sa Brojem narudžbi
	INNER JOIN AdventureWorks2017.Sales.SalesPerson AS SP				--
	ON SP.BusinessEntityID=SOH.SalesPersonID							--
	GROUP BY SP.BusinessEntityID										--
	) AS PODQ),'Iznadprosjecan','Ispodprosjecan') 'Grupa'				--

FROM AdventureWorks2017.Person.Person AS P
INNER JOIN AdventureWorks2017.HumanResources.Employee AS E
ON E.BusinessEntityID=P.BusinessEntityID
INNER JOIN AdventureWorks2017.Sales.SalesPerson AS SP
ON SP.BusinessEntityID=E.BusinessEntityID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH
ON SOH.SalesPersonID=SP.BusinessEntityID
GROUP BY P.FirstName,P.LastName,E.HireDate
ORDER BY 4 DESC



