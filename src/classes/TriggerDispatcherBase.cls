/**
* @author Scott Covert, Bartosz Juriewicz
* @date 11/9/2014, 10/30/2016
* @description This class implements the ITriggerDispatcher and acts as an adapter to avoid implementing all the 
*				ITriggerDispatcher methods.
*/
public virtual class TriggerDispatcherBase implements ITriggerDispatcher { 
	
	/** Stores handlers for trigger events */
    private static Map<String, Map<TriggerParameters.TriggerEvent, ITriggerHandler>> triggerHandlersMap;
    
    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called prior to execution of a before trigger event. If you want 
	*				to load any lookup data or cache the data, then this is the place that you need 
	*				to put your code. 
	*/
    public virtual void bulkBefore() {}

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called prior to execution of an after trigger event. 
	*/
    public virtual void bulkAfter() {}

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called for records to be inserted during a BEFORE trigger.
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void beforeInsert(TriggerParameters tp) {}

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called for records to be updated during a BEFORE trigger.
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void beforeUpdate(TriggerParameters tp) {}

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called for records to be deleted during a BEFORE trigger.
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void beforeDelete(TriggerParameters tp) {}

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called for records inserted during an AFTER trigger. Always put field validation 
	*				in the 'After' methods in case another trigger has modified any values. The record is 'read only' 
	*				at this point.
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void afterInsert(TriggerParameters tp) {} 

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called iteratively for each record updated during an AFTER trigger.
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void afterUpdate(TriggerParameters tp) {}

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called iteratively for each record deleted during an AFTER trigger.
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void afterDelete(TriggerParameters tp) {}
    
    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description This method is called prior to execution of a AFTER UNDELETE trigger. 
    * @param TriggerParameters Contains the trigger parameters
	*/
    public virtual void afterUnDelete(TriggerParameters tp) {}
    
    /** 
    * @author Scott Covert
    * @date 11/9/2014
    * @description This method is called at the end of a before trigger event
    */
    public virtual void andFinally() {}
    
    /** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
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
    		addTriggerHandler(handlerInstance, tEvent, tp.triggerObject);
            
    		if (System.isBatch()){
    			handlerInstance.batchEntry(tp);
    		}
    		else if (System.isFuture()){
    			handlerInstance.futureEntry(tp);
    		}
            else if (System.isQueueable()){
                handlerInstance.queueableEntry(tp);
            }
    		else if (System.isScheduled()){
    			handlerInstance.scheduledEntry(tp);
    		}
    		else {
    			handlerInstance.mainEntry(tp);
    		}
    		handlerInstance.updateObjects();
    	}
        //reentrant handling
    	else {
            ITriggerHandler handler = getTriggerHandler(tEvent, tp.triggerObject);
            if (handler != null) {
                handler.inProgressEntry(tp);
            }
    	}
    }


    /** 
    * @author Bartosz Juriewicz
    * @date 10/30/2016
    * @description Adds ITriggerHandler instance to static map 
    * @param ITriggerHandler The trigger handler instance.
    * @param TriggerParameters.TriggerEvent The trigger event.
    * @param String The API name of the SObject for the trigger event.
    **/
    private static void addTriggerHandler(ITriggerHandler handlerInstance, TriggerParameters.TriggerEvent tEvent, String soType) {
        if (triggerHandlersMap == null) {
            triggerHandlersMap = new Map<String, Map<TriggerParameters.TriggerEvent, ITriggerHandler>>();
        }
        if (!triggerHandlersMap.containsKey(soType)) {
            triggerHandlersMap.put(soType, new Map<TriggerParameters.TriggerEvent, ITriggerHandler>());
        }
        triggerHandlersMap.get(soType).put(tEvent, handlerInstance);
    }

    /** 
    * @author Bartosz Juriewicz
    * @date 10/30/2016
    * @description Gets ITriggerHandler instance from static map
    * @param TriggerParameters.TriggerEvent The trigger event.
    * @param String The API name of the SObject for the trigger event.
    * @return ITriggerHandler The ITriggerHandler instance for the trigger event.
    **/
    private static ITriggerHandler getTriggerHandler(TriggerParameters.TriggerEvent tEvent, String soType) {
        if (triggerHandlersMap == null || !triggerHandlersMap.containsKey(soType) || !triggerHandlersMap.get(soType).containsKey(tEvent)) {
            return null;
        }
        return triggerHandlersMap.get(soType).get(tEvent);
    }
}