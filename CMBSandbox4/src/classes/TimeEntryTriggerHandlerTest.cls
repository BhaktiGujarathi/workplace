/**
 * The Test class will check the Code coverage of TimeEntryTriggerHandler Class.
 *
 *
 * Revision History:
 *
 * Version         Author                                Date                              Description
 * 1.0             Ajay Singh Solanki                    27/06/2013                        Initial Draft
 */

@isTest
private class TimeEntryTriggerHandlerTest {


    /* The method will check the code coverage of OnInsertPopulateDeveloperNameAndCompany method of
     * TimeEntryTriggerHandler Class.
     */
    static testMethod void testOnInsertPopulateDeveloperNameAndCompany() {
        //Calling createAccounts method to create Accounts.
        list<Account> lstAccounts = TimeEntryTriggerHandlerTest.createAccounts();
        Database.SaveResult sr1 =  Database.insert(lstAccounts[0]);

        //Calling createContacts method to create Contacts.
        list<Contact> lstContacts = TimeEntryTriggerHandlerTest.createContacts(lstAccounts[0].Id);
        Database.SaveResult[] sr2 =  Database.insert(lstContacts);

        //Calling createProject method to create Project record.
        HarvestProject__c harvestProject = TimeEntryTriggerHandlerTest.createProject(lstAccounts[0].Id);
        Database.SaveResult sr3 =  Database.insert(harvestProject);

        //Calling createTimeEntries method to create Time Entries.
        list<HarvestTimeEntry__c> lstTimeEntries = TimeEntryTriggerHandlerTest.createTimeEntries(harvestProject.Id);
        lstTimeEntries[0].Notes__c = '[#notes for time Entry]';
        CheckRecursive.runAfter = true;
        Database.SaveResult sr4 =  Database.insert(lstTimeEntries[0]);

        //Inserting Time Entry Record that has duplicate Contact.
        CheckRecursive.runAfter = true;
        Database.SaveResult sr5 =  Database.insert(lstTimeEntries[1]);

        //Inserting Time Entry record that don't have Contact name and Account Name as mentioned in person Name.
        CheckRecursive.runAfter = true;
        Database.SaveResult sr6 =  Database.insert(lstTimeEntries[2]);

    }//End testOnInsertPopulateDeveloperNameAndCompany method.



    /* The method will check the code coverage of OnUpdatePopulateDeveloperNameAndCompany method of
     * TimeEntryTriggerHandler Class.
     */
    static testMethod void testOnUpdatePopulateDeveloperNameAndCompany() {
        //Calling createAccounts method to create Accounts.
        list<Account> lstAccounts = TimeEntryTriggerHandlerTest.createAccounts();
        Database.SaveResult sr1 =  Database.insert(lstAccounts[0]);

        //Calling createContacts method to create Contacts.
        list<Contact> lstContacts = TimeEntryTriggerHandlerTest.createContacts(lstAccounts[0].Id);
        Database.SaveResult[] sr2 =  Database.insert(lstContacts);

        //Calling createProject method to create Project record.
        HarvestProject__c harvestProject = TimeEntryTriggerHandlerTest.createProject(lstAccounts[0].Id);
        Database.SaveResult sr3 =  Database.insert(harvestProject);

        //Calling createTimeEntries method to create Time Entries.
        list<HarvestTimeEntry__c> lstTimeEntries = TimeEntryTriggerHandlerTest.createTimeEntries(harvestProject.Id);
        lstTimeEntries[0].Notes__c = '[#notes for time Entry]';
        CheckRecursive.runAfter = true;
        Database.SaveResult sr4 =  Database.insert(lstTimeEntries[0]);

        //Updating person Name to other unique Contact.
        lstTimeEntries[0].Person__c = 'Test Contact2(TestAccount1)';
        lstTimeEntries[0].Developer_Company__c = null;
        CheckRecursive.runAfter = true;
        Database.SaveResult sr5 =  Database.update(lstTimeEntries[0]);

        //Updating person Name to other Contact that also has a duplicate Contact based on Name and Account Name.
        lstTimeEntries[0].Person__c = 'Test Contact4(TestAccount1)';
        CheckRecursive.runAfter = true;
        Database.SaveResult sr6 =  Database.update(lstTimeEntries[0]);

        //Updating person Name to other Contact that doesn't exist based on Name and Account Name.
        lstTimeEntries[0].Person__c = 'Test Contact8(TestAccount1)';
        CheckRecursive.runAfter = true;
        Database.SaveResult sr7 =  Database.update(lstTimeEntries[0]);

        //Updating person Name to null.
        lstTimeEntries[0].Person__c = '';
        CheckRecursive.runAfter = true;
        Database.SaveResult sr8 =  Database.update(lstTimeEntries[0]);

        //Giving person Name in incorrect format .
        lstTimeEntries[0].Person__c = 'TestContact8';
        CheckRecursive.runAfter = true;
        Database.SaveResult sr9 =  Database.update(lstTimeEntries[0]);
        
        CheckRecursive.runAfter = true;
        Database.deleteResult sr10 =  Database.delete(lstTimeEntries[0]);


    }//End testOnUpdatePopulateDeveloperNameAndCompany method.



