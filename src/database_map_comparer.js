'use strict';

require('rootpath')();

const DatabaseMap = require('src/models/database_map');
const DatabaseMapDiff = require('src/models/database_map_diff');
const DatabaseObjectDiff = require('src/models/database_object_diff');
const DatabaseObjectDiffState = require('src/models/database_object_diff_state');

function DatabaseMapComparer (previousDatabaseMap, currentDatabaseMap) {
    let self = this;
    let _previousDatabaseMap = previousDatabaseMap || new DatabaseMap();
    let _currentDatabaseMap = currentDatabaseMap || new DatabaseMap();
    this.databaseMapDiff = new DatabaseMapDiff(_previousDatabaseMap, _currentDatabaseMap);

    function getSchemasNames (schemas) {
        if (schemas === undefined || schemas === null)
            return [];

        return schemas.map(schema => {
            return schema.name;
        });
    }

    function getTablesFullNames (tables) {
        if (tables === undefined || tables === null)
            return [];

        return tables.map(table => {
            return table.fullName;
        });
    }

    function getColumnsNames (table) {
        if (table === undefined || table === null)
            return [];

        return table.columns.map(column => {
            return column.name;
        });
    }

    function getDeletedSchemas () {
        let previousSchemas = _previousDatabaseMap.schemas;
        let currentSchemas = _currentDatabaseMap.schemas;

        let previousSchemasNames = getSchemasNames(previousSchemas);
        let currentSchemasNames = getSchemasNames(currentSchemas);

        let deletedSchemasNames = previousSchemasNames.filter(schemaName => {
            return currentSchemasNames.indexOf(schemaName) < 0;
        });

        let deletedSchemas = previousSchemas.filter(schema => {
            return deletedSchemasNames.indexOf(schema.name) >= 0;
        });

        let deletedSchemasDiff = deletedSchemas.map(schema => {
            return new DatabaseObjectDiff(schema, null, DatabaseObjectDiffState.DELETED);
        });

        return deletedSchemasDiff;
    }

    function getCreatedSchemas () {
        let previousSchemas = _previousDatabaseMap.schemas;
        let currentSchemas = _currentDatabaseMap.schemas;

        let previousSchemasNames = getSchemasNames(previousSchemas);
        let currentSchemasNames = getSchemasNames(currentSchemas);

        let createdSchemasNames = currentSchemasNames.filter(schemaName => {
            return previousSchemasNames.indexOf(schemaName) < 0;
        });

        let createdSchemas = currentSchemas.filter(schema => {
            return createdSchemasNames.indexOf(schema.name) >= 0;
        });

        let createdSchemasDiff = createdSchemas.map(schema => {
            return new DatabaseObjectDiff(null, schema, DatabaseObjectDiffState.CREATED);
        });

        return createdSchemasDiff;
    }

    function compareSchemas () {
        if (_previousDatabaseMap.schemas.length === 0 && _currentDatabaseMap.schemas.length === 0)
            return;

        let deletedSchemasDiff = getDeletedSchemas();
        let createdSchemasDiff = getCreatedSchemas();

        self.databaseMapDiff.schemasDiff.push(...deletedSchemasDiff);
        self.databaseMapDiff.schemasDiff.push(...createdSchemasDiff);
    }

    function getDeletedTables () {
        let previousTables = _previousDatabaseMap.tables;
        let currentTables = _currentDatabaseMap.tables;
        
        let previousTablesNames = getTablesFullNames(previousTables);
        let currentTablesNames = getTablesFullNames(currentTables);

        let deletedTablesNames = previousTablesNames.filter(tableName => {
            return currentTablesNames.indexOf(tableName) < 0;
        });

        let deletedTables = _previousDatabaseMap.tables.filter(table => {
            return deletedTablesNames.indexOf(table.fullName) >= 0;
        });

        let deletedTablesDiff = deletedTables.map(deletedTable => {
            return new DatabaseObjectDiff(deletedTable, null, DatabaseObjectDiffState.DELETED);
        });

        return deletedTablesDiff;
    }

    function getCreatedTables () {
        let previousTables = _previousDatabaseMap.tables;
        let currentTables = _currentDatabaseMap.tables;

        let previousTablesNames = getTablesFullNames(previousTables);
        let currentTablesNames = getTablesFullNames(currentTables);

        let createdTablesNames = currentTablesNames.filter(tableName => {
            return previousTablesNames.indexOf(tableName) < 0;
        });

        let createdTables = currentTables.filter(table => {
            return createdTablesNames.indexOf(table.fullName) >= 0;
        });

        let createdTablesDiff = createdTables.map(table => {
            return new DatabaseObjectDiff(null, table, DatabaseObjectDiffState.CREATED);
        });

        return createdTablesDiff;
    }

    function getAlteredTables() {
        let previousTables = _previousDatabaseMap.tables;
        let currentTables = _currentDatabaseMap.tables;

        let previousTablesFullNames = getTablesFullNames(previousTables);
        let currentTablesFullNames = getTablesFullNames(currentTables);

        let tablesFullNamesInBothMaps = previousTablesFullNames.filter(tableName => {
            return currentTablesFullNames.indexOf(tableName) >= 0;
        });

        let tablesInBothMaps = tablesFullNamesInBothMaps.map(tableFullName => {
            let previousTableVersion = previousTables.filter(table => {
                return table.fullName === tableFullName;
            });

            let currentTableVersion = currentTables.filter(table => {
                return table.fullName === tableFullName;
            });

            return { previousTableVersion: previousTableVersion[0], currentTableVersion: currentTableVersion[0] };
        });
        
        return tablesInBothMaps.filter(tables => {
            return tables.previousTableVersion.modifyDate.getTime() !== tables.currentTableVersion.modifyDate.getTime();
        }).map(tables => {
            return new DatabaseObjectDiff(tables.previousTableVersion, tables.currentTableVersion, DatabaseObjectDiffState.ALTERED);
        });
    }

    function getDeletedColumns(alteredTablesDiffs) {
        if (alteredTablesDiffs.length === 0)
            return [];

        let diffs = [];

        for (let tableDiff of alteredTablesDiffs) {
            let previousColumnsNames = getColumnsNames(tableDiff.previousObjectVersion);
            let currentColumnsNames = getColumnsNames(tableDiff.currentObjectVersion);
            
            let deletedColumnsNames = previousColumnsNames.filter(columnName => {
                return currentColumnsNames.indexOf(columnName) < 0;
            });

            let deletedColumns = tableDiff.previousObjectVersion.columns.filter(column => {
                return deletedColumnsNames.indexOf(column.name) >= 0;
            });

            let deletedColumnsDiffs = deletedColumns.map(deletedColumn => {
                return new DatabaseObjectDiff(deletedColumn, null, DatabaseObjectDiffState.DELETED);
            });

            diffs.push(...deletedColumnsDiffs);
        }

        return diffs;
    }

    function getCreatedColumns(alteredTablesDiff) {
        if (alteredTablesDiff.length === 0)
            return [];

        let diffs = [];

        for (let tableDiff of alteredTablesDiff) {
            let previousColumnsNames = getColumnsNames(tableDiff.previousObjectVersion);
            let currentColumnsNames = getColumnsNames(tableDiff.currentObjectVersion);
 
            let createdColumnsNames = currentColumnsNames.filter(columnName => {
                return previousColumnsNames.indexOf(columnName) < 0;
            });

            let createdColumns = tableDiff.currentObjectVersion.columns.filter(column => {
                return createdColumnsNames.indexOf(column.name) >= 0;
            })

            let createdColumnsDiffs = createdColumns.map(column => {
                return new DatabaseObjectDiff(null, column, DatabaseObjectDiffState.CREATED);
            });

            diffs.push(...createdColumnsDiffs);
       }

        return diffs;
    }

    function getColumnsDifferences(previousColumn, currentColumn) {
        const modifiableColumnProperties = [
            'type', 
            'typeMaxLength', 
            'typePrecision',
            'typeScale',
            'collationName',
            'isNullable',
            'isIdentity',
            'identityIncrementValue'
        ];

        let differences = [];

        for (let property of modifiableColumnProperties) {
            let previousPropertyValue = previousColumn[property];
            let currentPropertyValue = currentColumn[property];
        
            if (previousPropertyValue != currentPropertyValue)
                differences.push(property);
        }

        return differences;
    }

    function getAlteredColumns(alteredTablesDiff) {
        if (alteredTablesDiff.length === 0)
            return [];

        let diffs = [];

        for (let tableDiff of alteredTablesDiff) {
            let previousColumnsNames = getColumnsNames(tableDiff.previousObjectVersion);
            let currentColumnsNames = getColumnsNames(tableDiff.currentObjectVersion);

            let columnsNamesInBothTables = previousColumnsNames.filter(columnName => {
                return currentColumnsNames.indexOf(columnName) >= 0;
            });

            let columnsDiff = columnsNamesInBothTables.map(columnName => {
                let previousColumnVersion = tableDiff.previousObjectVersion.columns.filter(column => {
                    return column.name === columnName;
                });

                let currentColumnVersion = tableDiff.currentObjectVersion.columns.filter(column => {
                    return column.name === columnName;
                });

                let columnsDifferences = getColumnsDifferences(previousColumnVersion[0], currentColumnVersion[0]);
                if (columnsDifferences.length === 0)
                    return null;
                
                return new DatabaseObjectDiff(previousColumnVersion[0], currentColumnVersion[0], DatabaseObjectDiffState.ALTERED, columnsDifferences);
            });

            let nonNullDiffs = columnsDiff.filter(diff => { return diff !== null; });

            diffs.push(...nonNullDiffs);
        }

        return diffs;
    }

    function compareTables() {
        if (_previousDatabaseMap.tables.length === 0 && _currentDatabaseMap.tables.length === 0)
            return;

        let deletedTablesDiff = getDeletedTables();
        let createdTablesDiff = getCreatedTables();
        let alteredTablesDiff = getAlteredTables();

        self.databaseMapDiff.tablesDiff.push(...deletedTablesDiff);
        self.databaseMapDiff.tablesDiff.push(...createdTablesDiff);
        self.databaseMapDiff.tablesDiff.push(...alteredTablesDiff);

        let deletedColumnsDiff = getDeletedColumns(alteredTablesDiff);
        let createdColumnsDiff = getCreatedColumns(alteredTablesDiff);
        let alteredColumnsDiff = getAlteredColumns(alteredTablesDiff);

        self.databaseMapDiff.columnsDiff.push(...deletedColumnsDiff);
        self.databaseMapDiff.columnsDiff.push(...createdColumnsDiff);
        self.databaseMapDiff.columnsDiff.push(...alteredColumnsDiff);
    }

    this.compare = function compare() {
        compareSchemas();
        compareTables();

        return this.databaseMapDiff;
    }
}

module.exports = DatabaseMapComparer;