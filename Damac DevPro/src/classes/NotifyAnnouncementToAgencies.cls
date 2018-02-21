/****************************************************************************************************************
* Name                  : AnnouncementTriggerHandler                                                            *
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

global with sharing class NotifyAnnouncementToAgencies {

    
    /************************************************************************************************
    * @Description : this method takes the parameter as Map and this will call from AgencyPCTrigger *
    * @Params      : Set<ID>                                                                  *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    WebService Static String notifyAgencyAdminswithanAnnouncement(String newAnnouncementID){
        
        List<string> lstprofilenames = new List<string>();
        for(Announcement_Emails_for_Profiles__c annEmail : Announcement_Emails_for_Profiles__c.getall().values()){
            if(annEmail.Is_Subcribed__c && annEmail.Profile_Name__c != null)
                lstprofilenames.add(annEmail.Profile_Name__c);
        }
        
        Announcement__c Announcement = [SELECT Active__c,Are_Agencies_Notified__c,Description__c,Title__c,Start_Date__c,End_Date__c,Header__c,Footer__c,Agency_Type__c,Agency_Tier__c FROM Announcement__c WHERE ID =: newAnnouncementID];
        List<Messaging.SingleEmailMessage> singleEmails = new List<Messaging.SingleEmailMessage>();
        Map<String,Set<ID>> mapOfagencyAdminIDs = new  Map<String,Set<ID>>();
        Set<ID> agencyAdminIDs;
        List<ID> lstAgencyAdminIDs;
        String keyVal = '';
        
        try{
            List<EmailTemplate> emailTemp = new List<EmailTemplate>([SELECT Id,Name,Subject,body FROM EmailTemplate WHERE DeveloperName ='Announcement_Emails']);
            if(!Announcement.Active__c){
                return 'Announcement must be active, before notifying agencies.';
            } 
            else if(Announcement.Agency_Type__c == null && Announcement.Agency_Tier__c == null){
                return 'Please select Agency Type or Agency Tier.';
            }
            else if(!Announcement.Are_Agencies_Notified__c){
                
                String queryString = 'SELECT ID,Contact.Account.Recordtype.Name,Contact.Account.Agency_Tier__c FROM USER '+
                                     'WHERE Profile.Name IN: lstprofilenames'+
                                     ' AND IsActive = True ';
                
                if(Announcement.Agency_Type__c != null && Announcement.Agency_Tier__c != null){
                    queryString += ((Announcement.Agency_Type__c.equalsIgnoreCase('All') && Announcement.Agency_Tier__c.equalsIgnoreCase('All')) ? '' : (Announcement.Agency_Type__c.equalsIgnoreCase('All') ? '' : 'AND Contact.Account.Agency_Type__c =\''+Announcement.Agency_Type__c+'\'')+''+(Announcement.Agency_Tier__c.equalsIgnoreCase('All') ? '':' AND Contact.Account.Agency_Tier__c =\''+Announcement.Agency_Tier__c+'\''));
                }
                else{
                    queryString += (String.isNotBlank(Announcement.Agency_Type__c) ? (Announcement.Agency_Type__c.equalsIgnoreCase('All') ? '' : ' AND Contact.Account.Agency_Type__c =\''+Announcement.Agency_Type__c+'\'') : '');
                    queryString += (String.isNotBlank(Announcement.Agency_Tier__c) ? (Announcement.Agency_Tier__c.equalsIgnoreCase('All') ? '' : ' AND Contact.Account.Agency_Tier__c =\''+Announcement.Agency_Tier__c+'\'') : '');
                }
                
                System.debug('queryString = '+queryString);
                System.debug('Announcement = '+Announcement );
                
                OrgWideEmailAddress[] owdEmail = [select Id from OrgWideEmailAddress where DisplayName =: Label.Announcement_OWD_Email_Display_Name];
                
                for(User us : (List<User>)Database.query(queryString)){
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            
                    message.setSubject(Announcement.Title__c);
                    message.setTargetObjectId(us.id);
                    if ( owdEmail.size() > 0 ) { 
                        message.setOrgWideEmailAddressId(owdEmail.get(0).Id);
                    }
                    if(String.isNotBlank(Label.Announcement_Bcc_Email))
                        message.setBccAddresses(new List<String>{Label.Announcement_Bcc_Email});
                    
                    message.setHtmlBody(Announcement.Description__c);
                    message.setSaveAsActivity(false);
                    singleEmails.add(message);
                }
                
                System.debug('singleEmails = '+singleEmails);
                if(!singleEmails.isEmpty() && singleEmails.size() > 0){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(singleEmails);
                    if (results[0].success) {
                        Announcement.Are_Agencies_Notified__c = true;
                        update Announcement;
                        return 'Email has been sent to Agents successfully.';
                    } else {
                        System.debug('The email failed to send: '
                              + results[0].errors[0].message);
                        return 'The email failed to send:'+ results[0].errors[0].message;
                    }
                }
                return 'No Agency is notified.';
            }
            else {
                return 'Agents are already notified.';
            }
        }catch(Exception ex){
            return ex.getMessage();
        }
    }
}