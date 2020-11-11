import ballerina/encoding;
import ballerina/http;
import ballerina/log;

# Returns the prepared URL.
# + paths - An array of paths prefixes
# + return - The prepared URL
function prepareUrl(string[] paths) returns string {
    string url = EMPTY_STRING;

    if (paths.length() > 0) {
        foreach var path in paths {
            if (!path.startsWith(FORWARD_SLASH)) {
                url = url + FORWARD_SLASH;
            }
            url = url + path;
        }
    }
    return <@untainted> url;
}

# Returns the prepared URL with encoded query.
# + paths - An array of paths prefixes
# + queryParamNames - An array of query param names
# + queryParamValues - An array of query param values
# + return - The prepared URL with encoded query
function prepareQueryUrl(string[] paths, string[] queryParamNames, string[] queryParamValues) returns string {

    string url = prepareUrl(paths);

    url = url + QUESTION_MARK;
    boolean first = true;
    int i = 0;
    foreach var name in queryParamNames {
        string value = queryParamValues[i];

        var encoded = encoding:encodeUriComponent(value, ENCODING_CHARSET);

        if (encoded is string) {
            if (first) {
                url = url + name + EQUAL_SIGN + encoded;
                first = false;
            } else {
                url = url + AMPERSAND + name + EQUAL_SIGN + encoded;
            }
        } else {
            log:printError("Unable to encode value: " + value, err = encoded);
            break;
        }
        i = i + 1;
    }

    return url;
}


function toOrgMetadata(json payload) returns OrgMetadata|Error {
    OrgMetadata|error res = payload.cloneWithType(OrgMetadata);

    if (res is OrgMetadata) {
        return res;
    } else {
        string errMsg = "Error occurred while constructing OrgMetadata record.";
        log:printError(errMsg + " payload:" + payload.toJsonString(), err = res);
        return Error(errMsg, res);
    }
}


# Check HTTP response and return JSON payload if succesful, else set errors and return Error.
# + httpResponse - HTTP respone or Error
# + expectPayload - Payload is expected or not
# + return - JSON result if successful, else Error occured
function checkAndSetErrors(http:Response|http:Payload|error httpResponse, boolean expectPayload = true) 
    returns @tainted json|Error {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_OK || httpResponse.statusCode == http:STATUS_CREATED 
            || httpResponse.statusCode == http:STATUS_NO_CONTENT) {

            if (expectPayload) {
                json|error jsonResponse = httpResponse.getJsonPayload();

                if (jsonResponse is json) {
                    return jsonResponse;
                } else {
                    log:printError(JSON_ACCESSING_ERROR_MSG, err = jsonResponse);
                    return Error(JSON_ACCESSING_ERROR_MSG, jsonResponse);
                }

            } else {
                json result = {};
                return result;
            }

        } else {
            json|error jsonResponse = httpResponse.getJsonPayload();

            if (jsonResponse is json) {
                json[] errArr = <json[]> jsonResponse;

                string errCodes = "";
                string errMssgs = "";
                int counter = 1;

                foreach json err in errArr {
                    errCodes = errCodes + err.errorCode.toString();
                    errMssgs = errMssgs + err.message.toString();
                    if (counter != errArr.length()) {
                        errCodes = errCodes + ", ";
                        errMssgs = errMssgs + ", ";
                    }
                    counter = counter + 1;
                }

                return Error(errMssgs, errorCodes = errCodes);
            } else {
                log:printError(ERR_EXTRACTING_ERROR_MSG, err = jsonResponse);
                return Error(ERR_EXTRACTING_ERROR_MSG, jsonResponse);
            }
        }
    } else if (httpResponse is http:Payload) {
        if (httpResponse is json) {
            json[] errArr = <json[]> httpResponse;

            string errCodes = "";
            string errMssgs = "";
            int counter = 1;

            foreach json err in errArr {
                errCodes = errCodes + err.errorCode.toString();
                errMssgs = errMssgs + err.message.toString();
                if (counter != errArr.length()) {
                    errCodes = errCodes + ", ";
                    errMssgs = errMssgs + ", ";
                }
                counter = counter + 1;
            }

            return Error(errMssgs, errorCodes = errCodes);
        } else {
            log:printError(ERR_EXTRACTING_ERROR_MSG);
            return Error(ERR_EXTRACTING_ERROR_MSG);
        }
    } else {
        log:printError(HTTP_ERROR_MSG, err = httpResponse);
        return Error(HTTP_ERROR_MSG, httpResponse);
    }
}
