import ballerina/config;
import ballerina/test;
import ballerina/log;

// Create Salesforce client configuration by reading from config file.
SalesforceConfiguration sfConfig = {
    baseUrl: config:getAsString("EP_URL"),
    clientConfig: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            refreshUrl: config:getAsString("REFRESH_URL")
        }
    }
};

BaseClient baseClient = new(sfConfig);

//query
@test:Config {}
function testGetQueryResult() {
    log:printInfo("baseClient -> getQueryResult()");
    string sampleQuery = "SELECT name FROM Account";
    SoqlResult|Error res = baseClient->getQueryResult(sampleQuery);

    if (res is SoqlResult) {
        assertSoqlResult(res);
        
    } else {
        test:assertFail(msg = res.message());
    }
}

function assertSoqlResult(SoqlResult|Error res) {
    if (res is SoqlResult) {
        test:assertTrue(res.totalSize > 0, "Total number result records is 0");
        test:assertTrue(res.'done, "Query is not completed");
        test:assertTrue(res.records.length() == res.totalSize, "Query result records not equal to totalSize");
    } else {
        test:assertFail(msg = res.message());
    }
}

//sobject
json accountRecord = { 
    Name: "John Keells Holdings", 
    BillingCity: "Colombo 3" 
};
string testRecordId = "";

@test:Config {}
function testCreateRecord() {
    log:printInfo("baseClient -> createRecord()");
    string|Error stringResponse = baseClient->createRecord(ACCOUNT, accountRecord);

    if (stringResponse is string) {
        test:assertNotEquals(stringResponse, "", msg = "Found empty response!");
        testRecordId = <@untainted> stringResponse;
    } else {
        test:assertFail(msg = stringResponse.message());
    }
}

//bulk
@test:Config {}
function insertJson() {
    log:printInfo("baseClient -> insertJson");
    string batchId = "";

    json contacts = [
        {
            description: "Created_from_Ballerina_Sf_Bulk_API",
            FirstName: "Morne",
            LastName: "Morkel",
            Title: "Professor Grade 03",
            Phone: "0442226670",
            Email: "morne89@gmail.com",
            My_External_Id__c: "201"
        },
        {
            description: "Created_from_Ballerina_Sf_Bulk_API",
            FirstName: "Andi",
            LastName: "Flower",
            Title: "Professor Grade 03",
            Phone: "0442216170",
            Email: "flower.andie@gmail.com",
            My_External_Id__c: "202"
        }
    ];

    //create job
    error|BulkJob insertJob = baseClient->creatJob("insert", "Contact", "JSON");
    if (insertJob is BulkJob) {

        //add json content
        error|BatchInfo batch = insertJob->addBatch(contacts);
        if (batch is BatchInfo) {
            test:assertTrue(batch.id.length() > 0, msg = "Could not upload the contacts using json.");
            batchId = batch.id;
        } else {
            test:assertFail(msg = batch.message());
        }

        //get job info
        error|JobInfo jobInfo = baseClient->getJobInfo(insertJob);
        if (jobInfo is JobInfo) {
            test:assertTrue(jobInfo.id.length() > 0, msg = "Getting job info failed.");
        } else {
            test:assertFail(msg = jobInfo.message());
        }
    }
}
