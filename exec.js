'use strict';

const DatabaseType = require('./src/models/database_types');
const ConnectionSettings = require('./src/dao/connection_settings');
const DatabaseMapperDaoFactory = require('./src/dao/database_mapper_dao_factory');
const DatabaseMapper = require('./src/database_mapper');
const DatabaseMapComparer = require('./src/database_map_comparer');
const SqlBuilderFactory = require('./src/script_generators/sql_builder_factory');

function createDatabaseMapperDao (connectionSettings) {
    const daoFactory = new DatabaseMapperDaoFactory();
    return daoFactory.getInstance(connectionSettings);
}



(async () => {

    const connectionSettings = new ConnectionSettings(
        'localhost',
        'TSQL2012',
        'SA',
        '<YourStrong!Passw0rd>',
        DatabaseType.MSSQL_2016
    );

    const dao = createDatabaseMapperDao(connectionSettings);
    const mapper = new DatabaseMapper(dao);
    const map = await mapper.map();

    const mapComparer = new DatabaseMapComparer(null, map);
    const diff = mapComparer.compare();

    const sqlScriptBuilderFactory = new SqlBuilderFactory();
    const sqlScriptBuilder = sqlScriptBuilderFactory.getInstance(connectionSettings.databaseType);

    const script = sqlScriptBuilder.generateScript(diff);

    console.log(script);
})();