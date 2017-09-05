
SELECT DISTINCT
	SCH.[schema_id] AS [schema_id]
	,SCH.[name] AS [schema_name]
FROM {DatabaseName}.sys.tables AS TAB
	INNER JOIN {DatabaseName}.sys.schemas AS SCH ON SCH.[schema_id] = TAB.[schema_id];