    /* The method will create dummy records of Account.
     */
    private static list<Account> createAccounts(){
        list<Account> lstAccount = new list<Account>();
        for(Integer index = 1; index <= 4; index++){
            lstAccount.add(new Account(Name = 'TestAccount' + index, Type = 'Developer',
                                       Sub_Type__c = 'Salesforce Developer', Industry='Consulting'));
        }//End for.
        return lstAccount;
    }//End createAccounts method.



    /* The method will create dummy records of Contact.
     */
    private static list<Contact> createContacts(Id pAccountId){
        list<Contact> lstContact = new list<Contact>();
        for(Integer index = 1; index <= 4; index++){
            lstContact.add(new Contact(FirstName = 'Test', LastName = 'Contact' + index,
                                       Contact_Type__c = 'SFDC Developer', Tip_of_The_Week__c = 'Added - Active',
                                       AccountId = pAccountId));
        }//End for.
        //Adding duplicate Contact into the list.
        lstContact.add(new Contact(FirstName = 'Test', LastName = 'Contact4',
                                       Contact_Type__c = 'SFDC Developer', Tip_of_The_Week__c = 'Added - Active',
                                       AccountId = pAccountId));
        return lstContact;
    }//End createContacts method.



    /* The method will create dummy records of Project.
     */
    private static HarvestProject__c createProject(Id pAccountId){
        return(new HarvestProject__c(Name = 'Test Project', Account__c = pAccountId,
                                     Budget__c = 'Hours per task', InvoiceMethod__c = 'This project is billable',
                                     SyncStatus__c = 'Harvest Project Linked', ProjectInvoicedBy__c = 'N/A'));
    }//End createProject method.



    /* The method will create dummy records of Time Entry.
     */
    private static list<HarvestTimeEntry__c> createTimeEntries(Id pProjectId){
        list<HarvestTimeEntry__c> lstTimeEntries = new list<HarvestTimeEntry__c>();
        //Time Entry record that does not have duplicate Contact.
        lstTimeEntries.add(new HarvestTimeEntry__c(Person__c = 'Test Contact1(TestAccount1)', Date__c = system.today(),
                                                   Duration__c = 8, HarvestProject__c = pProjectId));
        //Time Entry record that have duplicate Contact.
        lstTimeEntries.add(new HarvestTimeEntry__c(Person__c = 'Test Contact4(TestAccount1)', Date__c = system.today(),
                                                   Duration__c = 4, HarvestProject__c = pProjectId));

        //Time Entry record that don't have Contact and Account as mentioned in person Name.
        lstTimeEntries.add(new HarvestTimeEntry__c(Person__c = 'Test Contact8(TestAccount1)', Date__c = system.today(),
                                                   Duration__c = 4, HarvestProject__c = pProjectId));
        return lstTimeEntries;
    }//End createTimeEntries method.

}//End TimeEntryTriggerHandlerTest class