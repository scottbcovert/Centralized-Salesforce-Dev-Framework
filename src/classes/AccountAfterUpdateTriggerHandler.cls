public class AccountAfterUpdateTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.mainEntry');
		process((List<Account>)tp.newList);
		DiagnosticsInstrumentation.Pop();
	}
	
	private void process(List<Account> listNewAccounts) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.mainEntry');
		sObjectsToUpdate.putAll(AccountHelper.updateWebsite(listNewAccounts));
		DiagnosticsInstrumentation.Pop();
	}
	
	public override void inProgressEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.inProgressEntry');
		System.debug('This is an example for reentrant code...');
		DiagnosticsInstrumentation.Pop();
	}

	public override void batchEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.batchEntry');
		System.debug('This is an example for batch entry code...');
		DiagnosticsInstrumentation.Pop();
	}

	public override void futureEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.futureEntry');
		System.debug('This is an example for future entry code...');
		DiagnosticsInstrumentation.Pop();
	}

	public override void scheduledEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.scheduledEntry');
		System.debug('This is an example for scheduled entry code...');
		DiagnosticsInstrumentation.Pop();
	}
	
}