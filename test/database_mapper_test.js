'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require('chai').expect;
const testHelpers = require('test/test_helpers');
const DatabaseMapper = require('src/database_mapper');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');

describe('DatabaseMapper', function () {
    describe ('mapSchemas', function () {
        it ('should return an empty array when no schemas exist', async function () {
            var databaseMappingDao = {
                getSchemas: testHelpers.createFunctionStubReturnsEmptyList()
            };

            let mapper = new DatabaseMapper(databaseMappingDao);
            let schemas = await mapper.mapSchemas();
            
            expect(schemas).to.be.empty;
        });

        it ('should return a non empty array when schemas exist', async function () {
            var databaseMappingDao = {
                getSchemas: testHelpers.createFunctionStubReturnsNonEmptyList([new Schema(1, 'dbo')])
            };

            let mapper = new DatabaseMapper(databaseMappingDao);
            let schemas = await mapper.mapSchemas();
            
            expect(schemas).to.not.be.empty;
        });
    });

    describe ('mapTables', function () {
        it ('should return an empty array when no tables exist', async function () {
            let databaseMappingDao = {
                getTables: testHelpers.createFunctionStubReturnsEmptyList()
            };

            let mapper = new DatabaseMapper(databaseMappingDao);
            let tables = await mapper.mapTables();
            
            expect(tables).to.be.empty;
        });

        it ('should return a non empty array when tables exists', async function () {
            let databaseMappingDao = {
                getTables: testHelpers.createFunctionStubReturnsNonEmptyList([new Table(1, 'tableName')])
            };

            let mapper = new DatabaseMapper(databaseMappingDao);
            let tables = await mapper.mapTables();
            
            expect(tables).to.not.be.empty;
        });
    });

    describe ('mapColumns', function () {
        it ('should return an empty array when no columns exist', async function () {
            let databaseMappingDao = {
                getColumns: testHelpers.createFunctionStubReturnsEmptyList()
            };

            let mapper = new DatabaseMapper(databaseMappingDao);
            let columns = await mapper.mapColumns();
            
            expect(columns).to.be.empty;
        });

        it ('should return a non empty array when columns exists', async function () {
            let databaseMappingDao = {
                getColumns: testHelpers.createFunctionStubReturnsNonEmptyList([new Column()])
            };

            let mapper = new DatabaseMapper(databaseMappingDao);
            let columns = await mapper.mapColumns();
            
            expect(columns).to.not.be.empty;
        });
    });
});