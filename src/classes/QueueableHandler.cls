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
    	List<AsyncRequest__c> asyncRequests = [SELECT Id, AsyncType__c, JobId__c, Scheduled_Time__c, Params__c, Attempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false ORDER BY Scheduled_Time__c ASC LIMIT 1];
    	// End chaining if all asynchronous requests have been processed
        if (asyncRequests.size() == 0) return;
        AsyncRequest__c ar = asyncRequests[0];
        Map<Id,AsyncRequest__c> arsToDelete = new Map<Id,AsyncRequest__c>();
    	try{
    		if (ar.AsyncType__c.contains(CALLOUT_TOKEN)){
	        	// Initialize Callout Handler
	        	List<CalloutRequest__c> calloutRequests = [SELECT Id, JobId__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c, Request__c, Response__c FROM CalloutRequest__c WHERE JobId__c = :ar.JobId__c LIMIT 1];
	        	if (calloutRequests.size()!=0) CalloutHandler.Start(calloutRequests[0]);
	        	arsToDelete.put(ar.Id,ar);
	        }
    	}
    	catch(Exception e){
    		// Error -> Preserving AsyncRequest leaves the job at the beginning of the queue
    		DiagnosticsInstrumentation.DebugException(e);
            DiagnosticsInstrumentation.PopAll();
        }

        // Increment attempts counter
		ar.Attempts__c++;
		if (ar.Attempts__c >= ar.MaxAttempts__c)
		{
			// This async request has failed the maximum number of times allowed; abort
			ar.Aborted__c = true;
		}
		// Only bother to update async request if it is not set to be deleted
        if (!arsToDelete.containsKey(ar.Id)) update ar;				
        if (!arsToDelete.isEmpty())
        {
            // Delete executed AsyncRequests
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