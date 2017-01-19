/**
* @author Scott Covert
* @date 3/3/2016
* @description This class provides mock HTTP callout responses for unit tests
*/
public with sharing class HttpCalloutMockService implements HttpCalloutMock {

	/** Content Type Header Key */
	public static final String CONTENT_TYPE_HEADER_KEY = 'Content-Type';
	/** Content Type to use for default response */
	public static final String DEFAULT_CONTENT_TYPE = 'application/json';
	/** Body to use for default response */
	private static final String DEFAULT_BODY = '{"data":""}';
	/** Default Status Code for HTTP Callout Mock Response */
	private static Integer DEFAULT_STATUS_CODE = 200;
	/** Mapping of unique endpoint identifiers by their corresponding inner class name for mocking */
    private static final Map<String,String> ENDPNT_ID_BY_IC = new Map<String,String>{AccountHelper.ACCOUNT_ENDPOINT=>'HttpCalloutMockService.AccountAPI'};
	/** Default empty HTTP Response to use as a fallback if no matching mock responses are found */
	private static HttpResponse defaultResponse
	{
		get
		{
			if (defaultResponse!=null) return defaultResponse;
			defaultResponse = new HttpResponse();
			defaultResponse.setStatusCode(DEFAULT_STATUS_CODE);
			defaultResponse.setHeader(CONTENT_TYPE_HEADER_KEY, DEFAULT_CONTENT_TYPE);
			defaultResponse.setBody(DEFAULT_BODY);
			return defaultResponse;
		}
	}
	/** HTTP Response to be configured by corresponding inner class */
    private static HttpResponse mockedResponse;

	/** 
    * @author Scott Covert
    * @date 3/3/2016
    * @description This method creates a mock callout response by querying custom metadata types based on HTTP request info
    * @param HttpRequest The HTTP callout request to provide a mock response to
    * @return HttpResponse The HTTP callout mock response
    */
    public HttpResponse respond(HttpRequest req) {
		// Obtain matching HTTP Callout Mock Response based on HTTP request info
        for (String endpntId : ENDPNT_ID_BY_IC.keySet())
        {
            if (req.getEndpoint().contains(endpntId)) {
                IMockResponse mockResponseImpl = (IMockResponse)(Type.forName(ENDPNT_ID_BY_IC.get(endpntId))).newInstance();
                mockedResponse = mockResponseImpl.createMockedResponse();                
            }
        }
        return (mockedResponse!=null) ? mockedResponse : defaultResponse;
	}

	/** Interface for MockResponse Implementations */
    private interface IMockResponse {
        /**
        * @author Scott Covert
        * @date 1/19/2017
        * @description This method creates a mock callout response
        * @return HttpResponse The HTTP callout mock response
        */
        HttpResponse createMockedResponse();
    }

    /**
    * @author Scott Covert
    * @date 1/19/2017
    * @description Inner Class for mocking the Account API Endpoint Response
    */
    public class AccountAPI implements HttpCalloutMockService.IMockResponse {
        public HttpResponse createMockedResponse() {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader(HttpCalloutMockService.CONTENT_TYPE_HEADER_KEY,HttpCalloutMockService.DEFAULT_CONTENT_TYPE);
            res.setBody(JSON.serialize('Hello World!'));
            return res;
        }
    }

}