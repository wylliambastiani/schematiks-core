
SELECT 
	KC.[object_id] AS [constraint_id]
	,KC.[name] AS [constraint_name]
	,TAB.[object_id] AS [table_id]
	,COL.[column_id] AS [column_id]
	,IC.[is_descending_key] AS [is_descending_key]
	,KC.[type] AS [constraint_type]
FROM {DatabaseName}.sys.tables AS TAB
    INNER JOIN {DatabaseName}.sys.columns AS COL ON COL.[object_id] = TAB.[object_id]
	INNER JOIN {DatabaseName}.sys.index_columns AS IC ON IC.[object_id] = TAB.[object_id] AND IC.column_id = COL.[column_id]
	INNER JOIN {DatabaseName}.sys.key_constraints AS KC ON KC.[parent_object_id] = TAB.[object_id] AND KC.[unique_index_id] = IC.index_id
WHERE
    TAB.[type] = N'U'
	AND KC.[type] = N'PK';