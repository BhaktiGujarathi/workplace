/**
 *
 *  Description : Used to test the functionality of the trigger to update the rollup fields on 
 *                account with respect to the total number of projects.
 *
 *      Version           Author          Date(DD/MM/YYYY)           Decsrption
 *        1.0       Ashwini Singh          25/9/2015         Test the populating of the field on 
 *                                                           account with respect to the assciated 
 *                                                           Projects.
 *
 **/

@isTest
private class HarvestProjectHandlerTest {

    //Test trigger call on Insert of Project records
    static testMethod void testOnProjectInsert() {
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(1);
        insert listAccounts;

        //insert contact record
        List<Contact> listContacts = TestUtility.getContactRecords(1, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts[0].Id);

        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);

        //insert project records
        List<HarvestProject__c> listProjects = TestUtility.getHarvestProjectRecords(2, 
                                    listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        Test.startTest();
            insert listProjects;
        Test.stopTest();
        System.assertNotEquals(Null, listProjects.size());

        //insert Time Entry Records
        List<HarvestTimeEntry__c> listTimeEntries = TestUtility.getHarvestTimeEntryRecords(2,
                                      listProjects[0].Id, listContacts[0].Id, listAccounts[0].Id);
        insert  listTimeEntries;
        System.assertNotEquals(Null, listTimeEntries.size());

        //fetch the account that is inserted
        List<Account> listAccountAssert = [SELECT Total_unused_estimated_hours__c,
                                                  Total_of_projects__c
                                           FROM Account
                                           WHERE Id = :listAccounts[0].Id];
        //assert if the fields are properly updated
        System.assertNotEquals(Null, listAccountAssert[0].Total_of_projects__c);
        System.assertNotEquals(Null, listAccountAssert[0].Total_unused_estimated_hours__c);

    }

    //Test trigger call on update of Project
     static testMethod void testOnProjectUpdate() {
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(2);
        insert listAccounts;
 
        //insert contact record
        List<Contact> listContacts = TestUtility.getContactRecords(2, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());

        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);

        //insert Project Records
        List<HarvestProject__c> listProjects = TestUtility.getHarvestProjectRecords(3, 
                                    listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        insert listProjects;
        System.assertNotEquals(Null, listProjects.size());

        //insert time Entry records
        List<HarvestTimeEntry__c> listTimeEntries = TestUtility.getHarvestTimeEntryRecords(2,
                                      listProjects[0].Id, listContacts[0].Id, listAccounts[0].Id);
        insert  listTimeEntries;
        System.assertNotEquals(Null, listTimeEntries.size());
        CheckRecursive.runAfter = true;
        listProjects[1].Account__c= listAccounts[1].Id;
        //update the projject record
        Test.startTest();
            update listProjects[1];
        Test.stopTest();

        //fetch the account that is inserted
        List<Account> listAccountAssert = [SELECT Total_unused_estimated_hours__c,
                                                  Total_of_projects__c
                                           FROM Account
                                           WHERE Id = :listAccounts[0].Id];
        //assert if the fields are properly updated
        System.assertNotEquals(Null, listAccountAssert[0].Total_of_projects__c);
        System.assertNotEquals(Null, listAccountAssert[0].Total_unused_estimated_hours__c);

    }

    //to test on delete of project
    static testMethod void testOnProjectDelete() {
        //insert account record
        List<Account> listAccounts = TestUtility.getAccountRecords(2);
        insert listAccounts;

        //insert contact record
        List<Contact> listContacts = TestUtility.getContactRecords(2, listAccounts[0].Id);
        insert listContacts;
        System.assertNotEquals(Null, listContacts.size());

        //insert opportunity record
        List<Opportunity> listOpportunity = TestUtility.getOpportunityRecords(1, listAccounts[0].Id);
        insert listOpportunity;
        System.assertEquals(listAccounts[0].Id, listOpportunity[0].AccountId);

        //insert Project Records
        List<HarvestProject__c> listProjects = TestUtility.getHarvestProjectRecords(3, 
                                    listAccounts[0].Id, listContacts[0].Id, listOpportunity[0].Id);
        insert listProjects;
        System.assertNotEquals(Null, listProjects.size());

        //insert time Entry records
        List<HarvestTimeEntry__c> listTimeEntries = TestUtility.getHarvestTimeEntryRecords(2,
                                      listProjects[0].Id, listContacts[0].Id, listAccounts[0].Id);
        insert  listTimeEntries;
        System.assertNotEquals(Null, listTimeEntries.size());

        CheckRecursive.runAfter = true;
        //delete the project record
        Test.startTest();
            delete listProjects[1];
        Test.stopTest();

        //fetch the account that is inserted
        List<Account> listAccountAssert = [SELECT Total_unused_estimated_hours__c,
                                                  Total_of_projects__c
                                           FROM Account
                                           WHERE Id = :listAccounts[0].Id];
        //assert if the fields are properly updated
        System.assertEquals(2, listAccountAssert[0].Total_of_projects__c);
        System.assertNotEquals(Null, listAccountAssert[0].Total_unused_estimated_hours__c);

    }
}