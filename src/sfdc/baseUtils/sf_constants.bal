
//Latest API Version
# Constant field `API_VERSION`. Holds the value for the Salesforce API version.
final string API_VERSION = "v48.0";

// For URL encoding
# Constant field `ENCODING_CHARSET`. Holds the value for the encoding charset.
final string ENCODING_CHARSET = "utf-8";

//Salesforce endpoints
# Constant field `BASE_PATH`. Holds the value for the Salesforce base path/URL.
final string BASE_PATH = "/services/data";

# Constant field `API_BASE_PATH`. Holds the value for the Salesforce API base path/URL.
final string API_BASE_PATH = string `${BASE_PATH}/${API_VERSION}`;

# Constant field `QUERY`. Holds the value query for SOQL query resource prefix and bulk API query operator.
const  QUERY = "query";

# Constant field `q`. Holds the value q for query resource prefix.
final string Q = "q";

# Constant field `QUESTION_MARK`. Holds the value of "?".
final string QUESTION_MARK = "?";

# Constant field `EQUAL_SIGN`. Holds the value of "=".
final string EQUAL_SIGN = "=";

# Constant field `EMPTY_STRING`. Holds the value of "".
final string EMPTY_STRING = "";

# Constant field `AMPERSAND`. Holds the value of "&".
final string AMPERSAND = "&";

# Constant field `FORWARD_SLASH`. Holds the value of "/".
final string FORWARD_SLASH = "/";

# Constant field `SOBJECTS`. Holds the value sobjects for get sobject resource prefix.
final string SOBJECTS = "sobjects";

// ================ Salesforce bulk client constants =======================================

# Constant field `BULK_API_VERSION`. Holds the value for the Salesforce Bulk API version.
const BULK_API_VERSION = "48.0";

# Constant field `SERVICES`. Holds the value of "services".
const SERVICES = "services";

# Constant field `ASYNC`. Holds the value of "async".
const ASYNC = "async";

// Bulk API Operators

# Constant field `INSERT`. Holds the value of "insert" for insert operator.
const INSERT = "insert";

# Constant field `UPSERT`. Holds the value of "upsert" for upsert operator.
const UPSERT = "upsert";

# Constant field `UPDATE`. Holds the value of "update" for update operator.
const UPDATE = "update";

# Constant field `DELETE`. Holds the value of "delete" for delete operator.
const DELETE = "delete";

// Content types allowed by Bulk API

# Constant field `CSV`. Holds the value of "CSV".
const CSV = "CSV";

# Constant field `XML`. Holds the value of "XML".
const XML = "XML";

# Constant field `JSON`. Holds the value of "JSON".
const JSON = "JSON";

// Salesforce bulk API terms

# Constant field `JOB`. Holds the value of "job".
const JOB = "job";

# Constant field `BATCH`. Holds the value of "batch".
const BATCH = "batch";

# Constant field `REQUEST`. Holds the value of "request".
const REQUEST = "request";


// Content types

# Constant field `APP_XML`. Holds the value of "application/xml".
const APP_XML =  "application/xml";

# Constant field `APP_JSON`. Holds the value of "application/xml".
const APP_JSON =  "application/json";

# Constant field `TEXT_CSV`. Holds the value of "text/csv".
const TEXT_CSV = "text/csv";

# Constant field `CONTENT_TYPE`. Holds the value of "Content-Type".
const CONTENT_TYPE = "Content-Type";


# Constant field `ACCOUNT`. Holds the value Account for account object.
final string ACCOUNT = "Account";

# Constant field `X_SFDC_SESSION`. 
# Holds the value of "X-SFDC-Session" which used as Authorization header name of bulk API.
const X_SFDC_SESSION = "X-SFDC-Session";

# Constant field `AUTHORIZATION`. 
# Holds the value of "Authorization" which used as Authorization header name of REST API.
const AUTHORIZATION = "Authorization";

# Constant field `BEARER`. Holds the value of "Bearer".
const BEARER = "Bearer ";

# Constant field `INVALID_SESSION_ID`. 
# Holds the value of "InvalidSessionId" which used to identify Unauthorized 401 response.
const INVALID_SESSION_ID = "InvalidSessionId";