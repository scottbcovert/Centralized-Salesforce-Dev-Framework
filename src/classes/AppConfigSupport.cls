/**
* @author Scott Covert
* @date 11/9/2014
* @description This class leverages the AppConfig custom setting to get and set configuration options for the application.
*/
public class AppConfigSupport {
	/** Cached config options for testing */
	private static AppConfig__c testconfig = null;
	/** KillSwitch value for testing */
	public static Boolean testKillSwitch = false;
	/** EmailDebugInfoLog value for testing */
	public static Boolean testEmailDebugInfoLog = false;
	/** DebugInfoRecipientEmails value for testing */
	public static String testDebugInfoRecipientEmails;
	/** DebugInfoMaxNum value for testing */
	public static Integer testDebugInfoMaxNum;
	/** DebugInfoMaxAge value for testing */
	public static Integer testDebugInfoMaxAge;
	/** Set of SObjects that should temporarily have their trigger logic bypassed */
	public static set<Schema.sObjectType> BypassObjects = new set<Schema.sObjectType>();

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called to get (or set and then return if currently null) config options for the execution context via the AppConfig custom setting.
	*				Caches result for future calls if within testing context.
	* @return AppConfig__c App Config Custom Settings
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
			theobject.DebugInfoRecipientEmails__c = (Test.isRunningTest() && testDebugInfoRecipientEmails!=null)? testDebugInfoRecipientEmails: null;
			theobject.MaxDebugInfoRecords__c = (Test.isRunningTest() && testDebugInfoMaxNum!=null)? testDebugInfoMaxNum: null;
			theobject.MaxDebugInfoAge__c = (Test.isRunningTest() && testDebugInfoMaxAge!=null)? testDebugInfoMaxAge: null;
			if(!Test.isRunningTest()) Database.Insert(theobject);
			else testconfig = theobject;
		}
		return theobject;
	}
	
	/** Stores if Diagnostics are enabled */
	public static Boolean DiagnosticsEnabled
	{ 
		get
		{
			return GetAppConfig().EnableDiagnostics__c;
		}
	}

	/** Stores if Kill Switch is enabled */
	public static Boolean KillSwitchEnabled
	{
		get
		{
			return GetAppConfig().KillSwitch__c;
		}
	}

	/** Stores if DebugInfo Log Emailing is enabled */
	public static Boolean EmailDebugInfoEnabled
	{
		get
		{
			return GetAppConfig().EmailDebugInfoLog__c;
		}
	}

	/** Stores Email Recipients for DebugInfo */
	public static String DebugInfoEmailRecipients
	{
		get
		{
			return GetAppConfig().DebugInfoRecipientEmails__c;
		}
	}

	/** Stores maximum number of DebugInfo records */
	public static Integer DebugInfoMaxNum
	{
		get
		{
			return (Integer)GetAppConfig().MaxDebugInfoRecords__c;
		}
	}

	/** Stores maximum age in days of DebugInfo records */
	public static Integer DebugInfoMaxAge
	{
		get
		{
			return (Integer)GetAppConfig().MaxDebugInfoAge__c;
		}
	}
	
}