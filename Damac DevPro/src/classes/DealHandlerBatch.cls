/**************************************************************************************************
* Name               : DealHandlerBatch                                                           *
* Description        : Batch class to handle Deal SR's, has the below functionality:              *
*                       - Release the booked units.                                               *
*                       - Reject any open approval request.                                       *
*                       - Reject the SR status with "Rejected Due To Timeout".                    *
*                       - Calling the webservice method to release the unit from IPMS.            *
* Created Date       : 30/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      30/04/2017      Initial Draft.                                    *
**************************************************************************************************/
public class DealHandlerBatch implements Database.Batchable<sObject>{  
    
    private static final Id DEAL_SR_RECORD_TYPE_ID = DamacUtility.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal');
    
    /********************************************************************************************* 
    * @Description : Implementing the start method of batch interface, contains query.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : Database.QueryLocator                                                       *
    *********************************************************************************************/  
    public Database.QueryLocator start(Database.BatchableContext BC){
		DateTime thisMoment = system.now();
		String query = 'SELECT Id, Name, Token_Deposit_Due_Date_Time__c '+
					   'FROM NSIBPM__Service_Request__c '+
					   'WHERE RecordTypeId =: DEAL_SR_RECORD_TYPE_ID AND '+
		                       'Deal_Expired_Date_Time__c = NULL AND '+
		                       'Token_Deposit_Paid_Date_Time__c = NULL AND '+
		                       'Token_Deposit_Due_Date_Time__c != NULL AND '+
		                       'Token_Deposit_Due_Date_Time__c <: thisMoment AND '+
		                       'CreatedDate >= 2017-05-18T00:00:00Z'; 
      return Database.getQueryLocator(query);
    }
   
