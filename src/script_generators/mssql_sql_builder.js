'use strict';

require('rootpath')();

const os = require('os');
const ScriptLoader = require('src/script_loader');

function MSSQLServerSqlBuilder(databaseType) {
    let _databaseType = databaseType;
    let _scriptLoader = new ScriptLoader(_databaseType);

    function wrapInNewLine(script) {
        const NEWLINE = os.EOL;
        return NEWLINE + script + NEWLINE;
    }

    this.generateUseStmt = function(databaseName) {
        if (!databaseName) {
            throw new Error(`Invalid database name: ${databaseName}`);
        }

        let script = _scriptLoader.getScript('use_stmt');
        script = script.replace('{DatabaseName}', databaseName);

        return wrapInNewLine(script);
    }

    this.generateDropSchemaStmt = function(schema) {
        if (!schema) {
            throw new Error(`Invalid schema value: ${schema}`);
        }

        let script = _scriptLoader.getScript('drop_schema_stmt');
        script = script.replace('{SchemaName}', schema.name);

        return wrapInNewLine(script);
    }

    this.generateDropTableStmt = function(table) {
        if (!table) {
            throw new Error(`Invalid table value: ${table}`);
        }
 
        let script = _scriptLoader.getScript('drop_table_stmt');
        script = script.replace('{SchemaName}', table.schema.name)
                       .replace('{TableName}', table.name);
        
        return wrapInNewLine(script);
    }

    this.generateCreateSchemaStmt = function(schema) {
        if (!schema) {
            throw new Error(`Invalid schema value: ${schema}`);
        }

        let script = _scriptLoader.getScript('create_schema_stmt');
        script = script.replace('{SchemaName}', schema.name);
        
        return wrapInNewLine(script);
    }

    this.generateCreateTableColumnStmt = function(column) {
        if (!column) {
            throw new Error(`Invalid column value: ${column}`);
        }

        let script = _scriptLoader.getScript('create_table_column_stmt');
        script = script.replace('{ColumnName}', column.name)
                       .replace('{ColumnType}', column.type.toString().toUpperCase());

        if (!column.isNullable) {
            script = script.replace('{IsNullable}', 'NOT NULL');
        }

        return script;
    }

    // this.generateCreateTableStmt = function(table) {
    //     if (!table) {
    //         throw new Error(`Invalid table value: ${table}`);
    //     }

    //     let script = _scriptLoader.getScript('create_table_stmt');
    //     script = script.replace('{SchemaName}', table.schema.name)
    //                    .replace('{TableName}', table.name);

    //     return wrapInNewLine(script);
    // };
}

module.exports = MSSQLServerSqlBuilder;