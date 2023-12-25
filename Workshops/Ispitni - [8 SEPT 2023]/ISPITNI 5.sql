USE AdventureWorks2017

CREATE DATABASE IB180079
GO
USE IB180079






--2a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Ime, 50 UNICODE karaktera (obavezan unos)
--• Prezime, 50 UNICODE karaktera (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE 

CREATE TABLE Prodavaci
(
ProdavacID INT CONSTRAINT PK_Prodavaci PRIMARY KEY IDENTITY(1,1),
Ime NVARCHAR(50) NOT NULL,
Prezime NVARCHAR(50) NOT NULL,
OpisPosla NVARCHAR(50) NOT NULL,
EmailAdresa NVARCHAR(50)
)
GO

--2b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)

CREATE TABLE Proizvodi
(
ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY IDENTITY (1,1),
Naziv NVARCHAR(50) NOT NULL,
SifraProizvoda NVARCHAR(25) NOT NULL,
Boja NVARCHAR(15),
NazivKategorije NVARCHAR(50) NOT NULL,
)
GO

--2c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGrada, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost i strani kljuè--• NacinIsporuke, 50 UNICODE (obavezan unos)

CREATE TABLE ZaglavljeNarudzbe
(
NarudzbaID INT CONSTRAINT PK_ZaglavljeNarudzbe PRIMARY KEY IDENTITY (1,1),
DatumNarudzbe DATETIME NOT NULL,
DatumIsporuke DATETIME,
KreditnaKarticaID INT,
ImeKupca NVARCHAR(50) NOT NULL,
PrezimeKupca NVARCHAR(50) NOT NULL,
NazivGrada NVARCHAR(30) NOT NULL,
ProdavacID INT CONSTRAINT FK_ZaglavljeNarudzbe_Prodavaci FOREIGN KEY REFERENCES Prodavaci(ProdavacID),
NacinIsporuke NVARCHAR(50) NOT NULL
)
GO

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• Cijena, novèani tip (obavezan unos),
--• Kolicina, skraæeni cjelobrojni tip (obavezan unos),
--• Popust, novèani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)


CREATE TABLE DetaljiNarudzbe
(
NarudzbaID INT NOT NULL CONSTRAINT FK_DetaljiNarudzbe_ZaglavljeNarudzbe FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID),
ProizvodID INT NOT NULL CONSTRAINT FK_DetaljiNarudzbe_Proizvodi FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina SMALLINT NOT NULL,
Popust MONEY NOT NULL,
OpisSpecijalnePonude NVARCHAR(255) NOT NULL,
DetaljiNarudzbeID INT NOT NULL CONSTRAINT PK_DetaljiNarudzbe PRIMARY KEY IDENTITY(1,1)
)
GO

--**Jedan proizvod se može više puta naruèiti, dok jedna narudžba može sadržavati više proizvoda. 
--U okviru jedne narudžbe jedan proizvod se može naruèiti više puta.


--3a. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeæe podatke:
--a) U tabelu Prodavaci dodati :
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName -> Ime
--• LastName -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa

SET IDENTITY_INSERT Prodavaci ON
INSERT INTO Prodavaci(ProdavacID,Ime,Prezime,OpisPosla,EmailAdresa)
SELECT SP.BusinessEntityID,P.FirstName,P.LastName,E.JobTitle, A.EmailAddress
FROM AdventureWorks2017.Sales.SalesPerson AS SP
	 INNER JOIN AdventureWorks2017.HumanResources.Employee AS E
	 ON E.BusinessEntityID=SP.BusinessEntityID
	 INNER JOIN AdventureWorks2017.Person.Person AS P
	 ON P.BusinessEntityID=E.BusinessEntityID
	 INNER JOIN AdventureWorks2017.Person.EmailAddress AS A
	 ON A.BusinessEntityID=P.BusinessEntityID  -- mozda emailID
SET IDENTITY_INSERT Prodavaci OFF



--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeæe podatke:
--3b) U tabelu Proizvodi dodati sve proizvode
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivKategorije)
SELECT P.ProductID,P.Name,P.ProductNumber,P.Color,PC.Name
FROM AdventureWorks2017.Production.Product AS P 
     INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PS
	 ON PS.ProductSubcategoryID=P.ProductSubcategoryID
	 INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	 ON PC.ProductCategoryID=PS.ProductCategoryID
