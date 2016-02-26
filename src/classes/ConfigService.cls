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
	/** Organization Id value for testing */
	@TestVisible private static String testOrgId;
	/** Organization Name value for testing */
	@TestVisible private static String testOrgName;
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
			if (KeyPrefixByObject!=null) return KeyPrefixByObject;
			BuildSchemaMaps();
			return KeyPrefixByObject;
		}
	}

	/** Object by Key Prefix Map */
	public static Map<String,String> ObjectByKeyPrefix
	{
		get
		{
			if (ObjectByKeyPrefix!=null) return ObjectByKeyPrefix;
			BuildSchemaMaps();
			return ObjectByKeyPrefix;			
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

	/** Package Version Number */
	public static String PackageVersion
	{
		get{
			return Settings.PackageVersionNumber!=null ? String.valueOf(Settings.PackageVersionNumber) : '';
		}
	}

	/** Organization Id */
	public static String OrgId
	{
		get{
			return Settings.OrganizationId;
		}
	}

	/** Organization Name */
	public static String OrgName
	{
		get{
			return Settings.OrganizationName;
		}
	}

	/**
	* @author Scott Covert
	* @date 12/21/2015
	* @description Builds Schema Map Static Variables
	*/
	private static void BuildSchemaMaps() {
		ConfigService.KeyPrefixByObject = new Map<String,String>();
		ConfigService.ObjectByKeyPrefix = new Map<String,String>();
		// Determine key prefix by object (and vice versa) mappings
		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
	    for(String sObj : gd.keySet()){
	        Schema.DescribeSObjectResult sObjResult =  gd.get(sObj).getDescribe(); 
	        // Some objects (such as history objects) may return null key prefix
	        if (sObjResult.getKeyPrefix()!=null){
	        	ConfigService.KeyPrefixByObject.put(sObjResult.getKeyPrefix(),sObjResult.getName().toLowerCase());
	        	ConfigService.ObjectByKeyPrefix.put(sObjResult.getName().toLowerCase(),sObjResult.getKeyPrefix());		        
	        }
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
		testOrgId = null;
		testOrgName = null;
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
		/** Package Version */
		private Version PackageVersionNumber;
		/** Organization Id */
		private String OrganizationId;
		/** Organization Name */
		private String OrganizationName;

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
			this.OrganizationId = Test.isRunningTest() ? testOrgId : UserInfo.getOrganizationId();
			this.OrganizationName = Test.isRunningTest() ? testOrgName : UserInfo.getOrganizationName();
			// Determine namespace
			this.AppNamespacePrefix = '';
			for (ApexClass ac : PACKAGED_CLASS){
	            if (ac.Body == OBFUSCATED_BODY_TEXT || ac.Body.contains(AUTHOR_NAME)){
	                if (ac.NameSpacePrefix!=null){
	                    // Namespace exists
	                    this.AppNamespacePrefix = ac.NameSpacePrefix.toLowerCase();	                    
	                    // Attempt to determine package version (http://bit.ly/1oFbMAl)
	                    Boolean isManaged;
	                    try{
					        UserInfo.isCurrentUserLicensed(this.AppNamespacePrefix);
					        isManaged = true;
					    }
					    catch(System.TypeException e)
					    {
					        // Not in a managed namespace
					        isManaged = false;
					    }
	                    if (isManaged){
	                    	this.PackageVersionNumber = System.requestVersion();
	                    }	                   
	                }
	            }
	        }
	        this.AppNamespace = ( !String.isBlank(this.AppNamespacePrefix) ) ? this.AppNamespacePrefix + '__' : '';
	        // Determine if current user is licensed for namespace, if any
	        this.UserLicensed = Test.isRunningTest() ? testLicensedUser : ( !String.isBlank(this.AppNamespacePrefix) ) ? UserInfo.isCurrentUserLicensed(this.AppNamespacePrefix) : true;	        		    
		}
	}
	
}