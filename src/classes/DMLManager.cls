/**
* @author Patron Holdings LLC
* @date 6/22/2016
* @description Performs CRUD/FLS Security Checks for DML Statements
* Copyright (c), 2014, Patron Holdings LLC
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
* - Neither the name of the Patron Holdings nor the names of its contributors
*      may be used to endorse or promote products derived from this software without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
public class DMLManager {
	// Items in the following set must be entered in lower case
	/* System fields to be ignored by module */
	private static Set<String> exceptionValues = new Set<String> {'id','isdeleted','createddate','systemmodstamp','lastmodifiedbyid','createdbyid','lastmodifieddate'};

	/** Cached mapping of restricted fields to respective SObjects and DML operations */
	private static Map<Operation,Map<SObjectType,List<String>>> cachedRestrictedFields = new Map<Operation,Map<SObjectType,List<String>>>();
	
	/** Possible DML Operations */
	public enum Operation {OP_INSERT,OP_UPDATE,OP_DELETE,OP_UPSERT}
	
	// CRUD/FLS-safe DML operations. These honor the CRUD and FLS permissions of the running user
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML insert for given SObject, respecting user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void insertAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_INSERT);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML update for given SObject, respecting user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void updateAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_UPDATE);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML upsert for given SObject, respecting user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void upsertAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_UPSERT);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML delete for given SObject, respecting user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void deleteAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_DELETE);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML insert for given SObject, respecting user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void insertAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_INSERT);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML update for given SObject, respecting user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void updateAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_UPDATE);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML upsert for given SObject, respecting user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void upsertAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_UPSERT);}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML delete for given SObject, respecting user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void deleteAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_DELETE);}
	
	// Pass-thru methods to raw DML operations. 
	// Use these sparingly, and only with good reason, since the DML operations are not CRUD/FLS safe
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML insert for given SObject, ignoring user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void insertAsSystem(sObject obj){ insert obj; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML update for given SObject, ignoring user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void updateAsSystem(sObject obj){ update obj; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML upsert for given SObject, ignoring user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void upsertAsSystem(sObject obj){ upsert obj; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML delete for given SObject, ignoring user CRUD/FLS permissions
    * @param SObject SObject for DML operation
    */
	public static void deleteAsSystem(sObject obj){ delete obj; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML insert for given SObject, ignoring user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void insertAsSystem(List<SObject> objList){ insert objList; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML update for given SObject, ignoring user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void updateAsSystem(List<SObject> objList){ update objList; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML upsert for given SObject, ignoring user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void upsertAsSystem(List<SObject> objList){ upsert objList; }
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes DML delete for given SObject, ignoring user CRUD/FLS permissions
    * @param List List of SObjects for DML operation
    */
	public static void deleteAsSystem(List<SObject> objList){ delete objList; }
	
	// Custom Exception Classes
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Custom exception class to represent errors thrown by DMLManager class
    */
	public virtual class DMLManagerException extends Exception{		
		/** SObject Type for thrown DML exception */
		public SObjectType objType {get; private set;}
		/** DML operation for thrown DML exception */
		public Operation op{get; private set;}
	}

	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Custom exception class specific to CRUD-based errors thrown by DMLManager class    
    */
	public class CRUDException extends DMLManagerException{
		
		/**
	    * @author Patron Holdings LLC
	    * @date 6/22/2016
	    * @description Constructor method for CRUDException class
	    * @param SObjectType SObject Type for thrown CRUD exception
	    * @param Operation DML operation for thrown CRUD exception
	    */
		public CRUDException(SObjectType objType, Operation op){
			this('Access Denied: ' + op + ' on ' + objType);
			this.objType = objType;
			this.op = op;
		}
	}
 
 	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Custom exception class specific to FLS-based errors thrown by DMLManager class    
    */
	public class FLSException extends DMLManagerException{
		/** SObjectField that caused FLS-based exception to be thrown*/
		public SObjectField field{get; private set;}	

		/**
	    * @author Patron Holdings LLC
	    * @date 6/22/2016
	    * @description Constructor method for FLSException class
	    * @param SObjectType SObject Type for thrown FLS exception
	    * @param SObjectField SObject field for thrown FLS exception
	    * @param Operation DML operation for thrown FLS exception
	    */
		public FLSException(SObjectType objType, SObjectField field, Operation op){
			this('Access Denied: ' + op + ' on ' + objType + '.' + field);
			this.objType = objType;
			this.op = op;
			this.field = field;
		}
	}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Attempts to perform DML operation on given SObject list after checking CRUD & FLS permissions
    * @param List List of SObjects for DML operation
    * @param Operation DML operation to be executed
    */	
	private static void performDMLOperation(List<SObject> objList, Operation dmlOperation){
		Map<SObjectType,List<Id>> objTypeMap = analyzeDMLCollection(objList, dmlOperation);

		checkCRUDPermission(objTypeMap.keySet(),dmlOperation);

		if(dmlOperation == Operation.OP_INSERT){
			for(SObject obj : objList){
				checkCreateAction(obj);
			}
		} else if (dmlOperation == Operation.OP_UPDATE || dmlOperation == Operation.OP_UPSERT){
			
			Map<Id,SObject> existingRecords = getExistingRecords(objTypeMap);

			for(SObject obj : objList){
				SObject existingRecord = existingRecords.get(obj.Id);
				if(obj.id != null){
					checkUpdateAction(obj,existingRecord);
				} else {
					checkCreateAction(obj);
				}
			}
		}
		// If no errors have been thrown to this point, execute the dml operation.
		if(dmlOperation == Operation.OP_INSERT){insert objList;} 
			else if (dmlOperation == Operation.OP_UPDATE){update objList;} 
				else if (dmlOperation == Operation.OP_UPSERT){upsertCollection(objList);}
					else if (dmlOperation == Operation.OP_DELETE){delete objList;}
	}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Executes upsert properly for either a single SObject or a list or SObjects
    * @param List List of SObjects for upsert
    */
	private static void upsertCollection(List<SObject> objList){
		// This is to deal with a call to upsertAsUser with a singular object.
		// Since we wrap that into a List<SObject> (which can't be passed into an upsert)
		// we unpack it and upsert the object individually.
		if(objList.size() == 1){
			upsert objList.get(0);
		} else {
			upsert objList;
		}
	} 
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Determines populated fields for given SObject, returning results as a map
    * @param SObject SObject for DML operation
    * @return Map Populated field map for given SObject
    */
	private static Map<String,Object> getFieldMapFromExistingSObject(SObject obj){
		// Get actual fields present in object.  This serialization technique removes implicit nulls.
		String s = JSON.serialize(obj);
		Map<String,Object> fieldsMap = (Map<String,Object>) JSON.deserializeUntyped(s);
		fieldsMap.remove('attributes');
		return fieldsMap;	
	}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Throws FLSException if given SObject to be inserted contains restricted fields for running user 
    * @param SObject SObject for DML operation    
    */
	private static void checkCreateAction(SObject obj){
		List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_INSERT).get(obj.getSObjectType());
		//Save ourselves a trip through the loop below if there are no restricted fields
		if(restrictedFields == null || restrictedFields.isEmpty()){
			return;
		}

		Map<String,Object> fieldsMap = getFieldMapFromExistingSObject(obj);
		
		// If any restricted fields are present, throw an exception
		for(String fieldName : restrictedFields){
			if(fieldsMap.get(fieldName) != null){ // if any of the restricted fields are present in the candidate, throw an exception
				throw new FLSException(obj.getSObjectType(),obj.getSObjectType().getDescribe().fields.getMap().get(fieldName),Operation.OP_INSERT);
			}
		}  
	}

	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Throws FLSException if given SObject to be updated contains changes to restricted fields for running user 
    * @param SObject SObject for DML operation, containing any and all field changes
    * @param SObject SObject for DML operation, containing any and all prior field values
    */
	private static void checkUpdateAction(SObject obj, SObject existingRecord){
		List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE).get(obj.getSObjectType());
		//Save ourselves a trip through the loop below if there are no restricted fields
		if(restrictedFields == null || restrictedFields.isEmpty()){
			return;
		}
		
		if(existingRecord == null){
		    throw new DMLManagerException('DMLManager ERROR:  An existing record could not be found for object with Id = ' + obj.Id);
		}

		Map<String,Object> fieldsMap = getFieldMapFromExistingSObject(obj);
		
		// If any of the restricted values are present and have changed in the dml candidate object, throw an exception
		for(String fieldName : restrictedFields){
			if(fieldsMap.get(fieldName) != null && fieldsMap.get(fieldName) != existingRecord.get(fieldName) ){
				throw new FLSException(obj.getSObjectType(),obj.getSObjectType().getDescribe().fields.getMap().get(fieldName),Operation.OP_UPDATE);
			}
		}	 
	}


	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Retrieves mapping of record ids to their SObject instances as they exist currently in the database
    * @param Map Mapping of SObject type to a list of corresponding record ids that need their existing records pulled
    * @return Map Mapping of record ids to their SObject instances as they exist currently in the database
    */
	private static Map<Id,SObject> getExistingRecords(Map<SObjectType,List<Id>> objTypeMap){
		// For update and upsert operations, retrieve a Map of all existing records, for each object that has an ID.
		// objects without an Id are skipped, because there is no existing record in the database.
		
		Map<ID, SObject> result = new Map<Id,SObject>();

		Map<SObjectType,List<String>> operationRestrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE);
		
		for(SObjectType objType : objTypeMap.keySet()){
			List<String> restrictedFields = operationRestrictedFields.get(objType);
			
			if(restrictedFields == null || restrictedFields.isEmpty()){
				continue;
			}

			List<Id> seenIds = objTypeMap.get(objType);
			if(seenIds.isEmpty()){
				continue;
			}

			String fieldList = String.join(restrictedFields,',');
			result.putAll((Database.query('SELECT ' + fieldList + ' FROM ' + objType.getDescribe().getName() + ' WHERE Id IN :seenIds')));
		}
		
		return result;
	}
		
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Checks CRUD permissions for the running user based on the given DML operation and specified SObject types
    * @param Set Set of SObject types that need CRUD permissions checked for the running user
    * @param Operation DML Operation to be executed
    */
	private static void checkCRUDPermission(Set<SObjectType> objTypeList, Operation dmlOperation){
		for(SObjectType objType : objTypeList){
			DescribeSObjectResult describeObject = objType.getDescribe();
			if((dmlOperation == Operation.OP_INSERT && !describeObject.isCreateable()) ||
				(dmlOperation == Operation.OP_UPDATE && !describeObject.isUpdateable()) ||
				(dmlOperation == Operation.OP_DELETE && !describeObject.isDeletable()) ||
				(dmlOperation == Operation.OP_UPSERT && !(describeObject.isCreateable() && describeObject.isUpdateable()))) {
				throw new CRUDException(objType,dmlOperation);
			}
		}
	}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Gets a Map of all the object types in the DML request and the list of fields for each that the running user cannot create/update based on FLS settings
    * @param List List of SObjects for given DML operation
    * @param Operation DML Operation to be executed
    * @return Map Mapping of SObjectTypes to list of record ids that have been run through for populating the cached restricted field map
    */	
	private static Map<SObjectType,List<Id>> analyzeDMLCollection(List<SObject> objList, Operation dmlOperation){
		Map<SObjectType,List<Id>> result = new Map<SObjectType,List<Id>>();
		
		for(SObject obj : objList){
			ensureRestrictedFieldsEntry(obj, dmlOperation);
		
			List<Id> seenIds = result.get(obj.getSObjectType());
			if(seenIds == null){
				seenIds = new List<Id>();
				result.put(obj.getSObjectType(),seenIds);
			}
			
			if(obj.Id == null){
				continue;
			}	
			
			seenIds.add(obj.Id);
			
		}
		return result;
	}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Entry point for ensuring the cached restricted field map is populated for the given DML operation and the SObject type of the given SObject
    * @param SObject SObject to be used in populating the restricted field map
    * @param Operation DML Operation to be executed    
    */	
	private static void ensureRestrictedFieldsEntry(SObject obj, Operation dmlOperation){
		if(dmlOperation == Operation.OP_UPSERT){
			ensureRestrictedFields(obj,Operation.OP_INSERT);
			ensureRestrictedFields(obj,Operation.OP_UPDATE);
		}
		else{
			ensureRestrictedFields(obj,dmlOperation);
		}
	}
	
	/**
    * @author Patron Holdings LLC
    * @date 6/22/2016
    * @description Checks Schema for FLS settings to ensures the cached restricted field map is populated for the given DML operation and the SObject type of the given SObject
    * @param SObject SObject to be used in populating the restricted field map
    * @param Operation DML Operation to be executed    
    */	
	private static void ensureRestrictedFields(SObject obj, Operation dmlOperation){
		Map<SObjectType,List<String>> operationRestrictedFields = cachedRestrictedFields.get(dmlOperation);
		if(operationRestrictedFields == null){
			operationRestrictedFields = new Map<SObjectType,List<String>>();
			cachedRestrictedFields.put(dmlOperation,operationRestrictedFields);
		}
		
		if(!operationRestrictedFields.containsKey(obj.getSObjectType())){

			DescribeSObjectResult describeObject = obj.getSObjectType().getDescribe();

			Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();

			List<String> restrictedFields = new List<String>();

			for(String nm : objectFields.keyset()){
				if(!exceptionValues.contains(nm.toLowerCase())){
					DescribeFieldResult fr = objectFields.get(nm).getDescribe();
					if((!fr.isCalculated()) && ((dmlOperation == Operation.OP_INSERT && !fr.isCreateable()) ||
					   (dmlOperation == Operation.OP_UPDATE && !fr.isUpdateable())) 
					){
						restrictedFields.add(fr.getName());
					}  // there is not an isDeletable method at the field level
				}
			}
			operationRestrictedFields.put(obj.getSObjectType(),restrictedFields);
		}
	}	

}