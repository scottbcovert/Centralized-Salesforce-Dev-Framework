/**
* @author Scott Covert
* @date 11/9/2014
* @description This class provides sample unit tests for Accounts
*/
@isTest (seealldata=false)
public with sharing class AccountsTest { 
	
	/** 
    * @author Scott Covert
    * @date 12/20/2015
    * @description This method creates test records for all other test methods in this class
    */
    @testSetup private static void testSetup()
    {
    	if (!TestVerificationService.ShouldExecute('AccountsTest.testSetup')) return;

        // Generate account records from factory
        list<Account> testAccounts = (list<Account>)DataFactoryService.CreateRecords('Account',new list<String>{'Name'},'TestAcct',1);
        // Insert test accounts
        DMLManager.insertAsSystem(testAccounts);
    }

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method tests the framework using the sample account trigger. 
	*/
	@isTest (seealldata=false)
	public static void testAccountTrigger() {
		
		if (!TestVerificationService.ShouldExecute('AccountsTest.testAccountTrigger')) return;

		Test.setMock(HttpCalloutMock.class, new HttpCalloutMockService());

		Account testAccount = (Account)SObjectService.RunQuery('Account', new List<String>{'Id','Name'}, new List<String>(), 'Name = \'TestAcct1\'', new List<String>{'Name'}, SObjectService.ASC_DIR_ORDER, 1, false)[0];
		testAccount.Name = 'TestAcct2';
		DMLManager.updateAsSystem(testAccount);

		// KillSwitch
		ConfigService.testKillSwitch = true;
		DMLManager.updateAsSystem(testAccount);

		ConfigService.resetTestSettings();

		// Fake Exception
		TriggerFactory.FakeException = true;

		// DebugInfo Log
		ConfigService.testEmailDebugInfoLog = true;
		ConfigService.testDebugInfoMaxAge = 7;
		ConfigService.testDebugInfoEmails = 'test@test.com';
		DMLManager.updateAsSystem(testAccount);

		TriggerFactory.FakeException = false;
		ConfigService.resetTestSettings();

		DMLManager.updateAsSystem(testAccount);

		// Simulate Concurrency Error
		TriggerHandlerBase.SimulateConcurrencyError = new List<Boolean>{true};
		DMLManager.updateAsSystem(testAccount);

		// Reset Simulate Concurrency Error Variable
		TriggerHandlerBase.SimulateConcurrencyError = null;
		DMLManager.updateAsSystem(testAccount);
		
		testAccount = (Account)SObjectService.RunQuery('Account', null, false, 'Name = \'TestAcct2\'', null, null, null, null)[0];
		System.assertEquals(testAccount.Website,'www.salesforce.com','Error in testAccountTrigger - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		DMLManager.deleteAsSystem(testAccount);
		
		list<Account> allAccounts = SObjectService.RunQuery('Account', null, false, null, null, null, null, null);
		System.assert(allAccounts.isEmpty(),'Error in testAccountTrigger - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		
		allAccounts = [SELECT Id FROM Account ALL ROWS];
		undelete allAccounts;
		allAccounts = SObjectService.RunQuery('Account', null, false, null, null, null, null, null);
		
		// Simulate RepeatingFuture
		AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c='Future:Default',ScheduledTime__c = System.now(),Params__c=allAccounts[0].Id);
		DMLManager.insertAsSystem(ar);
		RepeatingFuture.Start();
		System.assert(!allAccounts.isEmpty(),'Error in testAccountTrigger - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
	}
}