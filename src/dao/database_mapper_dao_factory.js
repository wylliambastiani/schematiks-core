
'use strict';

require('rootpath')();

const DatabaseTypes = require('src/models/database_types');
const MSSQLDatabaseMapperDao = require('src/dao/mssql/mssql_database_mapper_dao');

function DatabaseMappingDaoFactory() {
    this.getInstance = function(connectionSettings) {
        switch (connectionSettings.databaseType) {
            case DatabaseTypes.MSSQL_2016: {
                return new MSSQLDatabaseMapperDao(connectionSettings);
            }

            default:
                throw new Error(`Not supported database: ${connectionSettings.databaseType}`);
        }
    }
}

module.exports = DatabaseMappingDaoFactory;