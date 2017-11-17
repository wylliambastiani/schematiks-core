
require('rootpath')();

const fs = require('fs');

const DatabaseTypes = require('src/models/database_types');
const ConnectionSettings = require('src/dao/connection_settings');
const DatabaseMapperDaoFactory = require('src/dao/database_mapper_dao_factory');
const DatabaseMapper = require('src/database_mapper');
const SqlBuilderFactory = require('src/script_generators/sql_builder_factory');
const DatabaseMapComparer = require('src/database_map_comparer');
const SqlGenerator = require('src/script_generators/sql_generator');
const MapSerializer = require('src/utils/serializers/map_serializer');

(async function() {
    // let serializer = new MapSerializer();
    // let oldMapJson = fs.readFileSync('output.json');
    // let oldMap = serializer.deserialize(oldMapJson);
    
    let connectionSettings = new ConnectionSettings('localhost', 'TSQL2012', 'SA', 'yourStrong(!)Password', DatabaseTypes.MSSQL_2016);
    let daoFactory = new DatabaseMapperDaoFactory(connectionSettings);
    let dao = daoFactory.getInstance(connectionSettings);
    let mapper = new DatabaseMapper(dao);
    let map = await mapper.map();

    // let json = serializer.serialize(map);
    // fs.writeFileSync('output.json', json);

    let comparer = new DatabaseMapComparer(null, map);
    let diff = comparer.compare(); 
    let builderFactory = new SqlBuilderFactory();
    let builder = builderFactory.getInstance(connectionSettings.databaseType);
    let scriptGenerator = new SqlGenerator(builder);
    let script = scriptGenerator.generate(diff);
    console.log(script);
    
    // for (let constraint of map.constraints) {
    //     console.log(constraint.name);
    //     for (let sourceColumn of constraint.sourceTarget.constraintColumns) {
    //         console.log('\t' + sourceColumn.columnId + ' - ' + sourceColumn.is_descending_key);
    //     }
    // }
})();