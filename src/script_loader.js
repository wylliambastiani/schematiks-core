'use strict';

require('rootpath')();

const fs = require('fs');
const path = require('path');
const DatabaseTypes = require('src/models/database_types.js')
const Script = require('src/models/script.js');

function ScriptLoader(databaseType) {
    const _fileExtensionLength = 4;
    
    let _scriptsLoaded = false;
    let _versionAgnosticScripts = {};
    let _versionSpecificScripts = {};

    function getScriptsDirPath () {
        switch (databaseType) {
            case DatabaseTypes.MSSQL_2016:
                return 'src/scripts/mssql/';

            default:
                throw new Error(`Not supported database: ${databaseType}`)
        }
    }

    function readDirectorySqlFiles (dirPath) {
        let sqlFiles = [];

        if (!fs.existsSync(dirPath))
            return [];

        let filesNames = fs.readdirSync(dirPath);
        for (let fileName of filesNames) {
            let filePath = path.join(dirPath, fileName);

            let isSqlFile = /\w+\.sql/.test(filePath);
            if (isSqlFile) {
                var fileContent = fs.readFileSync(filePath, 'utf8');

                let filesNameWithoutExtension = fileName.substr(0, fileName.length - _fileExtensionLength);
                sqlFiles.push(new Script(filesNameWithoutExtension, fileContent));
            }
        }
        
        return sqlFiles;
    }

    this.getScript = function (scriptName) {
        if (!_scriptsLoaded) {
            let scriptsDirPath = getScriptsDirPath();
            _versionAgnosticScripts = readDirectorySqlFiles(scriptsDirPath);
            _versionSpecificScripts = readDirectorySqlFiles(scriptsDirPath + databaseType.toLowerCase() + '/');
        
            _scriptsLoaded = true;
        }

        let matches = _versionSpecificScripts.filter((script) => { return script.name === scriptName });
        if (matches.length > 0) {
            return matches[0].content;
        } else {
            matches = _versionAgnosticScripts.filter((script) => { return script.name === scriptName });
            if (matches.length > 0) {
                return matches[0].content;
            }

            throw new Error(`Script ${scriptName} not found`);
        }
    }
}

module.exports = ScriptLoader;