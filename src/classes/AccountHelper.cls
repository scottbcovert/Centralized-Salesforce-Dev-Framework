public with sharing class AccountHelper {
	public static map<Id,SObject> updateWebsite(list<Account> listNewAccounts){
		map<Id,SObject> resultMap = new map<Id,SObject>();
		for(Account acct : listNewAccounts) {
			Account newAccount = new Account();
			newAccount.Id = acct.Id;
			newAccount.Website = 'www.salesforce.com';
			resultMap.put(newAccount.Id, newAccount);
		}
		return resultMap;
	}
}