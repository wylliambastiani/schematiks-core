
'use strict';

function DatabaseObjectDiff(previousObjectVersion, currentObjectVersion, state, differentProperties) {
    let _previousObjectVersion = previousObjectVersion;
    let _currentObjectVersion = currentObjectVersion;
    let _diffState = state;
    let _differentProperties = differentProperties || [];

    Object.defineProperties(this, {
        'previousObjectVersion': {
            get: function () { return _previousObjectVersion; }
        },
        'currentObjectVersion': {
            get: function () { return _currentObjectVersion; }
        },
        'diffState' : {
            get: function () { return _diffState; }
        },
        'differentProperties': {
            get: function () { return _differentProperties; }
        }
    });
}

module.exports = DatabaseObjectDiff;