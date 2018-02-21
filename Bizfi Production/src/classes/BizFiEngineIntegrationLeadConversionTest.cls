@isTest
public class BizFiEngineIntegrationLeadConversionTest{

    public static testMethod void testOnLeadConversion() {

        Lead myLead = new Lead(LastName = 'Fry', Company='Fry And Sons', FirstName = 'Philip');

        myLead.Owner_2_First_Name__c = 'Test';
        myLead.Owner_2_Last_Name__c  = 'Owner2';
        myLead.Owner_2_Email__c      = 'Owner2@email.com';

        myLead.Owner_3_First_Name__c = 'Test';
        myLead.Owner_3_Last_Name__c  = 'Owner3';
        myLead.Owner_3_Email__c      = 'Owner3@email.com';

        myLead.Owner_4_First_Name__c = 'Test';
        myLead.Owner_4_Last_Name__c  = 'Owner4';
        myLead.Owner_4_Email__c      = 'Owner4@email.com';

        myLead.Business_Main_Phone__c = '2123456';
        myLead.Business_Email__c      = 'businessTest@email.com';


        Test.startTest();

        Preapproval__c myPreapproval = new Preapproval__c();

        insert myLead;

        myPreapproval.Lead__c = myLead.Id;

        insert myPreapproval;

        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setLeadId(myLead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);

        System.assert(lcr.isSuccess());

        List<Contact> contactsList = [select id, FirstName, LastName from Contact];

        List<OpportunityContactRole> contactRoles = [select id, OpportunityId, ContactId, Role from OpportunityContactRole];

        system.assert(contactsList.size() == 4);

        system.assertEquals(contactsList[1].FirstName, myLead.Owner_2_First_Name__c);
        system.assertEquals(contactsList[1].LastName, myLead.Owner_2_Last_Name__c);

        system.assertEquals(contactsList[2].FirstName, myLead.Owner_3_First_Name__c);
        system.assertEquals(contactsList[2].LastName, myLead.Owner_3_Last_Name__c);

        system.assertEquals(contactsList[3].FirstName, myLead.Owner_4_First_Name__c);
        system.assertEquals(contactsList[3].LastName, myLead.Owner_4_Last_Name__c);

        system.assert(contactRoles.size() == 4);

        system.assertEquals(contactRoles[1].ContactId, contactsList[1].id);
        system.assertEquals(contactRoles[1].ContactId, contactsList[1].id);     

        system.assertEquals(contactRoles[2].ContactId, contactsList[2].id);
        system.assertEquals(contactRoles[2].ContactId, contactsList[2].id);     

        system.assertEquals(contactRoles[3].ContactId, contactsList[3].id);
        system.assertEquals(contactRoles[3].ContactId, contactsList[3].id);     

        Test.stopTest();
    }

public static testMethod void testOnLeadConversionWithOneContacts() {

        Lead myLead = new Lead(LastName = 'Fry', Company='Fry And Sons', FirstName = 'Philip');

        myLead.Owner_2_First_Name__c = 'Test';
        myLead.Owner_2_Last_Name__c  = 'Owner2';
        myLead.Owner_2_Email__c      = 'Owner2@email.com';

        myLead.Owner_3_First_Name__c = 'Test';
        myLead.Owner_3_Email__c      = 'Owner3@email.com';

        myLead.Owner_4_Last_Name__c  = 'Owner4';
        myLead.Owner_4_Email__c      = 'Owner4@email.com';

        myLead.Business_Main_Phone__c = '2123456';
        myLead.Business_Email__c      = 'businessTest@email.com';


        Test.startTest();


        insert myLead;


        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setLeadId(myLead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);

        System.assert(lcr.isSuccess());

        List<Contact> contactsList = [select id, FirstName, LastName from Contact];

        //List contains the data for the automatically created Contact and one Contact corresponding to the second owner.
        system.assert(contactsList.size() == 2);

        system.assertEquals(contactsList[1].FirstName, myLead.Owner_2_First_Name__c);
        system.assertEquals(contactsList[1].LastName, myLead.Owner_2_Last_Name__c);

        Test.stopTest();
    }

    public static testMethod void testOnLeadConversionWithNoContacts() {

        Lead myLead = new Lead(LastName = 'Fry', Company='Fry And Sons', FirstName = 'Philip');

        myLead.Business_Main_Phone__c = '2123456';
        myLead.Business_Email__c      = 'businessTest@email.com';

        Test.startTest();


        insert myLead;


        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setLeadId(myLead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);

        System.assert(lcr.isSuccess());

        List<Contact> contactsList = [select id, FirstName, LastName from Contact];

        //List only contains the data for the automatically created Contact.
        system.assert(contactsList.size() == 1);


        Test.stopTest();
    }

}