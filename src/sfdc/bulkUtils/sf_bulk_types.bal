# Define the batch type.
#
# + id - The ID of the batch, May be globally unique, but does not have to be
# + jobId - The unique, 18–character ID for the job associated with this batch
# + state - The current state of processing for the batch
# + createdDate - The date and time in the UTC time zone when the batch was created
# + systemModstamp - The date and time in the UTC time zone that processing ended. This is only valid when the state
# is Completed.
# + numberRecordsProcessed - The number of records processed in this batch at the time the request was sent
# + numberRecordsFailed - The number of records that were not processed successfully in this batch
# + totalProcessingTime - The number of milliseconds taken to process the batch, This excludes the time the batch
# waited in the queue to be processed
# + apiActiveProcessingTime - The number of milliseconds taken to actively process the batch, and includes
# apexProcessingTime
# + apexProcessingTime - The number of milliseconds taken to process triggers and other processes related to the
# batch data
public type BatchInfo record {|
    string id;
    string jobId;
    string state;
    string createdDate;
    string systemModstamp;
    int numberRecordsProcessed;
    int numberRecordsFailed;
    int totalProcessingTime;
    int apiActiveProcessingTime;
    int apexProcessingTime;
    json...;
|};


# Define the job type.
#
# + id - Unique ID for this job
# + operation - The processing operation for all the batches in the job
# + object - The object type for the data being processed, All data in a job must be of a single object type
# + createdById - The ID of the user who created this job
# + createdDate - The date and time in the UTC time zone when the job was created
# + systemModstamp - Date and time in the UTC time zone when the job finished
# + state - The current state of processing for the job
# + concurrencyMode - The concurrency mode for the job
# + contentType - The content type for the job
# + numberBatchesQueued - The number of batches queued for this job
# + numberBatchesInProgress - The number of batches that are in progress for this job
# + numberBatchesCompleted - The number of batches that have been completed for this job
# + numberBatchesFailed - The number of batches that have failed for this job
# + numberBatchesTotal - The number of total batches currently in the job
# + numberRecordsProcessed - The number of records already processed
# + numberRetries - The number of times that Salesforce attempted to save the results of an operation
# + apiVersion - The API version of the job set in the URI when the job was created
# + numberRecordsFailed - The number of records that were not processed successfully in this job
# + totalProcessingTime - The number of milliseconds taken to process the job
# + apiActiveProcessingTime - The number of milliseconds taken to actively process the job and includes
# apexProcessingTime, but doesn't include the time the job waited in the queue to be processed or the time required for
# serialization and deserialization
# + apexProcessingTime - The number of milliseconds taken to process triggers and other processes related to the job
public type JobInfo record {|
    string id;
    string operation;
    string 'object;
    string createdById;
    string createdDate;
    string systemModstamp;
    string state;
    string concurrencyMode;
    string contentType;
    int numberBatchesQueued;
    int numberBatchesInProgress;
    int numberBatchesCompleted;
    int numberBatchesFailed;
    int numberBatchesTotal;
    int numberRecordsProcessed;
    int numberRetries;
    float apiVersion;
    int numberRecordsFailed;
    int totalProcessingTime;
    int apiActiveProcessingTime;
    int apexProcessingTime;
    json...;
|};