    /*********************************************************************************************
    * @Description : Implementing the execute method of batch interface, contains the criteria.  *
    * @Params      : Database.BatchableContext, List<sObject>                                    *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void execute(Database.BatchableContext BC, List<SObject> dealSrList){
    	Set<Id> srIdsSet = new Set<Id>();
    	system.debug('#### dealSrList = '+dealSrList);
        if(dealSrList != null){
            for(NSIBPM__Service_Request__c thisDeal : (List<NSIBPM__Service_Request__c>)dealSrList){
            	srIdsSet.add(thisDeal.Id);
            }
            if(!srIdsSet.isEmpty()){
            	TriggerFactoryCls.setBYPASS_UPDATE_TRIGGER();
            	/* Calling method to release units in salesforce and IPMS. */
            	releaseUnit(srIdsSet);	
            	/* Calling method to reject any open approval process. */
	            rejectApprovalProcess(srIdsSet);   
	            /* Calling method to reject the SR records. */ 
	            rejectDeals(srIdsSet);
	            /* Calling method to close any open step related to an SR. */
	            closeOpenSteps(srIdsSet);
            }
        }
    }
    
    /*********************************************************************************************
    * @Description : Implementing Finish method, to end an email after job completion.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void finish(Database.BatchableContext BC){
	   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
	      				 FROM AsyncApexJob 
	      				 WHERE Id =: BC.getJobId()];
	   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	   String[] toAddresses = new String[] {'vineet.kumar@nsigulf.com'};
	   mail.setToAddresses(toAddresses);
	   mail.setSubject('Deal Handler Batch : ' + a.Status);
	   mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
	   						 ' batches with '+ a.NumberOfErrors + ' failures.');
	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
    
    /*********************************************************************************************
    * @Description : Method to release inventory in case of token payment failed.                * 
    * @Params      : Set<Id>                                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    private void releaseUnit(Set<Id> srIdsSet){
        Set<Id> inventoryIdsSet = new Set<Id>();
        List<Id> bookingIdsList = new List<Id>();
        List<Inventory__c> updateInventoryStatus = new List<Inventory__c>();
        for(Booking_Unit__c thisBookingUnit : [SELECT Id, Inventory__c, Booking__c
                                               FROM Booking_Unit__c 
                                               WHERE Booking__r.Deal_SR__c IN: srIdsSet]){
            if(thisBookingUnit.Inventory__c != null){
                inventoryIdsSet.add(thisBookingUnit.Inventory__c);
            }   
            bookingIdsList.add(thisBookingUnit.Booking__c);
        }
        
        if(!inventoryIdsSet.isEmpty()){
            for(Inventory__c thisInventory : [SELECT Id, Status__c 
                                              FROM Inventory__c 
                                              WHERE Id IN: inventoryIdsSet]){
                thisInventory.Status__c = 'Released';
                updateInventoryStatus.add(thisInventory);   
            }   
            if(!updateInventoryStatus.isEmpty()){
                /* updating inventory to release in salesforce. */
                DAMAC_Constants.skip_InventoryTrigger = true;
                update updateInventoryStatus;   
            }   
        }
        if(!bookingIdsList.isEmpty()){
        	/* Calling method to release inventory from IPMS. */
        	system.enqueueJob(new AsyncReceiptWebservice (bookingIdsList, 'Booking Cancellation'));	
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to reject the deal due to time out.                                  * 
    * @Params      : Set<Id>                                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    private void rejectDeals(Set<Id> srIdsSet){
    	NSIBPM__SR_Status__c SUBMITTED_SR_STATUS = new NSIBPM__SR_Status__c();
    	List<NSIBPM__Service_Request__c> updateSrList = new List<NSIBPM__Service_Request__c>();
        for(NSIBPM__SR_Status__c thisSrStatus : [SELECT Id, Name FROM NSIBPM__SR_Status__c WHERE NSIBPM__Code__c = 'REJECTED_DUE_TO_TIME_OUT']){
            SUBMITTED_SR_STATUS = thisSrStatus;
            break;  
        }
        if(SUBMITTED_SR_STATUS != null && SUBMITTED_SR_STATUS.Id != null){
            for(Id thisSr : srIdsSet){
                updateSrList.add(new NSIBPM__Service_Request__c(Id = thisSr, 
                												NSIBPM__Required_Docs_not_Uploaded__c = false,
                                                                NSIBPM__Internal_SR_Status__c = SUBMITTED_SR_STATUS.Id, 
                                                                NSIBPM__External_SR_Status__c = SUBMITTED_SR_STATUS.Id,
                                                                Deal_Expired_Date_Time__c = system.now()));   
            }   
        }
        if(!updateSrList.isEmpty()){
            update updateSrList;    
        }	
    }
    
    /*********************************************************************************************
    * @Description : Method to reject reject any open step related to the SR's.                  * 
    * @Params      : Set<Id>                                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    private void closeOpenSteps(Set<Id> srIdsSet){
    	NSIBPM__Status__c REJECTED_STEP_STATUS;
    	List<NSIBPM__Step__c> closeStep = new List<NSIBPM__Step__c>();
    	for(NSIBPM__Status__c thisStepStatus : [SELECT Id, Name FROM NSIBPM__Status__c WHERE NSIBPM__Code__c = 'REJECTED_DUE_TO_TIME_OUT']){
            REJECTED_STEP_STATUS = thisStepStatus;
            break;  
        }
        if(REJECTED_STEP_STATUS != null && REJECTED_STEP_STATUS.Id != null){
        	for(NSIBPM__Step__c thisStep : [SELECT Id FROM NSIBPM__Step__c WHERE NSIBPM__SR__c =: srIdsSet AND Is_Closed__c = false]){
	    		thisStep.NSIBPM__Status__c = REJECTED_STEP_STATUS.Id;
	    		closeStep.add(thisStep);	
	    	}
	    	if(!closeStep.isEmpty()){
	    		update closeStep;	
	    	}	
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to reject open deals.                                                * 
    * @Params      : Set<Id>                                                                     *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    private void rejectApprovalProcess(Set<Id> srIdsSet){
        List<Approval.ProcessWorkitemRequest> rejectRequestList = New List<Approval.ProcessWorkitemRequest>(); 
        Set<Id> processInstanceIdsSet = new Set<Id>();
        Set<Id> processInstanceWorkItemsIdsSet = new Set<Id>();
        for(ProcessInstance thisProcessInstance : [SELECT Id,Status,TargetObjectId FROM ProcessInstance WHERE Status='Pending' AND TargetObjectId IN: srIdsSet]){
            processInstanceIdsSet.add(thisProcessInstance.Id);  
        }
        if(!processInstanceIdsSet.isEmpty()){
            for(ProcessInstanceWorkItem thispiwi : [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ProcessInstanceId IN: processInstanceIdsSet]){
                processInstanceWorkItemsIdsSet.add(thispiwi.Id);    
            }   
            if(!processInstanceWorkItemsIdsSet.isEmpty()){
                for (Id thispiwiId : processInstanceWorkItemsIdsSet){
                    Approval.ProcessWorkitemRequest rejectRequest = new Approval.ProcessWorkitemRequest();
                    rejectRequest.setComments('Rejected due to time out.');
                    rejectRequest.setAction('Reject');
                    rejectRequest.setWorkitemId(thispiwiId);
                    rejectRequestList.add(rejectRequest);
                }
                if(!rejectRequestList.isEmpty()){
                    Approval.ProcessResult[] result =  Approval.process(rejectRequestList); 
                }   
            }
        }
    }
}// End of class.