/**
* @author Scott Covert
* @date 1/16/2015
* @description Defines the Scheduled Apex for Scheduler Ping-Pong.
*/
public class ScheduleHandler implements ScheduledDispatcher.IScheduleDispatched {
	private static Boolean ScheduledInContext = false;
	private static final Integer MINIMUM_WAIT_TIME= 0;

	/**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Execute Batch Apex for Scheduler Ping-Pong.
	*/
	public void execute(SchedulableContext sc)
    {
        System.abortJob(sc.getTriggerID());
        RepeatingBatch.StartTheBatch();
    } 

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Returns Scheduled time in Cron format
	* @param DateTime Scheduled time
	*/
    public static String GetSchedulerExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Start Scheduler
	*/
    public static void StartScheduler(){

		List<AsyncRequest__c> requests = [Select Id, AsyncType__c, Scheduled_Time__c, Params__c FROM AsyncRequest__c ORDER BY Scheduled_Time__c ASC LIMIT 1];
		if(requests.size()==0) return;

    	if(ScheduledInContext) return;

		ScheduledInContext = true;
    	
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime FROM CronTrigger where CronJobDetail.Name='ASync_Process_Schedule'];
    	if(jobs.size()>0 && jobs[0].state!='COMPLETED' && jobs[0].state!='ERROR' && jobs[0].state!='DELETED') return;

        Set<String> activeJobStates = new Set<String>{'Queued','Processing','Preparing'};
		List<AsyncApexJob> apexJobs = [Select ID, ApexClass.Name from AsyncApexJob WHERE ApexClass.Name = 'RepeatingBatch' And Status in :activeJobStates];
		if(apexJobs.size()>0) return;

		try{
			System.schedule('ASync_Process_Schedule', GetSchedulerExpression(requests[0].Scheduled_Time__c.addSeconds(MINIMUM_WAIT_TIME)), new ScheduledDispatcher());
		}
		catch(Exception e){
			// Concurrency Error -> Ignore
		}
    }

}