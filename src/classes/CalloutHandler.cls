/**
* @author Scott Covert
* @date 2/21/2016
* @description Defines the Handler for making Callouts from Apex
*/
public class CalloutHandler {
    /** Constant to represent the default callout time limit */
    @TestVisible private static final Integer DEFAULT_CALLOUT_TIME = 10000;
    /** Constant representing the content type for JSON */
    private static final String JSON_CONTENT_TYPE = 'application/json';
    /** Constant representing the content type for plain text */
    private static final String PLAIN_TEXT_CONTENT_TYPE = 'text/plain';
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
    /** Constant representing the attachment name used to store the body of callout requests */
    public static final String REQUEST_BODY_NAME = 'request body';
    /** Constant representing the attachment name used to store the headers of callout requests */
    public static final String REQUEST_HEADERS_NAME = 'request headers';
    /** Constant representing the attachment name used to store the client certificate name of callout requests */
    public static final String REQUEST_CERT_NAME = 'request cert';
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
    
    /**
    * @author Scott Covert
    * @date 2/21/2016
    * @description Executes Apex Callout Asynchronously
    * @param Id Id of the callout request to be made
    */
    @future(callout=true)
    public static void sendAsyncCallout(Id crId)
    {       
        // Verify kill switch is not enabled
        if (ConfigService.KillSwitchEnabled) return;
        // Query for Callout Request
        CalloutRequest__c cr = [SELECT Id, AsyncRequest__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c FROM CalloutRequest__c WHERE Id = :crId LIMIT 1];
        // Send Callout
        sendCallout(cr);
    }

    /**
    * @author Scott Covert
    * @date 2/23/2016
    * @description Executes Apex Callout Synchronously
    * @param CalloutRequest__c Callout request to be made
    */
    public static void sendCallout(CalloutRequest__c cr)
    {
        // Perform HTTP Callout
        Long start = System.now().getTime();
        try {
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod(cr.Method__c);
            request.setEndpoint(cr.Endpoint__c);
            request.setTimeout(calculateTimeout(cr));            
            list<Attachment> requestAttachments = [SELECT Id, CreatedDate, ParentId, Name, ContentType, Body FROM Attachment WHERE ParentId = :cr.Id];
            for (Attachment a : requestAttachments)
            {
                if (a.Name == REQUEST_BODY_NAME)
                {
                    request.setBody(a.Body.toString());
                }
                else if (a.Name == REQUEST_HEADERS_NAME)
                {
                    String requestHeaders = a.Body.toString();
                    for (String headerKeyValuePair : requestHeaders.split(';'))
                    {
                        request.setHeader(headerKeyValuePair.split(':')[0], headerKeyValuePair.split(':')[0]);
                    }                    
                }
                else if (a.Name == REQUEST_CERT_NAME)
                {
                    request.setClientCertificateName(a.Body.toString());
                }
            }
            HttpResponse response = h.send(request);            
            processCalloutResponse(response, cr);         
        }
        catch (Exception ex){
            processFailure(cr, ex);                     
        }
        updateCalloutRequest(cr, start);        
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
        Attachment requestBodyAttachment = new Attachment(ParentId=crId,Name=REQUEST_BODY_NAME,Body=Blob.valueOf(jsonPayload),ContentType=JSON_CONTENT_TYPE);
        DMLManager.insertAsSystem(requestBodyAttachment);
    }

    /**
    * @author Scott Covert
    * @date 1/17/2017
    * @description Creates Request Client Cert Name Attachments for Callout Requests
    * @param String Client certificate name to be used
    * @param Id Corresponding CalloutRequest Id to attach client cert name to
    */
    public static void createRequestClientCert(String certName, Id crId)
    {
        Attachment requestCertAttachment = new Attachment(ParentId=crId,Name=REQUEST_CERT_NAME,Body=Blob.valueOf(certName),ContentType=PLAIN_TEXT_CONTENT_TYPE);
        DMLManager.insertAsSystem(requestCertAttachment);
    }

