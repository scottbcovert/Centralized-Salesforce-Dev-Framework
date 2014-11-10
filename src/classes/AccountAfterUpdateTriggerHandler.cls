public class AccountAfterUpdateTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.mainEntry');
		process((List<Account>)tp.newList);
		DiagnosticsInstrumentation.Pop();
	}
	
	private void process(List<Account> listNewAccounts) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.mainEntry');
		for(Account acct : listNewAccounts) {
			Account newAccount = new Account();
			newAccount.Id = acct.Id;
			newAccount.Website = 'www.salesforce.com';
			sObjectsToUpdate.put(newAccount.Id, newAccount);
		}
		DiagnosticsInstrumentation.Pop();
	}
	
	public override void inProgressEntry(TriggerParameters tp) {
		DiagnosticsInstrumentation.Push('AccountAfterUpdateTriggerHandler.inProgressEntry');
		System.debug('This is an example for reentrant code...');
		DiagnosticsInstrumentation.Pop();
	}
	
}