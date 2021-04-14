'use strict';

require('rootpath')();

const expect = require('chai').expect;

const DatabaseType = require('src/models/database_types');
const ConnectionSettings = require('src/dao/connection_settings');
const DatabaseMappingDaofactory = require('src/dao/database_mapper_dao_factory');
const MSSQLDatabaseMappingDao = require('src/dao/mssql/mssql_database_mapper_dao');

describe('DatabaseMappingDaofactory', function () {

  describe('getInstance', function () {

    it('throw Error if database type is not supported', function () {
      const factory = new DatabaseMappingDaofactory();
      const settings = new ConnectionSettings(null, null, null, null, 'NotSupportedDatabaseType');

      expect(function () { factory.getInstance(settings); }).to.throw(Error);
    });

    it('return an MSSQLDatabaseMappingDao object when type is MSSQL_2016', function () {
     
      const factory = new DatabaseMappingDaofactory();
      const settings = new ConnectionSettings(null, null, null, null, DatabaseType.MSSQL_2016);
      const dao = factory.getInstance(settings);
      
      expect(dao).instanceof(MSSQLDatabaseMappingDao);
    });
  });
});