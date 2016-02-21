/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the Handler for Queueable Apex
*/
public class QueueableHandler implements QueueableDispatcher.IQueueableDispatched {
	/** Determines if job is chainable; prevents 'Maximum callout depth reached' error */
	private static Boolean ChainableJob = true;
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
    	List<AsyncRequest__c> arsToDelete = new List<AsyncRequest__c>();
    	try{
    		if (asyncRequests.size()!=0 && asyncRequests[0].AsyncType__c.contains(CALLOUT_TOKEN)){
	        	// Initialize Callout Handler
	        	List<CalloutRequest__c> calloutRequests = [SELECT Id, JobId__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c, Request__c, Response__c FROM CalloutRequest__c WHERE JobId__c = :asyncRequests[0].JobId__c LIMIT 1];
	        	if (calloutRequests.size()!=0)
	        	{
	        		ChainableJob = false;
	        		CalloutHandler.Start(calloutRequests[0]);
	        	}
	        	arsToDelete.add(asyncRequests[0]);
	        }
    	}
    	catch(Exception e){
    		// Error -> Preserving AsyncRequest leaves the job at the beginning of the queue
    		// Increment attempts counter
    		asyncRequests[0].Attempts__c = asyncRequests[0].Attempts__c + 1;
    		if (asyncRequests[0].Attempts__c >= asyncRequests[0].MaxAttempts__c)
    		{
    			// This async request has failed the maximum number of times allowed; abort
    			asyncRequests[0].Aborted__c = true;
    		}
    		update asyncRequests;    		
    		DiagnosticsInstrumentation.DebugException(e);
            DiagnosticsInstrumentation.PopAll();
            // Enqueue another job if possible
            if (ChainableJob)
            {
            	System.enqueueJob(new QueueableDispatcher());
            }
    	}
    	if (arsToDelete.size()>0){
            // Delete executed AsyncRequests
            delete arsToDelete;
            Database.emptyRecycleBin(arsToDelete);
        }    	
    }

}