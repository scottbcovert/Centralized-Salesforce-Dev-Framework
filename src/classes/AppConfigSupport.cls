/**
* @author Scott Covert
* @date 11/9/2014
* @description This class leverages the AppConfig custom setting to get and set configuration options for the application.
*/
public class AppConfigSupport {
	private static AppConfig__c testconfig = null;
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called to get (or set and then return if currently null) config options for the execution context via the AppConfig custom setting.
	*				Caches result for future calls if within testing context.
	*/
	public static AppConfig__c GetAppConfig()
	{
		if(Test.isRunningTest() && testconfig!=null) return testconfig;
		
		AppConfig__c theobject = AppConfig__c.getInstance('default');
		if(theobject==null || Test.isRunningTest()) 
		{
			theobject = new AppConfig__c();
			theobject.name = 'default';
			theobject.EnableDiagnostics__c = (Test.isRunningTest())? true: false;
			if(!Test.isRunningTest()) Database.Insert(theobject);
			else testconfig = theobject;
		}
		return theobject;
	}
	
	public static Boolean DiagnosticsEnabled
	{ 
		get
		{
			return GetAppConfig().EnableDiagnostics__c;
		}
	}
	
}