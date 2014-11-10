/**
* @author Scott Covert
* @date 11/9/2014
* @description This class leverages the AppConfig custom setting to get and set configuration options for the application.
*/
public class AppConfigSupport {
	private static AppConfig__c testconfig = null;
	public static Boolean testKillSwitch = false;
	public static Boolean testEmailDebugInfoLog = false;
	public static String testDebugInfoRecipientEmails;
	public static Integer testDebugInfoMaxNum;
	public static Integer testDebugInfoMaxAge;

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
			theobject.KillSwitch__c = (Test.isRunningTest() && testKillSwitch)? true: false;
			theobject.EmailDebugInfoLog__c = (Test.isRunningTest() && testEmailDebugInfoLog)? true: false;
			theobject.DebugInfo_Recipient_Emails__c = (Test.isRunningTest() && testDebugInfoRecipientEmails!=null)? testDebugInfoRecipientEmails: null;
			theobject.MaxDebugInfoRecords__c = (Test.isRunningTest() && testDebugInfoMaxNum!=null)? testDebugInfoMaxNum: null;
			theobject.MaxDebugInfoAge__c = (Test.isRunningTest() && testDebugInfoMaxAge!=null)? testDebugInfoMaxAge: null;
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

	public static Boolean KillSwitchEnabled
	{
		get
		{
			return GetAppConfig().KillSwitch__c;
		}
	}

	public static Boolean EmailDebugInfoEnabled
	{
		get
		{
			return GetAppConfig().EmailDebugInfoLog__c;
		}
	}

	public static String DebugInfoEmailRecipients
	{
		get
		{
			return GetAppConfig().DebugInfo_Recipient_Emails__c;
		}
	}

	public static Integer DebugInfoMaxNum
	{
		get
		{
			return (Integer)GetAppConfig().MaxDebugInfoRecords__c;
		}
	}

	public static Integer DebugInfoMaxAge
	{
		get
		{
			return (Integer)GetAppConfig().MaxDebugInfoAge__c;
		}
	}
	
}