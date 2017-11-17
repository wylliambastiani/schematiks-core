'use strict';

const ConstraintTypes = require('src/models/constraint_types');

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

    this.resolvePrimaryKeyReferences = function (tables, constraints) {
        if ((!tables || tables.length === 0) || (!constraints || constraints.length === 0))
            return;

        let primaryKeys = constraints.filter(constraint => { return constraint.type === ConstraintTypes.PK; });
        for (let primaryKey of constraints) {
            let parentTable = tables.filter(table => { return table.id === primaryKey.sourceTarget.tableId; })[0];

            if (parentTable === null || parentTable === undefined)
                continue;

            primaryKey.sourceTarget.table = parentTable;
            parentTable.constraints.push(primaryKey);
        }
    }
}

module.exports = MappingReferenceResolver;