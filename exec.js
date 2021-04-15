'use strict';

const { 
  DatabaseType,
  ConnectionSettings,
  DatabaseMapperDaoFactory,
  DatabaseMapper,
  DatabaseMapComparer,
  SqlBuilderFactory   
 } = require('./src');

(async () => {

  const connectionSettings = new ConnectionSettings(
    'localhost',
    'TSQL2012',
    'SA',
    '<YourStrongPassw0rd>',
    DatabaseType.MSSQL_2016
  );

  const mapper = new DatabaseMapper({ connectionSettings });
  const map = await mapper.map();

  const mapComparer = new DatabaseMapComparer(null, map);
  const diff = mapComparer.compare();

  const sqlScriptBuilderFactory = new SqlBuilderFactory();
  const sqlScriptBuilder = sqlScriptBuilderFactory.getInstance(connectionSettings.databaseType);

  const script = sqlScriptBuilder.generateScript(diff);
  console.log(script)
})();