/**
* @author Scott Covert
* @date 11/9/2014
* @description This class implements diagnostics for the application
*/
public class DiagnosticsInstrumentation {
	
	public static Boolean DiagnosticsEnabled = AppConfigSupport.DiagnosticsEnabled;
	
	private static List<DiagnosticEntry> DiagnosticLog;
	private static Integer CurrentLevel = 0;

	private static List<String> StackTrace = new List<String>();
	public static String ExceptionTrace = '';

	private class DiagnosticEntry
	{
		Integer level;
		String description;
		
		public DiagnosticEntry(String entrydescription)
		{
			level = CurrentLevel;
			description = '[' + System.now().format('HH:mm:ss.SSS') + '] ' + entrydescription;
		}
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Should be called at the start of every function to increment and update the current execution context level..
	*/
	public static void Push(String functionname)
	{
		Debug('Entering: ' + functionname);
		CurrentLevel+=1;
		StackTrace.add(functionname);
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Adds new diagnostic entry to the diagnostic log (if diagnostics are enabled)
	*/
	public static void Debug(String debugstring)
	{
		if(!DiagnosticsEnabled) return;
		if(DiagnosticLog==null) DiagnosticLog = new List<DiagnosticEntry>();
		DiagnosticLog.add(new DiagnosticEntry(debugstring));
		System.Debug(LoggingLevel.Info, debugstring);
	}
	
	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Called prior to PopAll to add exception info to diagnostic log and object
	*/
	public static void DebugException(Exception ex)
	{
		String exceptioninfo = 'Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage() + ' stack: ' + ex.getStackTraceString();
		Debug(exceptioninfo);
		DebugInfo__c dbg = new DebugInfo__c(DebugData__c = CurrentLog());
		ExceptionTrace = ' Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage();
		for(String st: StackTrace) ExceptionTrace += ' | ' + st;
		ExceptionTrace += ' |\n ';
		if(DiagnosticsEnabled) insert dbg;
	}

	/** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Should be called on the exit of every function to decrement and update the current execution context level.
	*/
	public static void Pop()
	{
		if(CurrentLevel>0) CurrentLevel-=1;
		if(CurrentLevel==0) System.Debug(LoggingLevel.Info, 'Diagnostic Log\n' + CurrentLog());
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
	

	
}