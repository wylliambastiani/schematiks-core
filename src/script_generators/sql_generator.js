'use strict';

require('rootpath')();


function SqlGenerator(sqlBuilder) {
    let _builder = sqlBuilder;

    this.generate = function(diff) {
        let databaseName = diff.currentDatabaseMap.databaseName || diff.previousDatabaseMap.databaseName;

        _builder = _builder.generateUseStmt(databaseName);

        return _builder.toString();
    }
}

module.exports = SqlGenerator;