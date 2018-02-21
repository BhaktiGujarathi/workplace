/**
* Revision History : test clas sfor lead handler of trigger
*  Version      Author        Date        Description
*  1.0          Yogesh Mahana
*/

public with sharing class LeadHandlerTest {
    private static testMethod void testLeadTrigger() {
        Lead objLead = new Lead(LastName = 'Test Name', Company= 'Test Comp');
        insert objLead;

        objLead.Status = 'Working - Contacted';
        update objLead;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(objLead.Id); 

        LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(false);
        lc.setOverwriteLeadSource(false);
        lc.setSendNotificationEmail(false);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Contact objContact = [select Id from Contact where id =: lcr.getContactId()];
        list<Opportunity> opp = [Select Id, Owner_1__c from Opportunity where id =: lcr.getOpportunityId() ];

        system.assert(opp[0].Owner_1__c == objContact.id);
    }

    private static testMethod void testLeadStatusTrack() {
        Lead objLead = new Lead(LastName = 'Test Name', Company= 'Test Comp');
        insert objLead;

        objLead.Status = 'Working - Contacted';
        Test.startTest();
            update objLead;
        Test.stopTest();
        List<Lead> leads = [Select Id
                                 , Working_Contacted_Date_Time__c
                                 , Status
                                 , Working_Contacted__c
                              From Lead
                              Where Id =:objLead.Id];
       for(Lead lead :leads) {
           //System.assertEquals(system.now(), lead.Working_Contacted_Date_Time__c);
           System.assertEquals(true, lead.Working_Contacted__c);
       }
    }
}