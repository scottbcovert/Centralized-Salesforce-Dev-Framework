/**
* @author Scott Covert
* @date 12/20/2015
* @description This class provides verification services for test methods to ensure they should execute
*/
public class TestVerificationService {
    
    /** 
    * @author Scott Covert
    * @date 12/20/2015
    * @param String The full name (Class.Method) of the test method being verified for execution
    * @return Boolean Determines if given test method should execute
    * @description This method verifies if a given test method should execute
    */
    @TestVisible private static Boolean ShouldExecute(String methodName)
    {
    	DiagnosticsInstrumentation.Push('TestVerificationService.ShouldExecute');
    	
        // Check for any org-specific settings have marked the given method as disabled by dynamically querying custom metadata
        if ( ConfigService.ObjectByKeyPrefix.containsKey('disabledtest__mdt') )
        {
			for ( SObject disabledTest : Database.query('SELECT DeveloperName FROM DisabledTest__mdt WHERE TestMethod__c = \'' + methodName.toLowerCase() + '\'') )			
			{
				// Test method has been disabled
				DiagnosticsInstrumentation.Pop();
				return false;
			}
        }
        
        // Setup HTTP Mock Responses
        Test.setMock(HttpCalloutMock.class, new HTTPCalloutMockService());

        DiagnosticsInstrumentation.Pop();
        return true;
    }

}