SET IDENTITY_INSERT Proizvodi OFF
GO


--3c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• CreditCardID -> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGrada
--• SalesPersonID (SalesOrderHeader) -> ProdavacID
--• Name (ShipMethod) -> NacinIsporuke

SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,KreditnaKarticaID,ImeKupca,PrezimeKupca,NazivGrada,ProdavacID,NacinIsporuke)
SELECT SOH.SalesOrderID,SOH.OrderDate, SOH.ShipDate,SOH.CreditCardID,P.FirstName,P.LastName,A.City,SOH.SalesPersonID,SM.Name
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
     INNER JOIN AdventureWorks2017.Sales.Customer AS C
	 ON C.CustomerID=SOH.CustomerID
	 INNER JOIN AdventureWorks2017.Person.Person AS P
	 ON P.BusinessEntityID=C.PersonID
	 INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS SM
	 ON SM.ShipMethodID=SOH.ShipMethodID
	 INNER JOIN AdventureWorks2017.Person.Address AS A
	 ON A.AddressID=SOH.ShipToAddressID
SET IDENTITY_INSERT ZaglavljeNarudzbe OFF
GO

--3d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude



INSERT INTO DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust,OpisSpecijalnePonude)
SELECT SOD.SalesOrderID,SOD.ProductID,SOD.UnitPrice,SOD.OrderQty,SOD.UnitPriceDiscount,SO.Description
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD
     INNER JOIN AdventureWorks2017.Sales.SpecialOfferProduct AS SOP
	 ON SOP.ProductID=SOD.ProductID AND SOP.SpecialOfferID=SOD.SpecialOfferID
	 INNER JOIN AdventureWorks2017.Sales.SpecialOffer AS SO
	 ON SO.SpecialOfferID=SOP.SpecialOfferID





USE AdventureWorks2017




--3c)(6 bodova) Kreirati upit kojim ce se prikazati ukupan broj proizvoda po kategorijama.
-- Uslov je da se prikazu samo one kategorije kojima ne pripada vise od 30 proizvoda,
-- a sadrze broj u bilo kojoj od rijeci i ne nalaze se u prodaji.(AdventureWorks2017)

SELECT PC.Name, COUNT(P.ProductID) 'Ukupan broj proizvoda'
FROM Production.Product AS P
INNER JOIN Production.ProductSubcategory AS PS 
ON PS.ProductSubcategoryID=P.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC
ON PC.ProductCategoryID=PS.ProductCategoryID
WHERE P.Name LIKE '%[0-9]%' AND P.SellEndDate IS NOT NULL
GROUP BY PC.Name
HAVING COUNT(P.ProductID) <=30




--3d)(7 bodova) Kreirati upit koji ce prikazati uposlenike koji imaju iskustva( radilli su na jednom odjelu) 
--a trenutno rade na marketing ili odjelu za nabavku. 
--Osobama po prestanku rada na odjelu se upise podatak datuma prestanka rada.
--Rezultat upita treba prikazati ime i prezime uposlenika, odjel na kojem rade.
--(AdventureWorks2017)

SELECT P.FirstName + ' ' + P.LastName 'Ime i prezime' ,D.Name
FROM HumanResources.Employee AS E
INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
INNER JOIN HumanResources.Department as D
ON EDH.DepartmentID = D.DepartmentID
INNER JOIN Person.Person AS P
ON E.BusinessEntityID = P.BusinessEntityID
WHERE D.Name IN ('Marketing','Purchasing') 
AND E.BusinessEntityID IN(SELECT EDH.BusinessEntityID  -- naci da su nekad radili negdje i zavrsili 
	                      FROM HumanResources.EmployeeDepartmentHistory AS EDH
	                      WHERE EDH.EndDate IS NOT NULL
                          ) 
						  AND EDH.EndDate IS NULL      -- da sada rade 
GROUP BY P.FirstName + ' ' + P.LastName , D.Name




--3e)(7 bodova) Kreirati upit kojim ce se prikazati proizvod koji je najvise dana bio u prodaji
--( njegova prodaja je prestala) a pripada kategoriji bicikala. 
--Proizvodu se pocetkom i po prestanku prodaje biljezi datum.Ukoliko postoji vise proizvoda
--sa istim vremenskim periodom kao i prvi prikazati ih u rezultatima upita.(AdventureWorks2017)

