/**
* @author Scott Covert
* @date 11/9/2014
* @description This factory creates the correct dispatcher and dispatches the trigger event(s) to the appropriate 
*				event handler(s). The dispatchers are automatically created using the Type API, hence dispatcher 
*				registration is not required for each dispatchers.
*/
public with sharing class TriggerFactory
{

    /** Determines if a custom exception should be forced for test purposes */
    @TestVisible private static Boolean FakeException = false;

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Creates the appropriate dispatcher and dispatches the trigger event to the dispatcher's event handler method.
	* @param Schema.sObjectType Object type to process (SObject.sObjectType)
	*/
    public static void createTriggerDispatcher(Schema.sObjectType soType)
    {
        if (!ConfigService.KillSwitchEnabled && !ConfigService.BypassObjects.contains(soType)){
            // Initial Push to Diagnostic Log
            String beforeOrAfter = 'Before ';
            if (Trigger.isAfter)
                beforeOrAfter = 'After ';
            String dmlState = 'Insert';
            if (Trigger.isUpdate){
                dmlState = 'Update';
            }
            else if (Trigger.isDelete){
                dmlState = 'Delete';
            }
            else if (Trigger.isUndelete){
                dmlState = 'Undelete';
            }
            String soTypeName = soType.getDescribe().getLocalName();
            DiagnosticsInstrumentation.Push(beforeOrAfter + dmlState + ' Trigger for ' + soTypeName + ' Object');
            try{
                ITriggerDispatcher dispatcher = getTriggerDispatcher(soType);
                if (dispatcher == null || FakeException)
                    throw new CustomException('No Trigger dispatcher registered for Object Type: ' + soType);
                execute(dispatcher,soTypeName);
                // Final Pop from Diagnostic Log
                DiagnosticsInstrumentation.Pop();
            }
            catch(Exception ex){
                DiagnosticsInstrumentation.DebugException(ex);
            }
        }
    }

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Dispatches to the dispatcher's event handlers.
	* @param ITriggerDispatcher A Trigger dispatcher that dispatches to the appropriate handlers
	*/ 
    private static void execute(ITriggerDispatcher dispatcher, String soTypeName)
    {
    	TriggerParameters tp = new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
									Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, 
									Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);
        // Handle before trigger events
        if (Trigger.isBefore) {
            DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.bulkBefore');
            dispatcher.bulkBefore();
            DiagnosticsInstrumentation.Pop();
            if (Trigger.isDelete){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.beforeDelete');
                dispatcher.beforeDelete(tp);
                DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isInsert){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.beforeInsert');
                dispatcher.beforeInsert(tp);
                DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isUpdate){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.beforeUpdate');
                dispatcher.beforeUpdate(tp);      
                DiagnosticsInstrumentation.Pop();   
            }
        }
        else	// Handle after trigger events
        {
            DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.bulkAfter');
            dispatcher.bulkAfter();
            DiagnosticsInstrumentation.Pop();
            if (Trigger.isDelete){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterDelete');
                dispatcher.afterDelete(tp);
                DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isInsert){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterInsert');
                dispatcher.afterInsert(tp);
                DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isUpdate){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterUpdate');
                dispatcher.afterUpdate(tp);
                DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isUnDelete){
                DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterUnDelete');
                dispatcher.afterUnDelete(tp);
                DiagnosticsInstrumentation.Pop();
            }
        }
        DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.andFinally');
        dispatcher.andFinally();
        DiagnosticsInstrumentation.Pop();
    } 

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Gets the appropriate dispatcher based on the SObject. It constructs the instance of the dispatcher
	*				dynamically using the Type API. The name of the dispatcher has to follow this format:
	*				<ObjectName>TriggerDispatcher. For e.g. for the Account object, the dispatcher has to be named
	*				as AccountTriggerDispatcher. For the custom object Custom__c, the name should be CustomTriggerDispatcher.
	* @param Schema.sObjectType Object type to create the dispatcher
	* @return ITriggerDispatcher A trigger dispatcher if one exists, otherwise null.
	*/
    private static ITriggerDispatcher getTriggerDispatcher(Schema.sObjectType soType)
    {
    	String originalTypeName = soType.getDescribe().getName();
    	String dispatcherTypeName = null;
    	if (originalTypeName.toLowerCase().endsWith('__c')) {
    		Integer index = originalTypeName.toLowerCase().indexOf('__c');
    		dispatcherTypeName = originalTypeName.substring(0, index).replace('_','') + 'TriggerDispatcher';
    	}
    	else
    		dispatcherTypeName = originalTypeName.replace('_','') + 'TriggerDispatcher';

		Type obType = Type.forName(dispatcherTypeName);
		ITriggerDispatcher dispatcher = (obType == null) ? null : (ITriggerDispatcher)obType.newInstance();
    	return dispatcher;
    }
}