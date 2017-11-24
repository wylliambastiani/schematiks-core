SELECT
	FK.object_id AS [constraint_id]
	,FK.name AS [constraint_name]
	,FK.[type] AS [constraint_type]
	,FK.parent_object_id AS [parent_table_id]
	,FKC.parent_column_id AS [parent_column_id]
	,FK.referenced_object_id AS [referenced_object_id]
	,FKC.referenced_column_id AS [referenced_column_id]
FROM sys.foreign_keys AS FK
	INNER JOIN sys.foreign_key_columns AS FKC ON FKC.constraint_object_id = FK.object_id;
