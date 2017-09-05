
'use strict';

function Schema(id, name) {
    this.id = id;
    this.name = name;
    this.tables = [];
}

module.exports = Schema;
