--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

CREATE DATABASE IB180079
GO
USE IB180079
GO

--2. U kreiranoj bazi podataka kreirati tabele sa sljedeæom strukturom:
--2a) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)
--• Tezina, decimalna vrijednost sa 2 znaka iza zareza

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

--2b) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivTeritorije, 50 UNICODE (obavezan unos)
--• NazivRegije, 50 UNICODE (obavezan unos)
--• NacinIsporuke, 50 UNICODE (obavezan unos)

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

--2c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• Cijena, novèani tip (obavezan unos),
--• Kolicina, skraæeni cjelobrojni tip (obavezan unos),
--• Popust, novèani tip (obavezan unos)

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



--**Jedan proizvod se može više puta naruèiti, dok jedna narudžba može sadržavati više proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naruèiti više puta.--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeæe podatke:
--3a) U tabelu Proizvodi dodati sve proizvode, na mjestima gdje nema pohranjenih podataka o težini
--zamijeniti vrijednost sa 0
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije
--• Weight -> Tezina

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivKategorije,Tezina)
SELECT P.ProductID,P.Name,P.ProductNumber,P.Color,PC.Name,ISNULL(P.Weight,0)
FROM AdventureWorks2017.Production.Product AS P
     INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC
	 ON PSC.ProductSubcategoryID=P.ProductSubcategoryID
	 INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	 ON PC.ProductCategoryID=PSC.ProductCategoryID
SET IDENTITY_INSERT Proizvodi OFF
GO

--3b) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• Name (SalesTerritory) -> NazivTeritorije
--• Group (SalesTerritory) -> NazivRegije
--• Name (ShipMethod) -> NacinIsporuke

SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,ImeKupca,PrezimeKupca,NazivTeritorije,NazivRegije,NacinIsporuke)
SELECT SOH.SalesOrderID,SOH.OrderDate,SOH.ShipDate,P.FirstName,P.LastName,ST.Name,ST.[Group],SM.Name
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
     INNER JOIN AdventureWorks2017.Sales.Customer AS C
	 ON SOH.CustomerID=C.CustomerID
	 INNER JOIN AdventureWorks2017.Person.Person AS P
	 ON P.BusinessEntityID=C.PersonID
     INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS ST
	 ON ST.TerritoryID=SOH.TerritoryID
	 INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS SM
	 ON SM.ShipMethodID=SOH.ShipMethodID
SET IDENTITY_INSERT ZaglavljeNarudzbe OFF
GO

--3c) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust

INSERT INTO DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
SELECT SOD.SalesOrderID,SOD.ProductID,SOD.UnitPrice,SOD.OrderQty,SOD.UnitPriceDiscount
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD

USE AdventureWorks2017
GO

--4a) (6 bodova) Kreirati upit koji æe prikazati ukupan broj uposlenika po odjelima. Potrebno je prebrojati
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Takoðer, samo uzeti u obzir
--one uposlenike koji imaju više od 10 godina radnog staža (ne ukljuèujuæi graniènu vrijednost). Rezultate
--sortirati preba broju uposlenika u opadajuæem redoslijedu. (AdventureWorks2017)


SELECT D.Name, COUNT(E.BusinessEntityID) 'Broj uposlenika'
FROM HumanResources.Employee AS E
     INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH
	 ON EDH.BusinessEntityID=E.BusinessEntityID
	 INNER JOIN HumanResources.Department AS D
	 ON D.DepartmentID=EDH.DepartmentID
WHERE EDH.EndDate IS NULL AND DATEDIFF(YEAR,E.HireDate,GETDATE()) > 10
GROUP BY D.Name
ORDER BY 2 DESC

--4b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poruèene robe za skladište, te
--ukupnu kolièinu primljene robe, iskljuèivo u 2012 godini. Uslov je da su troškovi prevoza bili izmeðu
--500 i 2500, a da je dostava izvršena CARGO transportom. Takoðer u rezultatima upita je potrebno
--prebrojati stavke narudžbe na kojima je odbijena kolièina veæa od 100. (AdventureWorks2017)
SELECT MONTH(POH.OrderDate) 'Mjesec narudzbe', SUM(POD.LineTotal) 'Ukupna vrijednost',
SUM(POD.ReceivedQty) 'Ukupna kolicina primljene robe', (SELECT COUNT(POD1.ProductID)
                                                        FROM Purchasing.PurchaseOrderDetail AS POD1
														INNER JOIN Purchasing.PurchaseOrderHeader AS POH1
														ON POH1.PurchaseOrderID=POD1.PurchaseOrderID
														INNER JOIN Purchasing.ShipMethod AS SM1
														ON SM1.ShipMethodID=POH1.ShipMethodID
														WHERE POD1.RejectedQty > 100 AND
														YEAR(POH1.OrderDate) = 2012 AND
														POH1.Freight BETWEEN 500 AND 2500
														AND SM1.Name LIKE '%CARGO%' AND
														MONTH(POH.OrderDate) = MONTH(POH1.OrderDate)
                                                        )
