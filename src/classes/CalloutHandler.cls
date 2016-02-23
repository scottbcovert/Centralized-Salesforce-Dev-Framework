/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the Handler for making Callouts from Apex
*/
public class CalloutHandler {
	/** Constant to represent the default callout time limit */
    private static final Integer DEFAULT_CALLOUT_TIME = 10000;
    /** Constant representing the conent type for JSON */
    private static final String JSON_CONTENT_TYPE = 'application/json';
    /** Constant representing the OK status for callout requests */
    private static final String OK_STATUS = 'OK';
    /** Constant representing the KO status for callout requests */
    private static final String KO_STATUS = 'KO';
    /** Constant representing the failed status for callout requests */
    private static final String FAILED_STATUS = 'Failed';
    /** Constant representing the queued status for callout requests */
    public static final String QUEUED_STATUS = 'Queued';
    /** Constant to represent the maximum callout time limit */
    public static final Integer MAX_CALLOUT_TIME = 120000;
    /** Constant representing the attachment name used to store callout requests */
    public static final String REQUEST_NAME = 'request';
    /** Constant representing the attachment name used to store callout responses */
    public static final String RESPONSE_NAME = 'response';
    /** Constant representing the GET HTTP Method */
    public static final String GET_METHOD = 'GET';
    /** Constant representing the POST HTTP Method */
    public static final String POST_METHOD = 'POST';
    /** Constant representing the PUT HTTP Method */
    public static final String PUT_METHOD = 'PUT';
    /** Constant representing the PATCH HTTP Method */
    public static final String PATCH_METHOD = 'PATCH';
    /** Constant representing the DELETE HTTP Method */
    public static final String DELETE_METHOD = 'DELETE';
    /** Constant represengint the production endpoint for callouts to use */
    public static final String ENDPOINT = 'http://httpbin.org/delay/10';

	/**
	* @author Scott Covert
	* @date 2/21/2016
	* @description Executes Apex Callout
	* @param CalloutRequest__c Callout request to be made
	*/
    @future(callout=true)
	public static void Start(Id crId)
    {    	
		// Verify kill switch is not enabled
        if (ConfigService.KillSwitchEnabled) return;
        // Query for Callout Request
        CalloutRequest__c cr = [SELECT Id, JobId__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c FROM CalloutRequest__c WHERE Id = :crId LIMIT 1];
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
                cr.Timeout__c = DEFAULT_CALLOUT_TIME / 1000;			
    		}
    		else if ((cr.Timeout__c*1000) > MAX_CALLOUT_TIME)
    		{
    			request.setTimeout(MAX_CALLOUT_TIME);
                cr.Timeout__c = MAX_CALLOUT_TIME / 1000;	
    		}
    		else request.setTimeout(Integer.valueOf(cr.Timeout__c*1000));
    		list<Attachment> requestBody = [SELECT Id, CreatedDate, ParentId, Name, ContentType, Body FROM Attachment WHERE Name = :REQUEST_NAME AND ParentId = :cr.Id ORDER BY CreatedDate DESC LIMIT 1];
    		if (requestBody.size() > 0) request.setBody(requestBody[0].Body.toString());    		
    		HttpResponse response = h.send(request);
    		if (response.getStatusCode() == 200){
    			cr.Status__c = 'OK';
    		}
    		else{
    			cr.Status__c = 'KO';
    		}
    		// Create response body attachment
            createResponseBody(response.getBody(),cr.Id);            
    	}
    	catch (System.Exception ex){
    		cr.Status__c = 'Failed';
    		createResponseBody('Exception occurred line ' + ex.getLineNumber() + '\n' + ex.getMessage() + '\nStack: ' + ex.getStackTraceString(), cr.Id);
    		DiagnosticsInstrumentation.DebugException(ex);
            DiagnosticsInstrumentation.PopAll();
    	}
    	cr.Sent__c = System.now();
    	cr.Duration__c = cr.Sent__c.getTime() - start;
    	update cr;
    }

    /**
    * @author Scott Covert
    * @date 2/21/2016
    * @description Creates Request Body Attachments for Callout Requests
    * @param String Serialized JSON string to be used as HTTP request payload
    * @param Id Corresponding CalloutRequest Id to attach request body to
    */
    public static void createRequestBody(String jsonPayload, Id crId)
    {
        Attachment requestBodyAttachment = new Attachment(ParentId=crId,Name=REQUEST_NAME,Body=Blob.valueOf(jsonPayload),ContentType=JSON_CONTENT_TYPE);
        insert requestBodyAttachment;
    }

    /**
    * @author Scott Covert - Tython Co.
    * @date 2/23/2016
    * @description Creates Response Body Attachments for Callout Requests
    * @param String HTTP response body
    * @param Id Corresponding CalloutRequest Id to attach request body to
    */
    private static void createResponseBody(String httpResponse, Id crId)
    {
        Attachment requestBodyAttachment = new Attachment(ParentId=crId,Name=RESPONSE_NAME,Body=Blob.valueOf(httpResponse),ContentType=JSON_CONTENT_TYPE);
        insert requestBodyAttachment;
    }

}