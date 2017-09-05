
'use strict';

function Table(id, name, createDate, modifyDate, schemaId) {
    this.id = id;
    this.name = name;
    this.createDate = createDate;
    this.modifyDate = modifyDate;
    this.schemaId = schemaId;
    this.schema = null;
    this.columns = [];

    Object.defineProperty(this, 'fullName', {
        get: function() { 
            if (this.schema === null || this.schema === undefined) {
                throw new Error('No schema associated, cannot resolve full table name');
            }

            return this.schema.name + '.' + this.name;
        }
    });
}

module.exports = Table;