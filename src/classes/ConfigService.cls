/**
* @author Scott Covert
* @date 12/17/2015
* @description This class leverages the Config custom metadata type to return configuration options for the application.
*/
public class ConfigService {
	/** Licensed User state value for testing */
	@TestVisible private static Boolean testLicensedUser = true;
	/** Person Accounts state value for testing */
	@TestVisible private static Boolean testPersonAccounts = false;
	/** MultiCurrency state value for testing */
	@TestVisible private static Boolean testMultiCurrency = false;
	/** DebugInfoRecipientEmails value for testing */
	@TestVisible private static String testDebugInfoEmails;
	/** EmailDebugInfoLog value for testing */
	@TestVisible private static Boolean testEmailDebugInfoLog = false;
	/** KillSwitch value for testing */
	@TestVisible private static Boolean testKillSwitch = false;
	/** DebugInfoMaxAge value for testing */
	@TestVisible private static Integer testDebugInfoMaxAge;
	/** DebugInfoMaxNum value for testing */
	@TestVisible private static Integer testDebugInfoMaxNum;
	/** Packaged Apex Class Name */
	private static final String PACKAGED_CLASS_NAME = 'ConfigService';
	/** Obfuscated Body Text */
	private static final String OBFUSCATED_BODY_TEXT = '(hidden)';
	/** Author */
	private static final String AUTHOR_NAME = 'Scott Covert';
	/** Packaged Apex Class */
	private static final list<ApexClass> PACKAGED_CLASS = Database.query('SELECT Name, Body, NameSpacePrefix FROM ApexClass WHERE Name = \'' + PACKAGED_CLASS_NAME + '\' LIMIT 1');

	/** Default config options */
	private static Config Settings
	{
		get {
			// Use cached value, if any, unless in test context
			return ( Settings!=null && !Test.isRunningTest() ) ? 
				Settings
				: new Config();				
		}
	}

	/** Set of SObjects that should temporarily have their trigger logic bypassed */
	public static set<Schema.sObjectType> BypassObjects = new set<Schema.sObjectType>();

	/** Namespace Prefix */
	public static String NamespacePrefix
	{
		get
		{
			return Settings.AppNamespacePrefix;
		}
	}

	/** Namespace */
	public static String Namespace
	{
		get
		{
			return Settings.AppNamespace;
		}
	}

	/** Licensed User State */
	public static Boolean LicensedUser
	{
		get
		{
			return Settings.UserLicensed;
		}
	}

	/** Key Prefix by Object Map */
	public static Map<String,String> KeyPrefixByObject
	{
		get
		{
			return Settings.KeyPrefixByObjectName;
		}
	}

	/** Object by Key Prefix Map */
	public static Map<String,String> ObjectByKeyPrefix
	{
		get
		{
			return Settings.ObjectNameByKeyPrefix;
		}
	}

	/** Person Account Feature State */
	public static Boolean PersonAccounts
	{
		get
		{
			return Settings.PersonAccountState;
		}
	}

	/** MultiCurrency Feature State */
	public static Boolean MultiCurrency
	{
		get
		{
			return Settings.MultiCurrencyState;
		}
	}
	
	/** Email Recipients for DebugInfo */
	public static String DebugInfoEmails
	{
		get
		{
			return Settings.DebugInfoEmailRecipients;
		}
	}

	/** DebugInfo Log Emailing state */
	public static Boolean EmailDebugInfoEnabled
	{
		get
		{
			return Settings.EmailDebugInfo;
		}
	}
	
	/** Diagnostics state */
	public static Boolean DiagnosticsEnabled
	{
		get
		{
			return Settings.Diagnostics;
		}
	}
	
	/** Kill Switch state */
	public static Boolean KillSwitchEnabled
	{
		get
		{
			return Settings.KillSwitch;
		}
	}
	
	/** Maximum age in days of DebugInfo records */
	public static Integer DebugInfoMaxAge
	{
		get
		{
			return Settings.DebugInfoAgeMax;
		}
	} 
	
	/** Maximum number of DebugInfo records */
	public static Integer DebugInfoMaxNum
	{
		get
		{
			return Settings.DebugInfoNumMax;
		}
	}

	/**
	* @author Scott Covert
	* @date 12/17/2015
	* @description Resets test setting values to their defaults
	*/
	@TestVisible private static void resetTestSettings()
	{
		testLicensedUser = true;
		testPersonAccounts = false;
		testMultiCurrency = false;
		testDebugInfoEmails = null;
		testEmailDebugInfoLog = false;
		testKillSwitch = false;
		testDebugInfoMaxAge = null;
		testDebugInfoMaxNum = null;
	}
	
