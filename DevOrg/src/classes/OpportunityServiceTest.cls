/**
 * 
 * 
 *  Version    Author               Date(dd/mm/yyyy)      Description
 *  1.0        Yogesh Mahajan       11/25/2015            Test class to update contact from 
                                                          opportunity trigger Service
 *  1.1        Yogesh Mahajan       11/30/2015            TestUtility class is used to insert record
 **/

@isTest
public Class OpportunityServiceTest {
    static testMethod void myUnitTest() {
       
        //created record of Contact
        List<Contact> contRecord = TestDataUtility.getContactRecords(2);
        insert contRecord;
        system.assertNotEquals(null, contRecord );
        
        
        List<Opportunity> oppRecord = TestDataUtility.getOpportunityRecords(1);
        oppRecord[0].Owner_1__c= contRecord[0].Id;
        oppRecord[0].Owner_1_Ownership__c=20;
        oppRecord[0].Owner_2__c = contRecord[1].Id;
        oppRecord[0].Owner_2_Ownership__c =10;
        insert oppRecord;
        system.assertNotEquals(null, oppRecord);
        
        Test.startTest();
            List<Contact> listcontact1 = [SELECT Id, Of_Ownership__c FROM Contact where Of_Ownership__c = 20];
            system.assertEquals(contRecord[0].Id, listcontact1[0].Id);
            oppRecord[0].Owner_1_Ownership__c = 10;
            update oppRecord;
            system.assertNotEquals(null, oppRecord);
            List<Contact> listUpdatecontact = [SELECT Id, Of_Ownership__c FROM Contact where Of_Ownership__c= 10];
            //system.assertEquals(contRecord[0].Id, listUpdatecontact[0].Id);
            
            List<Opportunity> oppRecord1 = TestDataUtility.getOpportunityRecords(1);
            oppRecord1[0].Owner_1__c= contRecord[0].Id;
            oppRecord1[0].Owner_1_Ownership__c=30;
            oppRecord1[0].Owner_2__c = contRecord[1].Id;
            oppRecord1[0].Owner_2_Ownership__c =50;
            insert oppRecord1;
            system.assertNotEquals(null, oppRecord1);
            List<Contact> listcontact = [SELECT Id, Of_Ownership__c FROM Contact where Of_Ownership__c = 30];
            system.assertEquals(contRecord[0].Id, listcontact[0].Id);
            
        Test.stopTest();
    }
}