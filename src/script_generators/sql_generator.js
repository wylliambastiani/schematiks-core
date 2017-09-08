'use strict';

require('rootpath')();


function SqlGenerator(sqlBuilder) {
    let _builder = sqlBuilder;

    this.generate = function(diff) {
        let databaseName = diff.currentDatabaseMap.databaseName;

        _builder = _builder.createUseStmt(databaseName);

        return _builder.toString();
    }
}

module.exports = SqlGenerator;