'use strict';


function Constraint(id, name, type, sourceTableId, sourceColumnIds, destinationTableId, destinationColumnIds) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.sourceTableId = sourceTableId;
    this.sourceColumnIds = sourceColumnIds;
    this.destinationTableId = destinationTableId;
    this.destinationColumnIds = destinationColumnIds;
    this.sourceTable = null;
    this.destinationTable = null;
};

module.exports = Constraint;