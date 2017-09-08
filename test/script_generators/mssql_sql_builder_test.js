'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require('chai').expect;
const testHelpers = require('test/test_helpers');
const DatabaseMap = require('src/models/database_map');
const DatabaseMapDiff = require('src/models/database_map_diff')
const DatabaseType = require('src/models/database_types');
const MSSQLServerSqlBuilder = require('src/script_generators/mssql_sql_builder');


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

        var createUseStmtErrorCases = [
            {args: ''},
            {args: null},
            {args: undefined}
        ];

        createUseStmtErrorCases.forEach(function(testCase) {
            it(`should throw error if database name is ${testCase.args} for 'use database' statement`, function() {
                // Arrange
                let builder = new MSSQLServerSqlBuilder(DatabaseType.MSSQL_2016);
    
                // Act + Assert
                let fun = function() { builder.generateUseStmt(testCase.args).toString(); };
                expect(fun).to.throw(Error);
            });
        });
    });

    describe('generateDropTableStmt', function() {

        it('should return empty script if no tables has been dropped', function() {
            // Arrange
            
            // Act

            // Assert
        });
    });
});