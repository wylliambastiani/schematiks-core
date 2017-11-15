'use strict';


function Constraint(id, name, type, sourceTableId, sourceColumnId, destinationTableId, destinationColumnId ) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.sourceTableId = sourceTableId;
    this.sourceColumnId = sourceColumnId;
    this.destinationTableId = destinationTableId;
    this.destinationColumnId = destinationColumnId;
    this.sourceTable = undefined;
    this.sourceColumns = undefined;
    this.destinationTable = undefined;
    this.destinationColumns = undefined; 
};

module.exports = Constraint;