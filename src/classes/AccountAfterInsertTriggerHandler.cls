public class AccountAfterInsertTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterInsertTriggerHandler.mainEntry');
		DiagnosticsInstrumentation.Pop();
	}
}