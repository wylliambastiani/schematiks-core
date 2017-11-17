
'use strict';

require('rootpath')();

const mssql = require('mssql');
const S = require('string');
const ScriptLoader = require('src/script_loader');
const Schema = require('src/models/schema');
const Table = require('src/models/table');
const Column = require('src/models/column');
const Constraint = require('src/models/constraint');
const ConstraintColumn = require('src/models/constraint_column');
const ConstraintTarget = require('src/models/constraint_target');

function MSSQLDatabaseMapperDao(connectionSettings) {
    let _connectionSettings = connectionSettings;
    let _connectionString = `Data Source=${_connectionSettings.dataSource};` +
                            `Initial Catalog=${_connectionSettings.databaseName};` +
                            `User Id=${_connectionSettings.user};` +
                            `Password=${_connectionSettings.password};`;

    let _scriptLoader = new ScriptLoader(_connectionSettings.databaseType);

    function parseQuerySlots(query) {
        let parsedQuery = S(query).replaceAll('{DatabaseName}', _connectionSettings.databaseName);
        return parsedQuery.toString();
    }

    async function getDatabaseObject(scriptName) {
        let connection = new mssql.ConnectionPool(_connectionString);
        let pool;

        try {
            pool = await connection.connect();;
            let query = _scriptLoader.getScript(scriptName);
            let parsedQuery = parseQuerySlots(query);
            let request = pool.request().query(parsedQuery);
            let result = await request;
            return result;
        }
        catch (err) {
            throw new Error(err);
        }
        finally {
            pool.close();
        }
    };

    this.getSchemas = async function () {
        let result = await getDatabaseObject('select_all_database_schemas');
        return result.recordset.map(row => { 
            return new Schema(row.schema_id, row.schema_name); 
        });
    }

    this.getTables = async function() {
        let result = await getDatabaseObject('select_all_database_tables');
        return result.recordset.map(row => {
            return new Table(row.table_id, row.table_name, row.table_create_date, row.table_modify_date, row.schema_id, row.hasData);
        }); 
    }

    this.getColumns = async function() {
        let result = await getDatabaseObject('select_all_database_columns');
        return result.recordset.map(row => {
            return new Column(
                row.column_id, 
                row.column_name, 
                row.column_type,
                row.column_max_length,
                row.column_precision,
                row.column_scale,
                row.column_collation_name,
                row.columns_is_nullable,
                row.column_is_identity,
                row.column_identity_seed_value,
                row.column_identity_increment_value,
                row.column_is_computed,
                row.table_id
            );
        });
    }

    this.getPrimaryKeys = async function() {
        let result = await getDatabaseObject('select_all_database_primary_keys');
        let constraints = result.recordset.map(constraint => {
            return new Constraint(
                constraint.constraint_id,
                constraint.constraint_name,
                constraint.constraint_type,
                new ConstraintTarget(constraint.table_id, [new ConstraintColumn(constraint.column_id, constraint.is_descending_key)]),
                null
            );
        });

        let joinedConstraints = [];
        for (let constraint of constraints) {
            let constraintAlreadyJoined = false;
            
            for (let alreadyJoinedConstraint of joinedConstraints) {
                if (alreadyJoinedConstraint.id === constraint.id) {
                    alreadyJoinedConstraint.sourceTarget.constraintColumns.push(...constraint.sourceTarget.constraintColumns);
                    constraintAlreadyJoined = true;
                }
            }

            if (!constraintAlreadyJoined) {
                joinedConstraints.push(constraint);
            }
        }

        return joinedConstraints;
    }

    this.getDatabaseType = function() {
        return _connectionSettings.databaseType;
    }

    this.getDatabaseName = function() {
        return _connectionSettings.databaseName;
    }
}

module.exports = MSSQLDatabaseMapperDao;