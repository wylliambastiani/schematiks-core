
USE TSQL2012;
GO

SELECT 
    *
FROM Sales.OrderDetails






SELECT * FROM sys.index_columns  WHERE object_id = 901578250
SELECT * FROM sys.indexes WHERE object_id = 901578250
SELECT * FROM sys.key_constraints WHERE parent_object_id = 901578250

SELECT * FROM sys.objects AS A WHERE A.object_id = 917578307

SELECT 
	KC.[object_id] AS [constraint_id]
	,KC.[name] AS [constraint_name]
	,TAB.[object_id] AS [table_id]
	,COL.[column_id] AS [column_id]
	,IC.is_descending_key AS [is_descending_key]
	,KC.[type] AS [type]
FROM sys.tables AS TAB
    INNER JOIN sys.columns AS COL ON COL.[object_id] = TAB.[object_id]
	INNER JOIN sys.index_columns AS IC ON IC.[object_id] = TAB.[object_id] AND IC.column_id = COL.[column_id]
	INNER JOIN sys.key_constraints AS KC ON KC.[parent_object_id] = TAB.[object_id] AND KC.[unique_index_id] = IC.index_id
WHERE
    TAB.[type] = N'U'
	AND KC.[type] = N'PK'


SELECT
	FK.object_id AS [constraint_id]
	,FK.name AS [constraint_name]
	,FK.parent_object_id AS [parent_table_id]
	,FKC.parent_column_id AS [parent_column_id]
	,FK.referenced_object_id AS [referenced_object_id]
	,FKC.referenced_column_id AS [referenced_column_id]
FROM sys.foreign_keys AS FK
	INNER JOIN sys.foreign_key_columns AS FKC ON FKC.constraint_object_id = FK.object_id;

SELECT *
FROM sys.foreign_key_columns 

SELECT *
FROM sys.foreign_keys 

drop table TestCompoundFK1;
drop table TestCompoundFK2;

CREATE TABLE dbo.TestCompoundFK1
(
	id int,
	otoid int,
	CONSTRAINT PKFK12 PRIMARY KEY (id, otoid)
)


CREATE TABLE dbo.TestCompoundFK2
(
	id int,
	otoid int,
	FOREIGN KEY (id, otoid) REFERENCES TestCompoundFK1(id, otoid)
)

SELECT * FROM sys.objects WHERE object_id = 194099732