SELECT TOP 1 WITH TIES P.Name, DATEDIFF(DAY,P.SellStartDate,P.SellEndDate) 'Dana u prodaji'
FROM Production.Product AS P
INNER JOIN Production.ProductSubcategory AS PS 
ON PS.ProductSubcategoryID=P.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC 
ON PC.ProductCategoryID=PS.ProductCategoryID
WHERE P.SellEndDate IS NOT NULL AND PC.Name LIKE '%Bikes%'
ORDER BY 2 DESC

--a) (9 bodova) Prikazati nazive odjela na kojima TRENUTNO radi najmanje , 
--odnosno najvise uposlenika(AdventureWorks2017)
SELECT Q1.Name,Q1.[Trenutno uposlenika]
FROM (SELECT TOP 1 D.Name, COUNT(E.BusinessEntityID) 'Trenutno uposlenika'
      FROM HumanResources.Employee AS E
	  INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH
	  ON EDH.BusinessEntityID=E.BusinessEntityID
	  INNER JOIN HumanResources.Department AS D
	  ON D.DepartmentID=EDH.DepartmentID
	  WHERE EDH.EndDate IS NULL
	  GROUP BY D.Name
	  ORDER BY 2 DESC
      ) AS Q1
UNION
SELECT Q2.Name,Q2.[Trenutno uposlenika]
FROM (SELECT TOP 1 D.Name,COUNT(E.BusinessEntityID) 'Trenutno uposlenika'
      FROM HumanResources.Employee AS E
	  INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH
	  ON EDH.BusinessEntityID=E.BusinessEntityID
	  INNER JOIN HumanResources.Department AS D
	  ON D.DepartmentID=EDH.DepartmentID
	  WHERE EDH.EndDate IS NULL
	  GROUP BY D.Name
	  ORDER BY 2 ASC
      ) AS Q2

USE pubs
--5f)(12 bodova) Upitom prikazati id autora, ime i prezime, napisano djelo i šifra. Prikazati samo one zapise gdje adresa autora pocinje sa ISKLJUCIVO 2 broja (Pubs)
--Šifra se sastoji od sljedeæi vrijednosti: 
--	1.Prezime po pravilu(prezime od 6 karaktera -> uzeti prva 4 karaktera; prezime od 10 karaktera-> 
--  uzeti prva 6 karaktera, za sve ostale slucajeve uzeti prva dva karaktera)
--	2.Ime prva 2 karaktera
--	3.Karakter /
--	4.Zip po pravilu( 2 karaktera sa desne strane ukoliko je zadnja cifra u opsegu 0-5; 
--  u suprotnom 2 karaktera sa lijeve strane)
--	5.Karakter /
--	6.State(obrnuta vrijednost)
--	7.Phone(brojevi izmeðu space i karaktera -)
--	Primjer : za autora sa id-om 486-29-1786 šifra je LoCh/30/AC585
--			  za autora sa id-om 998-72-3567 šifra je RingAl/52/TU826
SELECT A.au_fname + ' '+A.au_lname 'Ime i prezime' , T.title ,A.phone,
IIF(LEN(A.au_lname)=6,SUBSTRING(A.au_lname,1,4),IIF(LEN(A.au_lname)=10,SUBSTRING(A.au_lname,1,6),SUBSTRING(A.au_lname,1,2)))+
SUBSTRING(A.au_fname,1,2)+ '/' +
IIF(PATINDEX(1,REVERSE(A.zip)) BETWEEN 0 AND 5, SUBSTRING(A.zip,4,2),SUBSTRING(A.zip,1,2))+ '/' +
REVERSE(A.state)+
SUBSTRING(A.phone,CHARINDEX(' ',A.phone)+1,3)
'Sifra'
FROM authors AS A
INNER JOIN titleauthor AS TA
ON TA.au_id=A.au_id
INNER JOIN titles AS T
ON T.title_id=TA.title_id
WHERE A.address LIKE '[0-9][0-9]%'


--b)( 4 bodova) U kreiranoj bazi kreirati wproceduru sp_insert_ZaglavljeNarudzbe kojom ce se omoguciti kreiranje nove narudzbe.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza).

