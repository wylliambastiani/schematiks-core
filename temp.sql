
USE TSQL2012;
GO

SELECT 
    *
FROM Sales.OrderDetails




SELECT
	COL.[column_id] AS [column_id]
	,COL.[name] AS [column_name]
	,TP.[name] AS [column_type]
	,COL.[max_length] AS [column_max_length]
	,COL.[precision] AS [column_precision]
	,COL.[scale] AS [column_scale]
	,COL.[collation_name] AS [column_collation_name]
	,COL.[is_nullable] AS [columns_is_nullable]
	,COL.[is_identity] AS [column_is_identity]
	,IC.[seed_value] AS [column_identity_seed_value]
	,IC.[increment_value] AS [column_identity_increment_value]
	,COL.[is_computed] AS [column_is_computed]
	,TAB.[object_id] AS [table_id]
FROM TSQL2012.sys.tables AS TAB
	INNER JOIN TSQL2012.sys.columns AS COL ON COL.[object_id] = TAB.[object_id]
	INNER JOIN TSQL2012.sys.types AS TP ON TP.[user_type_id] = COL.[user_type_id]
	LEFT JOIN TSQL2012.sys.identity_columns as IC ON IC.[object_id] = TAB.[object_id]
WHERE
	TAB.[type] = N'U'
ORDER BY
	TAB.[object_id] ASC
	,COL.[column_id] ASC;

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

-- SELECT ', [' + c.name + '] ' + CASE WHEN ic.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END
-- FROM sys.index_columns ic WITH (NOWAIT)
--     JOIN sys.columns c WITH (NOWAIT) ON c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
-- WHERE ic.is_included_column = 0
--     AND ic.[object_id] = k.parent_object_id 
--     AND ic.index_id = k.unique_index_id     