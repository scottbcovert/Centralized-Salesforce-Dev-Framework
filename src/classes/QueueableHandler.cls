/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the Handler for Queueable Apex
*/
public class QueueableHandler implements QueueableDispatcher.IQueueableDispatched {
	/** Stores whether or not the current transaction has already queued an async job for future processing */
    public static Boolean asyncJobQueued = false;
    /** Stores the id of the async job queued by this transaction */
    private static Id queuedJobId;
    /** Constant representing the token that signifies the queueable apex is to perform a callout */
	public static final String CALLOUT_TOKEN = 'Callout:';
    /** Constant representing the token that signifies the queueable apex job itself should be processed asynchronously */
    public static final String ASYNC_TOKEN = 'Async';

	/**
	* @author Scott Covert
	* @date 2/21/2016
	* @description Execute Queueable Apex
	* @param QueueableContext Current schedulable context
	*/
	public void execute(QueueableContext sc)
    {
        // Verify kill switch is not enabled
        if (ConfigService.KillSwitchEnabled)
        {
            flushAsyncQueue();            
            return;
        }
        // Instantiate async request for later processing
        AsyncRequest__c ar;
        // Instantiate empty map to store processed async requests ready for deletion
        Map<Id,AsyncRequest__c> arsToDelete = new Map<Id,AsyncRequest__c>();
        try{
            // Query for the earliest scheduled async request that still needs to be processed
            List<AsyncRequest__c> asyncRequests = [SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c FROM AsyncRequest__c WHERE IsDeleted = false AND Aborted__c = false ORDER BY ScheduledTime__c ASC LIMIT 1];                        
            // End chaining if all asynchronous requests have been or are being processed
            if (asyncRequests.isEmpty()) return;
            // Unfortunately the ORDER BY clause is not allowed while pessimistically locking rows in SOQL, so the query must be repeated to prevent concurrency issues
            asyncRequests = [SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false AND Id = :asyncRequests[0].Id LIMIT 1 FOR UPDATE];
            // Since the first SOQL query ordered by scheduled time was not row locking we must verify again that asyncRequests is not empty
            if (asyncRequests.isEmpty()) return;
            // Set async request to be processed
            ar = asyncRequests[0];
            // Process async request
            processAsyncRequest(ar);
            // Mark async request for deletion
            arsToDelete.put(ar.Id,ar);
    	}
    	catch(Exception ex){
    		// Long-running processes could mean locking errors are hit in lieu of concurrency errors; additionally a runtime error could occur while processing the async request
            // In this case the async request record will not be marked for deletion; leaving the job at the beginning of the queue to be processed again later
    		DiagnosticsInstrumentation.DebugException(ex);
        }
        // Update/Delete Aync Request as needed
        updateOrDeleteAsyncRequest(ar, arsToDelete);
        // Chain job to process additional async requests
        chainJob();
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Enqueues Queueable Apex Job
    * @param String Type of asynchronous job to be queued    
    */
    public static AsyncRequest__c startJob(String asyncJobType)
    {
        // Only enqueue a new job as needed
        if (!asyncJobQueued)
        {
            asyncJobQueued = true;
            queuedJobId = System.enqueueJob(new QueueableDispatcher());
        }
        // Add the async request to the queue
        AsyncRequest__c ar = new AsyncRequest__c(JobId__c = queuedJobId, AsyncType__c = asyncJobType);
        DMLManager.insertAsSystem(ar);
        return ar;
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Enqueues Queueable Apex Job
    * @param String Type of asynchronous job to be queued
    * @param CalloutRequest__c Callout request to be performed by the asynchronous job; should have HTTP request info populated but should not yet inserted to the database
    */
    public static void startCalloutJob(String asyncJobType, CalloutRequest__c cr)
    {
        // Add the async request to the queue
        AsyncRequest__c ar = startJob(asyncJobType);
        // Insert a related callout request to store HTTP request/response info
        cr.AsyncRequest__c = ar.Id;            
        DMLManager.insertAsSystem(cr);             
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Flushes Async Queue
    */
    private void flushAsyncQueue()
    {
        try
        {
            // Pessimistic locking SOQL query prevents other async jobs from processing async requests
            Map<Id,AsyncRequest__c> asyncRequestsToFlush = new Map<Id,AsyncRequest__c>([SELECT Id, Aborted__c FROM AsyncRequest__c WHERE IsDeleted = false AND Aborted__c = false FOR UPDATE]);
            if (!asyncRequestsToFlush.isEmpty())
            {
                for (AsyncRequest__c ar : asyncRequestsToFlush.values()) ar.Aborted__c = true;
                DMLManager.updateAsSystem(asyncRequestsToFlush.values());
            }                
        }
        catch(Exception ex)
        {
            // Locking error could occur if some async requests are currently being processed
            // In this case, the other async job will chain itself once it's done and the queue will be flushed then
            DiagnosticsInstrumentation.DebugException(ex);
        }
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Processes async request based on type; this is where specific business logic will be added
    * @param AsyncRequest__c Async request to be processed
    */
    private void processAsyncRequest(AsyncRequest__c ar)
    {
        if (ar.AsyncType__c.contains(CALLOUT_TOKEN)){
            // Initialize Callout Handler
            List<CalloutRequest__c> calloutRequests = [SELECT Id, AsyncRequest__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c FROM CalloutRequest__c WHERE AsyncRequest__c = :ar.Id AND Status__c = :CalloutHandler.QUEUED_STATUS LIMIT 1];
            if (!calloutRequests.isEmpty() && ar.AsyncType__c.contains(ASYNC_TOKEN)) CalloutHandler.sendAsyncCallout(calloutRequests[0].Id);
            else if (!calloutRequests.isEmpty()) CalloutHandler.sendCallout(calloutRequests[0]);
        }
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Increments async request attempts counter and aborts the job if needed or deletes the job altogether
    * @param AsyncRequest__c Async request that was processed
    * @param Map Map of Async Requests to be deleted from the queue
    */
    private void updateOrDeleteAsyncRequest(AsyncRequest__c ar, Map<Id,AsyncRequest__c> arsToDelete)
    {
        // Increment attempts counter
        ar.Attempts__c++;
        // This async request has failed the maximum number of times allowed; abort
        if (ar.Attempts__c >= ar.MaxAttempts__c) ar.Aborted__c = true;
        // Only bother to update async request if it is not set to be deleted
        // This also must be done after processing of the async request in case a synchronous callout is made
        // (SF does not allow DML prior to a callout in the same transaction - http://bit.ly/1QeV6dC)
        if (!arsToDelete.containsKey(ar.Id)) DMLManager.updateAsSystem(ar);        
        if (!arsToDelete.isEmpty())
        {
            // Delete executed AsyncRequests and empty them from the recycling bin
            DMLManager.deleteAsSystem(arsToDelete.values());
            Database.emptyRecycleBin(arsToDelete.values());            
        }
    }

    /**
    * @author Scott Covert
    * @date 2/22/2016
    * @description Chains Queueable Apex
    */
    @future
    private static void chainJob()
    {
        // This method for chaining the queued apex job is itself asynchronous in case the completed job made a callout
        // (Normally making a callout prevents chaining from being possible - http://sforce.co/1RnhPD9)
        System.enqueueJob(new QueueableDispatcher());
    }

}