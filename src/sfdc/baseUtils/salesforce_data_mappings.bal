import ballerina/log;

function toSoqlResult(json payload) returns SoqlResult|Error {
    SoqlResult|error res = payload.cloneWithType(SoqlResult);

    if (res is SoqlResult) {
        return res;
    } else {
        string errMsg = "Error occurred while constructing SoqlResult record.";
        log:printError(errMsg + " payload:" + payload.toJsonString(), err = res);
        return Error(errMsg, res);
    }
}