SELECT*
INTO TestniSlucaj
FROM ZaglavljeNarudzbe

CREATE PROCEDURE sp_insert1_ZaglavljeNarudzbe
(
     @DatumNarudzbe DATETIME,
	 @DatumIsporuke DATETIME = NULL,
	 @KreditnaKarticaID INT = NULL,
	 @ImeKupca NVARCHAR(50),
	 @PrezimeKupca NVARCHAR(50),
	 @NazivGrada NVARCHAR(30),
	 @ProdavacID INT = NULL,
	 @NacinIsporuke NVARCHAR(50)
)
AS
BEGIN
INSERT INTO TestniSlucaj(DatumNarudzbe,DatumIsporuke,KreditnaKarticaID,ImeKupca,PrezimeKupca,NazivGrada,ProdavacID,NacinIsporuke)
VALUES(@DatumNarudzbe,@DatumIsporuke,@KreditnaKarticaID,@ImeKupca,@PrezimeKupca,@NazivGrada,@ProdavacID,@NacinIsporuke)
END
GO

EXEC sp_insert1_ZaglavljeNarudzbe '2024-05-31 00:00:00.000', '2024-05-31 00:00:00.000',2323,'Vedad','Keskin','Mostar',279,'Posta'


USE AdventureWorks2017
--a)(6 bodova) kreirati pogled v_detalji gdje je korisniku potrebno prikazati identifikacijski broj narudzbe,
--spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudzbe sa popustom i bez popusta,
--te u dodatnom polju informacija da li je narudzba placena karticom ("Placeno karticom" ili "Nije placeno karticom").
--Rezultate sortirati prema vrijednosti narudzbe sa popustom u opadajucem redoslijedu.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza)
CREATE VIEW v_detalji
AS 
SELECT P.FirstName + ' '+P.LastName 'Ime i prezime',AD.City,SOH.TotalDue, 
SUM(SOD.OrderQty * SOD.UnitPrice) 'Narudzba bez popusta',
IIF(SOH.CreditCardID IS NULL,'Nije placeno karticom','Placeno karticom') 'Vrsta placanja'
FROM Person.Person AS P
     INNER JOIN Sales.Customer AS C
	 ON C.PersonID=P.BusinessEntityID
	 INNER JOIN Sales.SalesOrderHeader AS SOH
	 ON SOH.CustomerID=C.CustomerID
	 INNER JOIN Person.Address AS AD
	 ON AD.AddressID=SOH.ShipToAddressID
	 INNER JOIN Sales.SalesOrderDetail AS SOD
	 ON SOD.SalesOrderID=SOH.SalesOrderID
GROUP BY P.FirstName + ' '+P.LastName,AD.City,SOH.TotalDue, SOH.CreditCardID

SELECT*
FROM v_detalji
ORDER BY 3 DESC










--b)(10 bodova) Kreirati upit kojim ce se prikazati ukupan broj obradjenih narudzbi i
--  ukupnu vrijednost narudzbi sa popustom za svakog uposlenika pojedinacno,
--  i to od zadnje 30% kreiranih datumski kreiranih narudzbi.
--  Rezultate sortirati prema ukupnoj vrijednosti u opadajucem redoslijedu.
--  (AdventureWorks2017)

SELECT P.FirstName + ' '+ P.LastName 'Ime i prezime', COUNT(SOH.SalesOrderID) 'Broj naruzbi', SUM(SOH.TotalDue) 'Ukupna vrijednost sa popustom'
FROM Person.Person AS P
     INNER JOIN HumanResources.Employee AS E
	 ON E.BusinessEntityID=P.BusinessEntityID
	 INNER JOIN Sales.SalesPerson AS SP
	 ON SP.BusinessEntityID=E.BusinessEntityID
	 INNER JOIN Sales.SalesOrderHeader AS SOH
	 ON SOH.SalesPersonID=SP.BusinessEntityID
WHERE SOH.OrderDate IN (SELECT TOP 30 PERCENT SOH1.OrderDate
                        FROM Sales.SalesOrderHeader AS SOH1
						ORDER BY 1 DESC
                        )
GROUP BY P.FirstName + ' '+ P.LastName
ORDER BY 3 DESC



