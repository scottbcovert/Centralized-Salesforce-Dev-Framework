/**
* @author Scott Covert
* @date 11/9/2014
* @description This class provides unit tests for the framework.
*/
@isTest (oninstall=true seealldata=false)
public with sharing class CustomFrameworkTest { 
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

		Account acct2 = [SELECT Id, Name FROM Account WHERE Name = 'testacct1'];
		acct2.Name = 'testacct2';
		update acct2;
		//KillSwitch
		TriggerFactory.KillSwitchEnabled = true;
		update acct2;
		TriggerFactory.KillSwitchEnabled = false;
		//Fake Exception
		TriggerFactory.FakeException = true;
		//DebugInfo Log
		DiagnosticsInstrumentation.EmailDebugInfoEnabled = true;
		DiagnosticsInstrumentation.DebugInfoMaxAge = 7;
		DiagnosticsInstrumentation.DebugInfoEmailRecipients = 'test@test.com';
		update acct2;
		TriggerFactory.FakeException = false;
		update acct2;
		TriggerHandlerBase.SimulateConcurrencyError = new List<Boolean>{true};
		update acct2;
		TriggerHandlerBase.SimulateConcurrencyError = null;
		update acct2;
		acct2 = [SELECT Id, Name, Website FROM Account WHERE Name = 'testacct2'];
		System.assertEquals(acct2.Website,'www.salesforce.com','Error in testAccountTrigger. Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		delete acct2;
		list<Account> allAccounts = [SELECT Id FROM Account];
		System.assert(allAccounts.isEmpty(),'Error in testAccountTrigger. Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		allAccounts = [SELECT Id FROM Account ALL ROWS];
		undelete allAccounts;
		allAccounts = [SELECT Id FROM Account];
		// Simulate RepeatingFuture
		AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c='Future:Default',Scheduled_Time__c = System.now(),Params__c=allAccounts[0].Id);
		insert ar;
		RepeatingFuture.Start();
		System.assert(!allAccounts.isEmpty(),'Error in testAccountTrigger. Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
	}
}