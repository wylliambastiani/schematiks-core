'use strict';

require('rootpath')();

const ScriptLoader = require('src/script_loader');

function MSSQLServerSqlBuilder(databaseType) {
    let _databaseType = databaseType;
    let _scriptLoader = new ScriptLoader(_databaseType);

    this.generateUseStmt = function(databaseName) {
        if (!databaseName) {
            throw new Error(`Invalid database name: ${databaseName}`);
        }

        let script = _scriptLoader.getScript('use_stmt');
        script = script.replace('{DatabaseName}', databaseName);

        return '\n' + script + '\n';
    }

    this.generateDropTableStmt = function(table) {
        if (!table) {
            throw new Error(`Invalid table value: ${table}`);
        }

        let script = _scriptLoader.getScript('drop_table_stmt');
        script = script.replace('{SchemaName}', table.schema.name)
                       .replace('{TableName}', table.name);
        
        return '\n' + script + '\n';
    }
}

module.exports = MSSQLServerSqlBuilder;