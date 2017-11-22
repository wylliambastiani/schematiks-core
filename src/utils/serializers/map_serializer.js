'use strict';

require('rootpath')();

const DatabaseMap = require('src/models/database_map');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');
const Constraint = require('src/models/constraint');
const ConstraintTarget = require('src/models/constraint_target');
const ConstraintColumn = require('src/models/constraint_column');
const MappingReferenceResolver = require('src/mapping_reference_resolver');

function MapSerializer() {
    this.serialize = function(map) {
        if (map === null || map === undefined) {
            throw new Error(`Map cannot be ${map}`);
        }

        for (let table of map.tables) {
            table.schema = null;
        }

        for (let column of map.columns) {
            column.table = null;
        }

        for (let constraint of map.constraints) {
            if (constraint.sourceTarget)
                constraint.sourceTarget.table = null;

            if (constraint.destinationTarget)
                constraint.destinationTarget.table = null;
        }

        return JSON.stringify(map);
    }

    this.deserialize = function(json) {
        if (json === null || json === undefined) {
            throw new Error(`Json cannot be ${json}`);
        }

        let deserializedMap = JSON.parse(json);
        
        let recreatedMap = new DatabaseMap();
        recreatedMap.databaseName = deserializedMap.databaseName;
        recreatedMap.databaseType = deserializedMap.databaseType;
        recreatedMap.schemas = deserializedMap.schemas.map(schema => { return new Schema(schema.id, schema.name); });
        recreatedMap.tables = deserializedMap.tables.map(table => { 
            return new Table(table.id, 
                table.name, 
                new Date(new Date(table.createDate).toISOString()),
                new Date(new Date(table.modifyDate).toISOString()), 
                table.schemaId, 
                table.hasData
            );
        });

        recreatedMap.columns = deserializedMap.columns.map(column => {
            return new Column(column.id, 
                column.name, 
                column.type, 
                column.typeMaxLength, 
                column.typePrecision,
                column.typeScale, 
                column.collationName, 
                column.isNullable, 
                column.isIdentity, 
                column.identitySeedValue,
                column.identityIncrementValue, 
                column.isComputed, 
                column.tableId
            );
        });

        recreatedMap.constraints = deserializedMap.constraints.map(constraint => {
            let recreatedConstraint = new Constraint(
                constraint.id,
                constraint.name,
                constraint.type,
                null,
                null
            );

            if (constraint.sourceTarget) {
                let constraintColumns = constraint.sourceTarget.constraintColumns.map(constraintColumn => {
                    return new ConstraintColumn(constraintColumn.columnId, constraintColumn.is_descending_key);
                });

                recreatedConstraint.sourceTarget = new ConstraintTarget(constraint.sourceTarget.tableId, constraintColumns);
            }

            if (constraint.destinationTarget) {
                let constraintColumns = constraint.destinationTarget.constraintColumns.map(constraintColumn => {
                    return new ConstraintColumn(constraintColumn.columnId, constraintColumn.is_descending_key);
                });

                recreatedConstraint.destinationTarget = new ConstraintTarget(constraint.sourceTarget.tableId, constraintColumns);
            }

            return recreatedConstraint;
        });

        let referenceResolver = new MappingReferenceResolver();
        referenceResolver.resolveReferences(recreatedMap);

        return recreatedMap;
    }
};

module.exports = MapSerializer;