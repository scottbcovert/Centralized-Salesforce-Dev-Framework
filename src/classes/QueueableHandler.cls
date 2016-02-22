/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the Handler for Queueable Apex
*/
public class QueueableHandler implements QueueableDispatcher.IQueueableDispatched {
	/** Constant representing the token that signifies the queueable apex is to perform a callout */
	public static final String CALLOUT_TOKEN = 'Callout:';

	/**
	* @author Scott Covert
	* @date 2/21/2016
	* @description Execute Queueable Apex
	* @param QueueableContext Current schedulable context
	*/
	public void execute(QueueableContext sc)
    {
        // Instantiate null async request for later processing
        AsyncRequest__c ar;
        // Instantiate empty map to store processed async requests ready for deletion
        Map<Id,AsyncRequest__c> arsToDelete = new Map<Id,AsyncRequest__c>();
        try{
            // Query for unprocessed aync requests using FOR UPDATE to prevent concurrency issues; long-running processes (like callouts) could mean locking errors are hit in lieu of concurrency errors -> Thus the try/catch block
            // First try to match currently running queueable job with its matching async request
            List<AsyncRequest__c> asyncRequests = [SELECT Id, AsyncType__c, JobId__c, Scheduled_Time__c, Params__c, Attempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false AND JobId__c = :sc.getJobId() LIMIT 1 FOR UPDATE];
            // If the running job has no matching async request, then this must be a chained/cleanup job so the earliest scheduled async request should be processed
            if (asyncRequests.size() == 0) asyncRequests = [SELECT Id, AsyncType__c, JobId__c, Scheduled_Time__c, Params__c, Attempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false ORDER BY Scheduled_Time__c ASC LIMIT 1];                        
        	// End chaining if all asynchronous requests have been or are being processed
            if (asyncRequests.size() == 0) return;
            // Unfortunately the ORDER BY clause is not allowed while locking rows in SOQL, so the query must be repeated to use FOR UPDATE, again to prevent concurrency issues
            asyncRequests = [SELECT Id, AsyncType__c, JobId__c, Scheduled_Time__c, Params__c, Attempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false AND Id = :asyncRequests[0].Id LIMIT 1 FOR UPDATE]; 
            // Set async request record to be processed
            ar = asyncRequests[0];
            // Process async request based on type
    		if (ar.AsyncType__c.contains(CALLOUT_TOKEN)){
	        	// Initialize Callout Handler
	        	List<CalloutRequest__c> calloutRequests = [SELECT Id, JobId__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c, Request__c, Response__c FROM CalloutRequest__c WHERE JobId__c = :ar.JobId__c LIMIT 1];
	        	if (calloutRequests.size()!=0) CalloutHandler.Start(calloutRequests[0]);	        	
	        }
            // Mark async request for deletion
            arsToDelete.put(ar.Id,ar);
    	}
    	catch(Exception e){
    		// Error -> Either a locking error or runtime error has occurred; the async request record should be preserved leaving the job at the beginning of the queue
    		DiagnosticsInstrumentation.DebugException(e);
            DiagnosticsInstrumentation.PopAll();
        }
        // Verify that an async request record was processed
        if (ar!=null)
        {
            // Increment attempts counter
    		ar.Attempts__c++;
            // This async request has failed the maximum number of times allowed; abort
            if (ar.Attempts__c >= ar.MaxAttempts__c) ar.Aborted__c = true;
    		// Only bother to update async request if it is not set to be deleted -> This also must be done after processing of the async request in case a callout was made (SF does not allow DML prior to a callout)
            if (!arsToDelete.containsKey(ar.Id)) update ar;				
        }
        if (!arsToDelete.isEmpty())
        {
            // Delete executed AsyncRequests and empty them from the recycling bin
            delete arsToDelete.values();
            Database.emptyRecycleBin(arsToDelete.values());
        }
        // Chain job to process additional async requests
        chainJob();
    }

    /**
    * @author Scott Covert - Tython Co.
    * @date 2/22/2016
    * @description Chains Queueable Apex
    */
    @future
    private static void chainJob()
    {
        System.enqueueJob(new QueueableDispatcher());
    }

}