@isTest
private class NAC_OpportunityPageControllerTest {
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
        
        Trip__c tp = new Trip__c(Patient__c = con.id, Opportunity__c = opp.id);
        insert tp;
        
        Id RecRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();
        Reservation__c rc = new Reservation__c(RecordTypeID = RecRTId, Trip__c = tp.id, Rate__c = 10,Departure_Airport__c = 'PDX',Arrival_Airport__c = 'DEN', Total_Amount_Charged__c = 20);
        insert rc;
        
        PageReference pageRef = Page.NAC_OpportunityPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',opp.id);  
        NAC_OpportunityPageController controlr = new NAC_OpportunityPageController();
    }
}