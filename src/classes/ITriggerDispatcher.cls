/**
* @author Scott Covert
* @date 11/9/2014
* @description Defines the interface for the trigger dispatching architecture.
*/
public interface ITriggerDispatcher {
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the bulk operations.
	*/
	void bulkBefore();
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the bulk operations.
	*/
	void bulkAfter();
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after completing the bulk operations.
	*/
	void andFinally();
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting inserted.
	*/
	void beforeInsert(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are updated. 
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
	*/
	void beforeUpdate(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting deleted.
	*/
	void beforeDelete(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got inserted.
	*/
	void afterInsert(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are updated.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got updated.
	*/
	void afterUpdate(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the records got deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got deleted.
	*/
	void afterDelete(TriggerParameters tp);
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the records are undeleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got undeleted.
	*/
	void afterUnDelete(TriggerParameters tp);
}