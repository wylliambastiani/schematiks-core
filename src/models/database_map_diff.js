
'use strict';

function DatabaseMapDiff(previousDatabaseMap, currentDatabaseMap) {
    let _previousDatabaseMap = previousDatabaseMap;
    let _currentDatabaseMap = currentDatabaseMap;
    this.schemasDiff = [];
    this.tablesDiff = [];
    this.columnsDiff = [];

    Object.defineProperty(this, 'previousDatabaseMap', {
        get: function () { return _previousDatabaseMap; }
    });

    Object.defineProperty(this, 'currentDatabaseMap', {
        get: function () { return _currentDatabaseMap; }
    });
}

module.exports = DatabaseMapDiff;