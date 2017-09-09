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
                let fun = function() { builder.generateUseStmt(testCase.args).toString(); };
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
            it(`${testCase.args} table throws error`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
                
                // Act + Assert
                let fun  = function() { builder.generateDropTableStmt(testCase.args); }
                expect(fun).to.throw(Error);

            });
        });

        // let schema = new Schema(1, 'dbo');
        // let table = new Table(2, 'DroppedTable', new Date(2017, 1, 1), new Date(2017, 1, 1),
        //     schema.id, false);
    });
});