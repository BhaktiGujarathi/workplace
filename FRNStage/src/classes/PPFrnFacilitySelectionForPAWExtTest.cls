@isTest
private class PPFrnFacilitySelectionForPAWExtTest {

    static testMethod void constructorTestCase() {
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
        
        Patient_Insurance__c pins=new Patient_Insurance__c();
        pins.Opportunity__c=opp.id;
        pins.Insurance_Company__c = acc.Id;
        pins.Accreditation__c = 'JCAHO';
        insert pins;
        
        PageReference pageRef = Page.PPFrnFacilitySelectionForPAWAutoCreation;
        pageRef.getParameters().put('id',pins.id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        Test.setCurrentPage(pageRef);
            PPFrnFacilitySelectionForPAWCreationExt controller = new PPFrnFacilitySelectionForPAWCreationExt();
        Test.stopTest();
    }
    
    static testMethod void fetchPatientInsuranceTestCase() {
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
        acc.RecordTypeId = accRTId;
        insert acc;
        
        Patient_Insurance__c pins=new Patient_Insurance__c();
        pins.Opportunity__c=opp.id;
        pins.Insurance_Company__c = acc.Id;
        pins.Accreditation__c = 'JCAHO';
        insert pins;

        Facility_Program__c fp1 = new Facility_Program__c();
        fp1.FRN_Facility__c = acc.Id;
        fp1.Name = 'test1';
        fp1.Program_Length__c = 5;
        fp1.Is_Private_Pay__c = true;
        fp1.Auto_Add__c = true;
        fp1.Private_Pay_Fee__c = 100;
        insert fp1;
        
        PageReference pageRef = Page.PPFrnFacilitySelectionForPAWAutoCreation;
        pageRef.getParameters().put('id',pins.id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        Test.setCurrentPage(pageRef);
            PPFrnFacilitySelectionForPAWCreationExt controller = new PPFrnFacilitySelectionForPAWCreationExt();
            controller.fetchPatientInsurance(pins.id);
            Map<Id, Account> accountDBMap = new Map<Id, Account>();
            accountDBMap = controller.fetchFRNFaciltyDBMap();
            controller.getFrnFacilitySelectList(accountDBMap);
            controller.getPawDetailsWrapperList();
            controller.newPAWDetails();
            controller.pawIndexToRemove = 0;
            controller.removePAWRecord();
            controller.autoAddRecords();
            controller.redirectToPatientInsurance();
        Test.stopTest();
    }
    
    static testMethod void fetchFRNFaciltyDBMapTestCase() {
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
        
        Facility_Program__c fp1 = new Facility_Program__c();
        fp1.FRN_Facility__c = acc1.Id;
        fp1.Name = 'test1';
        fp1.Program_Length__c = 5;
        fp1.Is_Private_Pay__c = true;
        fp1.Auto_Add__c = true;
        fp1.Private_Pay_Fee__c = 100;
        insert fp1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.RecordTypeId = accRTId;
        acc2.Phone = '(123) 456-7890';
        acc2.FRN_Facility_Type__c ='Residential Treatment';
        insert acc2;
        
        Facility_Program__c fp2 = new Facility_Program__c();
        fp2.FRN_Facility__c = acc2.Id;
        fp2.Name = 'test2';
        fp2.Program_Length__c = 5;
        fp1.Is_Private_Pay__c = true;
        fp1.Auto_Add__c = false;
        fp1.Private_Pay_Fee__c = 100;
        insert fp2;
        
        Patient_Insurance__c pins=new Patient_Insurance__c();
        pins.Opportunity__c=opp.id;
        pins.Insurance_Company__c = acc.Id;
        pins.Accreditation__c = 'JCAHO';
        insert pins;
        
        Default_Pricebook__c pricebookName = new Default_Pricebook__c(Name = 'FRN Price Book',Default_Pricebook_Name__c = 'FRN Price Book');
        insert pricebookName;
        
        Pricebook2 prod = new Pricebook2(Name = pricebookName.Default_Pricebook_Name__c);
        insert prod;
        
        PageReference pageRef = Page.PPFrnFacilitySelectionForPAWAutoCreation;
        pageRef.getParameters().put('id',pins.id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        Test.setCurrentPage(pageRef);
            PPFrnFacilitySelectionForPAWCreationExt controller = new PPFrnFacilitySelectionForPAWCreationExt();
            Map<Id, Account> accountDBMap = new Map<Id, Account>();
            accountDBMap = controller.fetchFRNFaciltyDBMap();
            controller.getFrnFacilitySelectList(accountDBMap);
            controller.getPawDetailsWrapperList();
            controller.frnFacilitySelectedIndex = 0;
            controller.pawDetailsWrapperList[0].pawFRNFacility = controller.frnFacilitySelectList[1].getValue();
            controller.getProgramListForFacilitySelected();
            controller.pawDetailsWrapperList[0].pawProgram = controller.pawDetailsWrapperList[0].pawPrgmSelectList[1].getValue();
            controller.facilityPrgrmSelectedId = controller.pawDetailsWrapperList[0].pawPrgmSelectList[1].getValue();
            controller.getPrivatPayFeeForSelectedPrgrm();
            controller.newPAWDetails();
            controller.pawDetailsWrapperList[0].pawFRNFacility = controller.frnFacilitySelectList[1].getValue();
            controller.pawDetailsWrapperList[0].pawProgram = controller.pawDetailsWrapperList[0].pawPrgmSelectList[1].getValue();
            controller.pawDetailsWrapperList[0].pawPrivatePayFee = 1000;
            controller.savePAWRecords();
        Test.stopTest();
    }
    
}