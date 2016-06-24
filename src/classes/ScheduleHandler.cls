/**
* @author Scott Covert
* @date 1/16/2015
* @description Defines the Scheduled Apex for Scheduler Ping-Pong.
*/
public class ScheduleHandler implements ScheduledDispatcher.IScheduleDispatched {
	/** Determines if current execution state is already in a scheduled context */
	private static Boolean ScheduledInContext = false;
	/** Constant representing the minimum wait time between scheduled apex calls */
	private static final Integer MINIMUM_WAIT_TIME= 10;
	/** Constant representing the token that forces repeating future calls in lieu of Batch Apex */
	public static final String FUTURE_TOKEN = 'Future:';

	/**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Execute Scheduler Ping-Pong.
	* @param SchedulableContext Current schedulable context
	*/
	public void execute(SchedulableContext sc)
    {
    	List<AsyncRequest__c> requests = [Select Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false ORDER BY ScheduledTime__c ASC LIMIT 1];
    	try{
    		System.abortJob(sc.getTriggerID());
    		if (requests.size()!=0 && requests[0].AsyncType__c.contains(FUTURE_TOKEN)){
	        	// Initialize Repeating Future Calls
	        	RepeatingFuture.Start();
	        }
	        else{
	        	// Initialize Repeating Batch Apex
	        	RepeatingBatch.StartTheBatch();
	        }
    	}
    	catch(Exception ex){
    		// Error -> Preserve AsyncRequests & Reschedule
    		// Increment attempts counter
    		requests[0].Attempts__c = requests[0].Attempts__c + 1;
    		if (requests[0].Attempts__c >= requests[0].MaxAttempts__c)
    		{
    			// This async request has failed the maximum number of times allowed; abort
    			requests[0].Aborted__c = true;
    		}
    		DMLManager.updateAsSystem(requests);
    		DiagnosticsInstrumentation.DebugException(ex);
            ScheduleHandler.StartScheduler();
    	}
    }

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Returns Scheduled time in Cron format
	* @param DateTime Scheduled time
	* @return String Cron format of given scheduled time
	*/
    public static String GetSchedulerExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

    /**
	* @author Scott Covert
	* @date 1/16/2015
	* @description Start Scheduler
	*/
    public static void StartScheduler(){

		List<AsyncRequest__c> requests = [Select Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, Aborted__c FROM AsyncRequest__c WHERE Aborted__c = false ORDER BY ScheduledTime__c ASC LIMIT 1];
		if(requests.size()==0) return;

    	if(ScheduledInContext) return;

		ScheduledInContext = true;
    	
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime FROM CronTrigger where CronJobDetail.Name='ASync_Process_Schedule' ORDER BY NextFireTime ASC];
    	if(jobs.size()>0 && jobs[0].state!='COMPLETED' && jobs[0].state!='ERROR' && jobs[0].state!='DELETED') {
			// Job is already scheduled - check if batch job is running
			Set<String> activeJobStates = new Set<String>{'Queued','Processing','Preparing'};
			List<AsyncApexJob> apexJobs = [Select ID, ApexClass.Name from AsyncApexJob WHERE Status in :activeJobStates AND ApexClass.Name = 'RepeatingBatch'];
			if(apexJobs.size()>0) return; // Batch job is running
			// Check if current job is set to execute first  
			if(jobs[0].NextFireTime <= requests[0].ScheduledTime__c.addSeconds(MINIMUM_WAIT_TIME)) return; // Current job is still earliest in the queue
    	}
    	// At this point any existing job should be deleted
		for (CronTrigger job : jobs){
			System.abortJob(job.Id);
		}
        
		try{
			// Don't allow jobs to be scheduled in the past
			DateTime scheduledTime = requests[0].ScheduledTime__c;
			if (scheduledTime < System.now()){
				scheduledTime = System.now();
			}
			if (Test.isRunningTest()){
				// Execute directly when testing
				if (requests[0].AsyncType__c.contains(FUTURE_TOKEN)){
					RepeatingFuture.Start();
				}
				else{
					RepeatingBatch.StartTheBatch();
				}				
			}
			else{
				System.schedule('ASync_Process_Schedule', GetSchedulerExpression(scheduledTime.addSeconds(MINIMUM_WAIT_TIME)), new ScheduledDispatcher());
			}
		}
		catch(Exception ex){
			// Concurrency Error -> Ignore
			DiagnosticsInstrumentation.DebugException(ex);
		}
    }

}