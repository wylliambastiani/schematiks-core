'use strict';

function ConstraintColumn(columnId, is_descending_key) {
    this.columnId = columnId;
    this.is_descending_key = is_descending_key;
}

module.exports = ConstraintColumn;