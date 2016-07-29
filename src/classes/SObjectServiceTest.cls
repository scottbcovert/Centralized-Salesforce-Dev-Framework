/**
* @author Scott Covert
* @date 12/17/2015
* @description This class provides unit tests for SObjectService
*/
@isTest (seealldata=false)
public with sharing class SObjectServiceTest { 
	
	/** 
    * @author Scott Covert
    * @date 6/20/2016
    * @description This method creates test records for all other test methods in this class
    */
    @testSetup private static void testSetup()
    {
    	if (!TestVerificationService.ShouldExecute('SObjectServiceTest.testSetup')) return;

        // Generate contact records from factory
        list<Contact> testContacts = (list<Contact>)DataFactoryService.CreateRecords('Contact',new list<String>{'LastName'},'TestContact',1);
        // Insert test contacts
        DMLManager.insertAsSystem(testContacts);

        // Generate a standard user for testing sharing settings
    	List<Profile> standardUserProfile = SObjectService.RunQuery('Profile', null, false, 'Name = \'Standard User\'', null, null, 1, false);
      	list<User> standardUser = (list<User>)DataFactoryService.CreateRecords('User',new list<String>{'FirstName','LastName'},'Tester',1);
      	standardUser[0].Alias = 'Tester';
      	standardUser[0].Username = 'tester' + String.valueOf(System.now().getTime()) + '@tester.com';
      	standardUser[0].Email = 'tester@tester.com';
      	standardUser[0].EmailEncodingKey = 'UTF-8';
      	standardUser[0].LanguageLocaleKey='en_US';
      	standardUser[0].LocaleSidKey='en_US';
      	standardUser[0].TimeZoneSidKey='America/Los_Angeles';
      	standardUser[0].ProfileId = standardUserProfile[0].Id;
      	DMLManager.insertAsSystem(standardUser);
    }

    /** 
	* @author Scott Covert
	* @date 12/17/2015
	* @description This method tests the SObjectService methods
	*/
	@isTest (seealldata=false)
	public static void testSObjectService() {

		if (!TestVerificationService.ShouldExecute('SObjectServiceTest.testSobjectService')) return;
		
		// Execute query methods
		list<SObject> accountList = SObjectService.RunQuery('Account', new list<String>{'Id'}, new list<String>(), null, null, null, 2*SObjectService.SOQL_ROW_GOV_LIMIT, false);
		accountList = SObjectService.RunQuery('Account', null, false, SObjectService.BuildRelationshipFilter(new list<String>{'001123456789123456','001123456789123457','001123456789123458'}, 'Id', true), new List<String>{'Name'}, SObjectService.ASC_DIR_ORDER, 1, true);
		System.assertEquals(0,accountList.size(),'Error in SObjectService query methods - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		List<User> standardUser = SObjectService.RunQuery('User', new list<String>{'Id','FirstName','LastName','Username','Email','ProfileId'}, new list<String>(), 'LastName = \'Tester1\'', null, null, 1, false);
		System.runAs(standardUser[0]){
			// The standard user should be unable to see the previously inserted contact unless without sharing is utilized
			list<SObject> contactList = SObjectService.RunQuery('Contact', new list<String>{'Id'}, new list<String>(), null, null, null, 1, false);
			System.assertEquals(0,contactList.size(),'Error in SObjectService; query methods returning records that should not be shared - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
			contactList = SObjectService.RunQueryWithoutSharing('Contact', new list<String>{'Id'}, new list<String>(), null, null, null, 1, false);
			System.assertNotEquals(0,contactList.size(),'Error in SObjectService; query methods hiding records due to sharing permissions that should be ignored - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
			contactList = SObjectService.RunQuery('Contact', null, false, null, null, null, 1, false);
			System.assertEquals(0,contactList.size(),'Error in SObjectService; query methods returning records that should not be shared - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
			contactList = SObjectService.RunQueryWithoutSharing('Contact', null, false, null, null, null, 1, false);
			System.assertNotEquals(0,contactList.size(),'Error in SObjectService; query methods hiding records due to sharing permissions that should be ignored - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		}
		// Execute PrefixKey method
		String accountPrefix =  SObjectService.PrefixKey('Account');
		System.assertEquals('001',accountPrefix,'Error in SObjectService.KeyPrefix - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		// Execute ObjectName method
		String objectName = SObjectService.ObjectName('001');
		System.assertEquals('account',objectName,'Error in SObjectService.ObjectName - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
		// Execute VerifyFieldType method
		Boolean nameIsString = SObjectService.VerifyFieldType('Account', 'Name', Schema.DisplayType.STRING);
		System.assertEquals(true,nameIsString,'Error in SObjectService.VerifyFieldType - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);		
		
	}
}