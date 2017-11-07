'use strict';

require('rootpath')();

let DatabaseObjectDiffState = require('src/models/database_object_diff_state');

function SqlGenerator(sqlBuilder) {
    let _builder = sqlBuilder;
    let _script = '';

    function generateUseStmt(databaseName) {
        _script += _builder.generateUseStmt(databaseName);     
    }

    function generateDropTables(diff) {
        let tablesToDrop = diff.tablesDiff.filter(tableDiff => {
            return tableDiff.diffState === DatabaseObjectDiffState.DELETED;
        });

        tablesToDrop.forEach(tableToDrop => {
            _script += _builder.generateDropTableStmt(tableToDrop.previousObjectVersion);
        });
    }

    function generateDropSchemas(diff) {
        let schemasToDrop = diff.schemasDiff.filter(schemaDiff => {
            return schemaDiff.diffState === DatabaseObjectDiffState.DELETED;
        });

        schemasToDrop.forEach(schemaToDrop => {
            _script += _builder.generateDropSchemaStmt(schemaToDrop.previousObjectVersion);
        })
    }

    function generateCreateSchemas(diff) {
        let schemasToCreate = diff.schemasDiff.filter(schemaDiff => {
            return schemaDiff.diffState === DatabaseObjectDiffState.CREATED;
        });

        schemasToCreate.forEach(schemaToCreate => {
            _script += _builder.generateCreateSchemaStmt(schemaToCreate.currentObjectVersion);
        });
    }

    function generateCreateTables(diff) {
        let tablesToCreate = diff.tablesDiff.filter(tableDiff => {
            return tableDiff.diffState === DatabaseObjectDiffState.CREATED;
        });

        tablesToCreate.forEach(tableToCreate => {
            _script += _builder.generateCreateTableStmt(tableToCreate.currentObjectVersion);
        })
    }

    this.generate = function(diff) {
        let databaseName = diff.currentDatabaseMap.databaseName || diff.previousDatabaseMap.databaseName;

        // use statement
        generateUseStmt(databaseName);

        // drop's
        generateDropTables(diff);
        generateDropSchemas(diff);

        // creates
        generateCreateSchemas(diff);
        generateCreateTables(diff);

        return _script;
    }
}

module.exports = SqlGenerator;