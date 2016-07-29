/**
* @author Scott Covert
* @date 3/3/2016
* @description This class provides mock HTTP callout responses for unit tests
*/
@isTest (seealldata=false)
public with sharing class HttpCalloutMockService implements HttpCalloutMock {

	/** Content Type Header Key */
	private static final String CONTENT_TYPE_HEADER_KEY = 'Content-Type';
	/** Content Type to use for default response */
	private static final String DEFAULT_CONTENT_TYPE = 'application/json';
	/** Body to use for default response */
	private static final String DEFAULT_BODY = '{"data":""}';
	/** Desired Status Code for HTTP Callout Mock Response */
	@TestVisible private static Integer DESIRED_STATUS_CODE = 200;
	/** Default empty HTTP Response to use as a fallback if no matching mock responses are found */
	@TestVisible private static HttpResponse DEFAULT_RESPONSE
	{
		get
		{
			if (DEFAULT_RESPONSE!=null) return DEFAULT_RESPONSE;
			HttpResponse defaultResponse = new HttpResponse();
			defaultResponse.setStatusCode(DESIRED_STATUS_CODE);
			defaultResponse.setHeader(CONTENT_TYPE_HEADER_KEY, DEFAULT_CONTENT_TYPE);
			defaultResponse.setBody(DEFAULT_BODY);
			return defaultResponse;
		}
		set { DEFAULT_RESPONSE = value; }
	}

	/** 
    * @author Scott Covert
    * @date 3/3/2016
    * @description This method creates a mock callout response by querying custom metadata types based on HTTP request info
    * @param HTTPRequest The HTTP callout request to provide a mock response to
    * @return HTTPResponse The HTTP callout mock response
    */
    public HTTPResponse respond(HTTPRequest req) {
		// Query for matching HTTP Callout Mock Response based on HTTP request info
		list<HTTPCalloutMockResponse__mdt> mockResponse = [SELECT Id, DeveloperName, MasterLabel, Endpoint__c, Method__c, StatusCode__c, ContentType__c, Body__c FROM HTTPCalloutMockResponse__mdt WHERE Endpoint__c = :req.getEndpoint() AND Method__c = :req.getMethod() AND StatusCode__c = :DESIRED_STATUS_CODE LIMIT 1];
		if (mockResponse.isEmpty()) return DEFAULT_RESPONSE;		
		HTTPResponse res = new HTTPResponse();
		res.setStatusCode(Integer.valueOf(mockResponse[0].StatusCode__c));
		if (mockResponse[0].ContentType__c!=null) res.setHeader(CONTENT_TYPE_HEADER_KEY,mockResponse[0].ContentType__c);
		if (mockResponse[0].Body__c!=null) res.setBody(mockResponse[0].Body__c);
		return res;
	}
}