-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- SELECT, UPDATE, INSERT, DELETE 
SELECT * 
FROM Production.Product
WHERE StandardCost = 0
ORDER BY Name

UPDATE Production.Product
SET StandardCost = 0.1
WHERE StandardCost = 0

INSERT INTO Production.Product (Name, ProductNumber, StandardCost, ListPrice, SafetyStockLevel, ReorderPoint, DaysToManufacture, SellStartDate)
VALUES ('Anna', 'AA-1238', 0.8, 1.2, 500, 250, 1, '2021-03-20 00:00:00.000')

DELETE FROM Production.Product 
WHERE Name = 'Anna'

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- GROUP BY, HAVING, ORDER BY, COUNT, MAX, MIN, SUM, AVG
SELECT
	CustomerID,
	COUNT(*) as 'Number of orders',
	SUM(TotalDue) as 'Sum of all orders [PLN]',
	AVG(TotalDue) as 'Average of all orders [PLN]',
	MAX(TotalDue) as 'The most expensive order [PLN]',
	MIN(TotalDue) as 'The cheapest order [PLN]',
	MAX(TotalDue) - MIN(TotalDue) as 'The difference between the most expensive and the cheapest order [PLN]'
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(*) > 10
ORDER BY 2 DESC

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- JOINS
SELECT DISTINCT C.CustomerID, P.Name
FROM Production.Product AS P
JOIN Sales.SalesOrderDetail AS OD
ON P.ProductID = OD.ProductID
JOIN Sales.SalesOrderHeader AS OH
ON OD.SalesOrderID = OH.SalesOrderID
JOIN Sales.Customer AS C
ON OH.CustomerID = C.CustomerID
WHERE C.CustomerID = 29823

-- LEFT OUTER JOIN
SELECT C.CustomerID, OH.CustomerID
FROM Sales.Customer AS C
LEFT OUTER JOIN Sales.SalesOrderHeader AS OH
ON C.CustomerID = OH.CustomerID
WHERE OH.CustomerID IS NULL

-- FULL OUTER JOIN
SELECT P.ProductSubcategoryID, C.ProductCategoryID, P.ProductNumber, C.Name
FROM Production.Product AS P
FULL OUTER JOIN Production.ProductCategory AS C
ON P.ProductSubcategoryID = C.ProductCategoryID

-- UNION ALL
SELECT SalesOrderID, Freight, 'High'
FROM Sales.SalesOrderHeader
WHERE Freight > 100
UNION ALL
SELECT SalesOrderID, Freight, 'Low'
FROM Sales.SalesOrderHeader
WHERE Freight <= 100

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- CREATE TABLE WITH PRIMARY KEY
CREATE TABLE EmployeesList 
(
ID INT IDENTITY (1,1) CONSTRAINT PK_IDEmployeesList PRIMARY KEY,
Name VARCHAR(200),
Surname VARCHAR(200),
PhoneNumber INT UNIQUE,
LoginID VARCHAR(200) NOT NULL
)
-- ADD NEW COLUMN
ALTER TABLE EmployeesList
ADD PhoneNumber INT

-- DELETE COLUMN
ALTER TABLE EmployeesList
DROP COLUMN PhoneNumber;

-- DELETE TABLE
DROP TABLE EmployeesList;

-- ADD NEW ROWS
INSERT INTO EmployeesList (Name, Surname, PhoneNumber, LoginID)
VALUES 
	('Katarzyna', 'Nos', 666777888, 'adventure-works\nosk'),
	('Anna', 'Nowak', 666777889, 'adventure-works\nowaka'),
	('Jakub', 'Marzec', 666777887, 'adventure-works\marzecj')

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- INDEX
CREATE INDEX IX_SalesOrderID
ON Sales.SalesOrderDetail (SalesOrderID)

CREATE UNIQUE INDEX IX_Rowguid 
ON Sales.SalesOrderDetail (rowguid)

CREATE UNIQUE INDEX IX_Products
ON Production.Product (ProductNumber, StandardCost, SellStartDate)

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- DECLARE, SET
DECLARE @City VARCHAR(200), @PostalCode VARCHAR(200);
SET @City = 'Newton';
SET @PostalCode = 'V2M';

SELECT * FROM Person.Address
WHERE City like @City + '%' AND PostalCode like @PostalCode + '%'

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- STORED PROCEDURE (change of the list price)
CREATE PROCEDURE dbo.uspChangeListPrice
@Change float, @ProductSubcategoryID int
AS
UPDATE Production.Product
SET ListPrice = ListPrice * @Change
WHERE ProductSubcategoryID = @ProductSubcategoryID

SELECT Name,ListPrice,ProductSubcategoryID
FROM Production.Product
WHERE ProductSubcategoryID = @ProductSubcategoryID
ORDER BY ListPrice

-- EXECUTION OF THE PROCEDURE
EXEC dbo.uspChangeListPrice 1.1,4

---UPDATE OF THE PROCEDURE
ALTER PROCEDURE dbo.uspChangeListPrice
@Change float, @ProductSubcategoryID int
AS
UPDATE Production.Product
SET ListPrice = ListPrice * @Change
WHERE ProductSubcategoryID = @ProductSubcategoryID

SELECT Name,ListPrice,ProductSubcategoryID,StandardCost
FROM Production.Product
WHERE ProductSubcategoryID = @ProductSubcategoryID
ORDER BY ListPrice

---DELETE OF THE PROCEDURE
DROP PROCEDURE dbo.uspChangeListPrice

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- TRIGGER
CREATE TRIGGER trInformation 
ON Person.Person
AFTER INSERT, UPDATE, DELETE
AS
PRINT 'You have added, modified or deleted data in the table'

-- CHECK TRIGGER
UPDATE Person.Person SET FirstName = 'JOHN' WHERE BusinessEntityID = 1

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- TEMPORARY TABLE
CREATE TABLE #tmpNewTable 
(
ID INT IDENTITY (1,1), 
Value varchar(255)
)

SELECT SalesOrderID, SalesOrderDetailID, ProductID, UnitPrice
INTO #tmp
FROM Sales.SalesOrderDetail
WHERE ProductID BETWEEN 700 AND 710

UPDATE #tmp
SET	UnitPrice = 21
WHERE ProductID = 708

INSERT INTO #tmp (SalesOrderID, ProductID, UnitPrice)
VALUES (123456, 700, 20)

SELECT * FROM #tmp

DROP TABLE #tmp

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- VIEW
CREATE OR ALTER VIEW vEmployeeList AS
SELECT NationalIDNumber, LoginID, JobTitle
FROM HumanResources.Employee
WHERE HireDate > '2010-12-31'

-- CHECK VIEW
SELECT * FROM vEmployeeList 

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- CASE
SELECT NationalIDNumber, JobTitle, BirthDate, VacationHours ,
CASE
	WHEN VacationHours < 50 THEN 'less than 50 hours'
	WHEN VacationHours > 50 THEN 'more than 50 hours'
	ELSE 'equal to 50 hours'
END AS 'Vacation'
FROM HumanResources.Employee