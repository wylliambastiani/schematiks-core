'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require('chai').expect;
const testHelpers = require('test/test_helpers');
const DatabaseMapper = require('src/database_mapper');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');
const Constraint = require('src/models/constraint');

describe('DatabaseMapper', function () {

  describe ('constructor', function () {

    it ('should throw an Error if options is not defined', () => {

      // Arrange
      let exception = null;

      try {
        new DatabaseMapper();
      } catch (ex) {
        exception = ex;
      } finally {
        expect(exception).to.be.instanceOf(Error);
        expect(exception.message).to.be.equal("DatabaseMapper constructor needs dao of connectionSettings as arguments");
      }
    });

    it ('should throw an Error if both dao and connectionSettings is not defined', () => {

      // Arrange
      let exception = null;

      try {
        new DatabaseMapper({});
      } catch (ex) {
        exception = ex;
      } finally {
        expect(exception).to.be.instanceOf(Error);
        expect(exception.message).to.be.equal("DatabaseMapper constructor needs dao of connectionSettings as arguments");
      }
    });
  });

  describe ('mapSchemas', function () {
    it ('should return an empty array when no schemas exist', async function () {
      var dao = {
        getSchemas: testHelpers.createFunctionStubReturnsEmptyList()
      };

      let mapper = new DatabaseMapper({ dao });
      let schemas = await mapper.mapSchemas();
      
      expect(schemas).to.be.empty;
    });

    it ('should return a non empty array when schemas exist', async function () {
      var dao = {
        getSchemas: testHelpers.createFunctionStubReturnsNonEmptyList([new Schema(1, 'dbo')])
      };

      let mapper = new DatabaseMapper({ dao });
      let schemas = await mapper.mapSchemas();
      
      expect(schemas).to.not.be.empty;
    });
  });

  describe ('mapTables', function () {
    it ('should return an empty array when no tables exist', async function () {
      let dao = {
        getTables: testHelpers.createFunctionStubReturnsEmptyList()
      };

      let mapper = new DatabaseMapper({ dao });
      let tables = await mapper.mapTables();
      
      expect(tables).to.be.empty;
    });

    it ('should return a non empty array when tables exists', async function () {
      let dao = {
        getTables: testHelpers.createFunctionStubReturnsNonEmptyList([new Table(1, 'tableName')])
      };

      let mapper = new DatabaseMapper({ dao });
      let tables = await mapper.mapTables();
      
      expect(tables).to.not.be.empty;
    });
  });

  describe ('mapColumns', function () {
    it ('should return an empty array when no columns exist', async function () {
      let dao = {
        getColumns: testHelpers.createFunctionStubReturnsEmptyList()
      };

      let mapper = new DatabaseMapper({ dao });
      let columns = await mapper.mapColumns();
      
      expect(columns).to.be.empty;
    });

    it ('should return a non empty array when columns exists', async function () {
      let dao = {
        getColumns: testHelpers.createFunctionStubReturnsNonEmptyList([new Column()])
      };

      let mapper = new DatabaseMapper({ dao });
      let columns = await mapper.mapColumns();
      
      expect(columns).to.not.be.empty;
    });
  });

  describe ('mapPrimaryKeys', function () {
    it ('should return an empty array when no primary keys exists', async function () {
      // Arrange
      let dao = {
        getPrimaryKeys: testHelpers.createFunctionStubReturnsEmptyList()
      };

      // Act
      let mapper = new DatabaseMapper({ dao });
      let primaryKeys = await mapper.mapPrimaryKeys();

      // Assert
      expect(primaryKeys).to.be.empty;
    });

    it ('should return a non empty array when primary keys exists', async function () {
      // Arrange
      let dao = {
        getPrimaryKeys: testHelpers.createFunctionStubReturnsNonEmptyList([new Constraint()])
      };

      // Act
      let mapper = new DatabaseMapper({ dao });
      let primaryKeys = await mapper.mapPrimaryKeys();

      // Assert
      expect(primaryKeys).to.not.be.empty;
    });
  });

  describe ('mapForeignKeys', function () {
    it ('should return an empty array when no foreign keys exists', async function (){
      // Arrange
      let dao = {
        getForeignKeys: testHelpers.createFunctionStubReturnsEmptyList()
      };

      // Act
      let mapper = new DatabaseMapper({ dao });
      let foreignKeys = await mapper.mapForeignKeys();

      // Assert
      expect(foreignKeys).to.be.empty;
    });

    it ('should return a non empty array when foreign keys exists', async function () {
      // Arrange
      let dao = {
        getForeignKeys: testHelpers.createFunctionStubReturnsNonEmptyList([new Constraint()])
      };

      // Act
      let mapper = new DatabaseMapper({ dao });
      let foreignKeys = await mapper.mapForeignKeys();

      // Assert
      expect(foreignKeys).to.not.be.empty;
    });
  });
});