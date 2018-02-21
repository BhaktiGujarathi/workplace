/**************************************************************************************************
* Name               : TasksToInquiryMapping                                                      *
* Description        : Map the tasks to related Inquiry created from 3Cx integration              *
* Created Date       : 04/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE		COMMENTS                                              *
* 1.0         NSI - Sivasankar  04/04/2017  Initial Draft.                                        *
* 1.1         NSI - Vineet      18/05/2017  Remove the campaign number filter,                    *
* 											for assigning the task to the inquiry.                *
*											New logic is to only check for user extensions and,   *
*											the calling number match on the inquiry phone fields. *
**************************************************************************************************/
public with sharing class TasksToInquiryMapping {
    
    public static String mapTaskToInquiry(List<Task> tasksTobeMappedToInquiry, Boolean isupdateTasks){
        Set<String> callingNumbers = new Set<String>();
        Set<String> userExt = new Set<String>();
        Set<String> virtualCampaignNumber = new Set<String>();
        //DAMAC_Constants.userExtForBreak = new Set<String>();
        try{
            for(Task thisTask : tasksTobeMappedToInquiry){
                if(thisTask.WhatID == null){
                    if(String.isNotBlank(thisTask.User_Ext_No__c)) { userExt.add(thisTask.User_Ext_No__c); }
                    if(String.isNotBlank(thisTask.Campaign_Number__c)) { virtualCampaignNumber.add(thisTask.Campaign_Number__c); }
                    if(String.isNotBlank(thisTask.Calling_Number__c)) { callingNumbers.add(thisTask.Calling_Number__c); }
                    if(String.isNotBlank(thisTask.Status) && thisTask.Status.equalsIgnoreCase('Completed') && String.isNotBlank(thisTask.User_Ext_No__c)){
                        DAMAC_Constants.userExtForBreak.add(thisTask.User_Ext_No__c);
                    }
                }
            }
            system.debug('#### Calling Numbers = '+callingNumbers);
            system.debug('#### User Extension = '+userExt);
            system.debug('#### Virtual Campaign Number = '+virtualCampaignNumber);
            /* Calling method to get the matching inquiries. */
            Map<String, Id> mapmatchingInquiries = getMatchingInquiries(callingNumbers, userExt, virtualCampaignNumber);
            if(!mapmatchingInquiries.isEmpty()){
                for(Task thisTask : tasksTobeMappedToInquiry){
                    if(thisTask.WhatID == null && String.isNotBlank(thisTask.User_Ext_No__c) && 
                       String.isNotBlank(thisTask.Calling_Number__c)){
                        String keyVal = thisTask.User_Ext_No__c + thisTask.Calling_Number__c;
                        keyVal = keyVal.toUpperCase();
                        if(String.isNotBlank(keyVal) && mapmatchingInquiries.containsKey(keyVal)){
                        	system.debug('#### Assigning the inquiry');
                            thisTask.WhatID = mapmatchingInquiries.get(keyVal);
                        }
                    }
                }
                if(isupdateTasks){
                    Database.update(tasksTobeMappedToInquiry,false);
                    TaskTriggerHandler taskTrig = new TaskTriggerHandler();
                    taskTrig.updateInquiryStatus(tasksTobeMappedToInquiry);
                }
            }
            return 'Sucess';
        }catch(Exception ex){
            system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());
            return ex.getMessage();
        }
    }
    
    @testVisible static private Map<String,ID> getMatchingInquiries(Set<String> callingNumbers, Set<String> userExt, Set<String> virtualCampaignNumber){
        Map<String,ID> mapInquiries = new Map<String,ID>();
        Map<String,string> mapVirtualCampaignNumbers = getVirtualCampaignNumber(virtualCampaignNumber);
        for(Inquiry__c thisInquiry : [SELECT Id,User_Ext_No__c,Mobile_Phone__c,Mobile_Phone_2__c,Mobile_Phone_3__c,Mobile_Phone_4__c,
                                             Mobile_Phone_5__c,Campaign__c,Campaign__r.Name 
                                      FROM Inquiry__c 
                                      WHERE User_Ext_No__c IN: userExt AND 
                                      		(Mobile_Phone__c IN: callingNumbers OR 
                                      		 Mobile_Phone_2__c IN: callingNumbers OR 
                                      		 Mobile_Phone_3__c IN: callingNumbers OR 
                                      		 Mobile_Phone_4__c IN: callingNumbers OR 
                                      		 Mobile_Phone_5__c IN: callingNumbers)
                                      ORDER BY CreatedDate ASC]){
            String keyVal = thisInquiry.User_Ext_No__c + 
            				(isCallingNumberPresent(thisInquiry.Mobile_Phone__c, callingNumbers) ? 
            					thisInquiry.Mobile_Phone__c : 
            						(isCallingNumberPresent(thisInquiry.Mobile_Phone_2__c,callingNumbers) ? 
            							thisInquiry.Mobile_Phone_2__c : 
            								(isCallingNumberPresent(thisInquiry.Mobile_Phone_3__c,callingNumbers) ? 
            									thisInquiry.Mobile_Phone_3__c : 
            										(isCallingNumberPresent(thisInquiry.Mobile_Phone_4__c,callingNumbers) ? 
            											thisInquiry.Mobile_Phone_4__c : 
            												(isCallingNumberPresent(thisInquiry.Mobile_Phone_5__c,callingNumbers) ? 
            													thisInquiry.Mobile_Phone_5__c : '')))));
            keyVal = keyVal.toUpperCase();
            mapInquiries.put(keyVal,thisInquiry.Id);
        }
        system.debug('#### mapInquiries = '+mapInquiries);
        return mapInquiries;
    }
    
    @testVisible static private Boolean isCallingNumberPresent(String callingNumber, Set<String>callingNumbers){
        if(String.isNotBlank(callingNumber) && callingNumbers.contains(callingNumber)){
            return true;
        }
        return false;
    }
    
    @testVisible static private Map<String,string> getVirtualCampaignNumber(Set<String> virtualNumbers){
        Map<String,string> virtualCampaign = new Map<String,string>();
        Date todayDate = Date.today();
        for(JO_Campaign_Virtual_Number__c thisRecord : [SELECT Id,Related_Virtual_Number__r.Name, Related_Campaign__r.Name 
        												FROM JO_Campaign_Virtual_Number__c 
                                                        WHERE Related_Virtual_Number__r.Name IN: virtualNumbers AND 
                                                        	  Related_Campaign__c != null AND 
                                                        	  Related_Campaign__r.Marketing_Start_Date__c <=: todayDate AND 
                                                        	  Related_Campaign__r.Marketing_End_Date__c >=: todayDate]){
          virtualCampaign.put(thisRecord.Related_Campaign__r.Name,thisRecord.Related_Virtual_Number__r.Name);
          system.debug('#### virtualCampaign = '+virtualCampaign);
        }  
        return virtualCampaign; 
    }
}// End of class.