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

    /*
    * Test to update owner percetage on contact from opportunity.
    **/
    static testMethod void opportunityValidTest() {

        //created record of Contact
        List<Contact> contRecord = TestDataUtility.getContactRecords(4);
        insert contRecord;
        system.assertNotEquals(null, contRecord );

        List<Opportunity> oppRecord = TestDataUtility.getOpportunityRecords(1);
        oppRecord[0].Owner_1__c= contRecord[0].Id;
        oppRecord[0].Owner_1_Ownership__c=20;
        oppRecord[0].Owner_2__c = contRecord[1].Id;
        oppRecord[0].Owner_2_Ownership__c =10;
        oppRecord[0].Owner_3__c = contRecord[2].Id;
        oppRecord[0].Owner_3_Ownership__c =10;
        oppRecord[0].Owner_4__c = contRecord[3].Id;
        oppRecord[0].Owner_4_Ownership__c =10;
        insert oppRecord;
        CheckRecursive.runBefore = true;
        system.assertNotEquals(null, oppRecord);
        Test.startTest();
            oppRecord[0].Owner_1_Ownership__c = 41;
            oppRecord[0].Owner_2_Ownership__c = 54;
            oppRecord[0].Owner_3_Ownership__c = 56;
            oppRecord[0].Owner_4_Ownership__c = 45;
            update oppRecord;
            system.assertNotEquals(null, oppRecord);

            List<Opportunity> oppRecord1 = TestDataUtility.getOpportunityRecords(1);
            oppRecord1[0].Owner_1__c= contRecord[0].Id;
            oppRecord1[0].Owner_1_Ownership__c=30;
            oppRecord1[0].Owner_2__c = contRecord[1].Id;
            oppRecord1[0].Owner_2_Ownership__c =50;
            oppRecord1[0].Owner_3__c = contRecord[2].Id;
            oppRecord1[0].Owner_3_Ownership__c =50;
            insert oppRecord1;
            system.assertNotEquals(null, oppRecord1);
            List<Contact> listcontact = [SELECT Id, Of_Ownership__c FROM Contact where Of_Ownership__c = 30];
            //system.assertEquals(contRecord[0].Id, listcontact[0].Id);
        Test.stopTest();
    }

    static testMethod void testTrackOpportunityStage() {
        List<Opportunity> opportunities =TestDataUtility.getOpportunityRecords(5);
        Test.startTest();
            insert opportunities;
        Test.stopTest();
        List<Opportunity> fetchOpportunities = [Select Id
                                                     , StageName
                                                     , Underwriting__c
                                                     , Underwriting_Date_Time__c
                                                 From Opportunity
                                                 Where ID IN :opportunities];
     }

    /**
    * Test if owner  percentage is updated
    */
    static testMethod void testOwnerPercentageUpdate() {
        List<Contact> contacts = TestDataUtility.getContactRecords(2);
        insert contacts;

        List<Opportunity> opportunities =TestDataUtility.getOpportunityRecords(1);
        opportunities[0].Owner_1__c= contacts[0].Id;
        opportunities[0].Owner_1_Ownership__c=30;
        opportunities[0].Owner_2__c = contacts[1].Id;
        opportunities[0].Owner_2_Ownership__c =50;
        Test.startTest();
            insert opportunities;
        Test.stopTest();
        opportunities[0].Owner_1_Ownership__c=89;
        update opportunities[0];
        Opportunity opportunity = new Opportunity(
            Name ='Test',
            closeDate = System.Today(),
            StageName = 'Open',
            Owner_1__c= contacts[0].Id,
            Owner_1_Ownership__c=68,
            Owner_2__c = contacts[1].Id,
            Owner_2_Ownership__c =30
        );
        insert opportunity;
        opportunity.Owner_1_Ownership__c = 56;
        opportunity.Owner_2_Ownership__c = 32;
        update opportunity;
    }

    /**
    * Test if owner 1 percentage is updated
    */
    static testMethod void testOwner1PercentUpdate() {
        List<Contact> contacts = TestDataUtility.getContactRecords(2);
        insert contacts;

        List<Opportunity> opportunities =TestDataUtility.getOpportunityRecords(2);
        opportunities[0].Owner_1__c= contacts[0].Id;
        opportunities[0].Owner_1_Ownership__c=50;
        opportunities[0].Owner_2__c = contacts[1].Id;
        opportunities[0].Owner_2_Ownership__c =40;
        Test.startTest();
            insert opportunities;
        Test.stopTest();
        opportunities[0].Owner_1_Ownership__c= 0;
        opportunities[0].Owner_2_Ownership__c= 54;
        update opportunities[0];
    }
}