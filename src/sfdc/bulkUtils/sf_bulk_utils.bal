import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/lang.'string as strings;
import ballerina/lang.'int as ints;

# Check HTTP response and return JSON payload if succesful, else set errors and return Error.
# + httpResponse - HTTP response or error occurred
# + return - JSON response if successful else Error occured
function checkJsonPayloadAndSetErrors(http:Response|error httpResponse) returns @tainted json|Error {
    if (httpResponse is http:Response) {

        if (httpResponse.statusCode == http:STATUS_OK || httpResponse.statusCode == http:STATUS_CREATED 
            || httpResponse.statusCode == http:STATUS_NO_CONTENT) {
            json|error response = httpResponse.getJsonPayload();
            if (response is json) {
                return response;
            } else {
                log:printError(JSON_ACCESSING_ERROR_MSG, err = response);
                return Error(JSON_ACCESSING_ERROR_MSG, response);
            }
        } else {
            return handleJsonErrorResponse(httpResponse);
        }
    } else {
        return handleHttpError(httpResponse);
    }
}


# Convert ReadableByteChannel to string.
# 
# + rbc - ReadableByteChannel
# + return - converted string
function convertToString(io:ReadableByteChannel rbc) returns @tainted string|Error {
    byte[] readContent;
    string textContent = "";
    while (true) {
        byte[]|io:Error result = rbc.read(1000);
        if (result is io:EofError) {
            break;
        } else if (result is io:Error) {
            string errMsg = "Error occurred while reading from Readable Byte Channel.";
            log:printError(errMsg, err = result);
            return Error(errMsg, result);
        } else {
            readContent = result;
            string|error readContentStr = strings:fromBytes(readContent);
            if (readContentStr is string) {
                textContent = textContent + readContentStr; 
            } else {
                string errMsg = "Error occurred while converting readContent byte array to string.";
                log:printError(errMsg, err = readContentStr);
                return Error(errMsg, readContentStr);
            }                 
        }
    }
    return textContent;
}


# Convert ReadableByteChannel to json.
# 
# + rbc - ReadableByteChannel
# + return - converted json
function convertToJson(io:ReadableByteChannel rbc) returns @tainted json|Error {
    io:ReadableCharacterChannel|io:Error rch = new(rbc, ENCODING_CHARSET);

    if (rch is io:Error) {
        string errMsg = "Error occurred while converting ReadableByteChannel to ReadableCharacterChannel.";
        log:printError(errMsg, err = rch);
        return Error(errMsg, rch);
    } else {
        json|error jsonContent = rch.readJson();

        if (jsonContent is json) {
            return jsonContent;
        } else {
            string errMsg = "Error occurred while reading ReadableCharacterChannel as json.";
            log:printError(errMsg, err = jsonContent);
            return Error(errMsg, jsonContent);
        }
    }
}

# Handle HTTP error response and return Error.
# + httpResponse - error response
# + return - error
function handleJsonErrorResponse(http:Response httpResponse) returns @tainted Error {
    json|error response = httpResponse.getJsonPayload();
    if (response is json) {
        Error httpResponseHandlingError = Error(response.exceptionCode.toString());
        return httpResponseHandlingError;
    } else {
        log:printError(ERR_EXTRACTING_ERROR_MSG, err = response);
        return Error(ERR_EXTRACTING_ERROR_MSG, response);
    }
} 


# Handle HTTP error and return Error.
# + return - Constructed error
function handleHttpError( error httpResponse) returns Error {
    log:printError(HTTP_ERROR_MSG, err = httpResponse);
    Error httpError = Error(HTTP_ERROR_MSG, httpResponse);
    return httpError;
}

# Convert string to integer
# + value - string value
# + return - converted integer
function getIntValue(string value) returns int {
    int | error intValue = ints:fromString(value);
    if (intValue is int) {
        return intValue;
    } else {
        log:printError("String to int conversion failed, string value='" + value + "' ", err = intValue);
        panic intValue;
    }
}


# Logs, prepares, and returns the `AuthenticationError`.
#
# + message -The error message.
# + err - The `error` instance.
# + return - Returns the prepared `AuthenticationError` instance.
function prepareAuthenticationError(string message, error? err = ()) returns http:AuthenticationError {
    log:printDebug(function () returns string { return message; });
    if (err is error) {
        http:AuthenticationError preparedError = http:AuthenticationError(message, cause = err);
        return preparedError;
    }
    http:AuthenticationError preparedError = http:AuthenticationError(message);
    return preparedError;
}

# Creates a map out of the headers of the HTTP response.
#
# + resp - The `Response` instance.
# + return - Returns the map of the response headers.
function createResponseHeaderMap(http:Response resp) returns @tainted map<anydata> {
    map<anydata> headerMap = {};

    // If session ID is invalid, set staus code as 401.
    if (resp.statusCode == http:STATUS_BAD_REQUEST) {
        string contentType = resp.getHeader(CONTENT_TYPE);
        if (contentType == APP_JSON) {
            json | error payload = resp.getJsonPayload();
            if (payload is json){
                if (payload.exceptionCode == INVALID_SESSION_ID) {
                    headerMap[http:STATUS_CODE] = http:STATUS_UNAUTHORIZED;
                }
            } else {
                log:printError("Invalid payload", err = payload);
            }
        } else if (contentType == APP_XML) {
            xml | error payload = resp.getXmlPayload();
            if (payload is xml){
                if ((payload/<exceptionCode>/*).toString() == INVALID_SESSION_ID) {
                    headerMap[http:STATUS_CODE] = http:STATUS_UNAUTHORIZED;
                }
            } else {
                log:printError("Invalid payload", err = payload);
            }
        } else {
            log:printError("Invalid contentType, contentType='" + contentType + "' ", err = ());
        }
    } else {
        headerMap[http:STATUS_CODE] = resp.statusCode;
    }

    string[] headerNames = resp.getHeaderNames();
    foreach string header in headerNames {
        string[] headerValues = resp.getHeaders(<@untainted> header);
        headerMap[header] = headerValues;
    }
    return headerMap;
}