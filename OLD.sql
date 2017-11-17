---------------------------------------------------------------------
-- Script that creates the sample database TSQL2012
--
-- Supported versions of SQL Server: 2005, 2008, 2008 R2, 2012, SQL Azure
--
-- Based originally on the Northwind sample database
-- with changes in both schema and data
--
-- Last updated: 20120328
--
-- © Itzik Ben-Gan
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Create empty database TSQL2012
---------------------------------------------------------------------

-- For on-premises SQL Server use the steps in section A and then proceed to section C
-- For SQL Azure use the steps in section B and then proceed to section C

---------------------------------------------------------------------
-- Section A - for on-premises SQL Server only
---------------------------------------------------------------------

-- 1. Connect to your on-premises SQL Server instance, master database

-- 2. Run the following code to create an empty database called TSQL2012
USE master;

-- Drop database
IF DB_ID('TSQL2012') IS NOT NULL DROP DATABASE TSQL2012;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Create database
CREATE DATABASE TSQL2012;
GO

USE TSQL2012;
GO

-- 3. Proceed to section C

---------------------------------------------------------------------
-- Section B - for SQL Azure only
---------------------------------------------------------------------

/*
-- 1. Connect to SQL Azure, master database
USE master; -- used only as a test; will fail if not connected to master

-- 2. Run following if TSQL2012 database already exists, otherwise skip
DROP DATABASE TSQL2012; 
GO

-- 3. Run the following code to create an empty database called TSQL2012
CREATE DATABASE TSQL2012;
GO

-- 4. Connect to TSQL2012 before running the rest of the code
USE TSQL2012; -- used only as a test; will fail if not connected to TSQL2012
GO

-- 5. Proceed to section C
*/

---------------------------------------------------------------------
-- Populate database TSQL2012 with sample data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Section C - for both on-premises SQL Server and SQL Azure
---------------------------------------------------------------------

-- 1. Highlight the remaining code in the script file and execute

---------------------------------------------------------------------
-- Create Schemas
---------------------------------------------------------------------

CREATE SCHEMA HR AUTHORIZATION dbo;
GO
CREATE SCHEMA Production AUTHORIZATION dbo;
GO
CREATE SCHEMA Sales AUTHORIZATION dbo;
GO
CREATE SCHEMA Stats AUTHORIZATION dbo;
GO

---------------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------------

-- Create table HR.Employees
CREATE TABLE HR.Employees
(
  empid           INT          NOT NULL IDENTITY,
  lastname        NVARCHAR(20) NOT NULL,
  firstname       NVARCHAR(10) NOT NULL,
  title           NVARCHAR(30) NOT NULL,
  titleofcourtesy NVARCHAR(25) NOT NULL,
  birthdate       DATETIME     NOT NULL,
  hiredate        DATETIME     NOT NULL,
  address         NVARCHAR(60) NOT NULL,
  city            NVARCHAR(15) NOT NULL,
  region          NVARCHAR(15) NULL,
  postalcode      NVARCHAR(10) NULL,
  country         NVARCHAR(15) NOT NULL,
  phone           NVARCHAR(24) NOT NULL,
  mgrid           INT          NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT FK_Employees_Employees FOREIGN KEY(mgrid)
    REFERENCES HR.Employees(empid),
  CONSTRAINT CHK_birthdate CHECK(birthdate <= CURRENT_TIMESTAMP)
);

