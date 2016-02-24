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
		/* Sample code for performing callout asynchronously through queueable apex
		** To use, uncomment and set CalloutHandler.ENDPOINT; HTTP method will default to GET
		*/
		/*
		CalloutRequest__c cr = new CalloutRequest__c(Endpoint__c = CalloutHandler.ENDPOINT);		
		QueueableHandler.startCalloutJob(QueueableHandler.CALLOUT_TOKEN, cr);
		// QueueableHandler.startCalloutJob(QueueableHandler.ASYNC_TOKEN + QueueableHandler.CALLOUT_TOKEN, cr);
		*/
		return resultMap;
	}
}