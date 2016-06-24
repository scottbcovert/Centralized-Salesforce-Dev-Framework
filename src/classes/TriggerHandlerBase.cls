/**
* @author Scott Covert
* @date 11/9/2014
* @description This class implements the ITriggerHandler to provide abstract/virtual methods for the interface methods
*				and so that the trigger handlers need to implement only the method that they have to. The only exception
*				is the mainEntry, which is mandatory for the trigger handlers to implement.
*/
public abstract class TriggerHandlerBase implements ITriggerHandler {
	/** Map of sobjects to update at the end of the trigger event */
	protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
	/** Determines if a concurrency error should be simulated for test purposes */
	@TestVisible private static List<Boolean> SimulateConcurrencyError;

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called for the first time in the execution context. The trigger handlers need to implement
	*				this method.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public abstract void mainEntry(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called for the subsequent times in the same execution context. The trigger handlers can choose
	*				to ignore if they don't need the reentrant feature.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void inProgressEntry(TriggerParameters tp) {
		
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by batch apex. The trigger handlers can choose to ignore this method if they
	*				want batch entries to behave no differently than main entries.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void batchEntry(TriggerParameters tp) {
		mainEntry(tp);
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by asynchronous function. The trigger handlers can choose to ignore this method if they
	*				want future entries to behave no differently than main entries.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void futureEntry(TriggerParameters tp) {
		mainEntry(tp);
	}

	/** 
	* @author Scott Covert
	* @date 2/26/2016
	* @description Called by queueable function. The trigger handlers can choose to ignore this method if they
	*				want queueable entries to behave no differently than main entries.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void queueableEntry(TriggerParameters tp) {
		mainEntry(tp);
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by scheduled apex. The trigger handlers can choose to ignore this method if they
	*				want scheduled entries to behave no differently than main entries.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void scheduledEntry(TriggerParameters tp) {
		mainEntry(tp);
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Updates the objects (if any). Concurrency errors will be silently logged while any other errors will throw an exception.
	*/
	public virtual void updateObjects() {
		if(sObjectsToUpdate.size() > 0){
			List<Database.Saveresult> dmlResults = Database.Update(sObjectsToUpdate.values(), false);
			Map<Id, SObject> concurrencyFailures = new Map<Id, SObject>();
			List<Database.Error> updateFailures = new List<Database.Error>();
			for(Integer x = 0; x< sObjectsToUpdate.size(); x++) {
				Database.Saveresult sr = dmlResults[x];
				if(!sr.isSuccess() || (SimulateConcurrencyError!=null && SimulateConcurrencyError[x]))
				{
					for(Database.Error err : sr.getErrors())
					{
						if(err.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW)
						{
							concurrencyFailures.put(sObjectsToUpdate.values()[x].Id,sObjectsToUpdate.values()[x]);
						}
						else{
							updateFailures.add(err);
						}
					}
					if(SimulateConcurrencyError!=null && SimulateConcurrencyError[x]) concurrencyFailures.put(sObjectsToUpdate.values()[x].Id,sObjectsToUpdate.values()[x]);
				}
			}			
	    	if(concurrencyFailures.size()>0) {
	    		// Log Concurrency Error
	    		String errorMessage = 'Concurrency failure on records ' + String.Join(new List<ID>(concurrencyFailures.keyset()),',');
	    		DiagnosticsInstrumentation.Debug(errorMessage);
	    		// Attempt Recovery
	    		AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c = RepeatingBatch.TYPE_DEFAULT,ScheduledTime__c = System.now(),Params__c=String.Join(new List<ID>(concurrencyFailures.keyset()),','));
	    		DMLManager.insertAsSystem(ar);
	    		ScheduleHandler.StartScheduler();
	    	}
	    	if(updateFailures.size()>0) {
	    		throw new CustomException(updateFailures[0].getMessage());
	    	}
		}
	}
}