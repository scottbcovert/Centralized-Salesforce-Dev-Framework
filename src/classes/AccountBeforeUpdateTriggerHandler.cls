public class AccountBeforeUpdateTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountBeforeUpdateTriggerHandler.mainEntry');
		DiagnosticsInstrumentation.Pop();
	}
}