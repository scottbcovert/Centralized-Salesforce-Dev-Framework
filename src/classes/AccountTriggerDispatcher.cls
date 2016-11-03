/**
* @author Scott Covert, Bartosz Juriewicz
* @date 11/9/2014, 10/30/2016
* @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
*				on the Account object. The event handlers support allowing and preventing actions for reentrant scenarios. 
*				This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
*				to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
*				as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
*/
public class AccountTriggerDispatcher extends TriggerDispatcherBase {
	/** Stores if before insert handler is processing */
	private static Boolean isBeforeInsertProcessing = false;
	/** Stores if before update handler is processing */
	private static Boolean isBeforeUpdateProcessing = false;
	/** Stores if before delete handler is processing */
	private static Boolean isBeforeDeleteProcessing = false;
	/** Stores if after insert handler is processing */
	private static Boolean isAfterInsertProcessing = false;
	/** Stores if after update handler is processing */
	private static Boolean isAfterUpdateProcessing = false; 
	/** Stores if after delete handler is processing */
	private static Boolean isAfterDeleteProcessing = false;
	/** Stores if after undelete handler is processing */
	private static Boolean isAfterUnDeleteProcessing = false;

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions before the records are inserted. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void beforeInsert(TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new AccountBeforeInsertTriggerHandler(), tp, TriggerParameters.TriggerEvent.beforeInsert, Account.getSobjectType());
			isBeforeInsertProcessing = false;
		} else {
			execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert, Account.getSobjectType());
		}
	}

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions before the records are updated. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void beforeUpdate(TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new AccountBeforeUpdateTriggerHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate, Account.getSobjectType());
			isBeforeUpdateProcessing = false;
		} else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate, Account.getSobjectType());
	}

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions before the records are deleted. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void beforeDelete(TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			execute(new AccountBeforeDeleteTriggerHandler(), tp, TriggerParameters.TriggerEvent.beforeDelete, Account.getSobjectType());
			isBeforeDeleteProcessing = false;
		} else execute(null, tp, TriggerParameters.TriggerEvent.beforeDelete, Account.getSobjectType());
	}

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions after the records are inserted. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void afterInsert(TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new AccountAfterInsertTriggerHandler(), tp, TriggerParameters.TriggerEvent.afterInsert, Account.getSobjectType());
			isAfterInsertProcessing = false;
		} else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert, Account.getSobjectType());
	}

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions after the records are updated. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void afterUpdate(TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new AccountAfterUpdateTriggerHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate, Account.getSobjectType());
			isAfterUpdateProcessing = false;
		} else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate, Account.getSobjectType());
	}

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions after the records are deleted. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void afterDelete(TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			execute(new AccountAfterDeleteTriggerHandler(), tp, TriggerParameters.TriggerEvent.afterDelete, Account.getSobjectType());
			isAfterDeleteProcessing = false;
		} else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete, Account.getSobjectType());
	}

	/** 
	* @author Scott Covert, Bartosz Juriewicz
	* @date 11/9/2014, 10/30/2016
	* @description Called by the trigger framework to carry out the actions after the records are undeleted. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters
	*/	
	public virtual override void afterUnDelete(TriggerParameters tp) {
		if(!isAfterUnDeleteProcessing) {
			isAfterUnDeleteProcessing = true;
			execute(new AccountAfterUnDeleteTriggerHandler(), tp, TriggerParameters.TriggerEvent.afterUndelete, Account.getSobjectType());
			isAfterUnDeleteProcessing = false;
		} else execute(null, tp, TriggerParameters.TriggerEvent.afterUndelete, Account.getSobjectType());
	}
}