/**
* @author Scott Covert
* @date 11/9/2014
* @description This class holds the trigger parameters.
*/
public class TriggerParameters {
	/** An enum that represents the trigger event */
	public Enum TriggerEvent { beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete }
	/** Current trigger event */
	public TriggerEvent tEvent;
	/** Stores Trigger.old */
	public List<SObject> oldList { get; private set; }
	/** Stores Trigger.new */
	public List<SObject> newList { get; private set; }
	/** Stores Trigger.oldMap */
	public Map<Id, SObject> oldMap { get; private set; }
	/** Stores Trigger.newMap */
	public Map<Id, SObject> newMap { get; private set; }
	/** SObject for currently executing trigger */
	public String triggerObject { get; private set; }
	/** Stores execution state of trigger */
	public Boolean isExecuting { get; private set; }
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Constructs the TriggerParameter object.
	* @param List A list of records with the state of 'before' event.
	* @param List A list of records with the state of 'after' event.
	* @param Map A map of records with the state of 'before' event.
	* @param Map A map of records with the state of 'after' event.
	* @param Boolean A flag to indicate 'isBefore' event.
	* @param Boolean A flag to indicate 'isAfter' event.
	* @param Boolean A flag to indicate 'isDelete' event.
	* @param Boolean A flag to indicate 'isInsert' event.
	* @param Boolean A flag to indicate 'isUpdate' event.
	* @param Boolean A flag to indicate 'isUnDelete' event.
	* @param Boolean A flag to indicate 'isExecuting'.
	*/
	public TriggerParameters(List<SObject> olist, List<SObject> nlist, Map<Id, SObject> omap, Map<Id, SObject> nmap,
								Boolean ib, Boolean ia, Boolean id, Boolean ii, Boolean iu, Boolean iud, Boolean ie) {
		this.oldList = olist;
		this.newList = nlist;
		this.oldMap = omap;
		this.newMap = nmap;
		this.triggerObject = SObjectService.TypeName((this.oldList != null && this.oldList.size() > 0) ? this.oldList[0] : this.newList[0]);
		if (ib & ii) tEvent = TriggerEvent.beforeInsert;
		else if (ib && iu) tEvent = TriggerEvent.beforeUpdate;
		else if (ib && id) tEvent = TriggerEvent.beforeDelete;
		else if (ia && ii) tEvent = TriggerEvent.afterInsert;
		else if (ia && iu) tEvent = TriggerEvent.afterUpdate;
		else if (ia && id) tEvent = TriggerEvent.afterDelete;
		else if (ia && iud) tEvent = TriggerEvent.afterUndelete;
		isExecuting = ie;
	}
}