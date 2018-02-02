@isTest
public class CreateInsuranceBenefitCtrl_Test{
    static testMethod void Test1(){
        Contact con = new Contact(lastName='test',Birthdate=System.today().addYears(-25));
            insert con;
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.RecordTypeId = FRNOrgTestDataFactory.getRecordtypeIdForSobjectAndRecordtypeName('Opportunity', 'Residential Treatment');
        opportunityObj = FRNOrgTestDataFactory.createRtcOpportunityRecord(opportunityObj);
        insert opportunityObj;
            
        Patient_Insurance__c pIns = new Patient_Insurance__c(Name = 'Test',Patient__c = con.Id, Opportunity__c = opportunityObj.Id);
            insert pIns;
        
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
        Account acc = new Account(Name= 'Test1',RecordTypeId = accRTId,Phone = '(123) 456-7890',FRN_Facility_Type__c ='Residential Treatment');
        insert acc;
        
        RecordType rectyp = [select id from  RecordType where SobjectType='Insurance_Benefit__c' AND Name='In Network'];
        Insurance_Benefit__c inBen = new Insurance_Benefit__c(RecordTypeId = rectyp.id,Patient_Insurance__c = pIns.id,Detox_Admit_Co_Payment__c = 10,DTX_Apply_Copay__c = true,RTC_Admit_Co_Payment__c = 10,RTC_Apply_Copay__c = true,RTC_Copay_Type__c = 'Admit',IOP_Admit_Co_Payment__c = 10,IOP_Apply_Copay__c = true,IOP_Copay_Type__c = 'Admit',PHP_Admit_Co_Payment__c = 10,PHP_Apply_Copay__c = true,PHP_Copay_Type__c = 'Admit');
        insert inBen;

        Estimated_Coverage_Days__c est = new Estimated_Coverage_Days__c(Insurance_Benefit__c = inBen.Id,FRN_Facility__c = acc.Id,DTX_Days__c = 1,IOP_Days__c = 1,PHP_Days__c = 1,RTC_Days__c = 1);
        insert est;
        
        ApexPages.currentPage().getParameters().put('retURL','/'+pIns.id);
        ApexPages.CurrentPage().getparameters().put('id',inBen.id);
        ApexPages.StandardController  sc = new ApexPages.StandardController(inBen);      
        CreateInsuranceBenefitCtrl inBenCtrl = new CreateInsuranceBenefitCtrl(sc);
            inBenCtrl.saveOppInfo();
            inBenCtrl.saveNOppInfo();
            inBenCtrl.showDOB();
            inBenCtrl.addNewEstRows();
            inBenCtrl.ContinueInBenefit();
            inBenCtrl.getFRNFacilities();
            inBenCtrl.rowToRemove =0;
            inBenCtrl.removeRowFromEst();
            inBenCtrl.calculateTotalCoPay();
    }
    
    static testMethod void Test2(){
        Contact con = new Contact(lastName='test');
            insert con;
        
        Patient_Insurance__c pIns = new Patient_Insurance__c(Name = 'Test',Patient__c = con.Id);
            insert pIns;
            
        RecordType rectyp = [select id from  RecordType where SobjectType='Insurance_Benefit__c' AND Name='In Network'];
        Insurance_Benefit__c inBen = new Insurance_Benefit__c(RecordTypeId = rectyp.id,Patient_Insurance__c = pIns.id);
            insert inBen;
            
        ApexPages.currentPage().getParameters().put('retURL','/'+pIns.id);
        ApexPages.CurrentPage().getparameters().put('id',inBen.id);
        ApexPages.StandardController  sc = new ApexPages.StandardController(inBen);
        CreateInsuranceBenefitCtrl inBenCtrl = new CreateInsuranceBenefitCtrl(sc);
            inBenCtrl.saveOppInfo();
            inBenCtrl.saveNOppInfo();
            inBenCtrl.showDOB();
            inBenCtrl.ContinueInBenefit();
    }
    
    static testMethod void Test3(){
        Contact con = new Contact(lastName='test',Birthdate=System.today());
            insert con;
            
        Patient_Insurance__c pIns = new Patient_Insurance__c(Name = 'Test',Patient__c = con.Id);
            insert pIns;
         
        RecordType rectyp = [select id from  RecordType where SobjectType='Insurance_Benefit__c' AND Name='In Network'];
        Insurance_Benefit__c inBen = new Insurance_Benefit__c(RecordTypeId = rectyp.id,Patient_Insurance__c = pIns.id);
            insert inBen;
            
        ApexPages.currentPage().getParameters().put('retURL','/'+pIns.id);
        ApexPages.CurrentPage().getparameters().put('id',inBen.id);
        ApexPages.StandardController  sc = new ApexPages.StandardController(inBen);
        CreateInsuranceBenefitCtrl inBenCtrl = new CreateInsuranceBenefitCtrl(sc);
        inBenCtrl.saveOppInfo();
        inBenCtrl.saveNOppInfo();
        inBenCtrl.showDOB();
        inBenCtrl.getAccountPicklist();
        inBenCtrl.ContinueInBenefit();
        inBenCtrl.renderedSectionMethod();
        inBenCtrl.ib.DTX_Days_Used__c='10';
        inBenCtrl.ib.RTC_Days_Used__c='5';
        inBenCtrl.ib.PHP_Days_Used__c='5';
        inBenCtrl.ib.IOP_Days_Used__c='10';
        inBenCtrl.calculateTotalDaysUsed();

    }
}