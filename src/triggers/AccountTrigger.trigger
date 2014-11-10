trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	// This is the only line of code that is required.
	TriggerFactory.createTriggerDispatcher(Account.sObjectType);
}