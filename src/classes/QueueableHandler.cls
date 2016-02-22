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
    	List<AsyncRequest__c> asyncRequests = [SELECT Id, AsyncType__c, JobId__c, Scheduled_Time__c, Params__c, Attempts__c, Running__c, Aborted__c FROM AsyncRequest__c WHERE Running__c = false AND Aborted__c = false ORDER BY Scheduled_Time__c ASC];
    	// End chaining if all asynchronous requests have been or are being processed
        if (asyncRequests.size() == 0) return;
        // Otherwise, try to match the currently running queueable job with its matching async request to prevent concurrency issues
        AsyncRequest__c ar;
        for (AsyncRequest__c asyncRequest : asyncRequests)
        {
            if (ar.JobId__c == sc.getJobId()) ar = asyncRequest;
        }
        // If the running job has no matching async request, then this must be a chained, cleanup job so the earliest scheduled async request should be processed
        if (ar==null) ar = asyncRequests[0];
        // Mark the async request as running, again to prevent concurrency issues
        ar.Running__c = true;
        update ar;
        Map<Id,AsyncRequest__c> arsToDelete = new Map<Id,AsyncRequest__c>();
    	try{
    		if (ar.AsyncType__c.contains(CALLOUT_TOKEN)){
	        	// Initialize Callout Handler
	        	List<CalloutRequest__c> calloutRequests = [SELECT Id, JobId__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c, Request__c, Response__c FROM CalloutRequest__c WHERE JobId__c = :ar.JobId__c LIMIT 1];
	        	if (calloutRequests.size()!=0) CalloutHandler.Start(calloutRequests[0]);	        	
	        }
            arsToDelete.put(ar.Id,ar);
    	}
    	catch(Exception e){
    		// Error -> Preserving AsyncRequest leaves the job at the beginning of the queue
    		DiagnosticsInstrumentation.DebugException(e);
            DiagnosticsInstrumentation.PopAll();
        }
        // Increment attempts counter
		ar.Attempts__c++;
        // Mark the request as no longer running
        ar.Running__c = false;
		// This async request has failed the maximum number of times allowed; abort
        if (ar.Attempts__c >= ar.MaxAttempts__c) ar.Aborted__c = true;
		// Only bother to update async request if it is not set to be deleted
        if (!arsToDelete.containsKey(ar.Id)) update ar;				
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