@isTest
private class PatientNameforOppObj_Test {

    private static testMethod void test1() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;
                    
            ApexPages.CurrentPage().getparameters().put('id',opp.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(opp);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
    }

    private static testMethod void test2() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Abused_Substance__c abs = new Abused_Substance__c();
            abs.Opportunity__c = opp.Id;
            abs.Patient__c = con.Id;
            insert abs;
            
            ApexPages.CurrentPage().getparameters().put('id',abs.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(abs);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
    }

    private static testMethod void test3() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Treatment_History__c treat = new Treatment_History__c();
            treat.Opportunity__c = opp.Id;
            treat.Patient__c = con.Id;
            insert treat;
            
            ApexPages.CurrentPage().getparameters().put('id',treat.Id);     
            ApexPages.StandardController  controller = new ApexPages.StandardController(treat);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
    }
    
    private static testMethod void test4() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Medical_Problem_Symptom__c med = new Medical_Problem_Symptom__c();
            med.Opportunity__c = opp.Id;
            med.Patient__c = con.Id;
            insert med; 
            
            ApexPages.CurrentPage().getparameters().put('id',med.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(med);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
    }

    private static testMethod void test5() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Prescription_Medication__c pre = new Prescription_Medication__c();
            pre.Opportunity__c = opp.Id;
            pre.Patient__c = con.Id;
            insert pre;
            
            ApexPages.CurrentPage().getparameters().put('id',pre.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(pre);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
    }

    private static testMethod void test6() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Mental_Health_Symptom__c men = new Mental_Health_Symptom__c();
            men.Opportunity__c = opp.Id;
            men.Patient__c = con.Id;
            insert men; 
            
            ApexPages.CurrentPage().getparameters().put('id',men.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(men);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
    }

    private static testMethod void test7() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Psychiatric_Diagnosis__c psy = new Psychiatric_Diagnosis__c();
            psy.Opportunity__c = opp.Id;
            psy.Patient__c = con.Id;
            insert psy; 
            
            ApexPages.CurrentPage().getparameters().put('id',psy.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(psy);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);    
	}

	 private static testMethod void test8() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Infectious_Disease__c InDi = new Infectious_Disease__c();
            InDi.Opportunity__c = opp.Id;
            InDi.Patient__c = con.Id;
            insert InDi; 
            
            ApexPages.CurrentPage().getparameters().put('id',InDi.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(InDi);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);      
	 
    }
	 private static testMethod void test9() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Legal_Offense__c LeOff = new Legal_Offense__c();
            LeOff.Opportunity__c = opp.Id;
            LeOff.Patient__c = con.Id;
            insert LeOff; 
            
            ApexPages.CurrentPage().getparameters().put('id',LeOff.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(LeOff);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);    
	}
	private static testMethod void test10() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Medical_Equipment__c MedEqu = new Medical_Equipment__c();
            MedEqu.Opportunity__c = opp.Id;
            MedEqu.Patient__c = con.Id;
            insert MedEqu; 
            
            ApexPages.CurrentPage().getparameters().put('id',MedEqu.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(MedEqu);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);    
	}
	private static testMethod void test11() {        
        String acRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = acRT;
            acc.Name = 'test';
            insert acc;     
            
        String coRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            Contact con = new Contact();
                con.AccountId  = acc.Id;       
                con.RecordTypeId  = coRT;       
                con.LastName = 'test__fName';
                con.FirstName  = 'test__lName';
                con.Birthdate  = system.today();
                insert con;
                
        String opRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();   
            Opportunity opp = new Opportunity();
                opp.Name = 'test_OpportunityName';
                opp.Contact__c = con.Id;
                opp.StageName = 'Prospecting';
                opp.Probability = 70;
                opp.CloseDate = system.today();
                opp.RecordTypeId  = opRT;
                insert opp;

        Substance_Abuse_History_and_Frequency__c SuAbFr = new Substance_Abuse_History_and_Frequency__c();
            SuAbFr.Opportunity__c = opp.Id;
            SuAbFr.Patient__c = con.Id;
            insert SuAbFr; 
            
            ApexPages.CurrentPage().getparameters().put('id',SuAbFr.Id);       
            ApexPages.StandardController  controller = new ApexPages.StandardController(SuAbFr);
                PatientNameforOppObj opExt = new PatientNameforOppObj(controller);    
	}

    
}