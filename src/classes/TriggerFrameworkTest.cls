/**
* @author Scott Covert
* @date 11/9/2014
* @description This class provides unit tests for the framework.
*/
@isTest
public with sharing class TriggerFrameworkTest { 
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method tests framework via the sample account trigger. 
	*/
	public static testMethod void testAccountTrigger() {
		Account acct = new Account();
		acct.Name = 'testacct1';
		insert acct;

		Account acct1 = [SELECT Id, Name FROM Account WHERE Name = 'testacct1'];
		acct1.Name = 'testacct2';
		update acct1;
		System.assert(true);
	}
}