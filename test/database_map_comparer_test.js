'use strict';

require('rootpath')();

const mocha = require('mocha');
const expect = require  ('chai').expect;
const DatabaseMap = require('src/models/database_map');
const DatabaseMapComparer = require('src/database_map_comparer');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');
const DatabaseObjectDiffState = require('src/models/database_object_diff_state');

describe ('DatabaseMapComparer', function () {
    describe ('compare', function () {
        it ('should return empty schemaDiff list if there is no schemas difference', function () {
            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [new Schema(1, 'dbo')];
            
            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [new Schema(1, 'dbo')];

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.schemasDiff).to.be.empty;
        });

        it ('should return deleted schemas', function () {
            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [
                new Schema(1, 'dbo')
            ];

            let currentDatabaseMap = new DatabaseMap();

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.schemasDiff).to.have.lengthOf(1);
            expect(diff.schemasDiff[0].previousObjectVersion).to.be.equal(previousDatabaseMap.schemas[0]);
            expect(diff.schemasDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.DELETED);
        });

        it ('should return created schemas', function () {
            let previousDatabaseMap = new DatabaseMap();
            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [
                new Schema(1, 'CreatedSchema')
            ];

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.schemasDiff).to.have.lengthOf(1);
            expect(diff.schemasDiff[0].currentObjectVersion).to.be.equal(currentDatabaseMap.schemas[0]);
            expect(diff.schemasDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.CREATED);
        });

        it ('should return deleted tables', function () {
            // previous database map schema and table
            let previousDatabaseMapSchema = new Schema(1, 'dbo');
            let previousDatabaseMapTable = new Table(1, 'Table1', new Date(), new Date(), 1);
            previousDatabaseMapTable.schema = previousDatabaseMapSchema;

            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [ previousDatabaseMapSchema ];
            previousDatabaseMap.tables = [ previousDatabaseMapTable ];

            // current database map
            let currentDatabaseMap = new DatabaseMap();

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.have.lengthOf(1);
            expect(diff.tablesDiff[0].previousObjectVersion).to.be.equal(previousDatabaseMapTable);
            expect(diff.tablesDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.DELETED);
        });

        it ('should return created tables', function () {
            // previous database map
            let previousDatabaseMap = new DatabaseMap();
            
            // current database map schema and table
            let currentDatabaseMapSchema = new Schema(1, 'dbo');
            let currentDatabaseMapTable = new Table(1, 'Table1', new Date(), new Date(), 1);
            currentDatabaseMapTable.schema = currentDatabaseMapSchema;
            
            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [ currentDatabaseMapSchema ];
            currentDatabaseMap.tables = [ currentDatabaseMapTable ];

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.have.lengthOf(1);
            expect(diff.tablesDiff[0].currentObjectVersion).to.be.equal(currentDatabaseMap.tables[0]);
            expect(diff.tablesDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.CREATED);
        });

        it ('should return empty tableDiff list if no tables has different modify_date', function() {
            // previous database map
            let schema = new Schema(1, 'dbo');
            let table = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            table.schema = schema;

            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [ schema ];
            previousDatabaseMap.tables = [ table ];

            // current database map 
            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [ schema ];
            currentDatabaseMap.tables = [ table ];

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.be.empty;
        });

        it ('should return non empty tablesDiff list if the same table has different modify_date', function() {
            let schema = new Schema(1, 'dbo');

            // previous database map
            let previousDatabaseMapTableModified = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            previousDatabaseMapTableModified.schema = schema;
            let previousDatabaseMapTableNotModified = new Table(2, 'Table2', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            previousDatabaseMapTableNotModified.schema = schema;

            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [ schema ];
            previousDatabaseMap.tables = [ previousDatabaseMapTableModified, previousDatabaseMapTableNotModified ];

            // current database map
            let currentDatabaseMapTableModified = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1,), new Date(2017, 1, 1, 1, 1, 1, 99), 1);            
            currentDatabaseMapTableModified.schema = schema;
            let currentDatabaseMapTableNotModified = new Table(2, 'Table2', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            currentDatabaseMapTableNotModified.schema = schema;

            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [ schema ];
            currentDatabaseMap.tables = [ currentDatabaseMapTableModified, currentDatabaseMapTableNotModified ];

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.have.lengthOf(1);
            expect(diff.tablesDiff[0].previousObjectVersion).to.be.equals(previousDatabaseMapTableModified);
            expect(diff.tablesDiff[0].currentObjectVersion).to.be.equals(currentDatabaseMapTableModified);
            expect(diff.tablesDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.ALTERED);
        });

        it ('should return deleted columns', function() {
            let schema = new Schema(1, 'dbo');

            // previous database map
            let previousDatabaseMapTable = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            previousDatabaseMapTable.schema = schema;
            previousDatabaseMapTable.columns = [
                new Column(1, 'Id', 'int', 0, 0, 0, null, false, true, 1, 1, false, 1),
                new Column(2, 'Name', 'varchar', 20, 0, 0, 'SQL_Latin1_General_CP1_CI_AS', true, false, null, null, false, 1)
            ];
            
            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [ schema ];
            previousDatabaseMap.tables = [ previousDatabaseMapTable ];
            previousDatabaseMap.columns = previousDatabaseMapTable.columns;

            // current database map
            let currentDatabaseMapTable = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 2), 1);
            currentDatabaseMapTable.schema = schema;
            currentDatabaseMapTable.columns = [
                new Column(1, 'Id', 'int', 0, 0, 0, null, false, true, 1, 1, false, 1)
            ];

            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [ schema ];
            currentDatabaseMap.tables = [ currentDatabaseMapTable ];
            currentDatabaseMap.columns = currentDatabaseMapTable.columns;

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.have.lengthOf(1);
            expect(diff.columnsDiff).to.have.lengthOf(1);
            expect(diff.tablesDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.ALTERED);
            expect(diff.columnsDiff[0].previousObjectVersion).to.be.equal(previousDatabaseMapTable.columns[1]);
            expect(diff.columnsDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.DELETED);
        });

        it ('should return created columns', function () {
            let schema = new Schema(1, 'dbo');

            // previous database map
            let previousDatabaseMapTable = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            previousDatabaseMapTable.schema = schema;
            previousDatabaseMapTable.columns = [
                new Column(1, 'Id', 'int', 0, 0, 0, null, false, true, 1, 1, false, 1)
            ];
            
            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [ schema ];
            previousDatabaseMap.tables = [ previousDatabaseMapTable ];
            previousDatabaseMap.columns = previousDatabaseMapTable.columns;

            // current database map
            let currentDatabaseMapTable = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 2), 1);
            currentDatabaseMapTable.schema = schema;
            currentDatabaseMapTable.columns = [
                new Column(1, 'Id', 'int', 0, 0, 0, null, false, true, 1, 1, false, 1),
                new Column(2, 'Name', 'varchar', 20, 0, 0, 'SQL_Latin1_General_CP1_CI_AS', true, false, null, null, false, 1)
            ];

            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [ schema ];
            currentDatabaseMap.tables = [ currentDatabaseMapTable ];
            currentDatabaseMap.columns = currentDatabaseMapTable.columns;

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.have.lengthOf(1);
            expect(diff.columnsDiff).to.have.lengthOf(1);
            expect(diff.tablesDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.ALTERED);
            expect(diff.columnsDiff[0].currentObjectVersion).to.be.equal(currentDatabaseMapTable.columns[1]);
            expect(diff.columnsDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.CREATED);
        });

        it ('should return modified columns', function () {
            let schema = new Schema(1, 'dbo');

            // previous database map
            let previousDatabaseMapTable = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 1), 1);
            previousDatabaseMapTable.schema = schema;
            previousDatabaseMapTable.columns = [
                new Column(1, 'Id', 'int', 0, 0, 0, null, false, true, 1, 1, false, 1),
                new Column(2, 'Name', 'varchar', 20, 0, 0, 'SQL_Latin1_General_CP1_CS_AS', true, false, null, null, false, 1)
            ];
            
            let previousDatabaseMap = new DatabaseMap();
            previousDatabaseMap.schemas = [ schema ];
            previousDatabaseMap.tables = [ previousDatabaseMapTable ];
            previousDatabaseMap.columns = previousDatabaseMapTable.columns;

            // current database map
            let currentDatabaseMapTable = new Table(1, 'Table1', new Date(2017, 1, 1, 1, 1, 1, 1), new Date(2017, 1, 1, 1, 1, 1, 2), 1);
            currentDatabaseMapTable.schema = schema;
            currentDatabaseMapTable.columns = [
                new Column(1, 'Id', 'int', 0, 0, 0, null, false, true, 1, 1, false, 1),
                new Column(2, 'Name', 'varchar', 50, 0, 0, 'SQL_Latin1_General_CP1_CI_AS', true, false, null, null, false, 1)
            ];

            let currentDatabaseMap = new DatabaseMap();
            currentDatabaseMap.schemas = [ schema ];
            currentDatabaseMap.tables = [ currentDatabaseMapTable ];
            currentDatabaseMap.columns = currentDatabaseMapTable.columns;

            let databaseMapComparer = new DatabaseMapComparer(previousDatabaseMap, currentDatabaseMap);
            databaseMapComparer.compare();

            let diff = databaseMapComparer.databaseMapDiff;

            expect(diff.tablesDiff).to.have.lengthOf(1);
            expect(diff.columnsDiff).to.have.lengthOf(1);
            expect(diff.columnsDiff[0].previousObjectVersion).to.be.equal(previousDatabaseMap.columns[1]);
            expect(diff.columnsDiff[0].currentObjectVersion).to.be.equal(currentDatabaseMap.columns[1]);
            expect(diff.columnsDiff[0].diffState).to.be.equal(DatabaseObjectDiffState.ALTERED);
            expect(diff.columnsDiff[0].differentProperties).to.have.lengthOf(2);
            expect(diff.columnsDiff[0].differentProperties[0]).to.be.equal('typeMaxLength');
            expect(diff.columnsDiff[0].differentProperties[1]).to.be.equal('collationName');
        });
    });
});