'use strict';

function MappingReferenceResolver() {
    this.resolveReferences = function(map) {
        this.resolveSchemaTableReferences(map.schemas, map.tables);
        this.resolveTableColumnReferences(map.tables, map.columns);
    }

    this.resolveSchemaTableReferences = function (schemas, tables) {
        if ((!schemas || schemas.length === 0) || (!tables || tables.length === 0))
            return;

        for (let schema of schemas) {
            let tablesInSchema = tables.filter(table => { return table.schemaId === schema.id });

            for (let tableInSchema of tablesInSchema) {
                tableInSchema.schema = schema;
            }

            schema.tables.push(...tablesInSchema);
        }
    }

    this.resolveTableColumnReferences = function (tables, columns) {
        if ((!tables || tables.length === 0) || (!columns || columns.length === 0))
            return;

        for (let table of tables) {
            let columnsInTable = columns.filter(column => { return column.tableId === table.id; });

            for (let columnInTable of columnsInTable) {
                columnInTable.table = table;
            }

            table.columns.push(...columnsInTable);
        }
    }
}

module.exports = MappingReferenceResolver;