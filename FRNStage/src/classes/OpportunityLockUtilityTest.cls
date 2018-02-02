@isTest
private class OpportunityLockUtilityTest {
    static testMethod void validTest(){
        Account testAccount = new Account();
        testAccount.Name= 'Test Account'; 
        testAccount.Phone = '(012)-345-6769'; 
        testAccount.Facility_Type__c = 'Hospital'; 
        insert testAccount;
        
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId  = coRT;       
        con.LastName = 'test__fName';
        con.FirstName  = 'test__lName';
        con.Birthdate  = system.today();
        con.Salutation = 'Mr.';
        con.TIER_ID__c = 'test';
        con.Phone = '0123456789';
        con.Gender__c = 'Male';
        con.MobilePhone = '0123456789';
        insert con;
        
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();         
        Opportunity opp = new Opportunity();
        opp.Name = 'test_OpportunityName';
        opp.AccountId = testAccount.Id;
        opp.Contact__c = con.Id;
        opp.StageName = 'Prospecting';
        opp.Probability = 70;
        opp.CloseDate = system.today();
        opp.RecordTypeId  = opRT;
        opp.CloseDate = system.today();
        opp.Relationship_to_Patient__c = 'Self';
        opp.Prior_Pending_Financial_Issues__c = 'textArea test_data';           
        insert opp;
                
        Patient_Contact__c pc = new Patient_Contact__c(Last_Name__c = 'Test',First_Name__c = 'Test',Opportunity__c = opp.id, Contact__c = con.id);
        insert pc;
        update pc;    
        
        Patient_Insurance__c pi1 = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber__c=pc.Id);
        insert pi1;
        
        Test.starttest();
            OpportunityLockTest.opportunityLock(new List<Id> {opp.Id});
        Test.stopTest();
    }
}