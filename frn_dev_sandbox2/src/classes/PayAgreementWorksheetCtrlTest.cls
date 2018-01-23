@isTest
public class PayAgreementWorksheetCtrlTest {
    testMethod static void test1(){
       Contact con = new Contact();
        con.LastName = 'test';
        insert con;

        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Contact__c = con.Id;
        insert opp;
        
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
         
        Account acc = new Account();
        acc.Name = 'test';
        acc.Phone = '(123) 456-7890';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.RecordTypeId = accRTId;
        acc1.Phone = '(123) 456-7890';
        acc1.FRN_Facility_Type__c ='Residential Treatment';
        insert acc1;
        
        Patient_Insurance__c pins=new Patient_Insurance__c();
        pins.Opportunity__c=opp.id;
        pins.Insurance_Company__c = acc.Id;
        pins.Accreditation__c = 'JCAHO';
        insert pins;
       
        Insurance_Company_Rate_Adjustment__c icra = new Insurance_Company_Rate_Adjustment__c();
        icra.Insurance_Company__c = acc.Id;
        icra.FRN_Facility__c = acc1.Id;
        icra.In_Network_Rate_Adjustment__c = 10;
        icra.Out_of_Network_Rate_Adjustment__c = 10;
        icra.Active_Date__c = system.today();
        insert icra;
        
        Patient_Contact__c patcon = new Patient_Contact__c();
        patcon.Opportunity__c = opp.id;
        patcon.First_Name__c = 'test';
        patcon.Last_Name__c='test1';
        insert patcon;
        
        Insurance_Benefit__c ibf = new Insurance_Benefit__c();
        ibf.Patient_Insurance__c = pins.Id;
        ibf.Detox_Admit_Co_Payment__c = 10;
        ibf.DTX_Apply_Copay__c = true;
        ibf.DTX_Copay_Type__c = 'Admit';   
        ibf.PHP_Admit_Co_Payment__c = 10;
        ibf.PHP_Apply_Copay__c = true;
        ibf.PHP_Copay_Type__c = 'Admit';   
        insert ibf;
        
        Estimated_Coverage_Days__c est = new Estimated_Coverage_Days__c();
        est.Insurance_Benefit__c = ibf.Id;
        est.FRN_Facility__c = acc1.Id;
        est.DTX_Days__c = 1;
        est.IOP_Days__c = 1;
        est.PHP_Days__c = 1;
        est.RTC_Days__c = 1;
        insert est;
        
        Facility_Program__c fp = new Facility_Program__c();
        fp.FRN_Facility__c = acc1.Id;   
        fp.Name = 'test';
        fp.Program_Length__c = 5;
        fp.Target_EDR__c = 500;
        insert fp;
        
        
        
        Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c();
        paw.Patient_Insurance__c = pins.Id;
        paw.Facility_Program__c = fp.Id;
        paw.Miscellaneous_Fees__c = 2.00;
        paw.Ancillary_Fees__c = 2.00;
        paw.Room_and_Board_Fees__c = 2.00;
        paw.Ancillary_Fees__c = 2.00;
        paw.Num_Days_Detox_DTX__c = 1;
        paw.Num_Days_Residential_Treatment_RTC__c = 1;
        paw.FRN_Facility__c = acc1.Id;
        paw.Num_Days_Partial_Hospitalization_PHP__c = 1;
        paw.Num_Days_Intensive_Outpatient_IOP__c = 1;
        insert paw;
        
        List<Pay_Agreement_Worksheet_Detail__c> pawdList = new List<Pay_Agreement_Worksheet_Detail__c>();
        Pay_Agreement_Worksheet_Detail__c pawd = new Pay_Agreement_Worksheet_Detail__c(Pay_Agreement_Worksheet__c = paw.Id,Level_of_Care__c = 'Detox (DTX)');
        pawdList.add(pawd);
        Pay_Agreement_Worksheet_Detail__c pawd1 = new Pay_Agreement_Worksheet_Detail__c(Pay_Agreement_Worksheet__c = paw.Id,Level_of_Care__c = 'Residential Treatment (RTC)');
        pawdList.add(pawd1);
        Pay_Agreement_Worksheet_Detail__c pawd2 = new Pay_Agreement_Worksheet_Detail__c(Pay_Agreement_Worksheet__c = paw.Id,Level_of_Care__c = 'Partial hospitalization (PHP)');
        pawdList.add(pawd2);
        Pay_Agreement_Worksheet_Detail__c pawd3 = new Pay_Agreement_Worksheet_Detail__c(Pay_Agreement_Worksheet__c = paw.Id,Level_of_Care__c = 'Intensive Outpatient (IOP)');
        pawdList.add(pawd3);
        insert pawdList;
        
        
        
        List<Facility_Program_Level_of_Care__c> fplocList = new List<Facility_Program_Level_of_Care__c>();
        Id fpLOCRTIdDTX = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Detox (DTX)').getRecordTypeId();
        Facility_Program_Level_of_Care__c fploc = new Facility_Program_Level_of_Care__c();
        fploc.Facility_Program__c = fp.Id;
        fploc.Billing_Rate__c = 20;
        fploc.RecordTypeId = fpLOCRTIdDTX;
        fploc.Insurance_Company__c = acc.Id;        
        fplocList.add(fploc);
        
        Id fpLOCRTIdRTC = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Residential Treatment (RTC)').getRecordTypeId();
        Facility_Program_Level_of_Care__c fploc1 = new Facility_Program_Level_of_Care__c();
        fploc1.Facility_Program__c = fp.Id;
        fploc1.Billing_Rate__c = 20;
        fploc1.RecordTypeId = fpLOCRTIdRTC;
        fploc.Insurance_Company__c = acc.Id;
        fplocList.add(fploc1);
        
        Id fpLOCRTIdPHP = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Partial Hospitalization (PHP)').getRecordTypeId();
        Facility_Program_Level_of_Care__c fploc2 = new Facility_Program_Level_of_Care__c();
        fploc2.Facility_Program__c = fp.Id;
        fploc2.Billing_Rate__c = 20;
        fploc2.RecordTypeId = fpLOCRTIdPHP;
        fploc.Insurance_Company__c = acc.Id;
        fplocList.add(fploc2);
        
        Id fpLOCRTIdIOP = Schema.SObjectType.Facility_Program_Level_of_Care__c.getRecordTypeInfosByName().get('Intensive Outpatient (IOP)').getRecordTypeId();
        Facility_Program_Level_of_Care__c fploc3 = new Facility_Program_Level_of_Care__c();
        fploc3.Facility_Program__c = fp.Id;
        fploc3.Billing_Rate__c = 20;
        fploc3.RecordTypeId = fpLOCRTIdIOP;
        fplocList.add(fploc3);
        fploc.Insurance_Company__c = acc.Id;        
        
        Facility_Program_Level_of_Care__c defultFPLOC = new Facility_Program_Level_of_Care__c();
        defultFPLOC.Facility_Program__c = fp.Id;
        defultFPLOC.Billing_Rate__c = 20;
        defultFPLOC.RecordTypeId = fpLOCRTIdRTC;
        defultFPLOC.isDefault__c = true;
        fplocList.add(defultFPLOC);
        insert fplocList;
        
        
        
       //ApexPages.StandardController sc = new ApexPages.StandardController(paw);
         
        //From Pay_Agreement_Worksheet__c 
        PageReference pageRef = Page.PayAgreementWorksheetPage;
        pageRef.getParameters().put('id', paw.id);
        Test.setCurrentPage(pageRef);
        PayAgreementWorksheetCtrl obj = new PayAgreementWorksheetCtrl();
        obj.selectdFRNFacility = acc1.Id; 
          
        obj.selectdFacilityProgram = fp.Id;   
        system.debug('##### test>>>obj.selectdFacilityProgram'+obj.selectdFacilityProgram);    
        obj.getBenefit();
        obj.onBenefitChange();
        obj.getPatient();
        obj.onFRNFacilitySelected();
        obj.selectedBenefit = ibf.Id;
        obj.updateLOCValues();
        obj.onPatientSelected();
        obj.selectdFacilityProgram = fp.Id;   
        obj.updateDetail();
        obj.desableSaveButton();
        obj.saveDetail();
        obj.cancel();
        
                
        //From Opportunity__c
        pageRef = Page.PayAgreementWorksheetPage;
        pageRef.getParameters().put('retURL', '/'+opp.id);
       // pageRef.getParameters().put('retURL', '/'+opp.id);
        Test.setCurrentPage(pageRef);
        obj = new PayAgreementWorksheetCtrl();
        obj.selectdFRNFacility = acc1.Id;       
        obj.selectdFacilityProgram = fp.Id; 
        obj.selectedBenefit = ibf.Id;
        obj.LOCValues.pAWrkSht.Patient_Insurance__c = pins.Id;
        
        obj.getBenefit();
        //obj.getFRNFacilities();
        obj.getPatient();
        obj.onFRNFacilitySelected();        
        obj.selectdFacilityProgram = fp.Id;   
        obj.updateDetail();
        //obj.saveDetail(); 
        
        //From Insurance_Benefit__c
        pageRef = Page.PayAgreementWorksheetPage;
        pageRef.getParameters().put('retURL', '/'+ibf.id);
        Test.setCurrentPage(pageRef);
        obj = new PayAgreementWorksheetCtrl();
        obj.selectdFRNFacility = acc1.Id;       
        obj.selectdFacilityProgram = fp.Id; 
        obj.LOCValues.pAWrkSht.Patient_Insurance__c = pins.Id;
        
        obj.getBenefit();
        //obj.getFRNFacilities();
        obj.getPatient();
        obj.onFRNFacilitySelected();
        obj.selectedBenefit = ibf.Id;
        obj.selectdFacilityProgram = fp.Id;   
        obj.updateDetail();
        obj.getRateAdjustment();
       
        obj.cancelFromOpp();
        
        acc.Name = 'Private Pay';
        acc.Accreditation__c = 'Joint Commission';
        //acc.Facility_Restriction__c = 'test';
        update acc;
        
       // obj.calculateFormula();
        
        paw.Insurance_Benefit__c = ibf.id;
        update paw;
        obj.selectdFacilityProgram = fp.Id; 
        obj.onBenefitChange();
        obj.getBilledRate();

    }
}