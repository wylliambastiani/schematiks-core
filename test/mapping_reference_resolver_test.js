'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require('chai').expect;
const testHelpers = require('test/test_helpers');
const MappingReferenceResolver = require('src/mapping_reference_resolver');
const DatabaseMap = require('src/models/database_map');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');
const Constraint = require('src/models/constraint');
const ConstraintTypes = require('src/models/constraint_types');


describe('MappingReferenceResolver', function () {
    describe ('resolveSchemaTableReferences', function () {
        it ('should set no object reference for not related objects', async function () {
            let mapping = new DatabaseMap();
            mapping.schemas = [
                new Schema(1, 'dbo')
            ];
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 99)
            ];

            let referenceResolver = new MappingReferenceResolver();
            referenceResolver.resolveSchemaTableReferences(mapping.schemas, mapping.tables);

            expect(mapping.schemas[0].tables).to.be.empty;
            expect(mapping.tables[0].schema).to.be.null;
        });

        it ('should set schema table references for related objects only', function () {
            let mapping = new DatabaseMap();2
            mapping.schemas = [
                new Schema(1, 'dbo'), 
                new Schema(2, 'admin'),
                new Schema(3, 'sys')
            ];
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1),
                new Table(2, 'table2', new Date(), new Date(), 1),
                new Table(3, 'table3', new Date(), new Date(), 2)
            ];

            let referenceResolver = new MappingReferenceResolver();
            referenceResolver.resolveSchemaTableReferences(mapping.schemas, mapping.tables);

            expect(mapping.schemas[0].tables).to.have.lengthOf(2);
            expect(mapping.schemas[1].tables).to.have.lengthOf(1);
            expect(mapping.schemas[2].tables).to.have.lengthOf(0);
            expect(mapping.tables[0].schema).to.be.equal(mapping.schemas[0]);
            expect(mapping.tables[1].schema).to.be.equal(mapping.schemas[0]);
            expect(mapping.tables[2].schema).to.be.equal(mapping.schemas[1]);
        });
    });

    describe ('resolveTableColumnReferences', function () {
        it ('should set no object reference for not related objects', async function () {
            let mapping = new DatabaseMap();
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1)
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 99),
            ];

            let referenceResolver = new MappingReferenceResolver();
            referenceResolver.resolveTableColumnReferences(mapping.tables, mapping.columns);

            expect(mapping.tables[0].columns).to.have.lengthOf(0);
            expect(mapping.columns[0].table).to.be.null;
        });

        it ('should set table column references for related objects only', function () {
            let mapping = new DatabaseMap();
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1)
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 1),
                new Column(2, 'column2', 'int', null, null, null, null, false, true, 1, 1, false, 1),
                new Column(3, 'column3', 'int', null, null, null, null, false, true, 1, 1, false, 2),
            ];

            let referenceResolver = new MappingReferenceResolver();
            referenceResolver.resolveTableColumnReferences(mapping.tables, mapping.columns);

            expect(mapping.tables[0].columns).to.have.lengthOf(2);
            expect(mapping.columns[0].table).to.be.equal(mapping.tables[0]);
            expect(mapping.columns[1].table).to.be.equal(mapping.tables[0]);
            expect(mapping.columns[2].table).to.be.null;
        });
    });

    describe ('resolvePrimaryKeyReferences', function (){ 
        // resolve primary key refereces
        it ('should set no object reference for not related objects', function () {
            let mapping = new DatabaseMap();
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1)
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 1),
            ];
            mapping.primaryKeys = [
                new Constraint(1, 'PK_Table2_Column1', ConstraintTypes.PK, 99, 1, null, null)
            ];

            let referenceResolver = new MappingReferenceResolver();
            referenceResolver.resolvePrimaryKeyReferences(mapping.tables, mapping.primaryKeys);

            expect(mapping.tables[0].constraints).to.have.lengthOf(0);
            expect(mapping.primaryKeys[0].sourceTable).to.be.null;
        });

        it ('should set primary key references for related objects only', async function () {
            let mapping = new DatabaseMap();
            mapping.tables = [
                new Table(1, 'table1', new Date(), new Date(), 1)
            ];
            mapping.columns = [
                new Column(1, 'column1', 'int', null, null, null, null, false, true, 1, 1, false, 1),
            ];
            mapping.primaryKeys = [
                new Constraint(1, 'PK_Table1_Column1', ConstraintTypes.PK, 1, 1, null, null)
            ];

            let referenceResolver = new MappingReferenceResolver();
            referenceResolver.resolvePrimaryKeyReferences(mapping.tables, mapping.primaryKeys);

            expect(mapping.tables[0].constraints).to.have.lengthOf(1);
            expect(mapping.primaryKeys[0].sourceTable).to.not.be.null;
        });
    });
});