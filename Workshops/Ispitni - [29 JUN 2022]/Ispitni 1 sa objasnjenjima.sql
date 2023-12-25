--1. Kroz SQL kod kreirati bazu podataka sa imenom va�eg broja indeksa.

CREATE DATABASE IB180079
GO
USE IB180079
GO

--2. U kreiranoj bazi podataka kreirati tabele sa sljede�om strukturom:
--a) Proizvodi
--� ProizvodID, cjelobrojna vrijednost i primarni klju�, autoinkrement
--� Naziv, 50 UNICODE karaktera (obavezan unos)
--� SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--� Boja, 15 UNICODE karaktera
--� NazivKategorije, 50 UNICODE (obavezan unos)
--� Tezina, decimalna vrijednost sa 2 znaka iza zareza

CREATE TABLE Proizvodi
(
ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY IDENTITY (1,1),
-- UNICODE karaktera NVARCHAR
-- karaktera VARCHAR
-- karaktera fiksne duzine CHAR
-- UNICODE karaktera fiksne duzine VCHAR DEFAULT 'nepoznato' 
Naziv NVARCHAR(50) NOT NULL,
SifraProizvoda NVARCHAR(25) NOT NULL,
Boja NVARCHAR(15),
NazivKategorije NVARCHAR(50) NOT NULL,
Tezina DECIMAL(18,2)
)
GO -- odvoji stvari da se moze vise razlicitih stvari pokrenuti u isto vrijeme

--b) ZaglavljeNarudzbe
--� NarudzbaID, cjelobrojna vrijednost i primarni klju�, autoinkrement
--� DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--� DatumIsporuke, polje za unos datuma i vremena
--� ImeKupca, 50 UNICODE (obavezan unos)
--� PrezimeKupca, 50 UNICODE (obavezan unos)
--� NazivTeritorije, 50 UNICODE (obavezan unos)
--� NazivRegije, 50 UNICODE (obavezan unos)
--� NacinIsporuke, 50 UNICODE (obavezan unos)

CREATE TABLE ZaglavljeNarudzbe
(
NarudzbaID INT CONSTRAINT PK_ZaglavljeNarudzbe PRIMARY KEY IDENTITY (1,1),
DatumNarudzbe DATETIME NOT NULL,
DatumIsporuke DATETIME,
ImeKupca NVARCHAR(50) NOT NULL,
PrezimeKupca NVARCHAR(50) NOT NULL,
NazivTeritorije NVARCHAR(50) NOT NULL,
NazivRegije NVARCHAR(50) NOT NULL,
NacinIsporuke NVARCHAR(50) NOT NULL
)
GO

--c) DetaljiNarudzbe
--� NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani klju�
--� ProizvodID, cjelobrojna vrijednost, obavezan unos i strani klju�
--� Cijena, nov�ani tip (obavezan unos),
--� Kolicina, skra�eni cjelobrojni tip (obavezan unos),
--� Popust, nov�ani tip (obavezan unos)

CREATE TABLE DetaljiNarudzbe
(
NarudzbaID INT NOT NULL CONSTRAINT FK_DetaljiNarudzbe_ZaglavljeNarudzbe FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID),
ProizvodID INT NOT NULL CONSTRAINT FK_DetaljiNarudzbe_Proizvodi FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
-- skraceni cjelobrojni tip  ---> SMAILLINT
-- kratki cijelobrojni tip   ---> TINYINT
Kolicina SMALLINT NOT NULL,
Popust MONEY NOT NULL,
DetaljiNarudzbeID INT NOT NULL CONSTRAINT PK_DetaljiNarudzbe PRIMARY KEY IDENTITY(1,1)
)
GO
-- bit polje ---> BIT
-- tekstualni tip ---> TEXT
-- UNICODE tekstualni tip ---> NTEXT
-- datum ---> DATE
-- realna vrijednost ---> REAL 
-- calculated polje ---> VrijednostStavki AS (Cijena*Kolicina*(1-Popust)),



--**Jedan proizvod se mo�e vi�e puta naru�iti, dok jedna narud�ba mo�e sadr�avati vi�e proizvoda. U okviru jedne
--narud�be jedan proizvod se mo�e naru�iti vi�e puta.--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljede�e podatke:
--a) U tabelu Proizvodi dodati sve proizvode, na mjestima gdje nema pohranjenih podataka o te�ini
--zamijeniti vrijednost sa 0
--� ProductID -> ProizvodID
--� Name -> Naziv
--� ProductNumber -> SifraProizvoda
--� Color -> Boja
--� Name (ProductCategory) -> NazivKategorije
--� Weight -> Tezina

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivKategorije,Tezina)
SELECT P.ProductID,P.Name,P.ProductNumber,P.Color,PC.Name,ISNULL(P.Weight,0)
FROM AdventureWorks2017.Production.Product AS P 
     INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PS
	 ON PS.ProductSubcategoryID=P.ProductSubcategoryID
	 INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	 ON PC.ProductCategoryID=PS.ProductCategoryID
SET IDENTITY_INSERT Proizvodi OFF
GO

--b) U tabelu ZaglavljeNarudzbe dodati sve narud�be
--� SalesOrderID -> NarudzbaID
--� OrderDate -> DatumNarudzbe
--� ShipDate -> DatumIsporuke
--� FirstName (Person) -> ImeKupca
--� LastName (Person) -> PrezimeKupca
--� Name (SalesTerritory) -> NazivTeritorije
--� Group (SalesTerritory) -> NazivRegije
--� Name (ShipMethod) -> NacinIsporuke

SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,ImeKupca,PrezimeKupca,NazivTeritorije,NazivRegije,NacinIsporuke)
SELECT SOH.SalesOrderID,SOH.OrderDate, SOH.ShipDate,P.FirstName,P.LastName,ST.Name,ST.[Group],SM.Name
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
     INNER JOIN AdventureWorks2017.Sales.Customer AS C
	 ON C.CustomerID=SOH.CustomerID
	 INNER JOIN AdventureWorks2017.Person.Person AS P
	 ON P.BusinessEntityID=C.PersonID
	 INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS ST
	 ON ST.TerritoryID=SOH.TerritoryID
	 INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS SM
	 ON SM.ShipMethodID=SOH.ShipMethodID
SET IDENTITY_INSERT ZaglavljeNarudzbe OFF
GO

--c) U tabelu DetaljiNarudzbe dodati sve stavke narud�be
--� SalesOrderID -> NarudzbaID
--� ProductID -> ProizvodID
--� UnitPrice -> Cijena
--� OrderQty -> Kolicina
--� UnitPriceDiscount -> Popust

INSERT INTO DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
SELECT SOD.SalesOrderID,SOD.ProductID,SOD.UnitPrice,SOD.OrderQty,SOD.UnitPriceDiscount
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD
GO

-- 4a
--Kreirati upit koji �e prikazati ukupan broj uposlenika po odjelima. Potrebno je prebrojati
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Tako�er, samo uzeti u obzir
--one uposlenike koji imaju vi�e od 10 godina radnog sta�a (ne uklju�uju�i grani�nu vrijednost). Rezultate
--sortirati preba broju uposlenika u opadaju�em redoslijedu. (AdventureWorks2017)USE AdventureWorks2017GOSELECT D.Name, COUNT(E.BusinessEntityID) 'Broj uposlenika'FROM HumanResources.Employee AS E     INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH 	 ON EDH.BusinessEntityID=E.BusinessEntityID	 INNER JOIN HumanResources.Department AS D	 ON D.DepartmentID=EDH.DepartmentIDWHERE DATEDIFF(YEAR,E.HireDate,GETDATE()) > 10 AND EDH.EndDate IS NULL GROUP BY D.NameORDER BY 2 DESC--b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poru�ene robe za skladi�te, te
--ukupnu koli�inu primljene robe, isklju�ivo u 2012 godini. Uslov je da su tro�kovi prevoza bili izme�u
--500 i 2500, a da je dostava izvr�ena CARGO transportom. Tako�er u rezultatima upita je potrebno
--prebrojati stavke narud�be na kojima je odbijena koli�ina ve�a od 100. (AdventureWorks2017)SELECT MONTH(POH.OrderDate) 'Mjesec', SUM(POD.LineTotal) 'Porucena roba za skladiste',SUM(POD.ReceivedQty) 'Ukupna kolicina primljene robe', (SELECT COUNT(POH1.PurchaseOrderID)                                                        FROM Purchasing.PurchaseOrderHeader AS POH1														INNER JOIN Purchasing.PurchaseOrderDetail AS POD1														ON POD1.PurchaseOrderID=POH1.PurchaseOrderID														INNER JOIN Purchasing.ShipMethod AS SM1														ON SM1.ShipMethodID=POH1.ShipMethodID														WHERE YEAR(POH1.OrderDate) = 2012 														AND POH1.Freight BETWEEN 500 AND 2500 														AND SM1.Name LIKE '%CARGO%' AND														MONTH(POH.OrderDate) = MONTH(POH1.OrderDate)														AND POD1.RejectedQty> 100                                                        ) 'Stavke koji imaju odbijenu kolicinu vecu od 100'FROM Purchasing.PurchaseOrderHeader AS POH     INNER JOIN Purchasing.PurchaseOrderDetail AS POD	 ON POD.PurchaseOrderID=POH.PurchaseOrderID	 INNER JOIN Purchasing.ShipMethod AS SM	 ON SM.ShipMethodID=POH.ShipMethodIDWHERE YEAR(POH.OrderDate) = 2012 AND POH.Freight BETWEEN 500 AND 2500 AND SM.Name LIKE '%CARGO%'GROUP BY MONTH(POH.OrderDate)--c) (10 bodova) Prikazati ukupan broj narud�bi koje su obradili uposlenici, za svakog uposlenika
--pojedina�no. Uslov je da su narud�be kreirane u 2011 ili 2012 godini, te da je u okviru jedne narud�be
--odobren popust na dvije ili vi�e stavki. Tako�er uzeti u obzir samo one narud�be koje su isporu�ene u
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)
SELECT P.FirstName + ' '+P.LastName, COUNT(SOH.SalesOrderID) 'Broj narudzbi'
FROM Person.Person AS P INNER JOIN HumanResources.Employee AS E
     ON P.BusinessEntityID=E.BusinessEntityID
	 INNER JOIN Sales.SalesPerson AS SP
	 ON SP.BusinessEntityID=E.BusinessEntityID
	 INNER JOIN Sales.SalesOrderHeader AS SOH
	 ON SP.BusinessEntityID=SOH.SalesPersonID
GROUP BY P.FirstName + ' '+P.LastName




