
'use strict';

function DatabaseMap() {
    this.databaseName = undefined;
    this.databaseType = undefined;
    this.schemas = [];
    this.tables = [];
    this.columns = [];
    this.constraints = [];
}

module.exports = DatabaseMap;