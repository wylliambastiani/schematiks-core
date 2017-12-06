'use strict';

require('rootpath')();

const os = require('os');
const ScriptLoader = require('src/script_loader');
const ScriptPlaceholders = require('src/script_generators/script_placeholders');
const ConstraintTypes = require('src/models/constraint_types');
let DatabaseObjectDiffState = require('src/models/database_object_diff_state');

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
        'nchar': columnNCharPlaceholderReplacer,
        'varchar': columnVarCharPlaceholderReplacer,
        'nvarchar': columnNVarCharPlaceholderReplacer,
        'text': columnTextAndNTextPlaceholderReaplacer,
        'ntext': columnTextAndNTextPlaceholderReaplacer,
        'binary': columnBinaryPlaceholderReplacer,
        'varbinary': columnVarBinaryPlaceholderReplacer,
    }

    function wrapInNewLine(script, newLineCount = 1) {
        const NEWLINE = os.EOL;
        return NEWLINE.repeat(newLineCount) + script;
    }
    
    function indentLine(script) {
        return '\t' + script;
    }

    function removeRemainingPlaceholders(script) {
        let placeholderPattern = /[{][a-zA-Z0-9+]+[}]/g
        let scriptWithoutPlaceHolders = script.replace(placeholderPattern, '');
        let scriptWithoutParentheses = scriptWithoutPlaceHolders.replace(placeholderPattern, '');
        let scriptWithoutDoubleSpaces = scriptWithoutParentheses.replace(/(\s{2,})/g, ' ');
        let scriptWithNotRightSpaces = scriptWithoutDoubleSpaces.trimRight();
        return scriptWithNotRightSpaces;
    }

    function insertCommaBeforeColumnDefinition(columnScript) {
        return ',' + columnScript;
    }

    //#region Columns Methods

    function genericColumnPlaceholderReplacer(script, column) {
        script = script.replace(ScriptPlaceholders.ColumnName, column.name)
                       .replace(ScriptPlaceholders.ColumnType, column.type.toUpperCase());

        if (!column.isNullable) {
            script = script.replace(ScriptPlaceholders.IsNullable, 'NOT NULL');
        } else {
            script = script.replace(ScriptPlaceholders.IsNullable, 'NULL');
        }

        if (column.isIdentity) {
            script = script.replace('{Identity}', `IDENTITY(${column.identitySeedValue}, ${column.identityIncrementValue})`);
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

    function columnStringPlaceholderReplacer(script, column) {
        let maxLength = '';
        
        if (column.typeMaxLength == -1) {
            maxLength = '(MAX)';
        } else if (column.type.toLowerCase() == 'nchar' || column.type.toLowerCase() == 'nvarchar') {
            maxLength = '(' + column.typeMaxLength / 2 + ')';
        } else {
            maxLength = `(${column.typeMaxLength})`;
        }
         
        let scriptWithMaxLength = script.replace(ScriptPlaceholders.ColumnMaxLength, maxLength);
        let scriptWithCollate = scriptWithMaxLength.replace(ScriptPlaceholders.Collate, `COLLATE ${column.collationName}`);
        return scriptWithCollate;
    }

    function columnCharPlaceholderReplacer(script, column) {
        return columnStringPlaceholderReplacer(script, column);
    }

    function columnNCharPlaceholderReplacer(script, column) {
        return columnStringPlaceholderReplacer(script, column);
    }

    function columnVarCharPlaceholderReplacer(script, column) {
        return columnStringPlaceholderReplacer(script, column);
    }

    function columnNVarCharPlaceholderReplacer(script, column) {
        return columnStringPlaceholderReplacer(script, column);
    }

    function columnTextAndNTextPlaceholderReaplacer(script, column) {
        let scriptWithCollate = script.replace(ScriptPlaceholders.Collate, `COLLATE ${column.collationName}`);
        return scriptWithCollate;
    }
    
    function columnBinaryPlaceholderReplacer(script, column) {
        return script.replace(ScriptPlaceholders.ColumnMaxLength, `(${column.typeMaxLength})`);
    }

    function columnVarBinaryPlaceholderReplacer(script, column) {
        let maxLength = '';

        if (column.typeMaxLength == -1) {
            maxLength = '(MAX)';
        } else {
            maxLength = `(${column.typeMaxLength})`;
        }

        return script.replace(ScriptPlaceholders.ColumnMaxLength, maxLength);
    }
    
    //#endregion Columns Methods

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
        
        return wrapInNewLine(script, 2);
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
        
        return script;
    }

    this.generateCreateTablePrimaryKeyStmt = function(primaryKey) {
        if (!primaryKey) {
            throw new Error(`Invalid primary key value: ${primaryKey}`);
        }

        let constraintColumnsScriptPart = '';
        for (let index in primaryKey.sourceTarget.constraintColumns) {
            let constraintColumn = primaryKey.sourceTarget.constraintColumns[index];
            let column = primaryKey.sourceTarget.table.columns.filter(col => col.id === constraintColumn.columnId)[0];

            let columnScriptPart = '';

            if (index > 0)
                columnScriptPart += ', ';

            if (constraintColumn.is_descending_key) 
                columnScriptPart += `[${column.name}] DESC`;
            else
                columnScriptPart += `[${column.name}] ASC`;

            constraintColumnsScriptPart += columnScriptPart;
        }

        let script = _scriptLoader.getScript('create_table_primary_key_stmt');
        script = script.replace(ScriptPlaceholders.ConstraintColumns, constraintColumnsScriptPart);
        script = script.replace(ScriptPlaceholders.ConstraintName, primaryKey.name);

        return script;
    }

    this.generateCreateTableForeignKeyStmt = function(foreignKey) {
        if (!foreignKey) {
            throw new Error(`Invalid foreign key value: ${foreignKey}`);
        }
    
        let targetTable = foreignKey.destinationTarget.table.schema.name + '.' + foreignKey.destinationTarget.table.name;

        let constraintSourceColumnsScriptPart = '';
        for (let index in foreignKey.sourceTarget.constraintColumns) {
            let constraintColumn = foreignKey.sourceTarget.constraintColumns[index];
            let column = foreignKey.sourceTarget.table.columns.filter(col => col.id === constraintColumn.columnId)[0];

            let sourceColumnScriptPart = '';

            if (index > 0) 
                sourceColumnScriptPart += ', ';

            sourceColumnScriptPart += `[${column.name}]`;
            constraintSourceColumnsScriptPart += sourceColumnScriptPart;
        } 

        let constraintDestinationColumnsScriptPart = '';
        for (let index in foreignKey.destinationTarget.constraintColumns) {
            let constraintColumn = foreignKey.destinationTarget.constraintColumns[index];
            let column = foreignKey.destinationTarget.table.columns.filter(col => col.id === constraintColumn.columnId)[0];

            let destinationColumnScriptPart = '';

            if (index > 0)
                destinationColumnScriptPart += ', ';

            destinationColumnScriptPart += `[${column.name}]`;
            constraintDestinationColumnsScriptPart += destinationColumnScriptPart;
        }

        let script = _scriptLoader.getScript('create_table_foreign_key_stmt');
        script = script.replace(ScriptPlaceholders.ConstraintName, foreignKey.name);
        script = script.replace(ScriptPlaceholders.ConstraintParentColumns, constraintSourceColumnsScriptPart);
        script = script.replace(ScriptPlaceholders.ConstraintReferencedTable, targetTable);
        script = script.replace(ScriptPlaceholders.ConstraintReferencedColumns, constraintDestinationColumnsScriptPart);

        return script;
    }

    this.generateCreateTableStmt = function(table) {
        if (!table) {
            throw new Error(`Invalid table value: ${table}`);
        }

        if (table.columns === null || table.columns === undefined || table.columns.length === 0) {
            throw new Error('Cannot create table with no columns');
        }

        let script = _scriptLoader.getScript('create_table_stmt');
        script = script.replace(ScriptPlaceholders.SchemaName, table.schema.name);
        script = script.replace(ScriptPlaceholders.TableName, table.name);

        let tableContentScript = '';
        for(let index in table.columns) {
            let columnScript = this.generateCreateTableColumnStmt(table.columns[index]);
            
            if (index > 0) {
                columnScript = ',' + columnScript;
            }

            columnScript = indentLine(columnScript);

            if (index > 0) {
                columnScript = wrapInNewLine(columnScript);
            }
            
            tableContentScript += columnScript;
        }

        let primaryKeys = table.constraints.filter(constraint => { return constraint.type === ConstraintTypes.PK; });
        if (primaryKeys.length > 0) {
            let constraintScript = this.generateCreateTablePrimaryKeyStmt(primaryKeys[0]);
            tableContentScript += wrapInNewLine(indentLine(constraintScript));
        }

        let foreignKeys = table.constraints.filter(constraint => { return constraint.type === ConstraintTypes.FK; });
        for (let foreignKey of foreignKeys) {
            let constraintScript = this.generateCreateTableForeignKeyStmt(foreignKey);
            tableContentScript += wrapInNewLine(indentLine(constraintScript));
        }

        script = script.replace(ScriptPlaceholders.CreateTableBodyContent, tableContentScript);

        return wrapInNewLine(script, 2);
    };

    this.generateScript = function (diff) {
        let script = '';
        let databaseName = diff.currentDatabaseMap.databaseName || diff.previousDatabaseMap.databaseName;

        // use statement
        script += this.generateUseStmt(databaseName);

        // drop tables
        let tablesToDrop = diff.tablesDiff.filter(tableDiff => { return tableDiff.diffState === DatabaseObjectDiffState.DELETED; });
        tablesToDrop.forEach(tableToDrop => { script += this.generateDropTableStmt(tableToDrop.previousObjectVersion); });

        // drop schemas
        let schemasToDrop = diff.schemasDiff.filter(schemaDiff => { return schemaDiff.diffState === DatabaseObjectDiffState.DELETED; });
        schemasToDrop.forEach(schemaToDrop => { script += this.generateDropSchemaStmt(schemaToDrop.previousObjectVersion); })
        
        // creates schemas
        let schemasToCreate = diff.schemasDiff.filter(schemaDiff => { return schemaDiff.diffState === DatabaseObjectDiffState.CREATED; });
        schemasToCreate.forEach(schemaToCreate => { script += this.generateCreateSchemaStmt(schemaToCreate.currentObjectVersion); });

        // create tables
        let tablesToCreate = diff.tablesDiff.filter(tableDiff => { return tableDiff.diffState === DatabaseObjectDiffState.CREATED; });
        tablesToCreate.forEach(tableToCreate => { script += this.generateCreateTableStmt(tableToCreate.currentObjectVersion); })

        return script;
    }
}

module.exports = MSSQLServerSqlBuilder;