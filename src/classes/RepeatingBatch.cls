/**
* @author Scott Covert
* @date 1/16/2015
* @description Defines the Batch Apex for Scheduler Ping-Pong.
*/
public class RepeatingBatch implements Database.Batchable<sObject> {
    /** Batch size to use during execution, default to one */
    private static Integer BatchSize = 1;
    /** Constant representing the maximum batch size to use for testing */
    private static final Integer MAX_BATCH_SIZE = 200;
    /** Constant representing default ASyncRequest type */
    private static final String TYPE_DEFAULT = 'Default';

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Defines the QueryLocator to retrieve any AsyncRequests at or past their scheduled time.
    * @param Database.BatchableContext Current batchable context
    * @return Database.QueryLocator QueryLocator based on ASyncRequest records that are at or past their scheduled time
	*/
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime now = System.now();
        return Database.getQueryLocator('SELECT Id, AsyncType__c, Scheduled_Time__c, Params__c FROM AsyncRequest__c WHERE Scheduled_Time__c <= :now');
    }
    
    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Attempts to execute AsyncRequests.
    * @param Database.BatchableContext Current batchable context
    * @param List A list of AsyncRequest records for the current batchable context
	*/    
    public void execute(Database.BatchableContext BC, List<AsyncRequest__c> scope){
        try{
        	List<AsyncRequest__c> arsToDelete = new List<AsyncRequest__c>();
        	for (AsyncRequest__c ar : scope){
        		if (ar.AsyncType__c == TYPE_DEFAULT){
        			if (ar.Params__c!=null){
                        List<Id> idsToProcess = ar.Params__c.split(',');
        			    System.debug('This is an example of calling from our asynchronous process the default synchronous code with a list of ids to be processed...');
        			}
                    arsToDelete.add(ar);
        		}
        	}
        	if (arsToDelete.size()>0){
        		try{
                    // Delete AsyncRequests
                    delete arsToDelete;
                    Database.emptyRecycleBin(arsToDelete);
                }
                catch(Exception e){
                    // Concurrency Error on Delete --> Ignore
                }
        	}
        }
        catch(Exception e){
        	// Error -> Preserve AsyncRequests
            DiagnosticsInstrumentation.DebugException(e);
            DiagnosticsInstrumentation.PopAll();
        }
    }

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Execute Scheduled Apex for Scheduler Ping-Pong.
    * @param Database.BatchableContext Current batchable context
	*/  
    public void finish(Database.BatchableContext BC){
    	ScheduleHandler.StartScheduler();
    }
    
    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Execute Batch Apex for Scheduler Ping-Pong with a batch size of one.
	*/  
    public static void StartTheBatch()
    {
        RepeatingBatch rb = new RepeatingBatch();
        if (Test.isRunningTest()){
            // Ensure batch executes only once when testing
            BatchSize = MAX_BATCH_SIZE;
        }
        Database.executeBatch(rb, BatchSize);
    }
}