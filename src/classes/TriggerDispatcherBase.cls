/**
* @author Hari Krishnan
* @date 07/16/2013
* @description This class implements the ITriggerDispatcher and acts as an adapter to avoid implementing all the 
*				ITriggerDispatcher methods.
* @return Feedback__c The newly created feedback object.
*/
public virtual class TriggerDispatcherBase implements ITriggerDispatcher { 
	
	private static ITriggerHandler beforeInserthandler;
	private static ITriggerHandler beforeUpdatehandler;
	private static ITriggerHandler beforeDeleteHandler;
	private static ITriggerHandler afterInserthandler;
	private static ITriggerHandler afterUpdatehandler;
	private static ITriggerHandler afterDeleteHandler;
	private static ITriggerHandler afterUndeleteHandler;

	
    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called prior to execution of a before trigger event. If you want 
	*				to load any lookup data or cache the data, then this is the place that you need 
	*				to put your code. 
	*/
    public virtual void bulkBefore() {}

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called prior to execution of an after trigger event. 
	*/
    public virtual void bulkAfter() {}

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called for records to be inserted during a BEFORE trigger.
	*/
    public virtual void beforeInsert(TriggerParameters tp) {}

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called for records to be updated during a BEFORE trigger.
	*/
    public virtual void beforeUpdate(TriggerParameters tp) {}

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called for records to be deleted during a BEFORE trigger.
	*/
    public virtual void beforeDelete(TriggerParameters tp) {}

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called for records inserted during an AFTER trigger. Always put field validation 
	*				in the 'After' methods in case another trigger has modified any values. The record is 'read only' 
	*				at this point.
	*/
    public virtual void afterInsert(TriggerParameters tp) {} 

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called iteratively for each record updated during an AFTER trigger.
	*/
    public virtual void afterUpdate(TriggerParameters tp) {}

    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called iteratively for each record deleted during an AFTER trigger.
	*/
    public virtual void afterDelete(TriggerParameters tp) {}
    
    /** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description This method is called prior to execution of a AFTER UNDELETE trigger. 
	*/
    public virtual void afterUnDelete(TriggerParameters tp) {}
    
    public virtual void andFinally() {}
    
    /** 
	* @author Hari Krishnan
	* @date 06/20/2013
	* @description Called by the event handlers. If this is the first call in the context, then this method will create a new 
	*				instance of the appropriate handler and execute the mainEntry method. If there is an existing call runing 
	*				on the same context, then this method will use the existing handler instance created by the original call
	*				and execute the inProgressEntry method.
	* @param ITriggerHandler The trigger handler instance. The dispatcher need to pass an instance of the trigger handler, such
	*							as AccountAfterInsertTriggerHandler if this is the first call in a given context. If it is retry,
	*							then the dispatcher will need to pass null.
	* @param TriggerParameters The trigger parameters passed by the framework.
	* @param TriggerParameters.TriggerEvent The trigger event.
	*/
   	protected void execute(ITriggerHandler handlerInstance, TriggerParameters tp, TriggerParameters.TriggerEvent tEvent) {
    	if(handlerInstance != null) {
    		if(tEvent == TriggerParameters.TriggerEvent.beforeInsert)
    			beforeInsertHandler = handlerInstance;
    		if(tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
    			beforeUpdateHandler = handlerInstance;
    		if(tEvent == TriggerParameters.TriggerEvent.beforeDelete)
    			beforeDeleteHandler = handlerInstance;
    		if(tEvent == TriggerParameters.TriggerEvent.afterInsert)
    			afterInsertHandler = handlerInstance;
    		if(tEvent == TriggerParameters.TriggerEvent.afterUpdate)
    			afterUpdateHandler = handlerInstance;
    		if(tEvent == TriggerParameters.TriggerEvent.afterDelete)
    			afterDeleteHandler = handlerInstance;
    		if(tEvent == TriggerParameters.TriggerEvent.afterUnDelete)
    			afterUndeleteHandler = handlerInstance;
    		handlerInstance.mainEntry(tp);
    		handlerInstance.updateObjects();
    	}
    	else {
    		if(tEvent == TriggerParameters.TriggerEvent.beforeInsert)
    			beforeInsertHandler.inProgressEntry(tp);
    		if(tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
    			beforeUpdateHandler.inProgressEntry(tp);
    		if(tEvent == TriggerParameters.TriggerEvent.beforeDelete)
    			beforeDeleteHandler.inProgressEntry(tp);
    		if(tEvent == TriggerParameters.TriggerEvent.afterInsert)
    			afterInsertHandler.inProgressEntry(tp);
    		if(tEvent == TriggerParameters.TriggerEvent.afterUpdate)
    			afterUpdateHandler.inProgressEntry(tp);
    		if(tEvent == TriggerParameters.TriggerEvent.afterDelete)
    			afterDeleteHandler.inProgressEntry(tp);
    		if(tEvent == TriggerParameters.TriggerEvent.afterUnDelete)
    			afterUndeleteHandler.inProgressEntry(tp);
    	}
    }
}