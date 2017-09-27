'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require('chai').expect;
const testHelpers = require('test/test_helpers');
const DatabaseMap = require('src/models/database_map');
const DatabaseMapDiff = require('src/models/database_map_diff');
const DatabaseObjectDiff = require('src/models/database_object_diff');
const DatabaseObjectDiffState = require('src/models/database_object_diff_state');
const DatabaseType = require('src/models/database_types');
const MSSQLServerSqlBuilder = require('src/script_generators/mssql_sql_builder');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');

describe('MSSQLServerSqlBuilder', function () {

    describe('generateUseStmt', function () {

        it('should return \'use database\' statement ', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
            
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
            it(`should throw error if database name is ${testCase.args}`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
    
                // Act + Assert
                let fun = function() { builder.generateUseStmt(testCase.args); };
                expect(fun).to.throw(Error);
            });
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
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
                
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

            let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);

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
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);

                // Act + Assert
                let fun = function() { builder.generateDropSchemaStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid schema value: ${testCase.args}`);
            });
        });

        it('should return simple drop script', function() {
            // Arrnge
            let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);

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
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);

                // Act + Assert
                let fun = function() { builder.generateCreateSchemaStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid schema value: ${testCase.args}`);
            });
        });

        it ('should return simple create schema script', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
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
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);

                // Act + Assert
                let fun = function () { builder.generateCreateTableColumnStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid column value: ${testCase.args}`);
            });
        });


        it('should return column definition for int - no identity', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
            let column = new Column(1, 'ColumnName', 'int', 4, 10, 0, null, false, false, null, null, false, null);

            // Act
            let script = builder.generateCreateTableColumnStmt(column);

            // Assert
            expect(script).to.contains('ColumnName INT NOT NULL');
        });
    });

    /*
    describe('generateCreateTableStmt', function() {
        let createTableStmtErrorCases = [
            {args: null},
            {args: undefined}
        ];

        createTableStmtErrorCases.forEach(function(testCase) {
            
            it(`${testCase.args} should throw Error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
    
                // Act + Assert
                let fun = function() { builder.generateCreateTableStmt(testCase.args); };
                expect(fun).to.throw(Error, `Invalid table value: ${testCase.args}`);
            });
        });

        it('should return create table script for empty table', function() {
            // Arrange
            let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
            
            let schema = new Schema(1, 'Schema');
            let table = new Table(1, 'CreatedTable', new Date(2017, 1, 1), new Date(2017, 1, 1), 1, false);

            table.schema = schema;
            
            // Act
            let script = builder.generateCreateTableStmt(table);

            // Assert
            expect(script).to.contains(`CREATE TABLE ${schema.name}.${table.name}`);
        });
    });*/
});