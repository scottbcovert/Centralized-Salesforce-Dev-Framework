/**
* @author Scott Covert
* @date 11/9/2014
* @description Account Trigger Handler for Before Update Trigger Context
* @see TriggerHandlerBase
*/
public class AccountBeforeUpdateTriggerHandler extends TriggerHandlerBase {
	
	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Main Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountBeforeUpdateTriggerHandler.mainEntry');
		DiagnosticsInstrumentation.Pop();
	}
}