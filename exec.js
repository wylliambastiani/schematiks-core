'use strict';

const { 
    DatabaseType,
    ConnectionSettings,
    DatabaseMapperDaoFactory,
    DatabaseMapper,
    DatabaseMapComparer,
    SqlBuilderFactory   
 } = require('./src');

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