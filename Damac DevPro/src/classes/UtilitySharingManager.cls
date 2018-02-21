/**************************************************************************************************
* Name               : UtilitySharingManager                                                      *
* Description        : This is a utility class for sharing records.                               *
* Created Date       : 18/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      		DATE                                                              *
* 1.0         NSI - Vineet      18/01/2017                                                        *
**************************************************************************************************/
public virtual class UtilitySharingManager implements Queueable {
	
	public static final String READ_PERMISSION = 'Read';
	private List<sObject> insertShareRecordsList;  	
	private List<sObject> deleteShareRecordsList;  	
	
	/*********************************************************************************************
    * @Description : Controller                                                                  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public UtilitySharingManager(){}
	public UtilitySharingManager(List<sObject> insertShareRecordsList, List<sObject> deleteShareRecordsList){
		this.insertShareRecordsList = new List<sObject>(insertShareRecordsList);
		this.deleteShareRecordsList = new List<sObject>(deleteShareRecordsList);
	}
	 
	/*********************************************************************************************
    * @Description : Implementing the execute method.                                            *
    * @Params      : QueueableContext                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void execute(QueueableContext context) {
		if(!insertShareRecordsList.isEmpty()){
	    	insertShareRecords();
		}
		if(!deleteShareRecordsList.isEmpty()){
			deleteShareRecords();	
		}
    }
	
	/*********************************************************************************************
    * @Description : Calling method to insert sharing records.                                   *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	private void insertShareRecords(){
		if(!insertShareRecordsList.isEmpty()){
	    	database.saveResult[] result = database.insert(insertShareRecordsList, false);
			// Iterate through each returned result : TOBE REMOVED
			for (Database.SaveResult sr : result) {
			    if (sr.isSuccess()) {
			        System.debug('#### Successfully inserted record. ' + sr.getId());
			    }else {
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('#### The following error has occurred.');                   
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('#### Fields that affected this error: ' + err.getFields());
			        }
			    }
			}
		}	
	}
	
	/*********************************************************************************************
    * @Description : Calling method to delete sharing records.                                   *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	private void deleteShareRecords(){
		 if(!deleteShareRecordsList.isEmpty()){
            database.deleteResult[] result = database.delete(deleteShareRecordsList, false);
            // Iterate through each returned result : TOBE REMOVED
			for (Database.deleteResult sr : result) {
			    if (sr.isSuccess()) {
			        System.debug('#### Successfully inserted record. ' + sr.getId());
			    }else {
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('#### The following error has occurred.');                   
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('#### Fields that affected this error: ' + err.getFields());
			        }
			    }
			}
        }	
	}
	
	/*********************************************************************************************
    * @Description : Method to create invoke code for granting access to user hierarchy.         *
    * @Params      : User, String, String                                                        *
    * @Return      : List<SObject>                                                               *
    *********************************************************************************************/
	public List<SObject> invokeAccess(User userAgentRecord, String objectName, String parentRecordId, String customRowCauseName){
		List<SObject> insertShareRecordsList = new List<SObject>();	
		if(userAgentRecord != null){
			/* Sharing for Property Consultants (PCs).
			   Setting records to the wrapper in the following order :
			   ObjectName, ParentId, UserOrGroupId, AccessLevel, RowCause */
	    	if(userAgentRecord.Id != null){ 
	        	String rowCauseName = String.isNotBlank(customRowCauseName) ? customRowCauseName : 'Property_Consultant_Access__c';
	        	sObject shareRecord = 
	        		createShareRecord( 
	        			new UtilityWrapperManager.SharingWrapper(objectName, parentRecordId, userAgentRecord.Id, READ_PERMISSION, rowCauseName));
	        	if(shareRecord != null){
	            	insertShareRecordsList.add(shareRecord);     
	        	}          
	    	}   
			/* Sharing for Sales Manager (SM). 
			   Setting records to the wrapper in the following order :
			   ObjectName, ParentId, UserOrGroupId, AccessLevel, RowCause */
	        if(userAgentRecord.ManagerId != null){ 
	        	String rowCauseName = String.isNotBlank(customRowCauseName) ? customRowCauseName : 'Sales_Manager_Access__c';
	        	sObject shareRecord = 
	        		createShareRecord(
	        			new UtilityWrapperManager.SharingWrapper(objectName, parentRecordId, userAgentRecord.ManagerId, READ_PERMISSION, rowCauseName));
	        	if(shareRecord != null){
	            	insertShareRecordsList.add(shareRecord);     
	        	}             
	        }
	        /* Sharing for Head of Sales (HOS/DOS). 
			   Setting records to the wrapper in the following order :
			   ObjectName, ParentId, UserOrGroupId, AccessLevel, RowCause */
	        if(userAgentRecord.Manager != null && userAgentRecord.Manager.ManagerId != null){
	        	String rowCauseName = String.isNotBlank(customRowCauseName) ? customRowCauseName : 'Head_Or_Director_Of_Sales_Access__c';
	        	sObject shareRecord = 
	        		createShareRecord(
	        			new UtilityWrapperManager.SharingWrapper(objectName, parentRecordId, userAgentRecord.Manager.ManagerId, READ_PERMISSION, rowCauseName));
	        	if(shareRecord != null){
	            	insertShareRecordsList.add(shareRecord);     
	        	} 
	        }
	        /* Sharing for Head of Delivery (HOD). 
			   Setting records to the wrapper in the following order :
			   ObjectName, ParentId, UserOrGroupId, AccessLevel, RowCause */
	        if(userAgentRecord.ManagerId != null && userAgentRecord.Manager.Manager != null && 
	           userAgentRecord.Manager.Manager.ManagerId != null){
	           	String rowCauseName = String.isNotBlank(customRowCauseName) ? customRowCauseName : 'Head_Of_Department_Access__c';
	           	sObject shareRecord = 
	           		createShareRecord(
	           			new UtilityWrapperManager.SharingWrapper(objectName, parentRecordId, userAgentRecord.Manager.Manager.ManagerId, READ_PERMISSION, rowCauseName));
	        	if(shareRecord != null){
	            	insertShareRecordsList.add(shareRecord);     
	        	} 
	        }
	        /* Sharing for Managing Director (MD). 
			   Setting records to the wrapper in the following order :
			   ObjectName, ParentId, UserOrGroupId, AccessLevel, RowCause */
	        if(userAgentRecord.ManagerId != null && userAgentRecord.Manager.Manager != null && 
	           userAgentRecord.Manager.Manager.Manager != null && 
	           userAgentRecord.Manager.Manager.Manager.ManagerId != null){
	           	String rowCauseName = String.isNotBlank(customRowCauseName) ? customRowCauseName : 'Managing_Director_Access__c';
	           	sObject shareRecord = 
	           		createShareRecord(
	           			new UtilityWrapperManager.SharingWrapper(objectName, parentRecordId, userAgentRecord.Manager.Manager.Manager.ManagerId, READ_PERMISSION, rowCauseName));
	        	if(shareRecord != null){
	            	insertShareRecordsList.add(shareRecord);     
	        	} 
	    	}	
		}
		return insertShareRecordsList;
	}
	
	/*********************************************************************************************
    * @Description : Method to create sharing records.                                           *
    * @Params      : UtilityWrapperManager.SharingWrapper                                        *
    * @Return      : sObject                                                                     *
    *********************************************************************************************/ 
    public sObject createShareRecord(UtilityWrapperManager.SharingWrapper uwm_swObject){
    	String sharingObjectName;
    	sObject shareRecord;
    	if(String.isNotBlank(uwm_swObject.objectName)){
	    	if(uwm_swObject.objectName.endsWithIgnoreCase('__c')){
	    		sharingObjectName = uwm_swObject.objectName.substringBefore('__c')+'__share';		
	    	}else{
	    		sharingObjectName = uwm_swObject.objectName+'share';	
	    	}
	        Schema.SObjectType typeOfShareObject = Schema.getGlobalDescribe().get(sharingObjectName);
	        shareRecord = typeOfShareObject.newSObject();
	        if(shareRecord != null){
		        if(String.isNotBlank(uwm_swObject.objectName) && 
		           uwm_swObject.objectName.equalsIgnoreCase('User')){
		     		shareRecord.put('UserId', uwm_swObject.parentId);  
		     		shareRecord.put('UserAccessLevel', uwm_swObject.AccessLevel); 
		        }else{
		        	shareRecord.put('ParentId', uwm_swObject.parentId); 
		        	shareRecord.put('AccessLevel', uwm_swObject.AccessLevel);  	
		        }
				shareRecord.put('UserOrGroupId', uwm_swObject.UserOrGroupId);	
				shareRecord.put('RowCause', uwm_swObject.RowCause);	
	        }
    	}
		return shareRecord;
    }
}// End of class.