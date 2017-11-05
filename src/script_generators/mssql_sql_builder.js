'use strict';

require('rootpath')();

const os = require('os');
const ScriptLoader = require('src/script_loader');
const ScriptPlaceholders = require('src/script_generators/script_placeholders');

function MSSQLServerSqlBuilder(databaseType) {
    let _databaseType = databaseType;
    let _scriptLoader = new ScriptLoader(_databaseType);
    
    let _columnTypePlaceholderReplacers = {
        'decimal': columnDecimalPlaceholderReplacer,
        'numeric': columnNumericPlaceholderReplacer,
        'float': columnFloatPlaceholderReplacer,
        'real': columnRealPlaceholderReplacer,
        'time': columnTimePlaceholderReplacer,
        'datetime2': columnDateTime2PlaceholderReplacer,
        'datetimeoffset': columnDateTimeOffsetPlaceholderReplacer,
        'char': columnCharPlaceholderReplacer,
        'varchar': columnVarCharPlaceholderReplacer,
    }

    function wrapInNewLine(script) {
        const NEWLINE = os.EOL;
        return NEWLINE + script + NEWLINE;
    }
    
    function indentLine(script) {
        return '\t' + script;
    }

    function removeRemainingPlaceholders(script) {
        let placeholderPattern = /[{][a-zA-Z0-9+]+[}]/g
        let scriptWithoutPlaceHolders = script.replace(placeholderPattern, '');
        let scriptWithoutParentheses = scriptWithoutPlaceHolders.replace(placeholderPattern, '');
        let scriptWithoutDoubleSpaces = scriptWithoutParentheses.replace(/(\s{2,})/g, ' ');
        return scriptWithoutDoubleSpaces;
    }

    function genericColumnPlaceholderReplacer(script, column) {
        script = script.replace(ScriptPlaceholders.ColumnName, column.name)
                       .replace(ScriptPlaceholders.ColumnType, column.type.toUpperCase());

        if (!column.isNullable) {
            script = script.replace(ScriptPlaceholders.IsNullable, 'NOT NULL');
        } else {
            script = script.replace(ScriptPlaceholders.IsNullable, 'NULL');
        }

        return script
    }

    function columnNumericOrDecimalPlaceHolderReplacer(script, column) {
        script = script.replace(ScriptPlaceholders.PrecisionAndScale, `(${column.typePrecision},${column.typeScale})`);
        return script;
    }

    function columnDecimalPlaceholderReplacer(script, column) {
        return columnNumericOrDecimalPlaceHolderReplacer(script, column)
    }

    function columnNumericPlaceholderReplacer(script, column){
        return columnNumericOrDecimalPlaceHolderReplacer(script, column)
    }

    function columnFloatOrRealPlaceholderReplacer(script, column) {
        return script.replace(ScriptPlaceholders.PrecisionAndScale, `(${column.typePrecision})`);
    }

    function columnFloatPlaceholderReplacer(script, column) {
        return columnFloatOrRealPlaceholderReplacer(script, column);
    }

    function columnRealPlaceholderReplacer(script, column) {
        return columnFloatOrRealPlaceholderReplacer(script, column);
    }

    function columnDatesAndTimesPlaceholderReplacer(script, column) {
        return script.replace(ScriptPlaceholders.PrecisionAndScale, `(${column.typeScale})`);
    }

    function columnDateTime2PlaceholderReplacer(script, column) {
        return columnDatesAndTimesPlaceholderReplacer(script, column);
    }

    function columnTimePlaceholderReplacer(script, column) {
        return columnDatesAndTimesPlaceholderReplacer(script, column);
    }

    function columnDateTimeOffsetPlaceholderReplacer(script, column) {
        return columnDatesAndTimesPlaceholderReplacer(script, column);
    }

    function columnCharAndVarCharPlaceholderReplacer(script, column) {
        let scriptWithMaxLength = script.replace(ScriptPlaceholders.ColumnMaxLength, `(${column.typeMaxLength})`);
        let scriptWithCollate = scriptWithMaxLength.replace(ScriptPlaceholders.Collate, `COLLATE ${column.collationName}`);
        return scriptWithCollate;
    }

    function columnCharPlaceholderReplacer(script, column) {
        return columnCharAndVarCharPlaceholderReplacer(script, column);
    }

    function columnVarCharPlaceholderReplacer(script, column) {
        return columnCharAndVarCharPlaceholderReplacer(script, column);
    }
    
    this.generateUseStmt = function(databaseName) {
        if (!databaseName) {
            throw new Error(`Invalid database name: ${databaseName}`);
        }

        let script = _scriptLoader.getScript('use_stmt');
        script = script.replace(ScriptPlaceholders.DatabaseName, databaseName);

        return wrapInNewLine(script);
    }

    this.generateDropSchemaStmt = function(schema) {
        if (!schema) {
            throw new Error(`Invalid schema value: ${schema}`);
        }

        let script = _scriptLoader.getScript('drop_schema_stmt');
        script = script.replace(ScriptPlaceholders.SchemaName, schema.name);

        return wrapInNewLine(script);
    }

    this.generateDropTableStmt = function(table) {
        if (!table) {
            throw new Error(`Invalid table value: ${table}`);
        }
 
        let script = _scriptLoader.getScript('drop_table_stmt');
        script = script.replace(ScriptPlaceholders.SchemaName, table.schema.name)
                       .replace(ScriptPlaceholders.TableName, table.name);
        
        return wrapInNewLine(script);
    }

    this.generateCreateSchemaStmt = function(schema) {
        if (!schema) {
            throw new Error(`Invalid schema value: ${schema}`);
        }

        let script = _scriptLoader.getScript('create_schema_stmt');
        script = script.replace(ScriptPlaceholders.SchemaName, schema.name);
        
        return wrapInNewLine(script);
    }

    this.generateCreateTableColumnStmt = function(column) {
        if (!column) {
            throw new Error(`Invalid column value: ${column}`);
        }

        let script = _scriptLoader.getScript('create_table_column_stmt');
        script = genericColumnPlaceholderReplacer(script, column);
        
        if (column.type in _columnTypePlaceholderReplacers) {
            script = _columnTypePlaceholderReplacers[column.type](script, column)
        } 

        script = removeRemainingPlaceholders(script);
        script = indentLine(script);
        script = wrapInNewLine(script);

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