    /**
    * @author Scott Covert
    * @date 1/17/2017
    * @description Creates Request Headers Attachment for Callout Requests
    * @param Map Mapping of header keys by their corresponding values
    * @param Id Corresponding CalloutRequest Id to attach request headers to
    */
    public static void createRequestHeaders(Map<String,String> headerKeyByValue, Id crId)
    {
        String attachmentBody = '';
        for (String headerKey : headerKeyByValue.keySet())
        {
            attachmentBody += headerKey + ':' + headerKeyByValue.get(headerKey) + ';';
        }
        attachmentBody = attachmentBody.removeEnd(';');
        Attachment requestHeadersAttachment = new Attachment(ParentId=crId,Name=REQUEST_HEADERS_NAME,Body=Blob.valueOf(attachmentBody),ContentType=PLAIN_TEXT_CONTENT_TYPE);
        DMLManager.insertAsSystem(requestHeadersAttachment);
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Processes timeout to be used for HTTP callout and updates callout request record as needed
    * @param CalloutRequest__c The callout request to be sent
    * @return Integer Timeout (in milliseconds) to be used for HTTP callout
    */
    private static Integer calculateTimeout(CalloutRequest__c cr)
    {
        if (cr.Timeout__c==null || cr.Timeout__c <= 0)
        {
            cr.Timeout__c = DEFAULT_CALLOUT_TIME / 1000;
            return DEFAULT_CALLOUT_TIME;
        }
        else if ((cr.Timeout__c*1000) > MAX_CALLOUT_TIME)
        {
            cr.Timeout__c = MAX_CALLOUT_TIME / 1000;
            return MAX_CALLOUT_TIME;
        }
        else return Integer.valueOf(cr.Timeout__c*1000);
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Processes HTTP callout responses and updates callout request fields accordingly
    * @param HttpResponse Response of an HTTP callout
    * @param CalloutRequest__c Callout request that was made
    */
    private static void processCalloutResponse(HttpResponse response, CalloutRequest__c cr)
    {
        if (response.getStatusCode() == 200){
            cr.Status__c = OK_STATUS;
        }
        else{
            cr.Status__c = KO_STATUS;
        }
        // Create response body attachment
        createResponseBody(response.getBody(),cr.Id);
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Processes failure encountered in attempting to perform HTTP callout
    * @param CalloutRequest__c Callout request that should have been made
    * @param Exception System Exception encountered while attempting to perform HTTP callout
    */
    private static void processFailure(CalloutRequest__c cr, Exception ex)
    {
        cr.Status__c = FAILED_STATUS;
        DiagnosticsInstrumentation.DebugException(ex);
        if (DiagnosticsInstrumentation.CurrentLog()!=null) createResponseBody('Diagnostic Log\n' + DiagnosticsInstrumentation.CurrentLog(), cr.Id);
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Calculates callout duration and updates callout request
    * @param CalloutRequest__c Callout request that was made/attempted
    * @param Long Start time of callout request
    */
    private static void updateCalloutRequest(CalloutRequest__c cr, Long start)
    {
        cr.Sent__c = System.now();
        Decimal timeDiff = cr.Sent__c.getTime() - start;
        cr.Duration__c = timeDiff.Divide(1000,3);
        DMLManager.updateAsSystem(cr);
        // Since header attachments may contain authorization information it is probably best to delete them
        list<Attachment> requestHeaderAttachments = [SELECT Id FROM Attachment WHERE Name = :REQUEST_HEADERS_NAME AND ParentId = :cr.Id];
        if (!requestHeaderAttachments.isEmpty()) 
        {
            DMLManager.deleteAsSystem(requestHeaderAttachments);
            Database.emptyRecycleBin(requestHeaderAttachments);
        }
    }

    /**
    * @author Scott Covert
    * @date 2/23/2016
    * @description Creates Response Body Attachments for Callout Requests
    * @param String HTTP response body
    * @param Id Corresponding CalloutRequest Id to attach request body to
    */
    private static void createResponseBody(String httpResponse, Id crId)
    {
        Attachment requestBodyAttachment = new Attachment(ParentId=crId,Name=RESPONSE_NAME,Body=Blob.valueOf(httpResponse),ContentType=JSON_CONTENT_TYPE);
        DMLManager.insertAsSystem(requestBodyAttachment);
    }

}