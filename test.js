
require('rootpath')();

const DatabaseTypes = require('src/models/database_types');
const ConnectionSettings = require('src/dao/connection_settings');
const DatabaseMapperDaoFactory = require('src/dao/database_mapper_dao_factory');
const DatabaseMapper = require('src/database_mapper');
const SqlBuilderFactory = require('src/script_generators/sql_builder_factory');
const DatabaseMapComparer = require('src/database_map_comparer');
const SqlGenerator = require('src/script_generators/sql_generator');

(async function() {
    let connectionSettings = new ConnectionSettings('localhost', 'TSQL2012', 'SA', 'Password0*', DatabaseTypes.MSSQL_2016);
    let daoFactory = new DatabaseMapperDaoFactory(connectionSettings);
    let dao = daoFactory.getInstance(connectionSettings);
    let mapper = new DatabaseMapper(dao);
    let map = await mapper.map();
    let comparer = new DatabaseMapComparer(null, map);
    let diff = comparer.compare(); 
    let builderFactory = new SqlBuilderFactory();
    let builder = builderFactory.getInstance(connectionSettings.databaseType);
    let scriptGenerator = new SqlGenerator(builder);
    let script = scriptGenerator.generate(diff);
    console.log(script);
})();