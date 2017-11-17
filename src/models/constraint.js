'use strict';


function Constraint(id, name, type, sourceTarget, destinationTarget) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.sourceTarget = sourceTarget;
    this.destinationTarget = destinationTarget;
};

module.exports = Constraint;