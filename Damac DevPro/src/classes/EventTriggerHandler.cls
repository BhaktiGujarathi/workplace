/**************************************************************************************************
* Name               : EventTriggerHandler                                                        *
* Description        : This is a trigger handler class for Event. Has the below functions.        *
* Created Date       : 12/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      		DATE                                                              *
* 1.0         NSI - Vineet      12/01/2017                                                        *
**************************************************************************************************/
public class EventTriggerHandler implements TriggerFactoryInterface{
	
	private final String MEETING_TYPE_1 = 'Face to Face';
	private final String MEETING_TYPE_2 = 'Visit to Sales Office';
	private final String HOT_SCORE = 'Hot';
	private final String WARM_SCORE = 'Warm';
	
	/*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
    	try{
    		/*Calling method to update inquiry status when a activity is created. */
	    	updateInquiryStatus(newRecordsMap.values());	 
    	}catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }    
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after update.                        *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    	try{
    		/*Calling method to update inquiry status when a activity is created. */
	    	updateInquiryScore(newRecordsMap, oldRecordsMap);	
    	}catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }	
    }
    
    /*********************************************************************************************
    * @Description : Update inquiry score if event type is changed to 'Hot'; else 'Warm'         *
    *				 - Face to Face                                                              *
    *				 - Visit to Sales                                                            *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void updateInquiryScore(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    	List<Inquiry__c> updateInquiryList = new List<Inquiry__c>();
    	for(Id thisKey : newRecordsMap.keySet()){
    		Event eventNewValues = (Event)newRecordsMap.get(thisKey);		
    		Event eventOldValues = (Event)oldRecordsMap.get(thisKey);	
    		if(eventNewValues != null && eventOldValues != null &&
    		   String.isNotBlank(eventNewValues.Type) && String.isNotBlank(eventOldValues.Type) &&
    		   !eventNewValues.Type.equalsIgnoreCase(eventOldValues.Type)){
    			if(String.isNotBlank(eventNewValues.Type) && 
					(eventNewValues.Type.equalsIgnoreCase(MEETING_TYPE_1) ||
					 eventNewValues.Type.equalsIgnoreCase(MEETING_TYPE_2))){
					updateInquiryList.add(new Inquiry__c(Id = eventNewValues.WhatId,
														 By_Pass_Validation__c = true,
														 Inquiry_Score__c = HOT_SCORE,
														 Inquiry_Score_Last_Update__c = system.today()));
				}else{
					updateInquiryList.add(new Inquiry__c(Id = eventNewValues.WhatId,
														 By_Pass_Validation__c = true,
														 Inquiry_Score__c = WARM_SCORE,
														 Inquiry_Score_Last_Update__c = system.today()));
				}	
    		}	
    	}
    	if(!updateInquiryList.isEmpty()){
    		update updateInquiryList;	
    	}		
    }
    
    /*********************************************************************************************
    * @Description : Update inquiry status to 'Active' when an associated activity is created,   *
    *                Update the inquiry score to 'Hot' whenever a meeting of type is created:    *
    *				 - Face to Face                                                              *
    *				 - Visit to Sales                                                            *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void updateInquiryStatus(List<sObject> newRecordsList){
    	Map<Id, List<Event>> parentIdEventListMap = new Map<Id, List<Event>>();
		List<Inquiry__c> updateInquiryList = new List<Inquiry__c>(); 
    	for(sObject thisRecord : newRecordsList){            
            Event thisEvent = (Event) thisRecord;
            if(thisEvent.WhatId != null){
            	if(parentIdEventListMap.containsKey(thisEvent.WhatId)){
            		parentIdEventListMap.get(thisEvent.WhatId).add(thisEvent);		
            	}else{
            		parentIdEventListMap.put(thisEvent.WhatId, new List<Event>{thisEvent});
            	}
            }
        }	  
        if(!parentIdEventListMap.isEmpty()){
        	for(Inquiry__c thisInquiry : getEnquiryList(parentIdEventListMap.keySet())){
        		if(String.isNotBlank(thisInquiry.Inquiry_Status__c) && 
        			thisInquiry.Inquiry_Status__c.equalsIgnoreCase(DAMAC_Constants.INQUIRY_NEW_STATUS)){
        			thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_ACTIVE_STATUS;
        		}
        		if(parentIdEventListMap.containsKey(thisInquiry.Id)){
        			for(Event thisEvent : parentIdEventListMap.get(thisInquiry.Id)){
        				if(String.isNotBlank(thisEvent.Type) && 
						   (thisEvent.Type.equalsIgnoreCase(MEETING_TYPE_1) || thisEvent.Type.equalsIgnoreCase(MEETING_TYPE_2))){
							thisInquiry.Inquiry_Score__c = HOT_SCORE;	
							thisInquiry.Inquiry_Score_Last_Update__c = system.today();
							break;
						}		
        			}	
        		} 
				updateInquiryList.add(thisInquiry);
        	}	
        	if(!updateInquiryList.isEmpty()){
        		update updateInquiryList;
        	}		
        }  	
    }
    
    /*********************************************************************************************
    * @Description : Method to get inquiry details.                                              *
    * @Params      : Set<Id>                                                                     *
    * @Return      : List<Inquiry__c>                                                            *
    *********************************************************************************************/
    @TestVisible private List<Inquiry__c> getEnquiryList(Set<Id> enquiryIdsSet){
    	return ([SELECT Id, Name, Inquiry_Status__c, Inquiry_Score__c 
				 FROM Inquiry__c 
				 WHERE Id IN: enquiryIdsSet AND 
				 	   Inquiry_Status__c != null AND ( 
				 	   Inquiry_Status__c =: DAMAC_Constants.INQUIRY_NEW_STATUS OR Inquiry_Status__c =: DAMAC_Constants.INQUIRY_ACTIVE_STATUS)]);		 
    }
    
    // TOBE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
}//End of class.