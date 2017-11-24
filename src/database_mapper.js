'use strict';

require('rootpath')();

const DatabaseMap = require('src/models/database_map');
const MappingReferenceResolver = require('src/mapping_reference_resolver');
const DatabaseMapperDaoFactory = require('src/dao/database_mapper_dao_factory');

function DatabaseMapper(dao) {
    let _dao = dao;

    this.map = async function() {
        let referenceResolver = new MappingReferenceResolver();

        let schemas = await this.mapSchemas();
        let tables = await this.mapTables();
        let columns = await this.mapColumns();
        let primaryKeys = await this.mapPrimaryKeys();
        let foreignKeys = await this.mapForeignKeys();

        let mapping = new DatabaseMap();
        mapping.databaseType = dao.getDatabaseType();
        mapping.databaseName = dao.getDatabaseName();
        mapping.schemas = schemas;
        mapping.tables = tables;
        mapping.columns = columns;
        mapping.constraints.push(...primaryKeys);
        mapping.constraints.push(...foreignKeys);
        
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

    this.mapPrimaryKeys = async function() {
        return await _dao.getPrimaryKeys();
    }

    this.mapForeignKeys = async function() {
        return await _dao.getForeignKeys();
    }
}

module.exports = DatabaseMapper;