FROM Purchasing.PurchaseOrderHeader AS POH
     INNER JOIN Purchasing.PurchaseOrderDetail AS POD
	 ON POD.PurchaseOrderID=POH.PurchaseOrderID
	 INNER JOIN Purchasing.ShipMethod AS SM
	 ON SM.ShipMethodID=POH.ShipMethodID
WHERE YEAR(POH.OrderDate) = 2012 AND POH.Freight BETWEEN 500 AND 2500 AND SM.Name LIKE '%CARGO%'
GROUP BY MONTH(POH.OrderDate)

--4c) (10 bodova) Prikazati ukupan broj narudžbi koje su obradili uposlenici, za svakog uposlenika
--pojedinaèno. Uslov je da su narudžbe kreirane u 2011 ili 2012 godini, te da je u okviru jedne narudžbe
--odobren popust na dvije ili više stavki. Takoðer uzeti u obzir samo one narudžbe koje su isporuèene u
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)SELECT P.FirstName + ' ' + P.LastName 'Uposlenik', COUNT(SOH.SalesOrderID) 'Broj narudzbi'FROM Sales.SalesOrderHeader AS SOH     INNER JOIN Sales.SalesPerson AS SP	 ON SOH.SalesPersonID=SP.BusinessEntityID	 INNER JOIN HumanResources.Employee AS E	 ON E.BusinessEntityID=SP.BusinessEntityID	 INNER JOIN Person.Person AS P	 ON P.BusinessEntityID=E.BusinessEntityID	 INNER JOIN Sales.SalesTerritory AS ST	 ON ST.TerritoryID=SOH.TerritoryIDWHERE YEAR(SOH.OrderDate) IN (2011,2012) AND ST.Name IN ('France','Canada','United Kingdom')AND (SELECT COUNT(SOD.ProductID)     FROM Sales.SalesOrderDetail AS SOD	 WHERE SOD.UnitPriceDiscount > 0 AND SOD.SalesOrderID=SOH.SalesOrderID	 ) >= 2GROUP BY P.FirstName + ' ' + P.LastNameUSE Northwind--4d) (11 bodova) Napisati upit koji æe prikazati sljedeæe podatke o proizvodima: naziv proizvoda, naziv
--kompanije dobavljaèa, kolièinu na skladištu, te kreiranu šifru proizvoda. Šifra se sastoji od sljedeæih
--vrijednosti: (Northwind)
--1) Prva dva slova naziva proizvoda
--2) Karakter /
--3) Prva dva slova druge rijeèi naziva kompanije dobavljaèa, uzeti u obzir one kompanije koje u
--nazivu imaju 2 ili 3 rijeèi
--4) ID proizvoda, po pravilu ukoliko se radi o jednocifrenom broju na njega dodati slovo 'a', u
--suprotnom uzeti obrnutu vrijednost broja
--Npr. Za proizvod sa nazivom Chai i sa dobavljaèem naziva Exotic Liquids, šifra æe btiti Ch/Li1aSELECT P.ProductName,S.CompanyName,SUBSTRING(P.ProductName,1,2) + '/' +IIF(LEN(S.CompanyName)-LEN(REPLACE(S.CompanyName,' ','')) IN (1,2) ,SUBSTRING(S.CompanyName,CHARINDEX(' ',S.CompanyName)+1,2),'') + IIF(P.ProductID<10,CAST(P.ProductID AS NVARCHAR)+ 'a',REVERSE(P.ProductID))FROM Products AS P     INNER JOIN Suppliers AS S	 ON S.SupplierID=P.SupplierID--a) (3 boda) U kreiranoj bazi kreirati index kojim æe se ubrzati pretraga prema šifri i nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.CREATE INDEX I_Search_ProzivodiON Proizvodi(Naziv,SifraProizvoda)SELECT P.Naziv,P.SifraProizvodaFROM Proizvodi AS PWHERE P.Naziv LIKE 'H%' AND P.SifraProizvoda LIKE 'H%'--b) (7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom æe se vratiti podaci o
--proizvodima na osnovu kategorije kojoj pripadaju ili težini. Korisnici ne moraju unijeti niti jedan od
--parametara ali u tom sluèaju procedura ne vraæa niti jedan od zapisa. Korisnicima unosom veæ prvog
--slova kategorije se trebaju osvježiti zapisi, a vrijednost unesenog parametra težina æe vratiti one
--proizvode èija težina je veæa od unesene vrijednosti.CREATE PROCEDURE sp_search_products
(
@NazivKategorije NVARCHAR(50)=NULL,
@Tezina DECIMAL(18,2)=NULL
)AS BEGIN      SELECT*      FROM Proizvodi AS P      WHERE P.NazivKategorije LIKE @NazivKategorije+'%' OR P.Tezina > @TezinaENDGOEXEC sp_search_products 'Clothing'
EXEC sp_search_products @Tezina=2.2
EXEC sp_search_productsUSE AdventureWorks2017--1. proizvodi koji pripadaju kategoriji bikes, --imaju vise od 30 narudzbi i nemaju broj u imenu (AdventureWorks2017)SELECT P.NameFROM Production.Product AS P     INNER JOIN Production.ProductSubcategory AS PS 	 ON PS.ProductSubcategoryID=P.ProductSubcategoryID	 INNER JOIN Production.ProductCategory AS PC	 ON PC.ProductCategoryID=PS.ProductCategoryID	 INNER JOIN Sales.SalesOrderDetail AS SOD	 ON SOD.ProductID=P.ProductIDWHERE PC.Name LIKE '%Bikes%' AND P.Name NOT LIKE '%[0-9]%'GROUP BY P.NameHAVING COUNT(SOD.ProductID) > 30--2.	pokazati ime proizvode, koliko ga ima na stanju i koliko je puta prodat, -- i ukupna vrijedost proizvoda sa popustom.--Tamo gdje je kolicina na skladistu 0 staviti "proizvoda nema na skladistu",--tamo gdje je prodata kolicina 0 staviti "proizvod nije prodat"--tamo gdje je ukupna vrijdnost NULL staviti "stavka nije prodana"(AdventureWorks2017)SELECT P.Name,IIF(SUM(PPI.Quantity) =0, 'nepoznata vrijednost', CAST(SUM(PPI.Quantity) AS NVARCHAR)) AS 'Stanje na skladistu',IIF(COUNT(SOD.OrderQty)=0, 'proizvod nije prodat', CAST(COUNT(SOD.OrderQty) AS NVARCHAR)) 'Kolicina proizvoda',IIF(SUM(SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)) IS NULL ,'stavka nije prodana', CAST(SUM(SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)) AS NVARCHAR)) 'Ukupna vrijednost proizvoda sa popustom'FROM Production.Product AS P     INNER JOIN Production.ProductInventory AS PPI	 ON PPI.ProductID=P.ProductID	 LEFT OUTER JOIN Sales.SalesOrderDetail AS SOD	 ON SOD.ProductID=P.ProductIDGROUP BY P.Name,PPI.QuantityORDER BY 3 DESC--3.	prikazati prosjecnu vrijednost narudzbe po godinama za svaki teritorij zaokruzenu na dvije-- decimale,--uzeti u obzir onu narudzbu koja je placena kreditnom karticom , goidne u opadajucem-- teritoerije u rastucem (AdventureWorks2017)SELECT ST.Name, YEAR(SOH.OrderDate) 'Godina', ROUND(AVG(SOH.SubTotal),2) 'Prosjecna vrijednost narudzbe'FROM Sales.SalesOrderHeader AS SOH     INNER JOIN Sales.SalesTerritory AS ST	 ON ST.TerritoryID=SOH.TerritoryIDWHERE SOH.CreditCardID IS NOT NULLGROUP BY ST.Name,YEAR(SOH.OrderDate)--4.	Prikazati narudzbu koja je najmanje dana bila na prodaji --i ako ima vise narudzbi sa istim vrijednostima, prikazati i njih (AdventureWorks2017)SELECT TOP 1 WITH TIES SOD.SalesOrderID, DATEDIFF(DAY,P.SellStartDate,P.SellEndDate)FROM Sales.SalesOrderDetail AS SOD     INNER JOIN Production.Product AS P	 ON P.ProductID=SOD.ProductIDWHERE P.SellEndDate IS NOT NULLORDER BY 2 ASCSELECT SOD.SalesOrderID 'Narudzba',       SUM(SOD.LineTotal) 'LineTotal',	   SUM(SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)) 'Cijena sa popustom',	   SUM(SOD.UnitPrice*SOD.OrderQty) 'Cijena bez popusta',	   SUM(SOH.TotalDue) 'Ukupna vrijednost naruzdbe sa svim',	   SUM(SOH.SubTotal) 'Ukupna vrijednost narudzbe bez svega'  FROM Sales.SalesOrderHeader AS SOH     INNER JOIN Sales.SalesOrderDetail AS SOD	 ON SOD.SalesOrderID=SOH.SalesOrderIDGROUP BY SOD.SalesOrderIDSELECT SOH.SalesOrderID, SUM(SOD.LineTotal), SOH.SubTotalFROM Sales.SalesOrderHeader AS SOHINNER JOIN Sales.SalesOrderDetail AS SOD	 ON SOD.SalesOrderID=SOH.SalesOrderIDGROUP BY SOH.SalesOrderID, SOH.SubTotal
