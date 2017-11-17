'use strict';

function ConstraintTarget(tableId, constraintColumns) {
    this.tableId = tableId;
    this.constraintColumns = constraintColumns;
    this.table = null;
}

module.exports = ConstraintTarget;