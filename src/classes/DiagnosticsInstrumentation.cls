/**
* @author Scott Covert
* @date 11/9/2014
* @description This class implements diagnostics for the application
*/
public class DiagnosticsInstrumentation {
	/** Stores list of diagnostic entries */
	private static List<DiagnosticEntry> DiagnosticLog;
	/** Stores current stack level for push/pop functionality */
	private static Integer CurrentLevel = 0;
	/** Stores custom strack trace string */
	private static List<String> StackTrace = new List<String>();
	/** Stores exception trace for custom stack trace */
	@TestVisible private static String ExceptionTrace = '';

	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Inner class that represents a diagnostic entry
	*/
	private class DiagnosticEntry
	{
		/** Stores current stack level */
		Integer level;
		/** Stores description information for diagnostic entry */
		String description;
		
		/**
		* @author Scott Covert
		* @date 11/9/2014
		* @description Constructor method
		* @param String Description information for diagnostic entry
		*/
		private DiagnosticEntry(String entrydescription)
		{
			level = CurrentLevel;
			description = '[' + System.now().format('HH:mm:ss.SSS') + '] {' + UserInfo.getName() + '} ' + entrydescription;
		}
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Should be called at the start of every function to increment and update the current execution context level.
	* @param String Function name
	*/
	public static void Push(String functionName)
	{
		Debug('Entering: ' + functionName);
		CurrentLevel+=1;
		StackTrace.add(functionName);
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Adds new diagnostic entry to the diagnostic log (if diagnostics are enabled)
	* @param String Debug string value
	*/
	public static void Debug(String debugString)
	{
		if(!ConfigService.DiagnosticsEnabled) return;
		if(DiagnosticLog==null) DiagnosticLog = new List<DiagnosticEntry>();
		DiagnosticLog.add(new DiagnosticEntry(debugString));
		System.Debug(LoggingLevel.Info, debugString);
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called prior to PopAll to add exception info to diagnostic log and object
	* @param Exception Thrown exception
	*/
	public static void DebugException(Exception ex)
	{
		String exceptioninfo = 'Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage() + ' stack: ' + ex.getStackTraceString();
		Debug(exceptioninfo);
		DebugInfo__c dbg = new DebugInfo__c(DebugData__c = CurrentLog());
		ExceptionTrace = ' Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage();
		for(String st: StackTrace) ExceptionTrace += ' | ' + st;
		ExceptionTrace += ' |\n ';
		if(ConfigService.DiagnosticsEnabled){
			try {
				DMLManager.insertAsSystem(dbg);
			}
			catch(Exception e){
				// Unable to insert debug info
			}
			if (ConfigService.DebugInfoMaxNum!=null || ConfigService.DebugInfoMaxAge!=null)
				CheckDebugInfoLog();
		}
		PopAll();
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Should be called on the exit of every function to decrement and update the current execution context level.
	*/
	public static void Pop()
	{
		if(CurrentLevel>0) CurrentLevel-=1;
		if(CurrentLevel==0 && DiagnosticLog!=null) System.Debug(LoggingLevel.Info, 'Diagnostic Log\n' + CurrentLog());
		if(StackTrace.size()>0) StackTrace.remove(StackTrace.size()-1);
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Used for exception handling
	*/
	public static void PopAll()
	{
		CurrentLevel=0;
		Pop();
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Returns multi-line string representation of diagnostic log
	* @return String Indented log of diagnostic entries
	*/
	public static String CurrentLog()
	{
		if(DiagnosticLog == null) return null;
		String spaces = '                                                                        ';
		String result = '';
		for(DiagnosticEntry de: DiagnosticLog)
		{
			Integer endindex = 3 * de.level;
			if(endindex >= spaces.length()) endindex = spaces.length()-1;
			result += spaces.substring(0,endindex) + de.description + '\n';
		}
		return result;
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Checks if DebugInfo log needs clearing
	*/
	private static void CheckDebugInfoLog()
	{
		list<DebugInfo__c> debugInfoLog = [SELECT Id, Name, CreatedDate, DebugData__c FROM DebugInfo__c ORDER BY CreatedDate ASC];
		if (!debugInfoLog.isEmpty() && ConfigService.DebugInfoMaxNum!=null && debugInfoLog.size()>=ConfigService.DebugInfoMaxNum){
			ClearDebugInfoLog(debugInfoLog);
		}
		else if (!debugInfoLog.isEmpty() && ConfigService.DebugInfoMaxAge!=null && (debugInfoLog[0].CreatedDate <= System.now().addDays(-1 * ConfigService.DebugInfoMaxAge)) || Test.isRunningTest()){
			list<DebugInfo__c> debugInfoToDelete = new list<DebugInfo__c>();
			DateTime maxAge = System.now().addDays(-1 * ConfigService.DebugInfoMaxAge);
			for (DebugInfo__c di : debugInfoLog){
				if (di.CreatedDate <= maxAge)
					debugInfoToDelete.add(di);
			}
			ClearDebugInfoLog(debugInfoToDelete);
		}
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Deletes DebugInfo log records
	* @param List A list of debug info records to be deleted
	*/
	private static void ClearDebugInfoLog(list<DebugInfo__c> expiredDebugInfoLog)
	{
		if (ConfigService.EmailDebugInfoEnabled && ConfigService.DebugInfoEmails!=null && ConfigService.DebugInfoEmails!=''){
			EmailDebugInfoLog(expiredDebugInfoLog);
		}
		if (expiredDebugInfoLog.size()>0){
			try {
				DMLManager.deleteAsSystem(expiredDebugInfoLog);
				Database.emptyRecycleBin(expiredDebugInfoLog);
			}
			catch(Exception ex){
				// Unable to delete debug info log
			}
		}
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Emails DebugInfo log
	* @param List A list of debug info records to be emailed
	*/
	private static void EmailDebugInfoLog(list<DebugInfo__c> debugInfoLog)
	{
		//Define email settings
        Messaging.SingleEmailMessage debugInfoEmail = new Messaging.SingleEmailMessage();                   
        debugInfoEmail.setToAddresses(ConfigService.DebugInfoEmails.split(';'));
        debugInfoEmail.setSubject('DebugInfo Log for ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')');
        String emailMessage = 'Attached is the DebugInfo log that was cleared for ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')';
        debugInfoEmail.setPlainTextBody(emailMessage);
        debugInfoEmail.setHtmlBody(emailMessage);
        //Generate attachment
        String csvString = new DebugInfoLogAttachment().generate(debugInfoLog);
        transient Blob csvAttachment = Blob.valueOf(csvString);
        transient Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setBody(csvAttachment);
        efa.setContentType('text/csv');
        efa.setFileName(System.today().format()+'_'+UserInfo.getOrganizationName()+'_DebugInfoLog.csv');
        efa.setInline(false);
        debugInfoEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        //Send email
        if (!Test.isRunningTest())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {debugInfoEmail});
	}

	/**
	* @author Scott Covert
	* @date 11/9/2014
	* @description Inner class that represents a custom debug log attachment
	*/
	private class DebugInfoLogAttachment {
		
		/**
		* @author Scott Covert
		* @date 11/9/2014
		* @description Converts a list of debug info records into a string
		* @param List A list of debug info records
		* @return String A string representation of the debug info log
		*/
		private String generate(list<DebugInfo__c> diLog) {
	        String s = line(new String[] {
	                format('DebugInfo Entry'),
	                format('Created Date'),
	                format('Debug Data')
	                });
	        for (DebugInfo__c di : diLog) {
	            s += line(new String[] {
	                    format(di.Name),
	                    format(di.CreatedDate),
	                    format(di.DebugData__c)
	                    });
	        }
	        return s;
	    }

	    /**
		* @author Scott Covert
		* @date 11/9/2014
		* @description Converts list of strings to single, comma-delimited string with a line break
		* @param List A list of strings
		* @return String A comma-delimited string with a line break
		*/
	    private String line(String[] cells) {
	        return String.join(cells, ',') + '\n';
	    }

	    /**
		* @author Scott Covert
		* @date 11/9/2014
		* @description Converts datetime to CSV-formatted string
		* @param DateTime Datetime value
		* @return String CSV-formatted representation of datetime value
		*/
	    private String format(DateTime dt)    {
	        return dt != null ? '"' + dt.format().escapeCsv() + '"' : '""';
	    }

	    /**
		* @author Scott Covert
		* @date 11/9/2014
		* @description Converts text value to CSV-formatted string
		* @param String Text value
		* @return String CSV-formatted representation of text value
		*/
	    private String format(String s) {
	        return s != null ? '"' + s.escapeCsv() + '"' : '""';
	    }
	}
	
}