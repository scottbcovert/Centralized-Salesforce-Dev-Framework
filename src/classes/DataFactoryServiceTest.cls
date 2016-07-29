/**
* @author Scott Covert
* @date 12/20/2015
* @description This class provides unit tests for the DataFactoryService test class
*/
@isTest (seealldata=false)
public with sharing class DataFactoryServiceTest { 

	/** 
	* @author Scott Covert
	* @date 12/20/2015
	* @description Tests the DataFactoryService methods
	*/
	@isTest (seealldata=false)
	public static void testDataFactoryService() {
		// DataFactoryService must be tested individually since calls from @testSetup method do not count for code coverage
        
		if (!TestVerificationService.ShouldExecute('DataFactoryServiceTest.testDataFactoryService')) return;

        // Create account record
        list<Account> testAccount = (list<Account>)DataFactoryService.CreateRecords('Account',new list<String>{'Name'},'Test',1);
        DMLManager.insertAsSystem(testAccount);
        System.assertEquals('Test1',testAccount[0].Name,'Error in DataFactoryService.CreateRecords - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);

        // Create contact record
        list<Contact> testContact = (list<Contact>)DataFactoryService.CreateRecords('Contact',new list<String>{'LastName'},'Test',1);
        DMLManager.insertAsSystem(testContact);
        System.assertEquals('Test1',testContact[0].LastName,'Error in DataFactoryService.CreateRecords - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);

        // Relate contact record to account record
        DataFactoryService.CreateRelationships(testContact, testAccount, 'AccountId');
        DMLManager.updateAsSystem(testContact);
        System.assertEquals(testAccount[0].Id,testContact[0].AccountId,'Error in DataFactoryService.CreateRelationships - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);

	}

}