	/**
	* @author Scott Covert
	* @date 12/17/2015
	* @description Private inner class representing an org's default configuration
	*/
	private class Config {
		/** Sample Person Account Field */
		private final String SAMPLE_PERSON_ACCOUNT_FIELD = 'personcontactid';
		/** Default Config Settings */
		private Config__mdt defaultSettings = Test.isRunningTest() ? null : [SELECT DebugInfoRecipientEmails__c, EmailDebugInfoLog__c, EnableDiagnostics__c, KillSwitch__c, MaxDebugInfoAge__c, MaxDebugInfoRecords__c FROM Config__mdt WHERE DeveloperName = 'Default'];
		/** Namespace Prefix */
		private String AppNamespacePrefix;
		/** Namespace */
		private String AppNamespace;	
		/** Licensed User State */
		private Boolean UserLicensed;
		/** Key Prefix by Object Map */
		private Map<String,String> KeyPrefixByObjectName;
		/** Object by Key Prefix Map */
		private Map<String,String> ObjectNameByKeyPrefix;
		/** Person Account Feature State */
		private Boolean PersonAccountState;
		/** MultiCurrency Feature State */
		private Boolean MultiCurrencyState;
		/** Email Recipients for DebugInfo */
		private String DebugInfoEmailRecipients;
		/** DebugInfo Log Emailing state */
		private Boolean EmailDebugInfo;
		/** Diagnostics state */
		private Boolean Diagnostics;
		/** Kill Switch state */
		private Boolean KillSwitch;
		/** Maximum age in days of DebugInfo records */
		private Integer DebugInfoAgeMax;
		/** Maximum number of DebugInfo records */
		private Integer DebugInfoNumMax;		

		/**
		* @author Scott Covert
		* @date 12/17/2015
		* @description Constructor method for Config inner class
		*/
		private Config() {
			this.PersonAccountState = Test.isRunningTest() ? testPersonAccounts : Schema.SObjectType.Account.Fields.getMap().keySet().contains(SAMPLE_PERSON_ACCOUNT_FIELD);
			this.MultiCurrencyState = Test.isRunningTest() ? testMultiCurrency : UserInfo.isMultiCurrencyOrganization();
			this.DebugInfoEmailRecipients = Test.isRunningTest() ? testDebugInfoEmails : defaultSettings.DebugInfoRecipientEmails__c;
			this.EmailDebugInfo = Test.isRunningTest() ? testEmailDebugInfoLog : defaultSettings.EmailDebugInfoLog__c;
			this.Diagnostics = Test.isRunningTest() ? true : defaultSettings.EnableDiagnostics__c;
			this.KillSwitch = Test.isRunningTest() ? testKillSwitch : defaultSettings.KillSwitch__c;
			this.DebugInfoAgeMax = Test.isRunningTest() ? testDebugInfoMaxAge : (Integer)defaultSettings.MaxDebugInfoAge__c;
			this.DebugInfoNumMax = Test.isRunningTest() ? testDebugInfoMaxNum : (Integer)defaultSettings.MaxDebugInfoRecords__c;
			// Determine namespace
			this.AppNamespacePrefix = '';
			for (ApexClass ac : PACKAGED_CLASS){
	            if (ac.Body == OBFUSCATED_BODY_TEXT || ac.Body.contains(AUTHOR_NAME)){
	                if (ac.NameSpacePrefix!=null){
	                    // Namespace exists
	                    this.AppNamespacePrefix = ac.NameSpacePrefix.toLowerCase();	                    
	                }
	            }
	        }
	        this.AppNamespace = ( !String.isBlank(this.AppNamespacePrefix) ) ? this.AppNamespacePrefix + '__' : '';
	        // Determine if current user is licensed for namespace, if any
	        this.UserLicensed = Test.isRunningTest() ? testLicensedUser : ( !String.isBlank(this.AppNamespacePrefix) ) ? UserInfo.isCurrentUserLicensed(this.AppNamespacePrefix) : true;
	        // Determine key prefix by object mapping
			this.KeyPrefixByObjectName = new Map<String,String>();
			this.ObjectNameByKeyPrefix = new Map<String,String>();
			Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
		    for(String sObj : gd.keySet()){
		        Schema.DescribeSObjectResult sObjResult =  gd.get(sObj).getDescribe(); 
		        this.KeyPrefixByObjectName.put(sObjResult.getKeyPrefix(),sObjResult.getName().toLowerCase());
		        this.ObjectNameByKeyPrefix.put(sObjResult.getName().toLowerCase(),sObjResult.getKeyPrefix());		        
		    }		    
		}
	}
	
}