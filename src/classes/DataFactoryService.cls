/**
* @author Scott Covert
* @date 12/20/2015
* @description This class provides data factory services for @testSetup methods to utilize
*/
public class DataFactoryService {
    
    /** 
    * @author Scott Covert
    * @date 12/20/2015
    * @param String The API name of the SObject type to be instantiated
    * @param List A list of fields (must be of data type text) whose value should be set upon instantiation
    * @param String The base string value to assign to the specified required string fields
    * @param Integer The number of SObject records to instantiate
    * @return List A list of instantiated SObject records
    * @description This method generates records for test methods
    */
    @TestVisible private static list<SObject> CreateRecords(String objectName, list<String> requiredStringFields, String baseName, Integer numRecords)
    {
    	DiagnosticsInstrumentation.Push('DataFactoryService.CreateRecords');
        // Generate list of SObject records based on SObjectType defaults and predetermined number of records
        list<SObject> records = new list<SObject>();
        for (Integer i=0; i<numRecords; i++)
        {
            SObject newRecord = Schema.getGlobalDescribe().get(objectName)!=null ? Schema.getGlobalDescribe().get(objectName).newSObject(null,true) : null;
            // Populate required string field values
            for (String s : requiredStringFields){
                newRecord.put(s,baseName + String.valueOf(i+1));
            }
            records.add(newRecord);
        }
        
        // Check for any org-specific field requirements by dynamically querying custom metadata
        if (ConfigService.ObjectByKeyPrefix.containsKey('fieldrequirement__mdt'))
        {
            for ( SObject fieldRequirement : Database.query('SELECT DeveloperName, SObject__c, Field__c, RequiredValue__c FROM FieldRequirement__mdt WHERE SObject__c = \'' + objectName.toLowerCase() + '\'') )
            {
                for (SObject record : records)
                {
                    record.put( String.valueOf( fieldRequirement.get('Field__c') ) , String.valueOf( fieldRequirement.get('RequiredValue__c') ) );
                }
            }
        }
        DiagnosticsInstrumentation.Pop();
        return records;
    }

    /**
    * @author Scott Covert
    * @date 12/20/15
    * @description Relates two lists of SObjects through a specified lookup field
    * @param List A list of child SObject records
    * @param List A list of parent SObject records
    * @param String The API name of a lookup field that relates the child and parent SObjects
    */
    @TestVisible private static void CreateRelationships(list<sObject> children, list<sObject> parents, String relField){
        DiagnosticsInstrumentation.Push('DataFactoryService.CreateRelationships');
        // Determine list size of parent records
        Integer numParents = parents.size();
        // Create ParentId Mapping
        Integer counter=0;
        map<Integer,String> parentIdMap = new map<Integer,String>();
        for (sObject s : parents){
            parentIdMap.put(counter,String.valueOf(s.get('Id')));
            counter++;
        }
        // Associate children records to parent records using map & related field API Name
        counter=0;
        for (sObject s : children){
            if (counter>=numParents){
                // Exit loop if number of children has exceeded number of parents
                break;
            }
            else{
                s.put(relField,parentIdMap.get(counter));
                counter++;
            }
        }
        DiagnosticsInstrumentation.Pop();
    }

}