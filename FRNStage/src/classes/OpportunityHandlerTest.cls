@isTest
public class OpportunityHandlerTest{
    
    public static TestMethod void OpportunityHandler_UnitTest(){ 
    
        Profile p = [SELECT Id FROM Profile WHERE Name= 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='stand12a1r12duser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Update_AC_Assigned_on_Opportunity__c = True, TimeZoneSidKey='America/Los_Angeles', UserName='stand12a1r12duser@testorg.com');
        
        Contact con = new Contact();
        con.lastName ='test';
        insert con;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Contact__c=con.id;
        oppList.add(opp);
        insert opp;
        
                
        Product2 prod = new Product2(Name = 'test', Family = 'test', IsActive = true);
        insert prod;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'test', Description = 'test', IsActive = true); 
        insert standardPB;
        
        Id pbId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(Pricebook2id=pbId,Product2id=prod.Id,unitprice=1.0, isActive=true);
        insert pbe;
            
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
                
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId=standardPrice.Id,Quantity=1,UnitPrice=100);
        insert oli;
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId=standardPrice.Id,Quantity=1,UnitPrice=100);
        insert oli1;
        
        Mental_Health_Symptom__c mhs = new Mental_Health_Symptom__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert mhs;
        Mental_Health_Symptom__c mhs1 = new Mental_Health_Symptom__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert mhs1;
        
        Medical_Equipment__c me = new Medical_Equipment__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert me;
        Medical_Equipment__c me1 = new Medical_Equipment__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert me1;
        
        Infectious_Disease__c infDis = new Infectious_Disease__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert infDis;
        Infectious_Disease__c infDis1 = new Infectious_Disease__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert infDis1;
        
        Prescription_Medication__c pmc = new Prescription_Medication__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert pmc;
        Prescription_Medication__c pmc1 = new Prescription_Medication__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert pmc1;
        
        Medical_Problem_Symptom__c medprob = new Medical_Problem_Symptom__c(Opportunity__c = opp.Id,Patient__c = con.Id);
        insert medprob;
        Medical_Problem_Symptom__c medprob1 = new Medical_Problem_Symptom__c(Opportunity__c = opp.Id,Patient__c = con.Id);
        insert medprob1;
        
        Treatment_History__c pth= new Treatment_History__c(Opportunity__c = opp.Id,Patient__c = con.Id);
        insert pth; 
        Treatment_History__c pth1= new Treatment_History__c(Opportunity__c = opp.Id,Patient__c = con.Id);
        insert pth1;  
        
        Psychiatric_Diagnosis__c psd= new Psychiatric_Diagnosis__c(Patient__c = con.Id,Opportunity__c = opp.Id);        
        insert psd;
        Psychiatric_Diagnosis__c psd1 = new Psychiatric_Diagnosis__c(Patient__c = con.Id,Opportunity__c = opp.Id);        
        insert psd1;
                
        Abused_Substance__c abs = new Abused_Substance__c(Patient__c=con.Id,Opportunity__c=opp.Id);
        insert abs;
        Abused_Substance__c abs1 = new Abused_Substance__c(Patient__c=con.Id,Opportunity__c=opp.Id);
        insert abs1;
        
        Legal_Offense__c loc = new Legal_Offense__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert loc;
        Legal_Offense__c loc1 = new Legal_Offense__c(Patient__c = con.Id,Opportunity__c = opp.Id);
        insert loc1;
        
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.Phone = '(123) 456-7890';
        acc1.FRN_Facility_Type__c ='Residential Treatment';
        insert acc1;
        
        Referral__c ref = new Referral__c();
        ref.Account__c= acc1.Id;
        ref.Opportunity__c=opp.Id;
        ref.Admission_Date__c= System.today();
        ref.Benefits_Stage__c= 'Pending Medical / Clinical Review';
        ref.Shift_Assigned__c='test';
        ref.Facility_Of_Interest__c='La Paloma';
        ref.Facility_Of_Admission__c='Black Bear';
        ref.RecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
        insert ref;
        
        Referral__c ref1 = new Referral__c();
        ref1.Account__c= acc1.Id;
        ref1.Opportunity__c=opp.Id;
        ref1.Admission_Date__c= System.today();
        ref1.Benefits_Stage__c= 'Pending Medical / Clinical Review';
        ref1.Shift_Assigned__c='test';
        ref1.Facility_Of_Interest__c='La Paloma';
        ref1.Facility_Of_Admission__c='Black Bear';
        ref1.RecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
        insert ref1;
        
        Contact newCon = new Contact();
        newCon.lastName ='test';
        insert newCon;
        
        Patient_Contact__c pc = new Patient_Contact__c(Opportunity__c = opp.id, Contact__c = con.id, First_Name__c = 'test', Last_Name__c = 'test');
        insert pc;
        
        Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True,Subscriber__c=pc.Id);
        insert pi;
        
        Insurance_Benefit__c ib = new Insurance_Benefit__c(Patient_Insurance__c=pi.id, Disposition__c = 'Benefits Available');
            insert ib;
        
        Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id, Insurance_Benefit__c=ib.id);
            insert paw;
        
        opp.Contact__c=newCon.id;
        system.runas(u) {
            Test.startTest();
            update opp; 
            Test.stopTest();
        }
    }
}