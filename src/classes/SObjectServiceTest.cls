/**
* @author Scott Covert
* @date 12/17/2015
* @description This class provides unit tests for SObjectService
*/
@isTest (oninstall=true seealldata=false)
public with sharing class SObjectServiceTest { 
	/** 
	* @author Scott Covert
	* @date 12/17/2015
	* @description This method tests the SObjectService methods
	*/
	@isTest (oninstall=true seealldata=false)
	public static void testSObjectService() {
		
		// Execute query methods
		list<SObject> accountList = SObjectService.RunQuery('Account', new list<String>{'Id'}, new list<String>(), null, null, null);
		accountList = SObjectService.RunQuery('Account', null, false, SObjectService.BuildRelationshipFilter(new list<String>{'001123456789123456'}, 'Id'), 'Name', 1);
		System.assertEquals(0,accountList.size(),'Problem with SObjectService query methods');
		// Execute PrefixKey method
		String accountPrefix =  SObjectService.PrefixKey('Account');
		System.assertEquals('001',accountPrefix,'Problem with SObjectService.KeyPrefix method');
		// Execute ObjectName method
		String objectName = SObjectService.ObjectName('001');
		System.assertEquals('account',objectName,'Problem with SObjectService.ObjectName method');
		// Execute VerifyFieldType method
		Boolean nameIsString = SObjectService.VerifyFieldType('Account', 'Name', Schema.DisplayType.STRING);
		System.assertEquals(true,nameIsString,'Problem with SObjectService.VerifyFieldType method');
		
	}
}