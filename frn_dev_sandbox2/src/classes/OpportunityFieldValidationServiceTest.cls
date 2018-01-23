/**
* @author Bhakti Gujarathi
* @date 24-Apr-2016
*
* @description This class is test code for the class named 'OpportunityFieldValidationService'
* 
* 
*/
@isTest
private class OpportunityFieldValidationServiceTest {

    static testMethod void relatedFieldNullValueTestCase() {
        List<Contact> contactList = new List<Contact>();
        contactList = FRNTestDataFactory.createContactList(1);
        insert contactList;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = FRNTestDataFactory.createOpportunityList(1);
        
        opportunityList[0].Contact__c = contactList[0].Id;
        opportunityList[0].Readmit__c = 'Yes';
        insert opportunityList;
        
        Test.startTest();
        String resultStr = OpportunityFieldValidationService.validateForNullValue(opportunityList[0].Id);
        Test.stopTest();
    }
    
    static testMethod void fieldNullValueTestCase() {
        List<Contact> contactList = new List<Contact>();
        contactList = FRNTestDataFactory.createContactList(1);
        insert contactList;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = FRNTestDataFactory.createOpportunityList(1);
        
        opportunityList[0].Contact__c = contactList[0].Id;
        insert opportunityList;
        
        Test.startTest();
        String resultStr = OpportunityFieldValidationService.validateForNullValue(opportunityList[0].Id);
        Test.stopTest();
    }
    
    static testMethod void constructorTestCase() {
        List<Contact> contactList = new List<Contact>();
        contactList = FRNTestDataFactory.createContactList(1);
        insert contactList;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = FRNTestDataFactory.createOpportunityList(1);
        
        opportunityList[0].Contact__c = contactList[0].Id;
        insert opportunityList;
        
        Test.startTest();
        OpportunityFieldValidationService controller = new OpportunityFieldValidationService(); 
        Test.stopTest();
    }
}