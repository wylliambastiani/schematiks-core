
'use strict';

function ConnectionSettings(dataSource, databaseName, user, password, databaseType) {
    this.dataSource = dataSource;
    this.databaseName = databaseName;
    this.user = user;
    this.password = password;
    this.databaseType = databaseType;
}

module.exports = ConnectionSettings;  