public class AccountBeforeInsertTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountBeforeInsertTriggerHandler.mainEntry');
		DiagnosticsInstrumentation.Pop();
	}
}