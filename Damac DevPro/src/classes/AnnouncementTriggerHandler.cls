/****************************************************************************************************************
* Name                  : AnnouncementTriggerHandler                                                            *
* Trigger               : AnnouncementTrigger                                                                   *
* Description           : This class will Notify all Agency Admin uses once Announcement record is created      *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 05/Feb/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *                                        
* CH00              1.0         NSI - Sivasankar K         05/Feb/2017      Initial developmen                  *
* CH01              2.0                                                                                         *
* CH02              3.0                                                                                         *
*****************************************************************************************************************/

public with sharing class AnnouncementTriggerHandler implements TriggerFactoryInterface {

    // TO BE Implemented
    //Before
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
    //After executions
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
    /************************************************************************************************
    * @Description : this method will execute on after insert trigger only.                         *
    * @Params      : Map<Id, sObject>                                                               *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){
        try{
            notifyAgencyAdminswithanAnnouncement(newRecordsMap.values());
        }
        Catch(Exception ex){
            Trigger.old[0].addError(''+ex.getMessage()+' @ Line number : '+ex.getLineNumber());
        }
    }

    /************************************************************************************************
    * @Description : this method takes the parameter as Map and this will call from AgencyPCTrigger *
    * @Params      : Set<ID>                                                                  *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    @testvisible private void notifyAgencyAdminswithanAnnouncement(List<Announcement__c> newAnnouncements){
        
        List<Messaging.MassEmailMessage> massEmails = new List<Messaging.MassEmailMessage>();
        Map<String,Set<ID>> mapOfagencyAdminIDs = new  Map<String,Set<ID>>();
        Set<ID> agencyAdminIDs;
        List<ID> lstAgencyAdminIDs;
        String keyVal = '';
        
        try{
            List<EmailTemplate> emailTemp = new List<EmailTemplate>([SELECT Id,Name,Subject,body FROM EmailTemplate WHERE DeveloperName ='Announcement_Emails']);
            if(!emailTemp.isEmpty() && emailTemp.size() > 0 ){
                for(User us : [SELECT ID,Contact.Account.Recordtype.Name,Contact.Account.Agency_Tier__c FROM USER 
                                WHERE Profile.Name IN ('Customer Community - Admin','Customer Community - Agent + Admin','Customer Community - Agent + Admin + Auth','Customer Community - Auth + Admin')
                                    AND IsActive = True
                                    AND Contact.Account.Recordtype.Name LIKE '%Agency%']){
                    keyVal = ((String.isNotBlank(us.Contact.Account.Recordtype.Name) && us.Contact.Account.Recordtype.Name.containsIgnoreCase('Agency')) ? (us.Contact.Account.Recordtype.Name.containsIgnoreCase('Individual') ? 'INDIVIDUAL':'CORPORATE') : '');
                    keyVal += (String.isNotBlank(us.Contact.Account.Agency_Tier__c) ? us.Contact.Account.Agency_Tier__c : '');
                    keyVal = keyVal.toUpperCase();
                    
                    if(mapOfagencyAdminIDs.containsKey(keyVal)){
                        agencyAdminIDs = mapOfagencyAdminIDs.get(keyVal);
                        agencyAdminIDs.add(us.ID);
                        mapOfagencyAdminIDs.put(keyVal,agencyAdminIDs);
                    }
                    else{
                        agencyAdminIDs = new Set<ID>{us.ID};
                        mapOfagencyAdminIDs.put(keyVal,agencyAdminIDs);
                    }
                }
                
                for(Announcement__c ann : newAnnouncements){
                    
                     keyVal = ann.Agency_Type__c+''+ann.Agency_Tier__c;
                     keyVal = keyVal.toUpperCase();
                     if(String.isNotBlank(keyVal) && mapOfagencyAdminIDs.containsKey(keyVal) && mapOfagencyAdminIDs.get(keyVal).size() > 0){
                        lstAgencyAdminIDs = new List<ID>();
                        lstAgencyAdminIDs.addAll(mapOfagencyAdminIDs.get(keyVal));
                        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
                        mail.setTargetObjectIds(lstAgencyAdminIDs);
                        mail.setTemplateID(emailTemp[0].Id);
                        mail.setSaveAsActivity(false);
                        massEmails.add(mail);
                     }
                }
                if(!massEmails.isEmpty() && massEmails.size() > 0)
                    Messaging.sendEmail(massEmails);
            }
        }catch(Exception ex){
            Trigger.old[0].addError(''+ex.getMessage());
        }
    }
}