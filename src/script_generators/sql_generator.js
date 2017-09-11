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

    this.generate = function(diff) {
        let databaseName = diff.currentDatabaseMap.databaseName || diff.previousDatabaseMap.databaseName;

        // use statement
        generateUseStmt(databaseName);

        // drop tables
        generateDropTables(diff);

        return _script;
    }
}

module.exports = SqlGenerator;