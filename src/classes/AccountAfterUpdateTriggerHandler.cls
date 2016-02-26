/**
* @author Scott Covert
* @date 11/9/2014
* @description Account Trigger Handler for After Update Trigger Context
* @see TriggerHandlerBase
*/
public class AccountAfterUpdateTriggerHandler extends TriggerHandlerBase {
	
	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Main Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.mainEntry');
		process((List<Account>)tp.newList);
		DiagnosticsInstrumentation.Pop();
	}
	
	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Process Accounts
	* @param List A list of updated accounts
	*/
	private void process(List<Account> listNewAccounts) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.mainEntry');
		sObjectsToUpdate.putAll(AccountHelper.updateWebsite(listNewAccounts));
		DiagnosticsInstrumentation.Pop();
	}
	
	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description In Progress Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	public override void inProgressEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.inProgressEntry');
		System.debug('This is an example for reentrant code...');
		DiagnosticsInstrumentation.Pop();
	}

	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Batch Apex Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	/*
	public override void batchEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.batchEntry');
		System.debug('This is an example for batch entry code...');
		DiagnosticsInstrumentation.Pop();
	}
	*/

	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Future Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	/*
	public override void futureEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.futureEntry');
		System.debug('This is an example for future entry code...');
		DiagnosticsInstrumentation.Pop();
	}
	*/

	/**
	* @author Scott Covert
	* @date 2/26/2016
	* @description Queueable Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	/*
	public override void queueableEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.queueableEntry');
		System.debug('This is an example for queueable entry code...');
		DiagnosticsInstrumentation.Pop();
	}
	*/

	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Scheduled Apex Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	/*
	public override void scheduledEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.scheduledEntry');
		System.debug('This is an example for scheduled entry code...');
		DiagnosticsInstrumentation.Pop();
	}
	*/
	
}