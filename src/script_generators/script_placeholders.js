'use strict';

const placeholders = {
    'DatabaseName': '{DatabaseName}',
    'SchemaName': '{SchemaName}',
    'TableName': '{TableName}',
    'ColumnName': '{ColumnName}',
    'ColumnType': '{ColumnType}',
    'IsNullable': '{IsNullable}',
    'PrecisionAndScale': '{PrecisionAndScale}',
    'Collate': '{Collate}',
    'ColumnMaxLength': '{ColumnMaxLength}',
    'CreateTableBodyContent': '{CreateTableBodyContent}',
    'ConstraintName': '{ConstraintName}',
    'ConstraintColumns': '{ConstraintColumns}',
    'ConstraintParentColumns': '{ConstraintParentColumns}',
    'ConstraintReferencedTable': '{ConstraintReferencedTable}',
    'ConstraintReferencedColumns': '{ConstraintReferencedColumns}'
};

module.exports = Object.freeze(placeholders);