import ballerina/http;
import ballerina/io;
import ballerina/oauth2;

# The Salesforce Bulk Client object.
# + httpClient - OAuth2 client endpoint
# + salesforceConfiguration - Salesforce Connector configuration
public client class BulkClient {
    http:Client httpClient;
    SalesforceConfiguration salesforceConfiguration;

    # The Salesforce Bulk client initialization function.
    # + salesforceConfig - the Salesforce Connector configuration
    public function init(SalesforceConfiguration salesforceConfig) {
        self.salesforceConfiguration = salesforceConfig;
        // Create the OAuth2 provider.
        oauth2:OutboundOAuth2Provider oauth2Provider = new(salesforceConfig.clientConfig);
        // Create the bearer auth handler using the created provider.
        SalesforceBulkAuthHandler bearerHandler = new(oauth2Provider);

        http:ClientSecureSocket? socketConfig = salesforceConfig?.secureSocketConfig;
        
        // Create an HTTP client.
        if (socketConfig is http:ClientSecureSocket) {
            self.httpClient = new(salesforceConfig.baseUrl, {
                secureSocket: socketConfig,
                auth: {
                    authHandler: bearerHandler
                }
            });
        } else {
            self.httpClient = new(salesforceConfig.baseUrl, {
                auth: {
                    authHandler: bearerHandler
                }
            });
        }
    }

    # Create a bulk job.
    #
    # + operation - type of operation like insert, delete, etc.
    # + sobj - kind of sobject 
    # + contentType - content type of the job 
    # + extIdFieldName - field name of the external ID incase of an Upsert operation
    # + return - returns job object or error
    public remote function creatJob(OPERATION operation, string sobj, JOBTYPE contentType, string extIdFieldName = "") returns @tainted error|BulkJob {
        json jobPayload = {
            "operation" : operation,
            "object" : sobj,
            "contentType" : contentType
        };
        if (UPSERT == operation) {
            if (extIdFieldName.length() > 0) {
                json extField = {
                    "externalIdFieldName" : extIdFieldName
                };
                jobPayload = check jobPayload.mergeJson(extField);
            } else {
                return error("External ID Field Name Required for UPSERT Operation!");
            }
        }        
        http:Request req = new;
        req.setJsonPayload(jobPayload);
        string path = prepareUrl([SERVICES, ASYNC, BULK_API_VERSION, JOB]);
        var response = self.httpClient->post(path, req);
        json|Error jobResponse = checkJsonPayloadAndSetErrors(response);
        if (jobResponse is json) {
            BulkJob bulkJob = new(jobResponse.id.toString(), contentType, operation, self.httpClient);
            return bulkJob;
        } else {
            return jobResponse;
        }
    }

    # Get information about a job.
    #
    # + bulkJob - job object of which the info is required 
    # + return - job information record or error
    public remote function getJobInfo(BulkJob bulkJob) returns @tainted error|JobInfo {
        string jobId = bulkJob.jobId;
        JOBTYPE jobDataType = bulkJob.jobDataType;
        string path = prepareUrl([SERVICES, ASYNC, BULK_API_VERSION, JOB, jobId]);
        http:Request req = new;
        var response = self.httpClient->get(path, req);
            json|Error jobResponse = checkJsonPayloadAndSetErrors(response);
            if (jobResponse is json){            
                JobInfo jobInfo = check jobResponse.cloneWithType(JobInfo);
                return jobInfo;
            } else {
                return jobResponse;
            }      
    }
}


# The Job object.
public class BulkJob {
    string jobId;
    JOBTYPE jobDataType;
    OPERATION operation;
    http:Client httpClient;


    public function init(string jobId, JOBTYPE jobDataType, OPERATION operation, http:Client httpClient) {
        self.jobId = jobId;
        self.jobDataType = jobDataType;
        self.operation = operation;
        self.httpClient = httpClient;

    }

    # Add batch to the job.
    #
    # + content - batch content 
    # + return - batch info or error
    public function addBatch(json|string|xml|io:ReadableByteChannel content) returns @tainted error|BatchInfo{
        string path = prepareUrl([SERVICES, ASYNC, BULK_API_VERSION, JOB, self.jobId, BATCH]);
        http:Request req = new;
        // https://github.com/ballerina-platform/ballerina-lang/issues/26446
        if(self.jobDataType == JSON) {
            if (content is json) {
                req.setJsonPayload(content);
            }
            if (content is string) {
                req.setTextPayload(content);
            }                
            if (content is io:ReadableByteChannel) {
                if (QUERY == self.operation) {
                    string payload = check convertToString(content);
                    req.setTextPayload(<@untainted>  payload);
                } else {
                    json payload = check convertToJson(content);
                    req.setJsonPayload(<@untainted>  payload);
                }
            }
            req.setHeader(CONTENT_TYPE, APP_JSON);
            var response = self.httpClient->post(path, req);
            json|Error batchResponse = checkJsonPayloadAndSetErrors(response);
            if (batchResponse is json){
                BatchInfo binfo = check batchResponse.cloneWithType(BatchInfo);
                return binfo;
            } else {
                return batchResponse;
            } 
        }
        else {
                return error("Invalid Job Type!");
        }
    }
}