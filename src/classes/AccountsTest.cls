/**
* @author Scott Covert
* @date 11/9/2014
* @description This class provides sample unit tests for Accounts
*/
@isTest (oninstall=true seealldata=false)
public with sharing class AccountsTest { 
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method tests the framework using the sample account trigger. 
	*/
	@isTest (oninstall=true seealldata=false)
	public static void testAccountTrigger() {
		Account acct = new Account();
		acct.Name = 'testacct1';
		insert acct;

		Account acct2 = (Account)SObjectService.RunQuery('Account', new List<String>{'Id','Name'}, new List<String>(), 'Name = \'testacct1\'', 'Name', 1)[0];
		acct2.Name = 'testacct2';
		update acct2;

		// KillSwitch
		ConfigService.testKillSwitch = true;
		update acct2;

		ConfigService.resetTestSettings();

		// Fake Exception
		TriggerFactory.FakeException = true;

		// DebugInfo Log
		ConfigService.testEmailDebugInfoLog = true;
		ConfigService.testDebugInfoMaxAge = 7;
		ConfigService.testDebugInfoEmails = 'test@test.com';
		update acct2;

		TriggerFactory.FakeException = false;
		ConfigService.resetTestSettings();

		update acct2;

		// Simulate Concurrency Error
		TriggerHandlerBase.SimulateConcurrencyError = new List<Boolean>{true};
		update acct2;

		// Reset Simulate Concurrency Error Variable
		TriggerHandlerBase.SimulateConcurrencyError = null;
		update acct2;
		
		acct2 = (Account)SObjectService.RunQuery('Account', null, false, 'Name = \'testacct2\'', null, null)[0];
		System.assertEquals(acct2.Website,'www.salesforce.com','Error in testAccountTrigger. Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		delete acct2;
		
		list<Account> allAccounts = SObjectService.RunQuery('Account', null, false, null, null, null);
		System.assert(allAccounts.isEmpty(),'Error in testAccountTrigger. Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		
		allAccounts = [SELECT Id FROM Account ALL ROWS];
		undelete allAccounts;
		allAccounts = SObjectService.RunQuery('Account', null, false, null, null, null);
		
		// Simulate RepeatingFuture
		AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c='Future:Default',Scheduled_Time__c = System.now(),Params__c=allAccounts[0].Id);
		insert ar;
		RepeatingFuture.Start();
		System.assert(!allAccounts.isEmpty(),'Error in testAccountTrigger. Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
	}
}