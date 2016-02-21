/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the Handler for making Callouts from Apex
*/
public class CalloutHandler {
	/** Constant to represent the default callout time limit */
	private static final Integer DEFAULT_CALLOUT_TIME = 10000;
	/** Constant to represent the maximum callout time limit */
	private static final Integer MAX_CALLOUT_TIME = 120000;
	/** Constant representing the attachment name used to store callout requests */
	public static final String REQUEST_NAME = 'request';

	/**
	* @author Scott Covert
	* @date 2/21/2016
	* @description Executes Apex Callout
	* @param CalloutRequest__c Callout request to be made
	*/
	public static void Start(CalloutRequest__c cr)
    {    	
		// Perform HTTP Callout    	
    	Long start = System.now().getTime();
    	try {
    		Http h = new Http();
    		HttpRequest request = new HttpRequest();
    		request.setMethod(cr.Method__c);
    		request.setEndpoint(cr.Endpoint__c);
    		if (cr.Timeout__c==null || cr.Timeout__c <= 0 )
    		{
    			request.setTimeout(DEFAULT_CALLOUT_TIME);    			
    		}
    		else if ((cr.Timeout__c*1000) > MAX_CALLOUT_TIME)
    		{
    			request.setTimeout(MAX_CALLOUT_TIME);	
    		}
    		else
    		{
    			request.setTimeout(Integer.valueOf(cr.Timeout__c*1000));
    		}
    		list<Attachment> requestBody = [SELECT Id, CreatedDate, ParentId, Name, ContentType, Body FROM Attachment WHERE Name = :REQUEST_NAME AND ParentId = :cr.Id ORDER BY CreatedDate DESC LIMIT 1];
    		if (requestBody.size() > 0)
    		{
    			request.setBody(requestBody[0].Body.toString());
    		}
    		HttpResponse response = h.send(request);
    		if (response.getStatusCode() == 200){
    			cr.Status__c = 'OK';
    		}
    		else{
    			cr.Status__c = 'KO';
    		}
    		cr.Response__c = response.getBody();    		
    	}
    	catch (System.Exception ex){
    		cr.Status__c = 'Failed';
    		cr.Response__c = 'Exception occurred line ' + ex.getLineNumber() + '\n' + ex.getMessage() + '\nStack: ' + ex.getStackTraceString();
    		DiagnosticsInstrumentation.DebugException(ex);
            DiagnosticsInstrumentation.PopAll();
    	}
    	cr.Sent__c = System.now();
    	cr.Duration__c = cr.Sent__c.getTime() - start;
    	update cr;
    }

}