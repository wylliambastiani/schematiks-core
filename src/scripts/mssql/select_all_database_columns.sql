
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
FROM {DatabaseName}.sys.tables AS TAB
	INNER JOIN {DatabaseName}.sys.columns AS COL ON COL.[object_id] = TAB.[object_id]
	INNER JOIN {DatabaseName}.sys.types AS TP ON TP.[user_type_id] = COL.[user_type_id]
	LEFT JOIN {DatabaseName}.sys.identity_columns as IC ON IC.[object_id] = TAB.[object_id]
WHERE
	TAB.[type] = N'U'
ORDER BY
	TAB.[object_id] ASC
	,COL.[column_id] ASC;