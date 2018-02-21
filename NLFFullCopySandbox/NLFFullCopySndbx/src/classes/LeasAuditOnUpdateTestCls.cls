/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LeasAuditOnUpdateTestCls {

    /*Lead conversion*/
        public static testMethod void testOnLeadConversion() {

        // TO DO: implement unit test
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='shraddha@testorg.com');
        system.debug('###user'+u);
        User testUser = [select Id from User where Id = :UserInfo.getUserId()];
        system.debug('###testuser'+testUser);
        List<Lead> lstLead = new List<Lead>();
        Lead objLead;
        // This code runs as the system user
        System.runAs(u){
            for(Integer i=0; i<10; ++i){
                objLead = new Lead( LastName = 'Last',
                                    FirstName = 'first',
                                    Company = 'Company',
                                    Status = 'Open',
                                    Phone = '12345678',
                                    Business_Main_Phone__c = '12345678',
                                    Business_Email__c = 'test@testmail.com');
                lstLead.add(objLead);
            }
            insert lstLead;
        }
        for(Integer i=0; i<lstLead.size(); ++i){
            lstLead[i].Status = 'Unqualified';
            lstLead[i].OwnerId = testUser.Id;               
        }
        update lstLead;
        system.debug('###lstLead'+lstLead);
        Integer cnt = [select count() from Audit_Trail__c];
        //system.assertEquals(cnt, lstLead.size());

        Database.LeadConvert lc; 
        LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        list<Database.LeadConvert> listLeadConvert = new list<Database.LeadConvert>();
         for(integer j=0; j<lstLead.size(); j++) {    
            lc = new Database.LeadConvert(); 
            lc.setLeadId(lstLead[j].id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setOwnerId(testUser.Id);
            listLeadConvert.add(lc);
         }
         System.debug('%%%%listLeadConvert'+listLeadConvert);
        list<Database.LeadConvertResult> listLeadConvertResult = new list<Database.LeadConvertResult>();

        listLeadConvertResult =  Database.convertLead(listLeadConvert);

        List<Audit_Trail__c> lstAuditTrail;
        cnt = [select count() from Audit_Trail__c where Type__c = 'Convert']; 
        lstAuditTrail = [select Lead__c ,
                                Type__c,
                                Date_Time_change_was_made__c,
                                New_owner__c,
                                New_Status_Stage_value__c,
                                Old_owner__c,
                                Old_Status_Stage_value__c,
                                Opportunity__c
                         from Audit_Trail__c 
                         where Type__c = 'Convert'];
        System.debug('&&&&& lstAuditTrail size '+cnt);
        System.debug('&&&&& lstAuditTrail '+lstAuditTrail[0]); 
       // System.assertEquals(listLeadConvert.size(), lstAuditTrail.size());
       // System.assertEquals(listLeadConvertResult[0].isSuccess(),true);
       // System.assertEquals(lstAuditTrail[0].New_Status_Stage_value__c,'Qualified'); 
       // System.assertNotEquals(lstAuditTrail[0].New_Status_Stage_value__c,lstAuditTrail[0].Old_Status_Stage_value__c);
        
        
        
        //System.assertNotEquals(lstAuditTrail[0].New_owner__c,lstAuditTrail[0].Old_owner__c);
        
        //system.assertEquals(cnt, lstLead.size()/2);
        //1. Lead Status & Owner updates
        //2. Lead is converted & status is updated
        // 3. Lead is converted & Owner is updated
    }
}