CREATE NONCLUSTERED INDEX idx_nc_lastname   ON HR.Employees(lastname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode ON HR.Employees(postalcode);

-- Create table Production.Suppliers
CREATE TABLE Production.Suppliers
(
  supplierid   INT          NOT NULL IDENTITY,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Suppliers PRIMARY KEY(supplierid)
);

CREATE NONCLUSTERED INDEX idx_nc_companyname ON Production.Suppliers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Production.Suppliers(postalcode);

-- Create table Production.Categories
CREATE TABLE Production.Categories
(
  categoryid   INT           NOT NULL IDENTITY,
  categoryname NVARCHAR(15)  NOT NULL,
  description  NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_Categories PRIMARY KEY(categoryid)
);

CREATE INDEX categoryname ON Production.Categories(categoryname);

-- Create table Production.Products
CREATE TABLE Production.Products
(
  productid    INT          NOT NULL IDENTITY,
  productname  NVARCHAR(40) NOT NULL,
  supplierid   INT          NOT NULL,
  categoryid   INT          NOT NULL,
  unitprice    MONEY        NOT NULL
    CONSTRAINT DFT_Products_unitprice DEFAULT(0),
  discontinued BIT          NOT NULL 
    CONSTRAINT DFT_Products_discontinued DEFAULT(0),
  CONSTRAINT PK_Products PRIMARY KEY(productid),
  CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
    REFERENCES Production.Categories(categoryid),
  CONSTRAINT FK_Products_Suppliers FOREIGN KEY(supplierid)
    REFERENCES Production.Suppliers(supplierid),
  CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_categoryid  ON Production.Products(categoryid);
CREATE NONCLUSTERED INDEX idx_nc_productname ON Production.Products(productname);
CREATE NONCLUSTERED INDEX idx_nc_supplierid  ON Production.Products(supplierid);

-- Create table Sales.Customers
CREATE TABLE Sales.Customers
(
  custid       INT          NOT NULL IDENTITY,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE NONCLUSTERED INDEX idx_nc_city        ON Sales.Customers(city);
CREATE NONCLUSTERED INDEX idx_nc_companyname ON Sales.Customers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Sales.Customers(postalcode);
CREATE NONCLUSTERED INDEX idx_nc_region      ON Sales.Customers(region);

-- Create table Sales.Shippers
CREATE TABLE Sales.Shippers
(
  shipperid   INT          NOT NULL IDENTITY,
  companyname NVARCHAR(40) NOT NULL,
  phone       NVARCHAR(24) NOT NULL,
  CONSTRAINT PK_Shippers PRIMARY KEY(shipperid)
);

-- Create table Sales.OrderDetails
CREATE TABLE Sales.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Products FOREIGN KEY(productid)
    REFERENCES Production.Products(productid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_orderid   ON Sales.OrderDetails(orderid);
CREATE NONCLUSTERED INDEX idx_nc_productid ON Sales.OrderDetails(productid);

-- Create table Stats.Tests
CREATE TABLE Stats.Tests
(
  testid    VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Tests PRIMARY KEY(testid)
);

-- Create table Stats.Scores
CREATE TABLE Stats.Scores
(
  testid    VARCHAR(10) NOT NULL,
  studentid VARCHAR(10) NOT NULL,
  score     TINYINT     NOT NULL
    CONSTRAINT CHK_Scores_score CHECK (score BETWEEN 0 AND 100),
  CONSTRAINT PK_Scores PRIMARY KEY(testid, studentid),
  CONSTRAINT FK_Scores_Tests FOREIGN KEY(testid)
    REFERENCES Stats.Tests(testid)
);

CREATE NONCLUSTERED INDEX idx_nc_testid_score ON Stats.Scores(testid, score);

---------------------------------------------------------------------
-- Populate Tables
---------------------------------------------------------------------

SET NOCOUNT ON;

-- Populate table HR.Employees
SET IDENTITY_INSERT HR.Employees ON;
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(1, N'Davis', N'Sara', N'CEO', N'Ms.', '19581208 00:00:00.000', '20020501 00:00:00.000', N'7890 - 20th Ave. E., Apt. 2A', N'Seattle', N'WA', N'10003', N'USA', N'(206) 555-0101', NULL);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(2, N'Funk', N'Don', N'Vice President, Sales', N'Dr.', '19620219 00:00:00.000', '20020814 00:00:00.000', N'9012 W. Capital Way', N'Tacoma', N'WA', N'10001', N'USA', N'(206) 555-0100', 1);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(3, N'Lew', N'Judy', N'Sales Manager', N'Ms.', '19730830 00:00:00.000', '20020401 00:00:00.000', N'2345 Moss Bay Blvd.', N'Kirkland', N'WA', N'10007', N'USA', N'(206) 555-0103', 2);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(4, N'Peled', N'Yael', N'Sales Representative', N'Mrs.', '19470919 00:00:00.000', '20030503 00:00:00.000', N'5678 Old Redmond Rd.', N'Redmond', N'WA', N'10009', N'USA', N'(206) 555-0104', 3);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(5, N'Buck', N'Sven', N'Sales Manager', N'Mr.', '19650304 00:00:00.000', '20031017 00:00:00.000', N'8901 Garrett Hill', N'London', NULL, N'10004', N'UK', N'(71) 234-5678', 2);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(6, N'Suurs', N'Paul', N'Sales Representative', N'Mr.', '19730702 00:00:00.000', '20031017 00:00:00.000', N'3456 Coventry House, Miner Rd.', N'London', NULL, N'10005', N'UK', N'(71) 345-6789', 5);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(7, N'King', N'Russell', N'Sales Representative', N'Mr.', '19700529 00:00:00.000', '20040102 00:00:00.000', N'6789 Edgeham Hollow, Winchester Way', N'London', NULL, N'10002', N'UK', N'(71) 123-4567', 5);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(8, N'Cameron', N'Maria', N'Sales Representative', N'Ms.', '19680109 00:00:00.000', '20040305 00:00:00.000', N'4567 - 11th Ave. N.E.', N'Seattle', N'WA', N'10006', N'USA', N'(206) 555-0102', 3);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(9, N'Dolgopyatova', N'Zoya', N'Sales Representative', N'Ms.', '19760127 00:00:00.000', '20041115 00:00:00.000', N'1234 Houndstooth Rd.', N'London', NULL, N'10008', N'UK', N'(71) 456-7890', 5);
SET IDENTITY_INSERT HR.Employees OFF;

-- Populate table Production.Suppliers
SET IDENTITY_INSERT Production.Suppliers ON;
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(1, N'Supplier SWRXU', N'Adolphi, Stephan', N'Purchasing Manager', N'2345 Gilbert St.', N'London', NULL, N'10023', N'UK', N'(171) 456-7890', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(2, N'Supplier VHQZD', N'Hance, Jim', N'Order Administrator', N'P.O. Box 5678', N'New Orleans', N'LA', N'10013', N'USA', N'(100) 555-0111', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(3, N'Supplier STUAZ', N'Parovszky, Alfons', N'Sales Representative', N'1234 Oxford Rd.', N'Ann Arbor', N'MI', N'10026', N'USA', N'(313) 555-0109', N'(313) 555-0112');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(4, N'Supplier QOVFD', N'Balázs, Erzsébet', N'Marketing Manager', N'7890 Sekimai Musashino-shi', N'Tokyo', NULL, N'10011', N'Japan', N'(03) 6789-0123', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(5, N'Supplier EQPNC', N'Holm, Michael', N'Export Administrator', N'Calle del Rosal 4567', N'Oviedo', N'Asturias', N'10029', N'Spain', N'(98) 123 45 67', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(6, N'Supplier QWUSF', N'Popkova, Darya', N'Marketing Representative', N'8901 Setsuko Chuo-ku', N'Osaka', NULL, N'10028', N'Japan', N'(06) 789-0123', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(7, N'Supplier GQRCV', N'Ræbild, Jesper', N'Marketing Manager', N'5678 Rose St. Moonie Ponds', N'Melbourne', N'Victoria', N'10018', N'Australia', N'(03) 123-4567', N'(03) 456-7890');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(8, N'Supplier BWGYE', N'Iallo, Lucio', N'Sales Representative', N'9012 King''s Way', N'Manchester', NULL, N'10021', N'UK', N'(161) 567-8901', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(9, N'Supplier QQYEU', N'Basalik, Evan', N'Sales Agent', N'Kaloadagatan 4567', N'Göteborg', NULL, N'10022', N'Sweden', N'031-345 67 89', N'031-678 90 12');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(10, N'Supplier UNAHG', N'Barnett, Dave', N'Marketing Manager', N'Av. das Americanas 2345', N'Sao Paulo', NULL, N'10034', N'Brazil', N'(11) 345 6789', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(11, N'Supplier ZPYVS', N'Jain, Mukesh', N'Sales Manager', N'Tiergartenstraße 3456', N'Berlin', NULL, N'10016', N'Germany', N'(010) 3456789', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(12, N'Supplier SVIYA', N'Regev, Barak', N'International Marketing Mgr.', N'Bogenallee 9012', N'Frankfurt', NULL, N'10024', N'Germany', N'(069) 234567', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(13, N'Supplier TEGSC', N'Brehm, Peter', N'Coordinator Foreign Markets', N'Frahmredder 3456', N'Cuxhaven', NULL, N'10019', N'Germany', N'(04721) 1234', N'(04721) 2345');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(14, N'Supplier KEREV', N'Keil, Kendall', N'Sales Representative', N'Viale Dante, 6789', N'Ravenna', NULL, N'10015', N'Italy', N'(0544) 56789', N'(0544) 34567');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(15, N'Supplier NZLIF', N'Sałas-Szlejter, Karolina', N'Marketing Manager', N'Hatlevegen 1234', N'Sandvika', NULL, N'10025', N'Norway', N'(0)9-012345', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(16, N'Supplier UHZRG', N'Scholl, Thorsten', N'Regional Account Rep.', N'8901 - 8th Avenue Suite 210', N'Bend', N'OR', N'10035', N'USA', N'(503) 555-0108', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(17, N'Supplier QZGUF', N'Kleinerman, Christian', N'Sales Representative', N'Brovallavägen 0123', N'Stockholm', NULL, N'10033', N'Sweden', N'08-234 56 78', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(18, N'Supplier LVJUA', N'Canel, Fabrice', N'Sales Manager', N'3456, Rue des Francs-Bourgeois', N'Paris', NULL, N'10031', N'France', N'(1) 90.12.34.56', N'(1) 01.23.45.67');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(19, N'Supplier JDNUG', N'Chapman, Greg', N'Wholesale Account Agent', N'Order Processing Dept. 7890 Paul Revere Blvd.', N'Boston', N'MA', N'10027', N'USA', N'(617) 555-0110', N'(617) 555-0113');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(20, N'Supplier CIYNM', N'Köszegi, Emília', N'Owner', N'6789 Serangoon Loop, Suite #402', N'Singapore', NULL, N'10037', N'Singapore', N'012-3456', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(21, N'Supplier XOXZA', N'Shakespear, Paul', N'Sales Manager', N'Lyngbysild Fiskebakken 9012', N'Lyngby', NULL, N'10012', N'Denmark', N'67890123', N'78901234');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(22, N'Supplier FNUXM', N'Skelly, Bonnie L.', N'Accounting Manager', N'Verkoop Rijnweg 8901', N'Zaandam', NULL, N'10014', N'Netherlands', N'(12345) 8901', N'(12345) 5678');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(23, N'Supplier ELCRN', N'LaMee, Brian', N'Product Manager', N'Valtakatu 1234', N'Lappeenranta', NULL, N'10032', N'Finland', N'(953) 78901', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(24, N'Supplier JNNES', N'Clark, Molly', N'Sales Representative', N'6789 Prince Edward Parade Hunter''s Hill', N'Sydney', N'NSW', N'10030', N'Australia', N'(02) 234-5678', N'(02) 567-8901');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(25, N'Supplier ERVYZ', N'Sprenger, Christof', N'Marketing Manager', N'7890 Rue St. Laurent', N'Montréal', N'Québec', N'10017', N'Canada', N'(514) 456-7890', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(26, N'Supplier ZWZDM', N'Cunha, Gonçalo', N'Order Administrator', N'Via dei Gelsomini, 5678', N'Salerno', NULL, N'10020', N'Italy', N'(089) 4567890', N'(089) 4567890');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(27, N'Supplier ZRYDZ', N'Leoni, Alessandro', N'Sales Manager', N'4567, rue H. Voiron', N'Montceau', NULL, N'10036', N'France', N'89.01.23.45', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(28, N'Supplier OAVQT', N'Teper, Jeff', N'Sales Representative', N'Bat. B 2345, rue des Alpes', N'Annecy', NULL, N'10010', N'France', N'01.23.45.67', N'89.01.23.45');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(29, N'Supplier OGLRK', N'Walters, Rob', N'Accounting Manager', N'0123 rue Chasseur', N'Ste-Hyacinthe', N'Québec', N'10009', N'Canada', N'(514) 567-890', N'(514) 678-9012');
SET IDENTITY_INSERT Production.Suppliers OFF;

-- Populate table Production.Categories
SET IDENTITY_INSERT Production.Categories ON;
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(1, N'Beverages', N'Soft drinks, coffees, teas, beers, and ales');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(2, N'Condiments', N'Sweet and savory sauces, relishes, spreads, and seasonings');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(3, N'Confections', N'Desserts, candies, and sweet breads');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(4, N'Dairy Products', N'Cheeses');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(5, N'Grains/Cereals', N'Breads, crackers, pasta, and cereal');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(6, N'Meat/Poultry', N'Prepared meats');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(7, N'Produce', N'Dried fruit and bean curd');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(8, N'Seafood', N'Seaweed and fish');
SET IDENTITY_INSERT Production.Categories OFF;

-- Populate table Production.Products
SET IDENTITY_INSERT Production.Products ON;
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(1, N'Product HHYDP', 1, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(2, N'Product RECZE', 1, 1, 19.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(3, N'Product IMEHJ', 1, 2, 10.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(4, N'Product KSBRM', 2, 2, 22.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(5, N'Product EPEIM', 2, 2, 21.35, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(6, N'Product VAIIV', 3, 2, 25.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(7, N'Product HMLNI', 3, 7, 30.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(8, N'Product WVJFP', 3, 2, 40.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(9, N'Product AOZBW', 4, 6, 97.00, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(10, N'Product YHXGE', 4, 8, 31.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(11, N'Product QMVUN', 5, 4, 21.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(12, N'Product OSFNS', 5, 4, 38.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(13, N'Product POXFU', 6, 8, 6.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(14, N'Product PWCJB', 6, 7, 23.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(15, N'Product KSZOI', 6, 2, 15.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(16, N'Product PAFRH', 7, 3, 17.45, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(17, N'Product BLCAX', 7, 6, 39.00, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(18, N'Product CKEDC', 7, 8, 62.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(19, N'Product XKXDO', 8, 3, 9.20, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(20, N'Product QHFFP', 8, 3, 81.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(21, N'Product VJZZH', 8, 3, 10.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(22, N'Product CPHFY', 9, 5, 21.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(23, N'Product JLUDZ', 9, 5, 9.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(24, N'Product QOGNU', 10, 1, 4.50, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(25, N'Product LYLNI', 11, 3, 14.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(26, N'Product HLGZA', 11, 3, 31.23, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(27, N'Product SMIOH', 11, 3, 43.90, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(28, N'Product OFBNT', 12, 7, 45.60, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(29, N'Product VJXYN', 12, 6, 123.79, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(30, N'Product LYERX', 13, 8, 25.89, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(31, N'Product XWOXC', 14, 4, 12.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(32, N'Product NUNAW', 14, 4, 32.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(33, N'Product ASTMN', 15, 4, 2.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(34, N'Product SWNJY', 16, 1, 14.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(35, N'Product NEVTJ', 16, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(36, N'Product GMKIJ', 17, 8, 19.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(37, N'Product EVFFA', 17, 8, 26.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(38, N'Product QDOMO', 18, 1, 263.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(39, N'Product LSOFL', 18, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(40, N'Product YZIXQ', 19, 8, 18.40, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(41, N'Product TTEEX', 19, 8, 9.65, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(42, N'Product RJVNM', 20, 5, 14.00, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(43, N'Product ZZZHR', 20, 1, 46.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(44, N'Product VJIEO', 20, 2, 19.45, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(45, N'Product AQOKR', 21, 8, 9.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(46, N'Product CBRRL', 21, 8, 12.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(47, N'Product EZZPR', 22, 3, 9.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(48, N'Product MYNXN', 22, 3, 12.75, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(49, N'Product FPYPN', 23, 3, 20.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(50, N'Product BIUDV', 23, 3, 16.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(51, N'Product APITJ', 24, 7, 53.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(52, N'Product QSRXF', 24, 5, 7.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(53, N'Product BKGEA', 24, 6, 32.80, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(54, N'Product QAQRL', 25, 6, 7.45, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(55, N'Product YYWRT', 25, 6, 24.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(56, N'Product VKCMF', 26, 5, 38.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(57, N'Product OVLQI', 26, 5, 19.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(58, N'Product ACRVI', 27, 8, 13.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(59, N'Product UKXRI', 28, 4, 55.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(60, N'Product WHBYK', 28, 4, 34.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(61, N'Product XYZPE', 29, 2, 28.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(62, N'Product WUXYK', 29, 3, 49.30, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(63, N'Product ICKNK', 7, 2, 43.90, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(64, N'Product HCQDE', 12, 5, 33.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(65, N'Product XYWBZ', 2, 2, 21.05, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(66, N'Product LQMGN', 2, 2, 17.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(67, N'Product XLXQF', 16, 1, 14.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(68, N'Product TBTBL', 8, 3, 12.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(69, N'Product COAXA', 15, 4, 36.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(70, N'Product TOONT', 7, 1, 15.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(71, N'Product MYMOI', 15, 4, 21.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(72, N'Product GEEOO', 14, 4, 34.80, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(73, N'Product WEUJZ', 17, 8, 15.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(74, N'Product BKAZJ', 4, 7, 10.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(75, N'Product BWRLG', 12, 1, 7.75, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(76, N'Product JYGFE', 23, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(77, N'Product LUNZZ', 12, 2, 13.00, 0);
SET IDENTITY_INSERT Production.Products OFF;

-- Populate table Sales.Customers
SET IDENTITY_INSERT Sales.Customers ON;
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(1, N'Customer NRZBB', N'Allen, Michael', N'Sales Representative', N'Obere Str. 0123', N'Berlin', NULL, N'10092', N'Germany', N'030-3456789', N'030-0123456');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(2, N'Customer MLTDN', N'Hassall, Mark', N'Owner', N'Avda. de la Constitución 5678', N'México D.F.', NULL, N'10077', N'Mexico', N'(5) 789-0123', N'(5) 456-7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(3, N'Customer KBUDE', N'Peoples, John', N'Owner', N'Mataderos  7890', N'México D.F.', NULL, N'10097', N'Mexico', N'(5) 123-4567', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(4, N'Customer HFBZG', N'Arndt, Torsten', N'Sales Representative', N'7890 Hanover Sq.', N'London', NULL, N'10046', N'UK', N'(171) 456-7890', N'(171) 456-7891');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(5, N'Customer HGVLZ', N'Higginbotham, Tom', N'Order Administrator', N'Berguvsvägen  5678', N'Luleå', NULL, N'10112', N'Sweden', N'0921-67 89 01', N'0921-23 45 67');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(6, N'Customer XHXJV', N'Poland, Carole', N'Sales Representative', N'Forsterstr. 7890', N'Mannheim', NULL, N'10117', N'Germany', N'0621-67890', N'0621-12345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(7, N'Customer QXVLA', N'Bansal, Dushyant', N'Marketing Manager', N'2345, place Kléber', N'Strasbourg', NULL, N'10089', N'France', N'67.89.01.23', N'67.89.01.24');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(8, N'Customer QUHWH', N'Ilyina, Julia', N'Owner', N'C/ Araquil, 0123', N'Madrid', NULL, N'10104', N'Spain', N'(91) 345 67 89', N'(91) 012 34 56');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(9, N'Customer RTXGC', N'Raghav, Amritansh', N'Owner', N'6789, rue des Bouchers', N'Marseille', NULL, N'10105', N'France', N'23.45.67.89', N'23.45.67.80');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(10, N'Customer EEALV', N'Bassols, Pilar Colome', N'Accounting Manager', N'8901 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10111', N'Canada', N'(604) 901-2345', N'(604) 678-9012');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(11, N'Customer UBHAU', N'Jaffe, David', N'Sales Representative', N'Fauntleroy Circus 4567', N'London', NULL, N'10064', N'UK', N'(171) 789-0123', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(12, N'Customer PSNMQ', N'Ray, Mike', N'Sales Agent', N'Cerrito 3456', N'Buenos Aires', NULL, N'10057', N'Argentina', N'(1) 890-1234', N'(1) 567-8901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(13, N'Customer VMLOG', N'Benito, Almudena', N'Marketing Manager', N'Sierras de Granada 7890', N'México D.F.', NULL, N'10056', N'Mexico', N'(5) 456-7890', N'(5) 123-4567');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(14, N'Customer WNMAF', N'Jelitto, Jacek', N'Owner', N'Hauptstr. 0123', N'Bern', NULL, N'10065', N'Switzerland', N'0452-678901', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(15, N'Customer JUWXK', N'Richardson, Shawn', N'Sales Associate', N'Av. dos Lusíadas, 6789', N'Sao Paulo', N'SP', N'10087', N'Brazil', N'(11) 012-3456', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(16, N'Customer GYBBY', N'Birkby, Dana', N'Sales Representative', N'Berkeley Gardens 0123 Brewery', N'London', NULL, N'10039', N'UK', N'(171) 234-5678', N'(171) 234-5679');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(17, N'Customer FEVNN', N'Jones, TiAnna', N'Order Administrator', N'Walserweg 4567', N'Aachen', NULL, N'10067', N'Germany', N'0241-789012', N'0241-345678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(18, N'Customer BSVAR', N'Rizaldy, Arif', N'Owner', N'3456, rue des Cinquante Otages', N'Nantes', NULL, N'10041', N'France', N'89.01.23.45', N'89.01.23.46');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(19, N'Customer RFNQC', N'Boseman, Randall', N'Sales Agent', N'5678 King George', N'London', NULL, N'10110', N'UK', N'(171) 345-6789', N'(171) 345-6780');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(20, N'Customer THHDP', N'Kane, John', N'Sales Manager', N'Kirchgasse 9012', N'Graz', NULL, N'10059', N'Austria', N'1234-5678', N'9012-3456');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(21, N'Customer KIDPX', N'Russo, Giuseppe', N'Marketing Assistant', N'Rua Orós, 3456', N'Sao Paulo', N'SP', N'10096', N'Brazil', N'(11) 456-7890', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(22, N'Customer DTDMN', N'Bueno, Janaina Burdan, Neville', N'Accounting Manager', N'C/ Moralzarzal, 5678', N'Madrid', NULL, N'10080', N'Spain', N'(91) 890 12 34', N'(91) 567 89 01');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(23, N'Customer WVFAF', N'Khanna, Karan', N'Assistant Sales Agent', N'4567, chaussée de Tournai', N'Lille', NULL, N'10048', N'France', N'45.67.89.01', N'45.67.89.02');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(24, N'Customer CYZTN', N'San Juan, Patricia', N'Owner', N'Åkergatan 5678', N'Bräcke', NULL, N'10114', N'Sweden', N'0695-67 89 01', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(25, N'Customer AZJED', N'Carlson, Jason', N'Marketing Manager', N'Berliner Platz 9012', N'München', NULL, N'10091', N'Germany', N'089-8901234', N'089-5678901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(26, N'Customer USDBG', N'Koch, Paul', N'Marketing Manager', N'9012, rue Royale', N'Nantes', NULL, N'10101', N'France', N'34.56.78.90', N'34.56.78.91');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(27, N'Customer WMFEA', N'Schmöllerl, Martin', N'Sales Representative', N'Via Monte Bianco 4567', N'Torino', NULL, N'10099', N'Italy', N'011-2345678', N'011-9012345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(28, N'Customer XYUFB', N'Cavaglieri, Giorgio', N'Sales Manager', N'Jardim das rosas n. 8901', N'Lisboa', NULL, N'10054', N'Portugal', N'(1) 456-7890', N'(1) 123-4567');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(29, N'Customer MDLWA', N'Kolesnikova, Katerina', N'Marketing Manager', N'Rambla de Cataluña, 8901', N'Barcelona', NULL, N'10081', N'Spain', N'(93) 789 0123', N'(93) 456 7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(30, N'Customer KSLQF', N'Shabalin, Rostislav', N'Sales Manager', N'C/ Romero, 1234', N'Sevilla', NULL, N'10075', N'Spain', N'(95) 901 23 45', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(31, N'Customer YJCBX', N'Cheng, Yao-Qiang', N'Sales Associate', N'Av. Brasil, 5678', N'Campinas', N'SP', N'10128', N'Brazil', N'(11) 567-8901', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(32, N'Customer YSIQX', N'Krishnan, Venky', N'Marketing Manager', N'6789 Baker Blvd.', N'Eugene', N'OR', N'10070', N'USA', N'(503) 555-0122', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(33, N'Customer FVXPQ', N'Sigurdarson, Hallur ', N'Owner', N'5ª Ave. Los Palos Grandes 3456', N'Caracas', N'DF', N'10043', N'Venezuela', N'(2) 789-0123', N'(2) 456-7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(34, N'Customer IBVRG', N'Cohen, Shy', N'Accounting Manager', N'Rua do Paço, 7890', N'Rio de Janeiro', N'RJ', N'10076', N'Brazil', N'(21) 789-0123', N'(21) 789-0124');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(35, N'Customer UMTLM', N'Langohr, Kris', N'Sales Representative', N'Carrera 1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10066', N'Venezuela', N'(5) 567-8901', N'(5) 234-5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(36, N'Customer LVJSO', N'Smith, Denise', N'Sales Representative', N'City Center Plaza 2345 Main St.', N'Elgin', N'OR', N'10103', N'USA', N'(503) 555-0126', N'(503) 555-0135');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(37, N'Customer FRXZL', N'Crăciun, Ovidiu V.', N'Sales Associate', N'9012 Johnstown Road', N'Cork', N'Co. Cork', N'10051', N'Ireland', N'8901 234', N'5678 9012');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(38, N'Customer LJUCA', N'Lee, Frank', N'Marketing Manager', N'Garden House Crowther Way 3456', N'Cowes', N'Isle of Wight', N'10063', N'UK', N'(198) 567-8901', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(39, N'Customer GLLAG', N'Song, Lolan', N'Sales Associate', N'Maubelstr. 8901', N'Brandenburg', NULL, N'10060', N'Germany', N'0555-34567', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(40, N'Customer EFFTC', N'De Oliveira, Jose', N'Sales Representative', N'2345, avenue de l''Europe', N'Versailles', NULL, N'10108', N'France', N'12.34.56.78', N'12.34.56.79');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(41, N'Customer XIIWM', N'Litton, Tim', N'Sales Manager', N'3456 rue Alsace-Lorraine', N'Toulouse', NULL, N'10053', N'France', N'90.12.34.56', N'90.12.34.57');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(42, N'Customer IAIJK', N'Steiner, Dominik', N'Marketing Assistant', N'2345 Oak St.', N'Vancouver', N'BC', N'10098', N'Canada', N'(604) 567-8901', N'(604) 234-5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(43, N'Customer UISOJ', N'Deshpande, Anu', N'Marketing Manager', N'8901 Orchestra Terrace', N'Walla Walla', N'WA', N'10069', N'USA', N'(509) 555-0119', N'(509) 555-0130');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(44, N'Customer OXFRU', N'Louverdis, George', N'Sales Representative', N'Magazinweg 8901', N'Frankfurt a.M.', NULL, N'10095', N'Germany', N'069-7890123', N'069-4567890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(45, N'Customer QXPPT', N'Sunkammurali,  Krishna', N'Owner', N'1234 Polk St. Suite 5', N'San Francisco', N'CA', N'10062', N'USA', N'(415) 555-0118', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(46, N'Customer XPNIK', N'Dressler, Marlies', N'Accounting Manager', N'Carrera 7890 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10093', N'Venezuela', N'(9) 789-0123', N'(9) 456-7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(47, N'Customer PSQUZ', N'Lupu, Cornel', N'Owner', N'Ave. 5 de Mayo Porlamar 5678', N'I. de Margarita', N'Nueva Esparta', N'10121', N'Venezuela', N'(8) 01-23-45', N'(8) 67-89-01');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(48, N'Customer DVFMB', N'Szymczak, Radosław', N'Sales Manager', N'9012 Chiaroscuro Rd.', N'Portland', N'OR', N'10073', N'USA', N'(503) 555-0117', N'(503) 555-0129');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(49, N'Customer CQRAA', N'Duerr, Bernard', N'Marketing Manager', N'Via Ludovico il Moro 6789', N'Bergamo', NULL, N'10106', N'Italy', N'035-345678', N'035-901234');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(50, N'Customer JYPSC', N'Mace, Donald', N'Sales Agent', N'Rue Joseph-Bens 0123', N'Bruxelles', NULL, N'10074', N'Belgium', N'(02) 890 12 34', N'(02) 567 89 01');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(51, N'Customer PVDZC', N'Taylor, Maurice', N'Marketing Assistant', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10040', N'Canada', N'(514) 345-6789', N'(514) 012-3456');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(52, N'Customer PZNLA', N'Dupont-Roc, Patrice', N'Marketing Assistant', N'Heerstr. 4567', N'Leipzig', NULL, N'10125', N'Germany', N'0342-12345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(53, N'Customer GCJSG', N'Mallit, Ken', N'Sales Associate', N'South House 1234 Queensbridge', N'London', NULL, N'10061', N'UK', N'(171) 890-1234', N'(171) 890-1235');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(54, N'Customer TDKEG', N'Tiano, Mike', N'Sales Agent', N'Ing. Gustavo Moncada 0123 Piso 20-A', N'Buenos Aires', NULL, N'10094', N'Argentina', N'(1) 123-4567', N'(1) 890-1234');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(55, N'Customer KZQZT', N'Egelund-Muller, Anja', N'Sales Representative', N'7890 Bering St.', N'Anchorage', N'AK', N'10050', N'USA', N'(907) 555-0115', N'(907) 555-0128');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(56, N'Customer QNIVZ', N'Marinova, Nadejda', N'Owner', N'Mehrheimerstr. 9012', N'Köln', NULL, N'10047', N'Germany', N'0221-0123456', N'0221-7890123');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(57, N'Customer WVAXS', N'Tollevsen, Bjørn', N'Owner', N'5678, boulevard Charonne', N'Paris', NULL, N'10085', N'France', N'(1) 89.01.23.45', N'(1) 89.01.23.46');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(58, N'Customer AHXHT', N'Fakhouri, Fadi', N'Sales Representative', N'Calle Dr. Jorge Cash 8901', N'México D.F.', NULL, N'10116', N'Mexico', N'(5) 890-1234', N'(5) 567-8901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(59, N'Customer LOLJO', N'Meston, Tosh', N'Sales Manager', N'Geislweg 2345', N'Salzburg', NULL, N'10127', N'Austria', N'4567-8901', N'2345-6789');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(60, N'Customer QZURI', N'Uppal, Sunil', N'Sales Representative', N'Estrada da saúde n. 6789', N'Lisboa', NULL, N'10083', N'Portugal', N'(1) 789-0123', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(61, N'Customer WULWD', N'Florczyk, Krzysztof', N'Accounting Manager', N'Rua da Panificadora, 1234', N'Rio de Janeiro', N'RJ', N'10115', N'Brazil', N'(21) 678-9012', N'(21) 678-9013');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(62, N'Customer WFIZJ', N'Misiec, Anna', N'Marketing Assistant', N'Alameda dos Canàrios, 1234', N'Sao Paulo', N'SP', N'10102', N'Brazil', N'(11) 901-2345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(63, N'Customer IRRVL', N'Veronesi, Giorgio', N'Accounting Manager', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10126', N'Germany', N'0372-12345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(64, N'Customer LWGMD', N'Gaffney, Lawrie', N'Sales Representative', N'Av. del Libertador 3456', N'Buenos Aires', NULL, N'10124', N'Argentina', N'(1) 234-5678', N'(1) 901-2345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(65, N'Customer NYUHS', N'Moore, Michael', N'Assistant Sales Representative', N'6789 Milton Dr.', N'Albuquerque', N'NM', N'10109', N'USA', N'(505) 555-0125', N'(505) 555-0134');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(66, N'Customer LHANT', N'Voss, Florian', N'Sales Associate', N'Strada Provinciale 7890', N'Reggio Emilia', NULL, N'10038', N'Italy', N'0522-012345', N'0522-678901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(67, N'Customer QVEPD', N'Garden, Euan', N'Assistant Sales Agent', N'Av. Copacabana, 6789', N'Rio de Janeiro', N'RJ', N'10052', N'Brazil', N'(21) 345-6789', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(68, N'Customer CCKOT', N'Myrcha, Jacek', N'Sales Manager', N'Grenzacherweg 0123', N'Genève', NULL, N'10122', N'Switzerland', N'0897-012345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(69, N'Customer SIUIH', N'Watters, Jason M.', N'Accounting Manager', N'Gran Vía, 4567', N'Madrid', NULL, N'10071', N'Spain', N'(91) 567 8901', N'(91) 234 5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(70, N'Customer TMXGN', N'Ginters, Kaspars', N'Owner', N'Erling Skakkes gate 2345', N'Stavern', NULL, N'10123', N'Norway', N'07-89 01 23', N'07-45 67 89');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(71, N'Customer LCOUJ', N'Navarro, Tomás', N'Sales Representative', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10078', N'USA', N'(208) 555-0116', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(72, N'Customer AHPOP', N'Welcker, Brian', N'Sales Manager', N'4567 Wadhurst Rd.', N'London', NULL, N'10088', N'UK', N'(171) 901-2345', N'(171) 901-2346');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(73, N'Customer JMIKW', N'Gonzalez, Nuria', N'Owner', N'Vinbæltet 3456', N'Kobenhavn', NULL, N'10079', N'Denmark', N'12 34 56 78', N'90 12 34 56');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(74, N'Customer YSHXL', N'O’Brien, Dave', N'Marketing Manager', N'9012, rue Lauriston', N'Paris', NULL, N'10058', N'France', N'(1) 23.45.67.89', N'(1) 23.45.67.80');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(75, N'Customer XOJYP', N'Wojciechowska, Agnieszka', N'Sales Manager', N'P.O. Box 1234', N'Lander', N'WY', N'10113', N'USA', N'(307) 555-0114', N'(307) 555-0127');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(76, N'Customer SFOGW', N'Gulbis, Katrin', N'Accounting Manager', N'Boulevard Tirou, 2345', N'Charleroi', NULL, N'10100', N'Belgium', N'(071) 56 78 90 12', N'(071) 34 56 78 90');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(77, N'Customer LCYBZ', N'Osorio, Cristian', N'Marketing Manager', N'2345 Jefferson Way Suite 2', N'Portland', N'OR', N'10042', N'USA', N'(503) 555-0120', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(78, N'Customer NLTYP', N'Young, Robin', N'Marketing Assistant', N'0123 Grizzly Peak Rd.', N'Butte', N'MT', N'10107', N'USA', N'(406) 555-0121', N'(406) 555-0131');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(79, N'Customer FAPSM', N'Wickham, Jim', N'Marketing Manager', N'Luisenstr. 0123', N'Münster', NULL, N'10118', N'Germany', N'0251-456789', N'0251-012345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(80, N'Customer VONTK', N'Geschwandtner, Jens', N'Owner', N'Avda. Azteca 4567', N'México D.F.', NULL, N'10044', N'Mexico', N'(5) 678-9012', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(81, N'Customer YQQWW', N'Nagel, Jean-Philippe', N'Sales Representative', N'Av. Inês de Castro, 1234', N'Sao Paulo', N'SP', N'10120', N'Brazil', N'(11) 123-4567', N'(11) 234-5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(82, N'Customer EYHKM', N'Veninga, Tjeerd', N'Sales Associate', N'1234 DaVinci Blvd.', N'Kirkland', N'WA', N'10119', N'USA', N'(206) 555-0124', N'(206) 555-0133');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(83, N'Customer ZRNDE', N'Fonteneau, Karl', N'Sales Manager', N'Smagsloget 3456', N'Århus', NULL, N'10090', N'Denmark', N'23 45 67 89', N'01 23 45 67');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(84, N'Customer NRCSK', N'Tuntisangaroon, Sittichai', N'Sales Agent', N'6789, rue du Commerce', N'Lyon', NULL, N'10072', N'France', N'78.90.12.34', N'78.90.12.35');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(85, N'Customer ENQZT', N'McLin, Nkenge', N'Accounting Manager', N'5678 rue de l''Abbaye', N'Reims', NULL, N'10082', N'France', N'56.78.90.12', N'56.78.90.13');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(86, N'Customer SNXOJ', N'Syamala, Manoj', N'Sales Representative', N'Adenauerallee 7890', N'Stuttgart', NULL, N'10086', N'Germany', N'0711-345678', N'0711-901234');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(87, N'Customer ZHYOS', N'Ludwig, Michael', N'Accounting Manager', N'Torikatu 9012', N'Oulu', NULL, N'10045', N'Finland', N'981-123456', N'981-789012');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(88, N'Customer SRQVM', N'Li, Yan', N'Sales Manager', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10084', N'Brazil', N'(14) 234-5678', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(89, N'Customer YBQTI', N'Smith Jr., Ronaldo', N'Owner', N'8901 - 14th Ave. S. Suite 3B', N'Seattle', N'WA', N'10049', N'USA', N'(206) 555-0123', N'(206) 555-0132');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(90, N'Customer XBBVR', N'Larsson, Katarina', N'Owner/Marketing Assistant', N'Keskuskatu 2345', N'Helsinki', NULL, N'10055', N'Finland', N'90-012 3456', N'90-789 0123');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(91, N'Customer CCFIZ', N'Conn, Steve', N'Owner', N'ul. Filtrowa 6789', N'Warszawa', NULL, N'10068', N'Poland', N'(26) 234-5678', N'(26) 901-2345');
SET IDENTITY_INSERT Sales.Customers OFF;

-- Populate table Sales.Shippers
SET IDENTITY_INSERT Sales.Shippers ON;
INSERT INTO Sales.Shippers(shipperid, companyname, phone)
  VALUES(1, N'Shipper GVSUA', N'(503) 555-0137');
INSERT INTO Sales.Shippers(shipperid, companyname, phone)
  VALUES(2, N'Shipper ETYNR', N'(425) 555-0136');
INSERT INTO Sales.Shippers(shipperid, companyname, phone)
  VALUES(3, N'Shipper ZHISN', N'(415) 555-0138');
SET IDENTITY_INSERT Sales.Shippers OFF;


-- Populate table Sales.OrderDetails
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10248, 11, 14.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10248, 42, 9.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10248, 72, 34.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10249, 14, 18.60, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10249, 51, 42.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10250, 41, 7.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10250, 51, 42.40, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10250, 65, 16.80, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10251, 22, 16.80, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10251, 57, 15.60, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10251, 65, 16.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10252, 20, 64.80, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10252, 33, 2.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10252, 60, 27.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10253, 31, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10253, 39, 14.40, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10253, 49, 16.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10254, 24, 3.60, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10254, 55, 19.20, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10254, 74, 8.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 2, 15.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 16, 13.90, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 36, 15.20, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 59, 44.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10256, 53, 26.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10256, 77, 10.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10257, 27, 35.10, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10257, 39, 14.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10257, 77, 10.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10258, 2, 15.20, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10258, 5, 17.00, 65, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10258, 32, 25.60, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10259, 21, 8.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10259, 37, 20.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 41, 7.70, 16, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 57, 15.60, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 62, 39.40, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 70, 12.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10261, 21, 8.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10261, 35, 14.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10262, 5, 17.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10262, 7, 24.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10262, 56, 30.40, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 16, 13.90, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 24, 3.60, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 30, 20.70, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 74, 8.00, 36, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10264, 2, 15.20, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10264, 41, 7.70, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10265, 17, 31.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10265, 70, 12.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10266, 12, 30.40, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10267, 40, 14.70, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10267, 59, 44.00, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10267, 76, 14.40, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10268, 29, 99.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10268, 72, 27.80, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10269, 33, 2.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10269, 72, 27.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10270, 36, 15.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10270, 43, 36.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10271, 33, 2.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10272, 20, 64.80, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10272, 31, 10.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10272, 72, 27.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 10, 24.80, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 31, 10.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 33, 2.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 40, 14.70, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 76, 14.40, 33, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10274, 71, 17.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10274, 72, 27.80, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10275, 24, 3.60, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10275, 59, 44.00, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10276, 10, 24.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10276, 13, 4.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10277, 28, 36.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10277, 62, 39.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 44, 15.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 59, 44.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 63, 35.10, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 73, 12.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10279, 17, 31.20, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10280, 24, 3.60, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10280, 55, 19.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10280, 75, 6.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10281, 19, 7.30, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10281, 24, 3.60, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10281, 35, 14.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10282, 30, 20.70, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10282, 57, 15.60, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 15, 12.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 19, 7.30, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 60, 27.20, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 72, 27.80, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 27, 35.10, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 44, 15.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 60, 27.20, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 67, 11.20, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10285, 1, 14.40, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10285, 40, 14.70, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10285, 53, 26.20, 36, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10286, 35, 14.40, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10286, 62, 39.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10287, 16, 13.90, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10287, 34, 11.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10287, 46, 9.60, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10288, 54, 5.90, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10288, 68, 10.00, 3, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10289, 3, 8.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10289, 64, 26.60, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 5, 17.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 29, 99.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 49, 16.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 77, 10.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10291, 13, 4.80, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10291, 44, 15.50, 24, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10291, 51, 42.40, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10292, 20, 64.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 18, 50.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 24, 3.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 63, 35.10, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 75, 6.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 1, 14.40, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 17, 31.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 43, 36.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 60, 27.20, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 75, 6.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10295, 56, 30.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10296, 11, 16.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10296, 16, 13.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10296, 69, 28.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10297, 39, 14.40, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10297, 72, 27.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 2, 15.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 36, 15.20, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 59, 44.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 62, 39.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10299, 19, 7.30, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10299, 70, 12.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10300, 66, 13.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10300, 68, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10301, 40, 14.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10301, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10302, 17, 31.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10302, 28, 36.40, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10302, 43, 36.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10303, 40, 14.70, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10303, 65, 16.80, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10303, 68, 10.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10304, 49, 16.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10304, 59, 44.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10304, 71, 17.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10305, 18, 50.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10305, 29, 99.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10305, 39, 14.40, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10306, 30, 20.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10306, 53, 26.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10306, 54, 5.90, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10307, 62, 39.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10307, 68, 10.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10308, 69, 28.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10308, 70, 12.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 4, 17.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 6, 20.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 42, 11.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 43, 36.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 71, 17.20, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10310, 16, 13.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10310, 62, 39.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10311, 42, 11.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10311, 69, 28.80, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 28, 36.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 43, 36.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 53, 26.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 75, 6.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10313, 36, 15.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10314, 32, 25.60, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10314, 58, 10.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10314, 62, 39.40, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10315, 34, 11.20, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10315, 70, 12.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10316, 41, 7.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10316, 62, 39.40, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10317, 1, 14.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10318, 41, 7.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10318, 76, 14.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10319, 17, 31.20, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10319, 28, 36.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10319, 76, 14.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10320, 71, 17.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10321, 35, 14.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10322, 52, 5.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10323, 15, 12.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10323, 25, 11.20, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10323, 39, 14.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 16, 13.90, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 35, 14.40, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 46, 9.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 59, 44.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 63, 35.10, 80, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 6, 20.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 13, 4.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 14, 18.60, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 31, 10.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 72, 27.80, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10326, 4, 17.60, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10326, 57, 15.60, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10326, 75, 6.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 2, 15.20, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 11, 16.80, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 30, 20.70, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 58, 10.60, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10328, 59, 44.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10328, 65, 16.80, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10328, 68, 10.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 19, 7.30, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 30, 20.70, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 38, 210.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 56, 30.40, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10330, 26, 24.90, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10330, 72, 27.80, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10331, 54, 5.90, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10332, 18, 50.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10332, 42, 11.20, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10332, 47, 7.60, 16, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10333, 14, 18.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10333, 21, 8.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10333, 71, 17.20, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10334, 52, 5.60, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10334, 68, 10.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 2, 15.20, 7, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 31, 10.00, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 32, 25.60, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 51, 42.40, 48, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10336, 4, 17.60, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 23, 7.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 26, 24.90, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 36, 15.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 37, 20.80, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 72, 27.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10338, 17, 31.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10338, 30, 20.70, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10339, 4, 17.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10339, 17, 31.20, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10339, 62, 39.40, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10340, 18, 50.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10340, 41, 7.70, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10340, 43, 36.80, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10341, 33, 2.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10341, 59, 44.00, 9, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 2, 15.20, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 31, 10.00, 56, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 36, 15.20, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 55, 19.20, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10343, 64, 26.60, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10343, 68, 10.00, 4, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10343, 76, 14.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10344, 4, 17.60, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10344, 8, 32.00, 70, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10345, 8, 32.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10345, 19, 7.30, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10345, 42, 11.20, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10346, 17, 31.20, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10346, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 25, 11.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 39, 14.40, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 40, 14.70, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 75, 6.20, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10348, 1, 14.40, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10348, 23, 7.20, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10349, 54, 5.90, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10350, 50, 13.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10350, 69, 28.80, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 38, 210.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 41, 7.70, 13, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 44, 15.50, 77, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 65, 16.80, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10352, 24, 3.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10352, 54, 5.90, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10353, 11, 16.80, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10353, 38, 210.80, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10354, 1, 14.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10354, 29, 99.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10355, 24, 3.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10355, 57, 15.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10356, 31, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10356, 55, 19.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10356, 69, 28.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10357, 10, 24.80, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10357, 26, 24.90, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10357, 60, 27.20, 8, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10358, 24, 3.60, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10358, 34, 11.20, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10358, 36, 15.20, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10359, 16, 13.90, 56, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10359, 31, 10.00, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10359, 60, 27.20, 80, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 28, 36.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 29, 99.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 38, 210.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 49, 16.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 54, 5.90, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10361, 39, 14.40, 54, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10361, 60, 27.20, 55, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10362, 25, 11.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10362, 51, 42.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10362, 54, 5.90, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10363, 31, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10363, 75, 6.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10363, 76, 14.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10364, 69, 28.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10364, 71, 17.20, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10365, 11, 16.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10366, 65, 16.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10366, 77, 10.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 34, 11.20, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 54, 5.90, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 65, 16.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 77, 10.40, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 21, 8.00, 5, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 28, 36.40, 13, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 57, 15.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 64, 26.60, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10369, 29, 99.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10369, 56, 30.40, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10370, 1, 14.40, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10370, 64, 26.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10370, 74, 8.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10371, 36, 15.20, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 20, 64.80, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 38, 210.80, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 60, 27.20, 70, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 72, 27.80, 42, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10373, 58, 10.60, 80, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10373, 71, 17.20, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10374, 31, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10374, 58, 10.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10375, 14, 18.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10375, 54, 5.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10376, 31, 10.00, 42, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10377, 28, 36.40, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10377, 39, 14.40, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10378, 71, 17.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10379, 41, 7.70, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10379, 63, 35.10, 16, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10379, 65, 16.80, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 30, 20.70, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 53, 26.20, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 60, 27.20, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 70, 12.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10381, 74, 8.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 5, 17.00, 32, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 18, 50.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 29, 99.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 33, 2.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 74, 8.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10383, 13, 4.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10383, 50, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10383, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10384, 20, 64.80, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10384, 60, 27.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10385, 7, 24.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10385, 60, 27.20, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10385, 68, 10.00, 8, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10386, 24, 3.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10386, 34, 11.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 24, 3.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 28, 36.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 59, 44.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 71, 17.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10388, 45, 7.60, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10388, 52, 5.60, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10388, 53, 26.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 10, 24.80, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 55, 19.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 62, 39.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 70, 12.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 31, 10.00, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 35, 14.40, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 46, 9.60, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 72, 27.80, 24, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10391, 13, 4.80, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10392, 69, 28.80, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 2, 15.20, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 14, 18.60, 42, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 25, 11.20, 7, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 26, 24.90, 70, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 31, 10.00, 32, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10394, 13, 4.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10394, 62, 39.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10395, 46, 9.60, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10395, 53, 26.20, 70, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10395, 69, 28.80, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10396, 23, 7.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10396, 71, 17.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10396, 72, 27.80, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10397, 21, 8.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10397, 51, 42.40, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10398, 35, 14.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10398, 55, 19.20, 120, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 68, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 71, 17.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 76, 14.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 77, 10.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10400, 29, 99.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10400, 35, 14.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10400, 49, 16.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 30, 20.70, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 56, 30.40, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 65, 16.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 71, 17.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10402, 23, 7.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10402, 63, 35.10, 65, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10403, 16, 13.90, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10403, 48, 10.20, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10404, 26, 24.90, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10404, 42, 11.20, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10404, 49, 16.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10405, 3, 8.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 1, 14.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 21, 8.00, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 28, 36.40, 42, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 36, 15.20, 5, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 40, 14.70, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10407, 11, 16.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10407, 69, 28.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10407, 71, 17.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10408, 37, 20.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10408, 54, 5.90, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10408, 62, 39.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10409, 14, 18.60, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10409, 21, 8.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10410, 33, 2.00, 49, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10410, 59, 44.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10411, 41, 7.70, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10411, 44, 15.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10411, 59, 44.00, 9, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10412, 14, 18.60, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10413, 1, 14.40, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10413, 62, 39.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10413, 76, 14.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10414, 19, 7.30, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10414, 33, 2.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10415, 17, 31.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10415, 33, 2.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10416, 19, 7.30, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10416, 53, 26.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10416, 57, 15.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 38, 210.80, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 46, 9.60, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 68, 10.00, 36, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 77, 10.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 2, 15.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 47, 7.60, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 61, 22.80, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 74, 8.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10419, 60, 27.20, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10419, 69, 28.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 9, 77.60, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 13, 4.80, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 70, 12.00, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 73, 12.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 19, 7.30, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 26, 24.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 53, 26.20, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 77, 10.40, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10422, 26, 24.90, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10423, 31, 10.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10423, 59, 44.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10424, 35, 14.40, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10424, 38, 210.80, 49, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10424, 68, 10.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10425, 55, 19.20, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10425, 76, 14.40, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10426, 56, 30.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10426, 64, 26.60, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10427, 14, 18.60, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10428, 46, 9.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10429, 50, 13.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10429, 63, 35.10, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 17, 31.20, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 21, 8.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 56, 30.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 59, 44.00, 70, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10431, 17, 31.20, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10431, 40, 14.70, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10431, 47, 7.60, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10432, 26, 24.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10432, 54, 5.90, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10433, 56, 30.40, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10434, 11, 16.80, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10434, 76, 14.40, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10435, 2, 15.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10435, 22, 16.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10435, 72, 27.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 46, 9.60, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 56, 30.40, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 64, 26.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 75, 6.20, 24, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10437, 53, 26.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10438, 19, 7.30, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10438, 34, 11.20, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10438, 57, 15.60, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 12, 30.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 16, 13.90, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 64, 26.60, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 74, 8.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 2, 15.20, 45, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 16, 13.90, 49, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 29, 99.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 61, 22.80, 90, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10441, 27, 35.10, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10442, 11, 16.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10442, 54, 5.90, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10442, 66, 13.60, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10443, 11, 16.80, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10443, 28, 36.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 17, 31.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 26, 24.90, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 35, 14.40, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 41, 7.70, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10445, 39, 14.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10445, 54, 5.90, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 19, 7.30, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 24, 3.60, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 31, 10.00, 3, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 52, 5.60, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10447, 19, 7.30, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10447, 65, 16.80, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10447, 71, 17.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10448, 26, 24.90, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10448, 40, 14.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10449, 10, 24.80, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10449, 52, 5.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10449, 62, 39.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10450, 10, 24.80, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10450, 54, 5.90, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 55, 19.20, 120, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 64, 26.60, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 65, 16.80, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 77, 10.40, 55, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10452, 28, 36.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10452, 44, 15.50, 100, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10453, 48, 10.20, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10453, 70, 12.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10454, 16, 13.90, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10454, 33, 2.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10454, 46, 9.60, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 39, 14.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 53, 26.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 61, 22.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 71, 17.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10456, 21, 8.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10456, 49, 16.00, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10457, 59, 44.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 26, 24.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 28, 36.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 43, 36.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 56, 30.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 71, 17.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10459, 7, 24.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10459, 46, 9.60, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10459, 72, 27.80, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10460, 68, 10.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10460, 75, 6.20, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10461, 21, 8.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10461, 30, 20.70, 28, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10461, 55, 19.20, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10462, 13, 4.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10462, 23, 7.20, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10463, 19, 7.30, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10463, 42, 11.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 4, 17.60, 16, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 43, 36.80, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 56, 30.40, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 60, 27.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 24, 3.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 29, 99.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 40, 14.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 45, 7.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 50, 13.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10466, 11, 16.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10466, 46, 9.60, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10467, 24, 3.60, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10467, 25, 11.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10468, 30, 20.70, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10468, 43, 36.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10469, 2, 15.20, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10469, 16, 13.90, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10469, 44, 15.50, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10470, 18, 50.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10470, 23, 7.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10470, 64, 26.60, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10471, 7, 24.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10471, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10472, 24, 3.60, 80, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10472, 51, 42.40, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10473, 33, 2.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10473, 71, 17.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 14, 18.60, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 28, 36.40, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 40, 14.70, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 75, 6.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10475, 31, 10.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10475, 66, 13.60, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10475, 76, 14.40, 42, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10476, 55, 19.20, 2, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10476, 70, 12.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10477, 1, 14.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10477, 21, 8.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10477, 39, 14.40, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10478, 10, 24.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 38, 210.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 53, 26.20, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 59, 44.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 64, 26.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10480, 47, 7.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10480, 59, 44.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10481, 49, 16.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10481, 60, 27.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10482, 40, 14.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10483, 34, 11.20, 35, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10483, 77, 10.40, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10484, 21, 8.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10484, 40, 14.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10484, 51, 42.40, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 2, 15.20, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 3, 8.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 55, 19.20, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 70, 12.00, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10486, 11, 16.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10486, 51, 42.40, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10486, 74, 8.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10487, 19, 7.30, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10487, 26, 24.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10487, 54, 5.90, 24, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10488, 59, 44.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10488, 73, 12.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10489, 11, 16.80, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10489, 16, 13.90, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10490, 59, 44.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10490, 68, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10490, 75, 6.20, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10491, 44, 15.50, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10491, 77, 10.40, 7, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10492, 25, 11.20, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10492, 42, 11.20, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10493, 65, 16.80, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10493, 66, 13.60, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10493, 69, 28.80, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10494, 56, 30.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10495, 23, 7.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10495, 41, 7.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10495, 77, 10.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10496, 31, 10.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10497, 56, 30.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10497, 72, 27.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10497, 77, 10.40, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10498, 24, 4.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10498, 40, 18.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10498, 42, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10499, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10499, 49, 20.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10500, 15, 15.50, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10500, 28, 45.60, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10501, 54, 7.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10502, 45, 9.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10502, 53, 32.80, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10502, 67, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10503, 14, 23.25, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10503, 65, 21.05, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 2, 19.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 21, 10.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 53, 32.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 61, 28.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10505, 62, 49.30, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10506, 25, 14.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10506, 70, 15.00, 14, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10507, 43, 46.00, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10507, 48, 12.75, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10508, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10508, 39, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10509, 28, 45.60, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10510, 29, 123.79, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10510, 75, 7.75, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10511, 4, 22.00, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10511, 7, 30.00, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10511, 8, 40.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 24, 4.50, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 46, 12.00, 9, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 47, 9.50, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 60, 34.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10513, 21, 10.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10513, 32, 32.00, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10513, 61, 28.50, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 20, 81.00, 39, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 28, 45.60, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 56, 38.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 65, 21.05, 39, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 75, 7.75, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 9, 97.00, 16, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 16, 17.45, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 27, 43.90, 120, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 33, 2.50, 16, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 60, 34.00, 84, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10516, 18, 62.50, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10516, 41, 9.65, 80, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10516, 42, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10517, 52, 7.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10517, 59, 55.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10517, 70, 15.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10518, 24, 4.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10518, 38, 263.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10518, 44, 19.45, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10519, 10, 31.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10519, 56, 38.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10519, 60, 34.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10520, 24, 4.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10520, 53, 32.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10521, 35, 18.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10521, 41, 9.65, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10521, 68, 12.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 1, 18.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 8, 40.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 30, 25.89, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 40, 18.40, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 17, 39.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 20, 81.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 37, 26.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 41, 9.65, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 10, 31.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 30, 25.89, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 43, 46.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 54, 7.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10525, 36, 19.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10525, 40, 18.40, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10526, 1, 18.00, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10526, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10526, 56, 38.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10527, 4, 22.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10527, 36, 19.00, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10528, 11, 21.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10528, 33, 2.50, 8, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10528, 72, 34.80, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10529, 55, 24.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10529, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10529, 69, 36.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 17, 39.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 43, 46.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 61, 28.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 76, 18.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10531, 59, 55.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10532, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10532, 66, 17.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10533, 4, 22.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10533, 72, 34.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10533, 73, 15.00, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10534, 30, 25.89, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10534, 40, 18.40, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10534, 54, 7.45, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 11, 21.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 40, 18.40, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 57, 19.50, 5, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 59, 55.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 12, 38.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 60, 34.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 31, 12.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 51, 53.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 58, 13.25, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 72, 34.80, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 73, 15.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10538, 70, 15.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10538, 72, 34.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 13, 6.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 21, 10.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 33, 2.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 49, 20.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 3, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 26, 31.23, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 38, 263.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 68, 12.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 24, 4.50, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 38, 263.50, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 65, 21.05, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 71, 21.50, 9, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10542, 11, 21.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10542, 54, 7.45, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10543, 12, 38.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10543, 23, 9.00, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10544, 28, 45.60, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10544, 67, 14.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10545, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10546, 7, 30.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10546, 35, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10546, 62, 49.30, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10547, 32, 32.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10547, 36, 19.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10548, 34, 14.00, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10548, 41, 9.65, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10549, 31, 12.50, 55, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10549, 45, 9.50, 100, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10549, 51, 53.00, 48, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 17, 39.00, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 19, 9.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 21, 10.00, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 61, 28.50, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10551, 16, 17.45, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10551, 35, 18.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10551, 44, 19.45, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10552, 69, 36.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10552, 75, 7.75, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 16, 17.45, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 22, 21.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 31, 12.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 35, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 16, 17.45, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 23, 9.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 62, 49.30, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 77, 13.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 14, 23.25, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 19, 9.20, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 24, 4.50, 18, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 51, 53.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 56, 38.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10556, 72, 34.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10557, 64, 33.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10557, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 47, 9.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 52, 7.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 53, 32.80, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 73, 15.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10559, 41, 9.65, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10559, 55, 24.00, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10560, 30, 25.89, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10560, 62, 49.30, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10561, 44, 19.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10561, 51, 53.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10562, 33, 2.50, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10562, 62, 49.30, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10563, 36, 19.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10563, 52, 7.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10564, 17, 39.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10564, 31, 12.50, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10564, 55, 24.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10565, 24, 4.50, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10565, 64, 33.25, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10566, 11, 21.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10566, 18, 62.50, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10566, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10567, 31, 12.50, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10567, 51, 53.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10567, 59, 55.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10568, 10, 31.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10569, 31, 12.50, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10569, 76, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10570, 11, 21.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10570, 56, 38.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10571, 14, 23.25, 11, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10571, 42, 14.00, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 16, 17.45, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 32, 32.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 40, 18.40, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 75, 7.75, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10573, 17, 39.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10573, 34, 14.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10573, 53, 32.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 33, 2.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 40, 18.40, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 62, 49.30, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 64, 33.25, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 59, 55.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 63, 43.90, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 72, 34.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10576, 1, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10576, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10576, 44, 19.45, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10577, 39, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10577, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10577, 77, 13.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10578, 35, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10578, 57, 19.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10579, 15, 15.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10579, 75, 7.75, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10580, 14, 23.25, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10580, 41, 9.65, 9, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10580, 65, 21.05, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10581, 75, 7.75, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10582, 57, 19.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10582, 76, 18.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10583, 29, 123.79, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10583, 60, 34.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10583, 69, 36.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10584, 31, 12.50, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10585, 47, 9.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10586, 52, 7.00, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10587, 26, 31.23, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10587, 35, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10587, 77, 13.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10588, 18, 62.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10588, 42, 14.00, 100, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10589, 35, 18.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10590, 1, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10590, 77, 13.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10591, 3, 10.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10591, 7, 30.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10591, 54, 7.45, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10592, 15, 15.50, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10592, 26, 31.23, 5, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10593, 20, 81.00, 21, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10593, 69, 36.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10593, 76, 18.00, 4, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10594, 52, 7.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10594, 58, 13.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10595, 35, 18.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10595, 61, 28.50, 120, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10595, 69, 36.00, 65, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10596, 56, 38.00, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10596, 63, 43.90, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10596, 75, 7.75, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10597, 24, 4.50, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10597, 57, 19.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10597, 65, 21.05, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10598, 27, 43.90, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10598, 71, 21.50, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10599, 62, 49.30, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10600, 54, 7.45, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10600, 73, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10601, 13, 6.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10601, 59, 55.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10602, 77, 13.00, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10603, 22, 21.00, 48, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10603, 49, 20.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10604, 48, 12.75, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10604, 76, 18.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 16, 17.45, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 59, 55.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 60, 34.00, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 71, 21.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10606, 4, 22.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10606, 55, 24.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10606, 62, 49.30, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 7, 30.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 17, 39.00, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 33, 2.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 40, 18.40, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 72, 34.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10608, 56, 38.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10609, 1, 18.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10609, 10, 31.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10609, 21, 10.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10610, 36, 19.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10611, 1, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10611, 2, 19.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10611, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 10, 31.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 36, 19.00, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 49, 20.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 60, 34.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 76, 18.00, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10613, 13, 6.00, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10613, 75, 7.75, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10614, 11, 21.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10614, 21, 10.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10614, 39, 18.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10615, 55, 24.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 38, 263.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 56, 38.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 70, 15.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 71, 21.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10617, 59, 55.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10618, 6, 25.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10618, 56, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10618, 68, 12.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10619, 21, 10.00, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10619, 22, 21.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10620, 24, 4.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10620, 52, 7.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 19, 9.20, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 23, 9.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 70, 15.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 71, 21.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10622, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10622, 68, 12.50, 18, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 14, 23.25, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 19, 9.20, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 21, 10.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 24, 4.50, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 35, 18.00, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10624, 28, 45.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10624, 29, 123.79, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10624, 44, 19.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10625, 14, 23.25, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10625, 42, 14.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10625, 60, 34.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10626, 53, 32.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10626, 60, 34.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10626, 71, 21.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10627, 62, 49.30, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10627, 73, 15.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10628, 1, 18.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10629, 29, 123.79, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10629, 64, 33.25, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10630, 55, 24.00, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10630, 76, 18.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10631, 75, 7.75, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10632, 2, 19.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10632, 33, 2.50, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 12, 38.00, 36, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 13, 6.00, 13, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 26, 31.23, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 62, 49.30, 80, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 7, 30.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 18, 62.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 51, 53.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 75, 7.75, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10635, 4, 22.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10635, 5, 21.35, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10635, 22, 21.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10636, 4, 22.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10636, 58, 13.25, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10637, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10637, 50, 16.25, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10637, 56, 38.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10638, 45, 9.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10638, 65, 21.05, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10638, 72, 34.80, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10639, 18, 62.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10640, 69, 36.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10640, 70, 15.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10641, 2, 19.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10641, 40, 18.40, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10642, 21, 10.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10642, 61, 28.50, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10643, 28, 45.60, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10643, 39, 18.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10643, 46, 12.00, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10644, 18, 62.50, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10644, 43, 46.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10644, 46, 12.00, 21, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10645, 18, 62.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10645, 36, 19.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 1, 18.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 10, 31.00, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 71, 21.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 77, 13.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10647, 19, 9.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10647, 39, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10648, 22, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10648, 24, 4.50, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10649, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10649, 72, 34.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10650, 30, 25.89, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10650, 53, 32.80, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10650, 54, 7.45, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10651, 19, 9.20, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10651, 22, 21.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10652, 30, 25.89, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10652, 42, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10653, 16, 17.45, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10653, 60, 34.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10654, 4, 22.00, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10654, 39, 18.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10654, 54, 7.45, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10655, 41, 9.65, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10656, 14, 23.25, 3, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10656, 44, 19.45, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10656, 47, 9.50, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 15, 15.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 41, 9.65, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 46, 12.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 47, 9.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 56, 38.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 60, 34.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 21, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 40, 18.40, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 60, 34.00, 55, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 77, 13.00, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10659, 31, 12.50, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10659, 40, 18.40, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10659, 70, 15.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10660, 20, 81.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10661, 39, 18.00, 3, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10661, 58, 13.25, 49, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10662, 68, 12.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10663, 40, 18.40, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10663, 42, 14.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10663, 51, 53.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10664, 10, 31.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10664, 56, 38.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10664, 65, 21.05, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10665, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10665, 59, 55.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10665, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10666, 29, 123.79, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10666, 65, 21.05, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10667, 69, 36.00, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10667, 71, 21.50, 14, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10668, 31, 12.50, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10668, 55, 24.00, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10668, 64, 33.25, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10669, 36, 19.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 23, 9.00, 32, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 46, 12.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 67, 14.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 73, 15.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 75, 7.75, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10671, 16, 17.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10671, 62, 49.30, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10671, 65, 21.05, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10672, 38, 263.50, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10672, 71, 21.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10673, 16, 17.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10673, 42, 14.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10673, 43, 46.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10674, 23, 9.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10675, 14, 23.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10675, 53, 32.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10675, 58, 13.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10676, 10, 31.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10676, 19, 9.20, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10676, 44, 19.45, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10677, 26, 31.23, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10677, 33, 2.50, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 12, 38.00, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 41, 9.65, 120, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 54, 7.45, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10679, 59, 55.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10680, 16, 17.45, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10680, 31, 12.50, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10680, 42, 14.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10681, 19, 9.20, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10681, 21, 10.00, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10681, 64, 33.25, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10682, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10682, 66, 17.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10682, 75, 7.75, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10683, 52, 7.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10684, 40, 18.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10684, 47, 9.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10684, 60, 34.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10685, 10, 31.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10685, 41, 9.65, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10685, 47, 9.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10686, 17, 39.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10686, 26, 31.23, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10687, 9, 97.00, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10687, 29, 123.79, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10687, 36, 19.00, 6, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10688, 10, 31.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10688, 28, 45.60, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10688, 34, 14.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10689, 1, 18.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10690, 56, 38.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10690, 77, 13.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 1, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 29, 123.79, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 43, 46.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 44, 19.45, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 62, 49.30, 48, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10692, 63, 43.90, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 9, 97.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 54, 7.45, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 69, 36.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 73, 15.00, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10694, 7, 30.00, 90, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10694, 59, 55.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10694, 70, 15.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10695, 8, 40.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10695, 12, 38.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10695, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10696, 17, 39.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10696, 46, 12.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 19, 9.20, 7, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 35, 18.00, 9, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 58, 13.25, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 70, 15.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 17, 39.00, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 29, 123.79, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 65, 21.05, 65, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 70, 15.00, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10699, 47, 9.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 1, 18.00, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 34, 14.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 68, 12.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 71, 21.50, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10701, 59, 55.00, 42, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10701, 71, 21.50, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10701, 76, 18.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10702, 3, 10.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10702, 76, 18.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10703, 2, 19.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10703, 59, 55.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10703, 73, 15.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10704, 4, 22.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10704, 24, 4.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10704, 48, 12.75, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10705, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10705, 32, 32.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10706, 16, 17.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10706, 43, 46.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10706, 59, 55.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10707, 55, 24.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10707, 57, 19.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10707, 70, 15.00, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10708, 5, 21.35, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10708, 36, 19.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10709, 8, 40.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10709, 51, 53.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10709, 60, 34.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10710, 19, 9.20, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10710, 47, 9.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10711, 19, 9.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10711, 41, 9.65, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10711, 53, 32.80, 120, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10712, 53, 32.80, 3, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10712, 56, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 10, 31.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 26, 31.23, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 45, 9.50, 110, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 46, 12.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 2, 19.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 17, 39.00, 27, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 47, 9.50, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 56, 38.00, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 58, 13.25, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10715, 10, 31.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10715, 71, 21.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10716, 21, 10.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10716, 51, 53.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10716, 61, 28.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10717, 21, 10.00, 32, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10717, 54, 7.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10717, 69, 36.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 12, 38.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 16, 17.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 36, 19.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 62, 49.30, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10719, 18, 62.50, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10719, 30, 25.89, 3, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10719, 54, 7.45, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10720, 35, 18.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10720, 71, 21.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10721, 44, 19.45, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 2, 19.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 31, 12.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 68, 12.50, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 75, 7.75, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10723, 26, 31.23, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10724, 10, 31.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10724, 61, 28.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10725, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10725, 52, 7.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10725, 55, 24.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10726, 4, 22.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10726, 11, 21.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10727, 17, 39.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10727, 56, 38.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10727, 59, 55.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 40, 18.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 55, 24.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10729, 1, 18.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10729, 21, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10729, 50, 16.25, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10730, 16, 17.45, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10730, 31, 12.50, 3, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10730, 65, 21.05, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10731, 21, 10.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10731, 51, 53.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10732, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10733, 14, 23.25, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10733, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10733, 52, 7.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10734, 6, 25.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10734, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10734, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10735, 61, 28.50, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10735, 77, 13.00, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10736, 65, 21.05, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10736, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10737, 13, 6.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10737, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10738, 16, 17.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10739, 36, 19.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10739, 52, 7.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 28, 45.60, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 35, 18.00, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 45, 9.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 56, 38.00, 14, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10741, 2, 19.00, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10742, 3, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10742, 60, 34.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10742, 72, 34.80, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10743, 46, 12.00, 28, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10744, 40, 18.40, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 18, 62.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 44, 19.45, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 59, 55.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 72, 34.80, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 13, 6.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 42, 14.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 62, 49.30, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 69, 36.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 31, 12.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 41, 9.65, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 63, 43.90, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 69, 36.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10748, 23, 9.00, 44, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10748, 40, 18.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10748, 56, 38.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10749, 56, 38.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10749, 59, 55.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10749, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10750, 14, 23.25, 5, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10750, 45, 9.50, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10750, 59, 55.00, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 26, 31.23, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 30, 25.89, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 50, 16.25, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 73, 15.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10752, 1, 18.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10752, 69, 36.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10753, 45, 9.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10753, 74, 10.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10754, 40, 18.40, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 47, 9.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 56, 38.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 57, 19.50, 14, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 69, 36.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 18, 62.50, 21, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 36, 19.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 68, 12.50, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 69, 36.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 34, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 59, 55.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 62, 49.30, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 64, 33.25, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10758, 26, 31.23, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10758, 52, 7.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10758, 70, 15.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10759, 32, 32.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10760, 25, 14.00, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10760, 27, 43.90, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10760, 43, 46.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10761, 25, 14.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10761, 75, 7.75, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 39, 18.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 47, 9.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 51, 53.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 56, 38.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10763, 21, 10.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10763, 22, 21.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10763, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10764, 3, 10.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10764, 39, 18.00, 130, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10765, 65, 21.05, 80, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10766, 2, 19.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10766, 7, 30.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10766, 68, 12.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10767, 42, 14.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 22, 21.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 31, 12.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 71, 21.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 41, 9.65, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 52, 7.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 61, 28.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 62, 49.30, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10770, 11, 21.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10771, 71, 21.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10772, 29, 123.79, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10772, 59, 55.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10773, 17, 39.00, 33, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10773, 31, 12.50, 70, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10773, 75, 7.75, 7, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10774, 31, 12.50, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10774, 66, 17.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10775, 10, 31.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10775, 67, 14.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 31, 12.50, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 42, 14.00, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 45, 9.50, 27, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 51, 53.00, 120, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10777, 42, 14.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10778, 41, 9.65, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10779, 16, 17.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10779, 62, 49.30, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10780, 70, 15.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10780, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10781, 54, 7.45, 3, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10781, 56, 38.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10781, 74, 10.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10782, 31, 12.50, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10783, 31, 12.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10783, 38, 263.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10784, 36, 19.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10784, 39, 18.00, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10784, 72, 34.80, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10785, 10, 31.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10785, 75, 7.75, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10786, 8, 40.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10786, 30, 25.89, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10786, 75, 7.75, 42, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10787, 2, 19.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10787, 29, 123.79, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10788, 19, 9.20, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10788, 75, 7.75, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 18, 62.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 35, 18.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 63, 43.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 68, 12.50, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10790, 7, 30.00, 3, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10790, 56, 38.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10791, 29, 123.79, 14, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10791, 41, 9.65, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10792, 2, 19.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10792, 54, 7.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10792, 68, 12.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10793, 41, 9.65, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10793, 52, 7.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10794, 14, 23.25, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10794, 54, 7.45, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10795, 16, 17.45, 65, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10795, 17, 39.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 26, 31.23, 21, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 44, 19.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 64, 33.25, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 69, 36.00, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10797, 11, 21.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10798, 62, 49.30, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10798, 72, 34.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10799, 13, 6.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10799, 24, 4.50, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10799, 59, 55.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10800, 11, 21.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10800, 51, 53.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10800, 54, 7.45, 7, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10801, 17, 39.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10801, 29, 123.79, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 30, 25.89, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 51, 53.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 55, 24.00, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 62, 49.30, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10803, 19, 9.20, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10803, 25, 14.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10803, 59, 55.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10804, 10, 31.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10804, 28, 45.60, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10804, 49, 20.00, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10805, 34, 14.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10805, 38, 263.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10806, 2, 19.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10806, 65, 21.05, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10806, 74, 10.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10807, 40, 18.40, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10808, 56, 38.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10808, 76, 18.00, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10809, 52, 7.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10810, 13, 6.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10810, 25, 14.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10810, 70, 15.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10811, 19, 9.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10811, 23, 9.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10811, 40, 18.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10812, 31, 12.50, 16, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10812, 72, 34.80, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10812, 77, 13.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10813, 2, 19.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10813, 46, 12.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 41, 9.65, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 43, 46.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 48, 12.75, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 61, 28.50, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10815, 33, 2.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10816, 38, 263.50, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10816, 62, 49.30, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 26, 31.23, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 38, 263.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 40, 18.40, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 62, 49.30, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10818, 32, 32.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10818, 41, 9.65, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10819, 43, 46.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10819, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10820, 56, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10821, 35, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10821, 51, 53.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10822, 62, 49.30, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10822, 70, 15.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 11, 21.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 57, 19.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 59, 55.00, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 77, 13.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10824, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10824, 70, 15.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10825, 26, 31.23, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10825, 53, 32.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10826, 31, 12.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10826, 57, 19.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10827, 10, 31.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10827, 39, 18.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10828, 20, 81.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10828, 38, 263.50, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 2, 19.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 8, 40.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 60, 34.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 6, 25.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 39, 18.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 60, 34.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 68, 12.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 19, 9.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 35, 18.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 38, 263.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 43, 46.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 13, 6.00, 3, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 25, 14.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 44, 19.45, 16, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 64, 33.25, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10833, 7, 30.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10833, 31, 12.50, 9, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10833, 53, 32.80, 9, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10834, 29, 123.79, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10834, 30, 25.89, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10835, 59, 55.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10835, 77, 13.00, 2, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 22, 21.00, 52, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 35, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 57, 19.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 60, 34.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 64, 33.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 13, 6.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 40, 18.40, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 47, 9.50, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 76, 18.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10838, 1, 18.00, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10838, 18, 62.50, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10838, 36, 19.00, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10839, 58, 13.25, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10839, 72, 34.80, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10840, 25, 14.00, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10840, 39, 18.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 10, 31.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 56, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 59, 55.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 43, 46.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 70, 15.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10843, 51, 53.00, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10844, 22, 21.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 23, 9.00, 70, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 35, 18.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 42, 14.00, 42, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 58, 13.25, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 64, 33.25, 48, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10846, 4, 22.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10846, 70, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10846, 74, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 1, 18.00, 80, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 19, 9.20, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 37, 26.00, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 45, 9.50, 36, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 60, 34.00, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 71, 21.50, 55, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10848, 5, 21.35, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10848, 9, 97.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10849, 3, 10.00, 49, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10849, 26, 31.23, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10850, 25, 14.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10850, 33, 2.50, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10850, 70, 15.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 2, 19.00, 5, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 25, 14.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 57, 19.50, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 59, 55.00, 42, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10852, 2, 19.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10852, 17, 39.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10852, 62, 49.30, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10853, 18, 62.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10854, 10, 31.00, 100, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10854, 13, 6.00, 65, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 16, 17.45, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 31, 12.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 56, 38.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 65, 21.05, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10856, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10856, 42, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10857, 3, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10857, 26, 31.23, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10857, 29, 123.79, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10858, 7, 30.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10858, 27, 43.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10858, 70, 15.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10859, 24, 4.50, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10859, 54, 7.45, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10859, 64, 33.25, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10860, 51, 53.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10860, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 17, 39.00, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 18, 62.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 21, 10.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 33, 2.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 62, 49.30, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10862, 11, 21.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10862, 52, 7.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10863, 1, 18.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10863, 58, 13.25, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10864, 35, 18.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10864, 67, 14.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10865, 38, 263.50, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10865, 39, 18.00, 80, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10866, 2, 19.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10866, 24, 4.50, 6, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10866, 30, 25.89, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10867, 53, 32.80, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10868, 26, 31.23, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10868, 35, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10868, 49, 20.00, 42, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 1, 18.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 23, 9.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10870, 35, 18.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10870, 51, 53.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10871, 6, 25.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10871, 16, 17.45, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10871, 17, 39.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 55, 24.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 62, 49.30, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 64, 33.25, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 65, 21.05, 21, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10873, 21, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10873, 28, 45.60, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10874, 10, 31.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10875, 19, 9.20, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10875, 47, 9.50, 21, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10875, 49, 20.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10876, 46, 12.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10876, 64, 33.25, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10877, 16, 17.45, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10877, 18, 62.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10878, 20, 81.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10879, 40, 18.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10879, 65, 21.05, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10879, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10880, 23, 9.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10880, 61, 28.50, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10880, 70, 15.00, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10881, 73, 15.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10882, 42, 14.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10882, 49, 20.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10882, 54, 7.45, 32, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10883, 24, 4.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10884, 21, 10.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10884, 56, 38.00, 21, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10884, 65, 21.05, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 24, 4.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 70, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 77, 13.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10886, 10, 31.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10886, 31, 12.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10886, 77, 13.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10887, 25, 14.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10888, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10888, 68, 12.50, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10889, 11, 21.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10889, 38, 263.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10890, 17, 39.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10890, 34, 14.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10890, 41, 9.65, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10891, 30, 25.89, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10892, 59, 55.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 8, 40.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 24, 4.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 29, 123.79, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 30, 25.89, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 36, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10894, 13, 6.00, 28, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10894, 69, 36.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10894, 75, 7.75, 120, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 24, 4.50, 110, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 39, 18.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 40, 18.40, 91, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 60, 34.00, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10896, 45, 9.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10896, 56, 38.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10897, 29, 123.79, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10897, 30, 25.89, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10898, 13, 6.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10899, 39, 18.00, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10900, 70, 15.00, 3, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10901, 41, 9.65, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10901, 71, 21.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10902, 55, 24.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10902, 62, 49.30, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10903, 13, 6.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10903, 65, 21.05, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10903, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10904, 58, 13.25, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10904, 62, 49.30, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10905, 1, 18.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10906, 61, 28.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10907, 75, 7.75, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10908, 7, 30.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10908, 52, 7.00, 14, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10909, 7, 30.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10909, 16, 17.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10909, 41, 9.65, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10910, 19, 9.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10910, 49, 20.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10910, 61, 28.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10911, 1, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10911, 17, 39.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10911, 67, 14.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10912, 11, 21.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10912, 29, 123.79, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10913, 4, 22.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10913, 33, 2.50, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10913, 58, 13.25, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10914, 71, 21.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10915, 17, 39.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10915, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10915, 54, 7.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10916, 16, 17.45, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10916, 32, 32.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10916, 57, 19.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10917, 30, 25.89, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10917, 60, 34.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10918, 1, 18.00, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10918, 60, 34.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10919, 16, 17.45, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10919, 25, 14.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10919, 40, 18.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10920, 50, 16.25, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10921, 35, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10921, 63, 43.90, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10922, 17, 39.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10922, 24, 4.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10923, 42, 14.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10923, 43, 46.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10923, 67, 14.00, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10924, 10, 31.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10924, 28, 45.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10924, 75, 7.75, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10925, 36, 19.00, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10925, 52, 7.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 11, 21.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 19, 9.20, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 72, 34.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10927, 20, 81.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10927, 52, 7.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10927, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10928, 47, 9.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10928, 76, 18.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10929, 21, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10929, 75, 7.75, 49, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10929, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 21, 10.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 27, 43.90, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 55, 24.00, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 58, 13.25, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10931, 13, 6.00, 42, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10931, 57, 19.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 16, 17.45, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 62, 49.30, 14, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 72, 34.80, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 75, 7.75, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10933, 53, 32.80, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10933, 61, 28.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10934, 6, 25.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10935, 1, 18.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10935, 18, 62.50, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10935, 23, 9.00, 8, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10936, 36, 19.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10937, 28, 45.60, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10937, 34, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 13, 6.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 43, 46.00, 24, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 60, 34.00, 49, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 71, 21.50, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10939, 2, 19.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10939, 67, 14.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10940, 7, 30.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10940, 13, 6.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 31, 12.50, 44, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 62, 49.30, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 68, 12.50, 80, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 72, 34.80, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10942, 49, 20.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10943, 13, 6.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10943, 22, 21.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10943, 46, 12.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10944, 11, 21.00, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10944, 44, 19.45, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10944, 56, 38.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10945, 13, 6.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10945, 31, 12.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10946, 10, 31.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10946, 24, 4.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10946, 77, 13.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10947, 59, 55.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10948, 50, 16.25, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10948, 51, 53.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10948, 55, 24.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 6, 25.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 10, 31.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 17, 39.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 62, 49.30, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10950, 4, 22.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10951, 33, 2.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10951, 41, 9.65, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10951, 75, 7.75, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10952, 6, 25.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10952, 28, 45.60, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10953, 20, 81.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10953, 31, 12.50, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 16, 17.45, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 31, 12.50, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 45, 9.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 60, 34.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10955, 75, 7.75, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10956, 21, 10.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10956, 47, 9.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10956, 51, 53.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10957, 30, 25.89, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10957, 35, 18.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10957, 64, 33.25, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10958, 5, 21.35, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10958, 7, 30.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10958, 72, 34.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10959, 75, 7.75, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10960, 24, 4.50, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10960, 41, 9.65, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10961, 52, 7.00, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10961, 76, 18.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 7, 30.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 13, 6.00, 77, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 53, 32.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 69, 36.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 76, 18.00, 44, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10963, 60, 34.00, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10964, 18, 62.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10964, 38, 263.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10964, 69, 36.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10965, 51, 53.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10966, 37, 26.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10966, 56, 38.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10966, 62, 49.30, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10967, 19, 9.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10967, 49, 20.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10968, 12, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10968, 24, 4.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10968, 64, 33.25, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10969, 46, 12.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10970, 52, 7.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10971, 29, 123.79, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10972, 17, 39.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10972, 33, 2.50, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10973, 26, 31.23, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10973, 41, 9.65, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10973, 75, 7.75, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10974, 63, 43.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10975, 8, 40.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10975, 75, 7.75, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10976, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 39, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 47, 9.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 51, 53.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 63, 43.90, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 8, 40.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 21, 10.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 40, 18.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 44, 19.45, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 7, 30.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 12, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 24, 4.50, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 27, 43.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 31, 12.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 63, 43.90, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10980, 75, 7.75, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10981, 38, 263.50, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10982, 7, 30.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10982, 43, 46.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10983, 13, 6.00, 84, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10983, 57, 19.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10984, 16, 17.45, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10984, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10984, 36, 19.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10985, 16, 17.45, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10985, 18, 62.50, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10985, 32, 32.00, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 11, 21.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 20, 81.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10987, 7, 30.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10987, 43, 46.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10987, 72, 34.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10988, 7, 30.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10988, 62, 49.30, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10989, 6, 25.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10989, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10989, 41, 9.65, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 21, 10.00, 65, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 34, 14.00, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 55, 24.00, 65, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 61, 28.50, 66, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10991, 2, 19.00, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10991, 70, 15.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10991, 76, 18.00, 90, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10992, 72, 34.80, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10993, 29, 123.79, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10993, 41, 9.65, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10994, 59, 55.00, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10995, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10995, 60, 34.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10996, 42, 14.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10997, 32, 32.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10997, 46, 12.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10997, 52, 7.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 24, 4.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 61, 28.50, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 74, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 75, 7.75, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10999, 41, 9.65, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10999, 51, 53.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10999, 77, 13.00, 21, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11000, 4, 22.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11000, 24, 4.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11000, 77, 13.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 7, 30.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 22, 21.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 46, 12.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 55, 24.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 13, 6.00, 56, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 35, 18.00, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 42, 14.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 55, 24.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11003, 1, 18.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11003, 40, 18.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11003, 52, 7.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11004, 26, 31.23, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11004, 76, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11005, 1, 18.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11005, 59, 55.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11006, 1, 18.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11006, 29, 123.79, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11007, 8, 40.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11007, 29, 123.79, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11007, 42, 14.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11008, 28, 45.60, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11008, 34, 14.00, 90, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11008, 71, 21.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11009, 24, 4.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11009, 36, 19.00, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11009, 60, 34.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11010, 7, 30.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11010, 24, 4.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11011, 58, 13.25, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11011, 71, 21.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11012, 19, 9.20, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11012, 60, 34.00, 36, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11012, 71, 21.50, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 23, 9.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 42, 14.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 45, 9.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 68, 12.50, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11014, 41, 9.65, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11015, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11015, 77, 13.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11016, 31, 12.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11016, 36, 19.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11017, 3, 10.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11017, 59, 55.00, 110, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11017, 70, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11018, 12, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11018, 18, 62.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11018, 56, 38.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11019, 46, 12.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11019, 49, 20.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11020, 10, 31.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 2, 19.00, 11, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 20, 81.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 26, 31.23, 63, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 51, 53.00, 44, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 72, 34.80, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11022, 19, 9.20, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11022, 69, 36.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11023, 7, 30.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11023, 43, 46.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 26, 31.23, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 65, 21.05, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 71, 21.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11025, 1, 18.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11025, 13, 6.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11026, 18, 62.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11026, 51, 53.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11027, 24, 4.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11027, 62, 49.30, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11028, 55, 24.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11028, 59, 55.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11029, 56, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11029, 63, 43.90, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 2, 19.00, 100, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 5, 21.35, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 29, 123.79, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 59, 55.00, 100, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 1, 18.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 13, 6.00, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 24, 4.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 64, 33.25, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 71, 21.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11032, 36, 19.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11032, 38, 263.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11032, 59, 55.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11033, 53, 32.80, 70, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11033, 69, 36.00, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11034, 21, 10.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11034, 44, 19.45, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11034, 61, 28.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 1, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 35, 18.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 42, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 54, 7.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11036, 13, 6.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11036, 59, 55.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11037, 70, 15.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11038, 40, 18.40, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11038, 52, 7.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11038, 71, 21.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 35, 18.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 49, 20.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 57, 19.50, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11040, 21, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11041, 2, 19.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11041, 63, 43.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11042, 44, 19.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11042, 61, 28.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11043, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11044, 62, 49.30, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11045, 33, 2.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11045, 51, 53.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11046, 12, 38.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11046, 32, 32.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11046, 35, 18.00, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11047, 1, 18.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11047, 5, 21.35, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11048, 68, 12.50, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11049, 2, 19.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11049, 12, 38.00, 4, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11050, 76, 18.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11051, 24, 4.50, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11052, 43, 46.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11052, 61, 28.50, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11053, 18, 62.50, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11053, 32, 32.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11053, 64, 33.25, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11054, 33, 2.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11054, 67, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 24, 4.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 25, 14.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 57, 19.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11056, 7, 30.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11056, 55, 24.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11056, 60, 34.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11057, 70, 15.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11058, 21, 10.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11058, 60, 34.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11058, 61, 28.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11059, 13, 6.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11059, 17, 39.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11059, 60, 34.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11060, 60, 34.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11060, 77, 13.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11061, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11062, 53, 32.80, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11062, 70, 15.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11063, 34, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11063, 40, 18.40, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11063, 41, 9.65, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 17, 39.00, 77, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 53, 32.80, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 55, 24.00, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 68, 12.50, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11065, 30, 25.89, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11065, 54, 7.45, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11066, 16, 17.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11066, 19, 9.20, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11066, 34, 14.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11067, 41, 9.65, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11068, 28, 45.60, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11068, 43, 46.00, 36, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11068, 77, 13.00, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11069, 39, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 1, 18.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 2, 19.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 16, 17.45, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11071, 7, 30.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11071, 13, 6.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 2, 19.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 41, 9.65, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 50, 16.25, 22, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 64, 33.25, 130, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11073, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11073, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11074, 16, 17.45, 14, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11075, 2, 19.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11075, 46, 12.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11075, 76, 18.00, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11076, 6, 25.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11076, 14, 23.25, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11076, 19, 9.20, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 2, 19.00, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 3, 10.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 4, 22.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 6, 25.00, 1, 0.02);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 7, 30.00, 1, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 8, 40.00, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 10, 31.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 12, 38.00, 2, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 13, 6.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 14, 23.25, 1, 0.03);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 16, 17.45, 2, 0.03);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 20, 81.00, 1, 0.04);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 23, 9.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 32, 32.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 39, 18.00, 2, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 41, 9.65, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 46, 12.00, 3, 0.02);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 52, 7.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 55, 24.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 60, 34.00, 2, 0.06);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 64, 33.25, 2, 0.03);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 66, 17.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 73, 15.00, 2, 0.01);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 75, 7.75, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 77, 13.00, 2, 0);

-- Populate table Stats.Tests
INSERT INTO Stats.Tests(testid) VALUES ('Test ABC');
INSERT INTO Stats.Tests(testid) VALUES ('Test XYZ');

-- Populate table Stats.Scores
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student A', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student B', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student C', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student D', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student E', 50);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student F', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student G', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student H', 65);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student I', 75);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student A', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student B', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student C', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student D', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student E', 50);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student F', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student G', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student H', 65);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student I', 75);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student J', 95);
GO

-- Create and Populate table dbo.Nums
CREATE TABLE dbo.Nums(n INT NOT NULL CONSTRAINT PK_Nums PRIMARY KEY);

DECLARE @max AS INT, @rc AS INT;
SET @max = 100000;
SET @rc = 1;

INSERT INTO dbo.Nums VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO

SET NOCOUNT OFF;
GO

---------------------------------------------------------------------
-- Create Views and Functions
---------------------------------------------------------------------

CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
            FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO
