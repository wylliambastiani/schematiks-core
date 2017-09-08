'use strict';

require('rootpath')();

const DatabaseType = require('src/models/database_types')

function SqlBuilderFactory() {
    this.getInstance = function (databaseType) {
        switch(databaseType) {
            case DatabaseType.MSSQL_2016:
                {
                    const MSSQLSqlBuilder = require('src/script_generators/mssql_sql_builder');
                    return new MSSQLSqlBuilder(databaseType);
                }
                break;

            default:
                throw new Error(`Not supported database type: ${databaseType}`);
        }
    }   
}

module.exports = SqlBuilderFactory;