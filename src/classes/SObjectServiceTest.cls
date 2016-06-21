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

		if (!TestVerificationService.ShouldExecute('SObjectServiceTest.testSobjectService')) return;
		
		// Execute query methods
		list<SObject> accountList = SObjectService.RunQuery('Account', new list<String>{'Id'}, new list<String>(), null, null, null, 2*SObjectService.SOQL_ROW_GOV_LIMIT);
		accountList = SObjectService.RunQuery('Account', null, false, SObjectService.BuildRelationshipFilter(new list<String>{'001123456789123456','001123456789123457','001123456789123458'}, 'Id', true), new List<String>{'Name'}, SObjectService.ASC_DIR_ORDER, 1);
		System.assertEquals(0,accountList.size(),'Error in SObjectService query methods - Stacktrace: ' + DiagnosticsInstrumentation.ExceptionTrace);
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