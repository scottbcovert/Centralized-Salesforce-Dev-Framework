/**
* @author Scott Covert
* @date 11/9/2014
* @description Helper Methods for Account Trigger Handling
*/
public with sharing class AccountHelper {
	
	/**
    * @author Scott Covert
    * @date 11/9/2014
    * @description Update website field of accounts to the Salesforce homepage
    * @param List A list of accounts that should have their website field updated
    * @param Map A map of accounts with their website field set to the Salesforce homepage
    */
	public static map<Id,SObject> updateWebsite(list<Account> listNewAccounts){
		map<Id,SObject> resultMap = new map<Id,SObject>();
		for(Account acct : listNewAccounts) {
			Account newAccount = new Account();
			newAccount.Id = acct.Id;
			newAccount.Website = 'www.salesforce.com';
			resultMap.put(newAccount.Id, newAccount);
		}
		Id jobId = System.enqueueJob(new QueueableDispatcher());
		AsyncRequest__c ar = new AsyncRequest__c(JobId__c = jobId, AsyncType__c = QueueableHandler.CALLOUT_TOKEN);
		CalloutRequest__c cr = new CalloutRequest__c(JobId__c = jobId, Endpoint__c = CalloutHandler.ENDPOINT, Method__c = CalloutHandler.GET_METHOD, Status__c = CalloutHandler.QUEUED_STATUS, Timeout__c = (CalloutHandler.MAX_CALLOUT_TIME/1000) );
		insert ar;		
		insert cr;		
		return resultMap;
	}
}