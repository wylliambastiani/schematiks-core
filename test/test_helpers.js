'use strict';

const sinon = require('sinon');

function createFunctionStubReturnsEmptyList() {
    return function () { 
        let stub = sinon.stub().resolves([]);
        let promise = stub();
        return promise;
     };
}

function createFunctionStubReturnsNonEmptyList(list) {
    return function () {
        let stub = sinon.stub().resolves(list);
        let promise = stub()
        return promise;
    }
}

module.exports = {
    createFunctionStubReturnsEmptyList,
    createFunctionStubReturnsNonEmptyList
}