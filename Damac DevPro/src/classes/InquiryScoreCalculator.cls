/**************************************************************************************************
* Name               : InquiryScoreCalculator                                                     *
* Description        : Batch class to handle calculate inquiry score for each PC.                 *
*                       - Update the inquiry count.                                               *
*                       - Update the events count.                                                *
* Created Date       : 21/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/05/2017      Initial Draft.                                    *
**************************************************************************************************/
public class InquiryScoreCalculator implements Database.Batchable<sObject>{ 
	 
	public static String PROFILE_NAME = 'Property Consultant';
	public static String COMPLETED = 'Completed';
	public static String INQUIRY_ACTIVE_STATUS = DAMAC_Constants.INQUIRY_ACTIVE_STATUS;
	public static String INQUIRY_NEW_STATUS = DAMAC_Constants.INQUIRY_NEW_STATUS;
	private static final Id INQUIRY_RECORD_TYPE_ID = DamacUtility.getRecordTypeId('Inquiry__c', 'Inquiry');
	
    /********************************************************************************************* 
    * @Description : Implementing the start method of batch interface, contains query.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : Database.QueryLocator                                                       *
    *********************************************************************************************/  
    public Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Id, OwnerId, Inquiry_Status__c, Owner.Name, '+
								'(SELECT Id, OwnerId, Status__c FROM Events '+
								  'WHERE ActivityDate = LAST_N_DAYS:90) '+
					   'FROM Inquiry__c '+
					   'WHERE Owner.Profile.Name =: PROFILE_NAME AND '+
							 'RecordTypeId =: INQUIRY_RECORD_TYPE_ID AND '+
							 '(Inquiry_Status_Indexed__c =: INQUIRY_ACTIVE_STATUS OR '+
							  'Inquiry_Status_Indexed__c =: INQUIRY_NEW_STATUS) AND '+
							 'Duplicate__c = false AND IsDeleted = false AND ('; 
		for(String thisSource : DAMAC_Constants.inquirySourceToInclude){
			query = query + 'Inquiry_Source_Indexed__c = \''+thisSource+'\' OR ';
		}
		query = query.removeEnd('OR '); 
		query = query + ')'; 
		system.debug('#### query = '+query);
		return Database.getQueryLocator(query);
    }
   
    /*********************************************************************************************
    * @Description : Implementing the execute method of batch interface, contains the criteria.  *
    * @Params      : Database.BatchableContext, List<sObject>                                    *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void execute(Database.BatchableContext BC, List<SObject> inquiryList){
    	system.debug('#### inquiryList = '+inquiryList);
    	Map<Id, Integer> pcWithNewLeadCount = new Map<Id, Integer>();
    	Map<Id, Integer> pcWithCompletedMeetingCount = new Map<Id, Integer>();
        Map<Id, Integer> pcWithNewMeetingCount = new Map<Id, Integer>();
    	Map<Id, List<Inquiry__c>> userAssociatedInquiryListMap = new Map<Id, List<Inquiry__c>>();
        if(inquiryList != null){
            for(Inquiry__c thisInquiry : (List<Inquiry__c>)inquiryList){
            	if(userAssociatedInquiryListMap.containsKey(thisInquiry.OwnerId)){
	                userAssociatedInquiryListMap.get(thisInquiry.OwnerId).add(thisInquiry);    
	            }else{
	                userAssociatedInquiryListMap.put(thisInquiry.OwnerId, new List<Inquiry__c>{thisInquiry});       
	            }   
     		}
        }
        if(!userAssociatedInquiryListMap.isEmpty()){
        	for(Id thisKey : userAssociatedInquiryListMap.keySet()){
				for(Inquiry__c thisInquiry : userAssociatedInquiryListMap.get(thisKey)){
					/* Creating map of all new leads count. */ 
					if(String.isNotBlank(thisInquiry.Inquiry_Status__c) && 
	                   thisInquiry.Inquiry_Status__c.equalsIgnoreCase(DAMAC_Constants.INQUIRY_NEW_STATUS)){ 
	                    if(pcWithNewLeadCount.containsKey(thisInquiry.OwnerId)){
	                        pcWithNewLeadCount.put(thisInquiry.OwnerId, pcWithNewLeadCount.get(thisInquiry.OwnerId)+1);     
	                    }else{
	                        pcWithNewLeadCount.put(thisInquiry.OwnerId, 1); 
	                    }  
	                }
					for(Event thisEvent : thisInquiry.Events){
	                    /* Creating map of completed meeting count. */
	                    if(String.isNotBlank(thisEvent.Status__c) && 
	                       thisEvent.Status__c.equalsIgnoreCase(DAMAC_Constants.EVENT_COMPLETED_STATUS)){
	                        if(pcWithCompletedMeetingCount.containsKey(thisInquiry.OwnerId)){
	                            pcWithCompletedMeetingCount.put(thisInquiry.OwnerId, pcWithCompletedMeetingCount.get(thisInquiry.OwnerId) + 1);     
	                        }else{
	                            pcWithCompletedMeetingCount.put(thisInquiry.OwnerId, 1);    
	                        }       
	                    }   
	                    /* Creating map of planned meeting count. */
	                    if(String.isNotBlank(thisEvent.Status__c) && 
	                       thisEvent.Status__c.equalsIgnoreCase(DAMAC_Constants.EVENT_PLANNED_STATUS)){
	                        if(pcWithNewMeetingCount.containsKey(thisInquiry.OwnerId)){
	                            pcWithNewMeetingCount.put(thisInquiry.OwnerId, pcWithNewMeetingCount.get(thisInquiry.OwnerId) + 1);     
	                        }else{
	                            pcWithNewMeetingCount.put(thisInquiry.OwnerId, 1);  
	                        }       
	                    }   
	                }
				}
        	}
        	Map<Id, Integer> existingPcWithAllLeadCount = new Map<Id, Integer>();
        	Map<Id, Integer> existingPcWithNewLeadCount = new Map<Id, Integer>();
	    	Map<Id, Integer> existingPcWithCompletedMeetingCount = new Map<Id, Integer>();
	        Map<Id, Integer> existingPcWithNewMeetingCount = new Map<Id, Integer>();
        	for(PCInquiryCounter__c thisScore : [SELECT Id, Name, Owner_Name__c, All_Inquiry_Count__c, New_Inquiry_Count__c, 
        												New_Meeting_Count__c, Completed_Meeting_Count__c 
        										 FROM PCInquiryCounter__c]){
        		existingPcWithAllLeadCount.put(thisScore.Name, Integer.valueOf(thisScore.All_Inquiry_Count__c));
        		existingPcWithNewLeadCount.put(thisScore.Name, Integer.valueOf(thisScore.New_Inquiry_Count__c));
        		existingPcWithCompletedMeetingCount.put(thisScore.Name, Integer.valueOf(thisScore.Completed_Meeting_Count__c));	
        		existingPcWithNewMeetingCount.put(thisScore.Name, Integer.valueOf(thisScore.New_Meeting_Count__c));	
        	}
        	Map<Id, PCInquiryCounter__c> pcInquiryCountMap = new Map<Id, PCInquiryCounter__c>();
        	/* Setting the values in custom setting. */
        	for(User thisUser : [SELECT Id, Name FROM User WHERE Profile.Name =: PROFILE_NAME AND isActive= true]){
        		PCInquiryCounter__c newPCInquiryCounter = new PCInquiryCounter__c(); 
        		newPCInquiryCounter.Name = thisUser.Id;
				newPCInquiryCounter.Owner_Name__c = thisUser.Name; 
				/* If the all lead data already exists in the table, add to it else insert the new value. */
				if(existingPcWithAllLeadCount.containsKey(thisUser.Id)){
					newPCInquiryCounter.All_Inquiry_Count__c = userAssociatedInquiryListMap.containsKey(thisUser.Id) ? 
						userAssociatedInquiryListMap.get(thisUser.Id).size() + existingPcWithAllLeadCount.get(thisUser.Id) : 0;	
				}else{
					newPCInquiryCounter.All_Inquiry_Count__c = userAssociatedInquiryListMap.containsKey(thisUser.Id) ? userAssociatedInquiryListMap.get(thisUser.Id).size() : 0;	
				}
				/* If the new lead data already exists in the table, add to it else insert the new value. */
				if(existingPcWithNewLeadCount.containsKey(thisUser.Id)){
					newPCInquiryCounter.New_Inquiry_Count__c = pcWithNewLeadCount.containsKey(thisUser.Id) ? 
						pcWithNewLeadCount.get(thisUser.Id) + existingPcWithNewLeadCount.get(thisUser.Id) : 0;	
				}else{
					newPCInquiryCounter.New_Inquiry_Count__c = pcWithNewLeadCount.containsKey(thisUser.Id) ? pcWithNewLeadCount.get(thisUser.Id) : 0;	
				}
				/* If the completed meeting data already exists in the table, add to it else insert the new value. */
				if(existingPcWithCompletedMeetingCount.containsKey(thisUser.Id)){
					newPCInquiryCounter.Completed_Meeting_Count__c = pcWithCompletedMeetingCount.containsKey(thisUser.Id) ? 
						pcWithCompletedMeetingCount.get(thisUser.Id) + existingPcWithCompletedMeetingCount.get(thisUser.Id) : 0;	
				}else{
					newPCInquiryCounter.Completed_Meeting_Count__c = pcWithCompletedMeetingCount.containsKey(thisUser.Id) ? pcWithCompletedMeetingCount.get(thisUser.Id) : 0;	
				}
				/* If the new meeting data already exists in the table, add to it else insert the new value. */
				if(existingPcWithNewMeetingCount.containsKey(thisUser.Id)){
					newPCInquiryCounter.New_Meeting_Count__c = pcWithNewMeetingCount.containsKey(thisUser.Id) ? 
						pcWithNewMeetingCount.get(thisUser.Id) + existingPcWithNewMeetingCount.get(thisUser.Id) : 0;	
				}else{
					newPCInquiryCounter.New_Meeting_Count__c = pcWithNewMeetingCount.containsKey(thisUser.Id) ? pcWithNewMeetingCount.get(thisUser.Id) : 0;	
				}
				pcInquiryCountMap.put(thisUser.Id, newPCInquiryCounter);
        	}
        	if(!pcInquiryCountMap.isEmpty()){
        		/* Calling method to clear the score table and enter the new values. */
        		initializeScoreTable(pcInquiryCountMap.keySet());
    			upsert pcInquiryCountMap.values() Name;
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
	   mail.setSubject('Inquiry Score Calculator Batch : ' + a.Status);
	   mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
	   						 ' batches with '+ a.NumberOfErrors + ' failures.');
	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	/*********************************************************************************************
    * @Description : Method to clear scoring table.                                              *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	private void initializeScoreTable(Set<Id> pcIdsSet){
		List<PCInquiryCounter__c> deletePcScoreList = [SELECT Id FROM PCInquiryCounter__c WHERE Name IN: pcIdsSet];	
		delete deletePcScoreList;
	}
}// End of class.