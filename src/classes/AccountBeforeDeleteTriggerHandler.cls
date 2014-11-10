public class AccountBeforeDeleteTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountBeforeDeleteTriggerHandler.mainEntry');
		DiagnosticsInstrumentation.Pop();
	}
}