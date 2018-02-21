/**************************************************************************************************
* Name               : TaskTriggerHandler                                                         *
* Description        : This is a trigger handler class for Activities. Has the below functions.   *
* Created Date       : 12/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE                                                              *
* 1.0         NSI - Vineet      12/01/2017                                                        *
* 1.1         NSI - Sivasankar  12/03/2017     Updating the activity counter                      *
* 1.2         NSI - Sivasankar  30/03/2017     Assign the 3Cx task to PC using extension          *
* 1.3         NSI - Sivasankar  04/04/2017     Update the Related to filed for Task- Inquiry      *
**************************************************************************************************/
public class TaskTriggerHandler implements TriggerFactoryInterface{
    
    private final String MEETING_TYPE_1 = 'Face to Face';
	private final String MEETING_TYPE_2 = 'Visit to Sales Office';
    private final String TASK_TYPE_1 = 'Call';
    private final String HOT_SCORE = 'Hot';
    private final String WARM_SCORE = 'Warm';
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        //V1.2.Start
        try{
            assignTasktoExtNoUser(newRecordsList);
            //V1.3
            if(UserInfo.getName().containsIgnoreCase('CTI')){
            	TasksToInquiryMapping.mapTaskToInquiry(newRecordsList,false);
            }
            //V1.3
            for(Task thisTask : (List<Task>) newRecordsList){
        		if(String.isNotBlank(thisTask.Calling_Number__c)){
        			thisTask.Encrypt_Calling_Number__c = UtilityHelperCls.encryptMobile(thisTask.Calling_Number__c);
        		}
        	}
        }catch(Exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
        //V1.2.End
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before update.                       *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    	for(Task thisTask : (List<Task>) newRecordsMap.values()){
        	if(String.isNotBlank(thisTask.Calling_Number__c))
        		thisTask.Encrypt_Calling_Number__c = UtilityHelperCls.encryptMobile(thisTask.Calling_Number__c);
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
    	try{
            /*Calling method to update inquiry activity counter when a activity is created. */
            updateActivityCounter(newRecordsMap.values());
            /*Calling method to update inquiry status when a activity is created. */
            updateInquiryStatus(newRecordsMap.values());
            if(UserInfo.getName().containsIgnoreCase('CTI') || System.Test.isRunningTest()){
            	updateOneHourBreakTimeofUsers(DAMAC_Constants.userExtForBreak); 
            }
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
            /*Calling method to update inquiry activity counter when a activity is created. */
            updateActivityCounter(newRecordsMap.values());
            /*Calling method to update inquiry status when a activity is created. */
            updateInquiryScore(newRecordsMap, oldRecordsMap);
        }catch(exception ex){
        	system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }
    
    /*********************************************************************************************
    * @Description : Update inquiry score if task type is changed to 'Hot'; else 'Warm'          *
    *                - Face to Face                                                              *
    *                - Visit to Sales                                                            *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void updateInquiryScore(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        List<Inquiry__c> updateInquiryList = new List<Inquiry__c>();
        for(Id thisKey : newRecordsMap.keySet()){
            Task taskNewValues = (Task)newRecordsMap.get(thisKey);      
            Task taskOldValues = (Task)oldRecordsMap.get(thisKey);  
            if(taskNewValues != null && taskOldValues != null &&
               String.isNotBlank(taskNewValues.Subject) && 
               String.isNotBlank(taskOldValues.Subject) &&
               !taskNewValues.Subject.containsIgnoreCase(taskOldValues.Subject)){
                if(String.isNotBlank(taskNewValues.Subject) && 
                    (taskNewValues.Subject.containsIgnoreCase(TASK_TYPE_1))){
                    updateInquiryList.add(new Inquiry__c(Id = taskNewValues.WhatId,
                    									 By_Pass_Validation__c = true,
                                                         Inquiry_Score__c = HOT_SCORE,
                                                         Inquiry_Score_Last_Update__c = system.today()));
                }else{
                    updateInquiryList.add(new Inquiry__c(Id = taskNewValues.WhatId,
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
    *                - Face to Face                                                              *
    *                - Visit to Sales                                                            *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void updateInquiryStatus(List<sObject> newRecordsList){
        Map<Id, List<Task>> parentIdTaskListMap = new Map<Id, List<Task>>();
        List<Inquiry__c> updateInquiryList = new List<Inquiry__c>(); 
        for(sObject thisRecord : newRecordsList){            
            Task thisTask = (Task) thisRecord;
            if(thisTask.WhatId != null){
                if(parentIdTaskListMap.containsKey(thisTask.WhatId)){
                    parentIdTaskListMap.get(thisTask.WhatId).add(thisTask);     
                }else{
                    parentIdTaskListMap.put(thisTask.WhatId, new List<Task>{thisTask});
                }
            }
        }     
        if(!parentIdTaskListMap.isEmpty()){
            for(Inquiry__c thisInquiry : getEnquiryList(parentIdTaskListMap.keySet())){
                if(String.isNotBlank(thisInquiry.Inquiry_Status__c) && 
                    thisInquiry.Inquiry_Status__c.equalsIgnoreCase(DAMAC_Constants.INQUIRY_NEW_STATUS)){
                    thisInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_ACTIVE_STATUS;
                }
                if(parentIdTaskListMap.containsKey(thisInquiry.Id)){
                    for(Task thisTask : parentIdTaskListMap.get(thisInquiry.Id)){
                        if(String.isNotBlank(thisTask.Subject) && 
                           (thisTask.Subject.containsIgnoreCase(TASK_TYPE_1))){
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
                       Inquiry_Status__c != null AND 
                       (Inquiry_Status__c =: DAMAC_Constants.INQUIRY_NEW_STATUS OR 
                        Inquiry_Status__c =: DAMAC_Constants.INQUIRY_ACTIVE_STATUS)]);       
    }
    
    /*********************************************************************************************
    * @Description : Method to Update the Activity Counter value                                 *
    * @Params      : Set<Id>                                                                     *
    * @Return      : List<Inquiry__c>                                                            *
    *********************************************************************************************/
    public static void updateActivityCounter(List<sObject> oldNewrecordsList){
    	String inquiryPrefix = DamacUtility.getObjectPrefix('Inquiry__c');
    	String inquityID = '';
    	Set<ID> inquiryRecordsID = new Set<ID>();
    	List<Inquiry__c> updateInquiries = new List<Inquiry__c>();
    	Integer completedEvents = 0,completedTasks=0,activeEvents = 0,activeTasks = 0;
    	for(sObject activityObj : oldNewrecordsList){
    		inquityID = (String)activityObj.get('WhatId'); 
    		if(String.isNotBlank(inquiryPrefix) && String.isNotBlank(inquityID) && inquityID.startsWith(inquiryPrefix))
    			inquiryRecordsID.add(inquityID);
    	}
    	if(!inquiryRecordsID.isEmpty()){
    		for(Inquiry__c inquiry : [SELECT Id,Activity_Counter__c,Completed_Activities_Counter__c,All_Activities_Counter__c,
    									(SELECT ID,Status__c FROM Events  ORDER BY Status__c ASC),//WHERE (Status__c =: DAMAC_Constants.EVENT_PLANNED_STATUS OR Status__c =: DAMAC_Constants.EVENT_COMPLETED_STATUS)
    									(SELECT ID,Status FROM Tasks ) //WHERE Status IN:DAMAC_Constants.TASK_STATUS
									  FROM Inquiry__c 
									  WHERE Id IN: inquiryRecordsID ]){
				completedEvents = 0;
				completedTasks=0;
				activeEvents = 0;
				activeTasks = 0;
				//Completed Events
				for(Event eventStatus : inquiry.Events){
					if(String.isNotBlank(eventStatus.Status__c) ){
						if(eventStatus.Status__c.containsIgnoreCase(DAMAC_Constants.EVENT_COMPLETED_STATUS))
							completedEvents ++;
						if(eventStatus.Status__c.containsIgnoreCase(DAMAC_Constants.EVENT_PLANNED_STATUS) )
							activeEvents ++;
					}
				}
				//Completed Tasks		 
				for(Task TaskStatus : inquiry.Tasks){
					if(String.isNotBlank(TaskStatus.Status)){
						if(TaskStatus.Status.containsIgnoreCase(DAMAC_Constants.EVENT_COMPLETED_STATUS))
							completedTasks ++;
						if(DAMAC_Constants.ACTIVE_TASK_STATUS.containsIgnoreCase(TaskStatus.Status))
							activeTasks ++;
					}
				}
				//if Activity Counter or Completed Activity Counter not same
				//if( (inquiry.Activity_Counter__c != ((inquiry.Events.size() - completedEvents)  + (inquiry.Tasks.size() - completedTasks))) 
				//	|| (inquiry.Completed_Activities_Counter__c != (completedEvents + completedTasks)) )
				//	updateInquiries.add(new Inquiry__c(ID = inquiry.Id,Activity_Counter__c = ((inquiry.Events.size() - completedEvents)  + (inquiry.Tasks.size() - completedTasks)), Completed_Activities_Counter__c = (completedEvents + completedTasks) ));
				/*System.debug('==>completedEvents = '+completedEvents);	
				System.debug('==>completedTasks =  '+completedTasks);
				System.debug('==>activeEvents =  '+activeEvents);
				System.debug('==>activeTasks = '+activeTasks);
				System.debug('==> '+inquiry.Events.size()+', '+inquiry.Tasks.size());
				
				System.debug('==>active = '+inquiry.Activity_Counter__c);
				System.debug('==>comple = '+inquiry.Completed_Activities_Counter__c);
				System.debug('==>all = '+inquiry.All_Activities_Counter__c);*/
				
				if( (inquiry.Activity_Counter__c != (activeEvents  + activeTasks)) || 
					(inquiry.Completed_Activities_Counter__c != (completedEvents + completedTasks)) || 
					(inquiry.All_Activities_Counter__c != (inquiry.Events.size() + inquiry.Tasks.size()))){
					updateInquiries.add(new Inquiry__c(Id = inquiry.Id, 
													   Activity_Counter__c = ((inquiry.Events.size() - completedEvents)  + (inquiry.Tasks.size() - completedTasks)), 
													   Completed_Activities_Counter__c = (completedEvents + completedTasks), 
													   All_Activities_Counter__c = (inquiry.Events.size() + inquiry.Tasks.size()), 
													   By_Pass_Validation__c = true));
				}
			}
			
			if(!updateInquiries.isEmpty() && updateInquiries.size() > 0){
				update updateInquiries;
			}
    	}
    }
    
    /*********************************************************************************************
    * @Description : Method to Update the Activity Counter value                                 *
    * @Params      : Set<Id>                                                                     *
    * @Return      : List<Inquiry__c>                                                            *
    *********************************************************************************************/
    public static void assignTasktoExtNoUser(List<sObject> newRecordsList){
        System.debug('Activity method is calling for task assignment'+newRecordsList);
        Set<String> userExtNos = new Set<String>();
        Map<String,ID> mapExtofUserID = new Map<String,ID>();
        for(sObject thisActivity : newRecordsList)
            if(String.isNotBlank((String)thisActivity.get('User_Ext_No__c')))
                userExtNos.add((String)thisActivity.get('User_Ext_No__c'));
        if(!userExtNos.isEmpty()){
            for(User thisExtUser : [SELECT ID,Name,Extension FROM USER WHERE Extension IN:userExtNos])
                mapExtofUserID.put(thisExtUser.Extension,thisExtUser.ID);

            for(sObject thisActivity : newRecordsList)
                if(String.isNotBlank((String)thisActivity.get('User_Ext_No__c')) && mapExtofUserID != null && mapExtofUserID.containsKey((String)thisActivity.get('User_Ext_No__c')))
                    thisActivity.put('OwnerId',mapExtofUserID.get((String)thisActivity.get('User_Ext_No__c')));
        }
    }
    
    @future 
    public static void updateOneHourBreakTimeofUsers(Set<String> userExts){
    	DAMAC_Constants.userExtForBreak = userExts;
    	System.debug('activtity DAMAC_Constants.userExtForBreak='+DAMAC_Constants.userExtForBreak.isEmpty());
    	System.debug('UserInfo.getName()='+UserInfo.getName()); 
    	if(!DAMAC_Constants.userExtForBreak.isEmpty()){
    		List<User> updateBreakTime = new List<User>();
    		for(User thisUser : [Select Id,Break_Time__c FROM USER WHERE Extension IN: DAMAC_Constants.userExtForBreak ]){
    			updateBreakTime.add(new User(Id=thisUser.Id,Break_Time__c=System.now()));
    			System.debug('Inside activtity DAMAC_Constants.userExtForBreak='+DAMAC_Constants.userExtForBreak.isEmpty()); 
    		}
    		if(updateBreakTime != null && !updateBreakTime.isEmpty() && updateBreakTime.size() > 0 ){
    			update updateBreakTime;
    		}
    	}
    }
    
    // TOBE Implemented
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){ }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){ }
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
}//End of class.