import ballerina/oauth2;
import ballerina/http;

public client class BaseClient{
    http:Client salesforceClient;
    SalesforceConfiguration salesforceConfiguration;

    public function init(SalesforceConfiguration salesforceConfig) {
        self.salesforceConfiguration = salesforceConfig;
        // Create an OAuth2 provider.
        oauth2:OutboundOAuth2Provider oauth2Provider = new(salesforceConfig.clientConfig);
        // Create a bearer auth handler using the a created provider.
        http:BearerAuthHandler bearerHandler = new(oauth2Provider);

        http:ClientSecureSocket? socketConfig = salesforceConfig?.secureSocketConfig;

        // Create an HTTP client.
        if (socketConfig is http:ClientSecureSocket) {
            self.salesforceClient = new(salesforceConfig.baseUrl, {
                secureSocket: socketConfig,
                auth: {
                    authHandler: bearerHandler
                }
            });
        } else {
            self.salesforceClient = new(salesforceConfig.baseUrl, {
                auth: {
                    authHandler: bearerHandler
                }
            });
        }
    }

    //Query

    # Executes the specified SOQL query.
    # + receivedQuery - Sent SOQL query
    # + return - `SoqlResult` record if successful. Else, the occurred `Error`.
    public remote function getQueryResult(string receivedQuery) returns @tainted SoqlResult|Error {
        string path = prepareQueryUrl([API_BASE_PATH, QUERY], [Q], [receivedQuery]);
        json res = check self.getRecord(path);
        return toSoqlResult(res);
    }

    private function getRecord(string path) returns @tainted json|Error {
        http:Response|error response = self.salesforceClient->get(path);
        return checkAndSetErrors(response);
    }

    //SObjects

   # Create records based on relevant object type sent with json record.
    # + sObjectName - SObject name value
    # + recordPayload - JSON record to be inserted
    # + return - created entity ID if successful else Error occured
    public remote function createRecord(string sObjectName, json recordPayload) returns @tainted string|Error {
        http:Request req = new;
        string path = prepareUrl([API_BASE_PATH, SOBJECTS, sObjectName]);
        req.setJsonPayload(recordPayload);

        var response = self.salesforceClient->post(path, req);

        json|Error result = checkAndSetErrors(response);
        if (result is json) {
            return result.id.toString();
        } else {
            return result;
        }
    }


    # Get the Salesforce bulk API client.
    # + return - Salesforce bulk client
    public remote function getBulkClient() returns BulkClient {
        BulkClient bulkClient = new(self.salesforceConfiguration);
        return bulkClient;
    }

}

# Salesforce client configuration.
# + baseUrl - The Salesforce endpoint URL
# + clientConfig - OAuth2 direct token configuration
# + secureSocketConfig - HTTPS secure socket configuration
public type SalesforceConfiguration record {
    string baseUrl;
    oauth2:DirectTokenConfig clientConfig;
    http:ClientSecureSocket secureSocketConfig?;
};
