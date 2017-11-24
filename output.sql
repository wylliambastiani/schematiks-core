
USE TSQL2012;
GO

CREATE SCHEMA dbo;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Production;
GO

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Stats;
GO

CREATE TABLE HR.Employees
(
	[empid] INT NOT NULL IDENTITY(1, 1)
	,[lastname] NVARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[firstname] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[title] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[titleofcourtesy] NVARCHAR(25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[birthdate] DATETIME NOT NULL
	,[hiredate] DATETIME NOT NULL
	,[address] NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[city] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[region] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[postalcode] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[country] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[phone] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[mgrid] INT NULL
	,CONSTRAINT [PK_Employees] PRIMARY KEY([empid] ASC)
);
GO

CREATE TABLE Production.Suppliers
(
	[supplierid] INT NOT NULL IDENTITY(1, 1)
	,[companyname] NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[contactname] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[contacttitle] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[address] NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[city] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[region] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[postalcode] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[country] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[phone] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[fax] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,CONSTRAINT [PK_Suppliers] PRIMARY KEY([supplierid] ASC)
);
GO

CREATE TABLE Production.Categories
(
	[categoryid] INT NOT NULL IDENTITY(1, 1)
	,[categoryname] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[description] NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,CONSTRAINT [PK_Categories] PRIMARY KEY([categoryid] ASC)
);
GO

CREATE TABLE Production.Products
(
	[productid] INT NOT NULL IDENTITY(1, 1)
	,[productname] NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[supplierid] INT NOT NULL
	,[categoryid] INT NOT NULL
	,[unitprice] MONEY NOT NULL
	,[discontinued] BIT NOT NULL
	,CONSTRAINT [PK_Products] PRIMARY KEY([productid] ASC)
);
GO

CREATE TABLE Sales.Customers
(
	[custid] INT NOT NULL IDENTITY(1, 1)
	,[companyname] NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[contactname] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[contacttitle] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[address] NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[city] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[region] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[postalcode] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[country] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[phone] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[fax] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,CONSTRAINT [PK_Customers] PRIMARY KEY([custid] ASC)
);
GO

CREATE TABLE Sales.Shippers
(
	[shipperid] INT NOT NULL IDENTITY(1, 1)
	,[companyname] NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[phone] NVARCHAR(24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,CONSTRAINT [PK_Shippers] PRIMARY KEY([shipperid] ASC)
);
GO

CREATE TABLE Sales.Orders
(
	[orderid] INT NOT NULL IDENTITY(1, 1)
	,[custid] INT NULL
	,[empid] INT NOT NULL
	,[orderdate] DATETIME NOT NULL
	,[requireddate] DATETIME NOT NULL
	,[shippeddate] DATETIME NULL
	,[shipperid] INT NOT NULL
	,[freight] MONEY NOT NULL
	,[shipname] NVARCHAR(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[shipaddress] NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[shipcity] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[shipregion] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[shippostalcode] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,[shipcountry] NVARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,CONSTRAINT [PK_Orders] PRIMARY KEY([orderid] ASC)
);
GO

CREATE TABLE Sales.OrderDetails
(
	[orderid] INT NOT NULL
	,[productid] INT NOT NULL
	,[unitprice] MONEY NOT NULL
	,[qty] SMALLINT NOT NULL
	,[discount] NUMERIC(4,3) NOT NULL
	,CONSTRAINT [PK_OrderDetails] PRIMARY KEY([orderid] ASC, [productid] ASC)
);
GO

CREATE TABLE Stats.Tests
(
	[testid] VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,CONSTRAINT [PK_Tests] PRIMARY KEY([testid] ASC)
);
GO

CREATE TABLE Stats.Scores
(
	[testid] VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[studentid] VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,[score] TINYINT NOT NULL
	,CONSTRAINT [PK_Scores] PRIMARY KEY([testid] ASC, [studentid] ASC)
);
GO

CREATE TABLE dbo.Nums
(
	[n] INT NOT NULL
	,CONSTRAINT [PK_Nums] PRIMARY KEY([n] ASC)
);
GO
