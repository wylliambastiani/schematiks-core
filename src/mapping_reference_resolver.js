'use strict';

require('rootpath')();

const ConstraintTypes = require('src/models/constraint_types');

function MappingReferenceResolver() {
  this.resolveReferences = function (map) {
    this.resolveSchemaTableReferences(map.schemas, map.tables);
    this.resolveTableColumnReferences(map.tables, map.columns);
    this.resolvePrimaryKeyReferences(map.tables, map.constraints);
    this.resolveForeignKeyReferences(map.tables, map.constraints);
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
    for (let primaryKey of primaryKeys) {
      let parentTable = tables.filter(table => { return table.id === primaryKey.sourceTarget.tableId; })[0];

      if (parentTable === null || parentTable === undefined)
        continue;

      primaryKey.sourceTarget.table = parentTable;
      parentTable.constraints.push(primaryKey);
    }
  }

  this.resolveForeignKeyReferences = function (tables, constraints) {
    if ((!tables || tables.length === 0) || (!constraints || constraints.length === 0))
      return;

    let foreignKeys = constraints.filter(constraint => { return constraint.type === ConstraintTypes.FK; });
    for (let foreignKey of foreignKeys) {
      let parentTable = tables.filter(table => { return table.id === foreignKey.sourceTarget.tableId; })[0];
      let referencedTable = tables.filter(table => { return table.id === foreignKey.destinationTarget.tableId; })[0];

      if (parentTable === null || parentTable === undefined)
        continue;

      foreignKey.sourceTarget.table = parentTable;
      foreignKey.destinationTarget.table = referencedTable;
      parentTable.constraints.push(foreignKey);
    }
  }
}

module.exports = MappingReferenceResolver;