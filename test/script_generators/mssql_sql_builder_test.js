'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require('chai').expect;
const testHelpers = require('test/test_helpers');
const DatabaseMap = require('src/models/database_map');
const DatabaseMapDiff = require('src/models/database_map_diff');
const DatabaseObjectDiff = require('src/models/database_object_diff');
const DatabaseObjectDiffState = require('src/models/database_object_diff_state');
const DatabaseTypes = require('src/models/database_types');
const MSSQLServerSqlBuilder = require('src/script_generators/mssql_sql_builder');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');
const Constraint = require('src/models/constraint');
const ConstraintTarget = require('src/models/constraint_target');
const ConstraintColumn = require('src/models/constraint_column');
const ConstraintTypes = require('src/models/constraint_types');

describe('MSSQLServerSqlBuilder', function () {

    describe('generateUseStmt', function () {

        it('should return \'use database\' statement ', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
            
            // Act
            let script = builder.generateUseStmt('TestDB').toString();

            // Assert
            expect(script).to.contain('USE TestDB;');
        });

        let createUseStmtErrorCases = [
            {args: ''},
            {args: null},
            {args: undefined}
        ];

        createUseStmtErrorCases.forEach(function(testCase) {
            it(`should throw error if database name is ${testCase.args}`, function () {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
    
                // Act + Assert
                let fun = function () { builder.generateUseStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid database name: ${testCase.args}`);
            });
        });
    });

    describe('generateCreateDatabaseStmt', function () {

        let createDatabaseStmtErrorCases = [
            {args: ''},
            {args: null},
            {args: undefined}
        ];

        createDatabaseStmtErrorCases.forEach(function(testCase) {
            it (`should throw error if database name is ${testCase.args}`, function () {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

                // Act + Assert
                let fun = function () { builder.generateCreateDatabaseStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid database name: ${testCase.args}`);
            });
        });

        it ('should return \'create database\' statement', function () {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
            let databaseName = 'TestDB';

            // Act
            let script = builder.generateCreateDatabaseStmt(databaseName);

            // Assert
            expect(script).to.contains(`IF NOT EXISTS (SELECT * FROM sys.databases WHERE [name] = '${databaseName}')`);
            expect(script).to.contains('BEGIN');
            expect(script).to.contains(`    CREATE DATABASE ${databaseName};`);
            expect(script).to.contains('END;');
        });
    });

    describe('generateDropTableStmt', function() {

        let dropTableStmtErrorCases = [
            {args: null},
            {args: undefined}
        ];

        dropTableStmtErrorCases.forEach(function(testCase) {
            it(`${testCase.args} table throw error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
                
                // Act + Assert
                let fun  = function() { builder.generateDropTableStmt(testCase.args); }
                expect(fun).to.throw(Error, `Invalid table value: ${testCase.args}`);

            });
        });

        it('should return simple drop script', function() {
            // Arrange
            let schema = new Schema(1, 'dbo');
            let table = new Table(2, 'DroppedTable', new Date(2017, 1, 1), new Date(2017, 1, 1), 1, false);
            table.schema = schema;

            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

            // Act
            let script = builder.generateDropTableStmt(table);

            // Assert
            expect(script).to.contains('DROP TABLE dbo.DroppedTable');
        });
    });

    describe('generateDropSchemaStmt', function() {
        
        let dropSchemaStmtErrorCases = [
            {args: null},
            {args: undefined}
        ];

        dropSchemaStmtErrorCases.forEach(function(testCase) {
            it(`${testCase.args} should throw error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

                // Act + Assert
                let fun = function() { builder.generateDropSchemaStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid schema value: ${testCase.args}`);
            });
        });

        it('should return simple drop script', function() {
            // Arrnge
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

            let schema = new Schema(1, 'DroppedSchema');

            // Act
            let script = builder.generateDropSchemaStmt(schema);

            // Assert
            expect(script).to.contains(`DROP SCHEMA DroppedSchema;`);
        })
    });

    describe('generateCreateSchemaStmt', function() {
        
        let createSchemaStmtErrorCases = [
            {args: null},
            {args: undefined}
        ];

        createSchemaStmtErrorCases.forEach(function(testCase) {

            it (`${testCase.args} should throw error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

                // Act + Assert
                let fun = function() { builder.generateCreateSchemaStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid schema value: ${testCase.args}`);
            });
        });

        it ('should return simple create schema script', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
            let schema = new Schema(1, 'CreatedSchema');
            
            // Act
            let script = builder.generateCreateSchemaStmt(schema);

            // Assert
            expect(script).to.contains('CREATE SCHEMA CreatedSchema');
        });
    });

    describe('generateCreateTableColumnStmt', function() {

        let createTableColumnErrorCases = [
            {args: null},
            {args: undefined}
        ];

        createTableColumnErrorCases.forEach(function(testCase) {

            it(`${testCase.args} should return error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

                // Act + Assert
                let fun = function () { builder.generateCreateTableColumnStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid column value: ${testCase.args}`);
            });
        });

        let typesCases = [
            {type: 'int', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] INT NOT NULL'},
            {type: 'int', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] INT NULL'},
            {type: 'int', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: true, seed: 1, increment: 1, expectedResult: '[ColumnName] INT NOT NULL IDENTITY(1, 1)'},
            {type: 'bit', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] BIT NOT NULL'},
            {type: 'bit', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] BIT NULL'},
            {type: 'smallint', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] SMALLINT NOT NULL'},
            {type: 'smallint', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] SMALLINT NULL'},
            {type: 'tinyint', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] TINYINT NOT NULL'},
            {type: 'tinyint', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] TINYINT NULL'},
            {type: 'bigint', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] BIGINT NOT NULL'},
            {type: 'bigint', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] BIGINT NULL'},
            {type: 'decimal', maxLength: null, precision: 5, scale: 2, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DECIMAL(5,2) NOT NULL'},
            {type: 'decimal', maxLength: null, precision: 5, scale: 2, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DECIMAL(5,2) NULL'},
            {type: 'money', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] MONEY NOT NULL'},
            {type: 'money', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] MONEY NULL'},
            {type: 'smallmoney', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] SMALLMONEY NOT NULL'},
            {type: 'smallmoney', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] SMALLMONEY NULL'},
            {type: 'numeric', maxLength: null, precision: 5, scale: 2, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NUMERIC(5,2) NOT NULL'},
            {type: 'numeric', maxLength: null, precision: 5, scale: 2, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NUMERIC(5,2) NULL'},
            {type: 'float', maxLength: null, precision: 24, scale: 0, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] FLOAT(24) NOT NULL'},
            {type: 'float', maxLength: null, precision: 24, scale: 0, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] FLOAT(24) NULL'},
            {type: 'real', maxLength: null, precision: 24, scale: 0, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] REAL(24) NOT NULL'},
            {type: 'real', maxLength: null, precision: 24, scale: 0, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] REAL(24) NULL'},
            {type: 'date', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATE NOT NULL'},
            {type: 'date', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATE NULL'},
            {type: 'time', maxLength: null, precision: null, scale: 3, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] TIME(3) NOT NULL'},
            {type: 'time', maxLength: null, precision: null, scale: 3, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] TIME(3) NULL'},
            {type: 'datetime', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATETIME NOT NULL'},
            {type: 'datetime', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATETIME NULL'},
            {type: 'datetime2', maxLength: null, precision: null, scale: 7, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATETIME2(7) NOT NULL'},
            {type: 'datetime2', maxLength: null, precision: null, scale: 7, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATETIME2(7) NULL'},
            {type: 'smalldatetime', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] SMALLDATETIME NOT NULL'},
            {type: 'smalldatetime', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] SMALLDATETIME NULL'},
            {type: 'datetimeoffset', maxLength: null, precision: null, scale: 7, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATETIMEOFFSET(7) NOT NULL'},
            {type: 'datetimeoffset', maxLength: null, precision: null, scale: 7, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] DATETIMEOFFSET(7) NULL'},
            {type: 'char', maxLength: 10, precision: null, scale: null, isNullable: false, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL'},
            {type: 'char', maxLength: 10, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'nchar', maxLength: 20, precision: null, scale: null, isNullable: false, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL'},
            {type: 'nchar', maxLength: 20, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'varchar', maxLength: 10, precision: null, scale: null, isNullable: false, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL'},
            {type: 'varchar', maxLength: 10, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'varchar', maxLength: -1, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] VARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'nvarchar', maxLength: 20, precision: null, scale: null, isNullable: false, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL'},
            {type: 'nvarchar', maxLength: 20, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'nvarchar', maxLength: -1, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'text', maxLength: 10, precision: null, scale: null, isNullable: false, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] TEXT COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL'},
            {type: 'text', maxLength: 10, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] TEXT COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'ntext', maxLength: 20, precision: null, scale: null, isNullable: false, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NTEXT COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL'},
            {type: 'ntext', maxLength: 20, precision: null, scale: null, isNullable: true, collate: 'SQL_Latin1_General_CP1_CI_AS', isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] NTEXT COLLATE SQL_Latin1_General_CP1_CI_AS NULL'},
            {type: 'binary', maxLength: 10, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] BINARY(10) NOT NULL'},
            {type: 'binary', maxLength: 10, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] BINARY(10) NULL'},
            {type: 'varbinary', maxLength: 10, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] VARBINARY(10) NOT NULL'},
            {type: 'varbinary', maxLength: 10, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] VARBINARY(10) NULL'},
            {type: 'varbinary', maxLength: -1, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] VARBINARY(MAX) NULL'},
            {type: 'image', maxLength: null, precision: null, scale: null, isNullable: false, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] IMAGE NOT NULL'},
            {type: 'image', maxLength: null, precision: null, scale: null, isNullable: true, collate: null, isIdentity: false, seed: null, increment: null, expectedResult: '[ColumnName] IMAGE NULL'}
        ];

        typesCases.forEach(typeCase => {
            it(`should return column definition for type ${typeCase.type.toUpperCase()}, IsNullable: ${typeCase.isNullable}`, () => {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
                let column = new Column(1, 'ColumnName', typeCase.type, typeCase.maxLength, typeCase.precision, typeCase.scale, typeCase.collate, typeCase.isNullable, 
                    typeCase.isIdentity, typeCase.seed, typeCase.increment, null, null);

                // Act
                let script = builder.generateCreateTableColumnStmt(column);

                // Assert
                expect(script).to.contains(typeCase.expectedResult);
            });
        });
    });

    describe('generateCreateTablePrimaryKeyStmt', function (){
        it ('should return simple primary key definition for non-compound primary key', function () {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

            let mapping = new DatabaseMap();
            mapping.schemas = [
                new Schema(1, 'dbo')
            ];
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1)
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 1),
            ];
            mapping.constraints = [
                new Constraint(1, 'PK_Table1_Column1', ConstraintTypes.PK,
                new ConstraintTarget(1, [new ConstraintColumn(1, false)]),
                null)
            ];

            mapping.schemas[0].tables.push(...mapping.tables);
            mapping.tables[0].schema =  mapping.schemas[0];

            mapping.tables[0].columns.push(...mapping.columns);
            mapping.columns[0].table = mapping.tables[0];

            mapping.tables[0].constraints.push(...mapping.constraints);
            mapping.constraints[0].sourceTarget.table = mapping.tables[0];

            // Act
            let script = builder.generateCreateTablePrimaryKeyStmt(mapping.constraints[0]);

            // Assert
            expect(script).to.contains(',CONSTRAINT [PK_Table1_Column1] PRIMARY KEY([column1] ASC)');
        });

        it ('should return compound primary key definition for compound primary key', function () {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

            let mapping = new DatabaseMap();
            mapping.schemas = [
                new Schema(1, 'dbo')
            ];
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1)
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 1),
                new Column(2, 'column2', 'bigint', null, null, null, null, false, false, null, null, false, 1)
            ];
            mapping.constraints = [
                new Constraint(1, 'PK_Table1_Column1', ConstraintTypes.PK,
                new ConstraintTarget(1, [new ConstraintColumn(1, false), new ConstraintColumn(2, true)]),
                null)
            ];

            mapping.schemas[0].tables.push(...mapping.tables);
            mapping.tables[0].schema =  mapping.schemas[0];

            mapping.tables[0].columns.push(...mapping.columns);
            mapping.columns[0].table = mapping.tables[0];

            mapping.tables[0].constraints.push(...mapping.constraints);
            mapping.constraints[0].sourceTarget.table = mapping.tables[0];

            // Act
            let script = builder.generateCreateTablePrimaryKeyStmt(mapping.constraints[0]);

            // Assert
            expect(script).to.contains(',CONSTRAINT [PK_Table1_Column1] PRIMARY KEY([column1] ASC, [column2] DESC)');
        });
    });

    describe('generateCreateTableForeignKeyStmt', function (){
        it ('should return simple foreign key definition for non-compound foreign key', function () {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
            
            let mapping = new DatabaseMap();
            mapping.schemas = [
                new Schema(1, 'dbo')
            ];
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1),
                new Table(2, 'table2', new Date(), new Date(), 1),
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 1),
                new Column(1, 'column2', 'int', null, null, null, null, false, true, 1, 1, false, 2)
            ];
            mapping.constraints = [
                new Constraint(1, 'FK_Table_Table1', ConstraintTypes.FK,
                new ConstraintTarget(2, [new ConstraintColumn(1, null)]),
                new ConstraintTarget(1, [new ConstraintColumn(1, null)]),)
            ];

            mapping.schemas[0].tables = mapping.tables;
            mapping.tables[0].schema = mapping.schemas[0];
            mapping.tables[1].schema = mapping.schemas[0];

            mapping.tables[0].columns = [mapping.columns[0]];
            mapping.columns[0].table = mapping.tables[0];

            mapping.tables[1].columns = [mapping.columns[1]];
            mapping.columns[1].table = mapping.tables[1];

            mapping.tables[0].constraints = mapping.constraints;
            mapping.tables[1].constraints = mapping.constraints;

            mapping.constraints[0].sourceTarget.table = mapping.tables[1];
            mapping.constraints[0].destinationTarget.table = mapping.tables[0];

            // Act
            let script = builder.generateCreateTableForeignKeyStmt(mapping.constraints[0]);

            // Assert
            expect(script).to.contains(',CONSTRAINT [FK_Table_Table1] FOREIGN KEY ([column2]) REFERENCES dbo.table1 ([column1])');
        });
    });

    describe('generateCreateTableStmt', function() {
        let createTableStmtErrorCases = [
            {args: null},
            {args: undefined}
        ];

        createTableStmtErrorCases.forEach(function(testCase) {
            
            it(`${testCase.args} should throw Error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
    
                // Act + Assert
                let fun = function() { builder.generateCreateTableStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid table value: ${testCase.args}`);
            });
        });

        it('should throw Error for empty table', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);
            
            let schema = new Schema(1, 'Schema');
            let table = new Table(1, 'CreatedTable', new Date(2017, 1, 1), new Date(2017, 1, 1), 1, false);

            table.schema = schema;
            
            // Act + Assert
            let fun = function() { builder.generateCreateTableStmt(table); };
            expect(fun).to.throw(Error, `Cannot create table with no columns`);
        });

        it('should return script for table with columns', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseTypes.MSSQL_2016);

            let schema = new Schema(1, 'Schema');
            let table = new Table(1, 'CreatedTable', new Date(2017, 1, 1), new Date(2017, 1, 1), 1, false);
            let column1 = new Column(1, 'ColumnName1', 'INT', null, null, null, null, false, false, 0, 0, false, 1);
            let column2 = new Column(2, 'ColumnName2', 'INT', null, null, null, null, false, false, 0, 0, false, 1);

            column1.table = table;
            column2.table = table;
            table.schema = schema;
            table.columns = [column1, column2];

            // Act
            let script = builder.generateCreateTableStmt(table);

            // Assert
            expect(script).to.contain('CREATE TABLE Schema.CreatedTable');
            expect(script).to.contain('[ColumnName1] INT NOT NULL');
            expect(script).to.contain('[ColumnName2] INT NOT NULL');
        });
    });
});