/**
* @author Scott Covert
* @date 1/16/2015
* @description Defines the Batch Apex for Scheduler Ping-Pong.
*/
public class RepeatingBatch implements Database.Batchable<sObject> {
    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Defines the QueryLocator to retrieve any AsyncRequests at or past their scheduled time.
	*/
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime now = System.now();
        return Database.getQueryLocator('SELECT Id, AsyncType__c, Scheduled_Time__c, Params__c FROM AsyncRequest__c WHERE Scheduled_Time__c <= :now');
    }
    
    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Attempts to execute AsyncRequests.
	*/    
    public void execute(Database.BatchableContext BC, List<AsyncRequest__c> scope){
        try{
        	System.debug('This is an example of calling synchronous code from asynchronous process...');
        	// Delete AsyncRequests
        	delete scope;
        	Database.emptyRecycleBin(scope);
        }
        catch(Exception e){
        	// Error -> Preserve AsyncRequests
        }
        delete scope;
    }

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Execute Scheduled Apex for Scheduler Ping-Pong.
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
        Database.executeBatch(rb, 1);
    }
}