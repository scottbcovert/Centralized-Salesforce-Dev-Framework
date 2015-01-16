/**
* @author Scott Covert
* @date 1/16/2015
* @description Defines the interface for Scheduler Ping-Pong.
*/
public class ScheduledDispatcher Implements Schedulable {
	public Interface IScheduleDispatched 
    { 
        void execute(SchedulableContext sc); 
    } 
    /** 
	* @author Scott Covert
	* @date 1/16/2015
	* @description Executes ScheduleHandler.
	*/
    public void execute(SchedulableContext sc) 
    {
        Type targettype = Type.forName('ScheduleHandler');   
        if(targettype!=null) {
            IScheduleDispatched obj = (IScheduleDispatched)targettype.NewInstance();
            obj.execute(sc);   
        } 
    } 
}