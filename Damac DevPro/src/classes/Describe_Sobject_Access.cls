/*
Description : This class will define the access of SObject
Created By : Sivasankar K
		On : 07-05-2017
Test Class : Describe_Sobject_Access_Test
Change History : 
*/
public virtual class Describe_Sobject_Access {
	
	public Boolean canEditRecord {get;set;} // specifies that user has the edit access or not
	public Boolean canDeleteRecord {get;set;}// specifies that user has the delete access or not
	protected String sObjectName {get;set;}// specifies that user operation on sObject
	protected String recordID {get;set;}// specifies that user operation on sObject
	
	public Describe_Sobject_Access(String sObjectName,String recordID){
		this.sObjectName = sObjectName;
		this.recordID = recordID;
	}
	
	public Describe_Sobject_Access (){}
	
	/*
	getAccess(): Method will help to identify that current login user has the Edit and Delete access or not on current accessing sObject.
	*/
	public virtual void getAccess(){
		String recordTypeName = '';
		List<Schema.RecordTypeInfo> RT;
		sObject thisObject;
		
		//Login User Profile name
		Profile[] profileRecord = [SELECT Name from Profile WHERE ID =: userinfo.getProfileId() LIMIT 1];
		//Prepare the key with profile name and current operation on sObject
		String keyString = (profileRecord[0].Name+'#'+sObjectName).toLowerCase();
		//get all custom setting entries to identify that user has edit or delete access
		Map<String,Eidt_Delete_Restrictions_on_sObjects__c> allAccessRecords =  Eidt_Delete_Restrictions_on_sObjects__c.getAll();
		system.debug('#### allAccessRecords = '+allAccessRecords);
		//Default user has the edit and delete access
    	canEditRecord = (profileRecord != null && profileRecord[0].Name.containsIgnoreCase('System Administrator')) ?  true : false;
    	canDeleteRecord = (profileRecord != null && profileRecord[0].Name.containsIgnoreCase('System Administrator')) ?  true : false;
    	system.debug('#### keyString = '+keyString);
    	
    	//check the profile and sObject entry is available in custom setting, if present then get the specified access 
    	//else login user will have the edit and delete access.
    	if(allAccessRecords != null && !allAccessRecords.isEmpty() && allAccessRecords.containsKey(keyString) ){
    		//if Record Type filed is not blank
    		if(String.isNotBlank(allAccessRecords.get(keyString).Record_Types__c)){
	    		//get the Schema.DescribeSobjectResult
	    		Schema.DescribeSObjectResult objectResult;
	    		for(Schema.DescribeSobjectResult res : Schema.describeSObjects(new List<String>{allAccessRecords.get(keyString).sObject_Name__c})) {
	    			objectResult = res;
	    			break;
	    		}
	    		//get the record types information of Sobject
	    		RT = objectResult.getRecordTypeInfos();
	    		//get the record type of current record.
	    		if(RT != null && !RT.isEmpty() && RT.size() > 1){
	    			for(Sobject obj : Database.query('Select Id,RecordType.Name From '+allAccessRecords.get(keyString).sObject_Name__c+' WHERE ID =: recordID')){
	    				thisObject = obj;	
	    				break;
	    			}
	    			system.debug('#### thisObject = '+thisObject);
	    			if(thisObject != null){
	    				system.debug('#### thisObject = '+thisObject.getSobject('RecordType'));
	    				recordTypeName = (String) thisObject.getSobject('RecordType').get('Name');	
	    			}
	    		}
    		}
			canEditRecord = (String.isNotBlank(recordTypeName) ? ( (String.isNotBlank(allAccessRecords.get(keyString).Record_Types__c) && allAccessRecords.get(keyString).Record_Types__c.containsIgnoreCase(recordTypeName)) ?  allAccessRecords.get(keyString).Edit_Access__c : false) : allAccessRecords.get(keyString).Edit_Access__c); //allAccessRecords.get(keyString).Edit_Access__c
    		canDeleteRecord = (String.isNotBlank(recordTypeName) ? ( (String.isNotBlank(allAccessRecords.get(keyString).Record_Types__c) && allAccessRecords.get(keyString).Record_Types__c.containsIgnoreCase(recordTypeName)) ?  allAccessRecords.get(keyString).Delete_Access__c : false) : allAccessRecords.get(keyString).Delete_Access__c); //allAccessRecords.get(keyString).Delete_Access__c;
		}
		system.debug('== > thisObject = '+thisObject);
		system.debug('== > recordTypeName = '+recordTypeName);
    	system.debug('== > canEditRecord = '+canEditRecord);
		system.debug('== > canDeleteRecord = '+canDeleteRecord);
	}
}