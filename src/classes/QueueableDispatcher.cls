/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the interface for Queueable Apex
*/
public class QueueableDispatcher Implements Queueable, Database.AllowsCallouts {
	
	/**
    * @author Scott Covert
    * @date 2/21/2016
    * @description Queueable Apex interface
    */
    public Interface IQueueableDispatched 
    { 
        void execute(QueueableContext sc); 
    } 

    /** 
	* @author Scott Covert
	* @date 2/21/2016
	* @description Executes QueueableHandler.
    * @param QueueableContext Current queueable context
	*/
    public void execute(QueueableContext sc) 
    {
        Type targettype = Type.forName('QueueableHandler');   
        if(targettype!=null) {
            IQueueableDispatched obj = (IQueueableDispatched)targettype.NewInstance();
            obj.execute(sc);   
        } 
    } 
}