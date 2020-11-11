import ballerina/http;
import ballerina/io;

# The Job object.
public client class BulkJob {
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
    public remote function addBatch(json|string|xml|io:ReadableByteChannel content) returns @tainted error|BatchInfo{
        string path = prepareUrl([SERVICES, ASYNC, BULK_API_VERSION, JOB, self.jobId, BATCH]);
        http:Request req = new;
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