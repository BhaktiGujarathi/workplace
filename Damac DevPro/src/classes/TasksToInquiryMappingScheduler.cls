/**************************************************************************************************
* Name               : TasksToInquiryMappingScheduler                                             *
* Description        : Run the class to map the tasks to related Inquiry created from 3Cx integ   *
* Created Date       : 04/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE                                                              *
* 1.0         NSI - Sivasankar  12/01/2017                                                        *
**************************************************************************************************/
global without sharing class TasksToInquiryMappingScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        List<Task> tasksToMapInquiry = new List<Task>([SELECT Id, Status, User_Ext_No__c, Campaign_Number__c, 
        													  Calling_Number__c, WhatID 
        											   FROM Task 
        											   WHERE User_Ext_No__c != null AND 
        											   		 Campaign_Number__c != null AND 
        											   		 Calling_Number__c != null AND 
        											   		 WhatID = null AND 
        											   		 CreatedBy.UserName LIKE '%CTI%']);
        try{
	        if(!tasksToMapInquiry.isEmpty()){
	            TasksToInquiryMapping.mapTaskToInquiry(tasksToMapInquiry, true);
	        }
        }catch(Exception ex){ 
    		system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage()); 
        }
    }
}//End of class.