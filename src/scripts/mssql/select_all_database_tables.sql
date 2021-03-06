
SELECT
	TAB.[object_id] AS [table_id]
	,TAB.[name] AS [table_name]
	,TAB.[create_date] AS [table_create_date]
	,TAB.[modify_date] AS [table_modify_date]
	,SCH.[schema_id] AS [schema_id]
	,(SELECT CASE WHEN PRT.rows = 0 THEN 0 ELSE 1 END FROM sys.partitions AS PRT WHERE PRT.object_id = TAB.object_id AND PRT.index_id IN (0, 1)) AS hasData
FROM {DatabaseName}.sys.tables AS TAB
	INNER JOIN {DatabaseName}.sys.schemas AS SCH ON SCH.[schema_id] = TAB.[schema_id];