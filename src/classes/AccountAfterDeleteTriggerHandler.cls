/**
* @author Scott Covert
* @date 11/9/2014
* @description Account Trigger Handler for After Delete Trigger Context
* @see TriggerHandlerBase
*/
public class AccountAfterDeleteTriggerHandler extends TriggerHandlerBase {
	
	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Main Entry point for trigger handling
	* @param TriggerParameters Contains the trigger parameters
	*/
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterDeleteTriggerHandler.mainEntry');
		DiagnosticsInstrumentation.Pop();
	}
}