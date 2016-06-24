/**
* @author Scott Covert
* @date 5/14/2015
* @description Defines the Future Handler for Scheduler Ping-Pong.
*/
public class RepeatingFuture {
    /** Constant representing the token that forces repeating future calls in lieu of Batch Apex */
    private static final String FUTURE_TOKEN = ScheduleHandler.FUTURE_TOKEN;
    /** Constant representing default ASyncRequest type */
    public static final String TYPE_DEFAULT = ScheduleHandler.FUTURE_TOKEN + 'Default';

    /**
    * @author Scott Covert
    * @date 5/14/2015
    * @description Attempts to execute Future AsyncRequests.
    */    
    public static void Start(){
        List<AsyncRequest__c> arsToDelete = new List<AsyncRequest__c>();
        String futureType = FUTURE_TOKEN + '%';
        for (AsyncRequest__c ar : [SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false AND AsyncType__c LIKE :futureType ORDER BY ScheduledTime__c ASC LIMIT 1]){
            if (ar.AsyncType__c == TYPE_DEFAULT){
                if (ar.Params__c!=null){
                    List<Id> idsToProcess = ar.Params__c.split(',');
                    System.debug('This is an example of calling an asynchronous method with a list of ids to be processed...');
                }
                arsToDelete.add(ar);
            }
        }
        if (arsToDelete.size()>0){
            // Delete AsyncRequests
            DMLManager.deleteAsSystem(arsToDelete);
            Database.emptyRecycleBin(arsToDelete);
        }
        ScheduleHandler.StartScheduler();
    }
}