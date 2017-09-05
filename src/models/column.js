
'use strict';    

function Column(id, name, type, typeMaxLength, typePrecision, typeScale, collationName,
    isNullable, isIdentity, identitySeedValue, identityIncrementValue, isComputed, tableId) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.typeMaxLength = typeMaxLength;
        this.typePrecision = typePrecision;
        this.typeScale = typeScale;
        this.collationName = collationName;
        this.isNullable = isNullable;
        this.isIdentity = isIdentity;
        this.identitySeedValue = identitySeedValue;
        this.identityIncrementValue = identityIncrementValue;
        this.isComputed = isComputed;
        this.tableId = tableId; 
        this.table = null;
}

module.exports = Column;