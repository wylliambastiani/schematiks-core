'use strict';

require('rootpath')();

const DatabaseMap = require('src/models/database_map');
const MappingReferenceResolver = require('src/mapping_reference_resolver');
const DatabaseMapperDaoFactory = require('src/dao/database_mapper_dao_factory');

function DatabaseMapper(dao) {
    let _dao = dao;

    this.map = async function() {
        let referenceResolver = new MappingReferenceResolver();

        let schemas = await this.mapSchemas(dao);
        let tables = await this.mapTables(dao);
        let columns = await this.mapColumns(dao);

        let mapping = new DatabaseMap();
        mapping.databaseType = dao.getDatabaseType();
        mapping.databaseName = dao.getDatabaseName();
        mapping.schemas = schemas;
        mapping.tables = tables;
        mapping.columns = columns;

        referenceResolver.resolveReferences(mapping);

        return mapping;
    }

    this.mapSchemas = async function() {
        return await _dao.getSchemas();
    }

    this.mapTables = async function() {
        return await _dao.getTables();
    }

    this.mapColumns = async function() {
        return await _dao.getColumns();
    }
}

module.exports = DatabaseMapper;