# Define the SOQL result type.
# 
# + done - query is completed or not
# + totalSize - the total number result records
# + records - result records
public type SoqlResult record {|
    boolean done;
    int totalSize;
    SoqlRecord[] records;
    json...;
|};

# Define the SOQL query result record type. 
# 
# + attributes - Attribute record
public type SoqlRecord record {|
    Attribute attributes;
    json...;
|};

# Define the Attribute type.
# Contains the attribute information of the resultant record.
# 
# + type - type of the resultant record
# + url - url of the resultant record
public type Attribute record {|
    string 'type;
    string url;
|};

# Metadata for your organization and available to the logged-in user.
# 
# + encoding - encoding
# + maxBatchSize - maximum batch size
# + sobjects - available SObjects
public type OrgMetadata record {|
    string encoding;
    int maxBatchSize;
    SObjectMetaData[] sobjects;
    json...;
|};

# Metadata for an SObject, including information about each field, URLs, and child relationships.
# 
# + name - SObject name
# + createable - is createable
# + deletable - is deletable
# + updateable - is updateable
# + queryable - is queryable
# + label - SObject label
# + urls - SObject urls
public type SObjectMetaData record {|
    string name;
    boolean createable;
    boolean deletable;
    boolean updateable;
    boolean queryable;
    string label;
    map<string> urls;
    json...;
|};


# Operation type of the bulk job.
public type OPERATION INSERT|UPDATE|DELETE|UPSERT|QUERY;

# Data type of the bulk job.
public type JOBTYPE JSON|XML|CSV;
