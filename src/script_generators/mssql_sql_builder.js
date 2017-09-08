'use strict';

require('rootpath')();

const ScriptLoader = require('src/script_loader');

function MSSQLServerSqlBuilder(databaseType) {
    let _databaseType = databaseType;
    let _scriptLoader = new ScriptLoader(_databaseType);
    let _script = '';

    this.generateUseStmt = function (databaseName) {
        if (!databaseName) {
            throw new Error(`Invalid database name: ${databaseName}`);
        }

        let script = _scriptLoader.getScript('use_stmt');
        script = script.replace('{DatabaseName}', databaseName);
        script.replace()
        _script += '\n' + script;

        return this;
    }

    this.toString = function () {
        return _script;
    }
}

module.exports = MSSQLServerSqlBuilder;