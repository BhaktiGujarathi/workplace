@isTest
private class CMAFacilityStatusControllerTest {

    static testMethod void constructorTestCase() {
        // Account creation
        List<Account> accList = new List<Account>(); 
        accList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert accList;

        // Case creatation
        Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1);
        tempCase.AccountId = accList[0].Id;
        insert tempCase;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(tempCase);
            CMAFacilityStatusController controller = new CMAFacilityStatusController(stdController);
        Test.stopTest();
    }
    
    static testMethod void getWrapperListTestCase() {
        // Account creation
        List<Account> accList = new List<Account>(); 
        accList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert accList;

        // Case creatation
        Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1);
        tempCase.AccountId = accList[0].Id;
        insert tempCase;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(tempCase);
            CMAFacilityStatusController controller = new CMAFacilityStatusController(stdController);
            controller.getFacilityStatusWrapperList();
        Test.stopTest();
    }
    
    static testMethod void editAllFacilityStatusTestCase() {
        // Account creation
        List<Account> accList = new List<Account>(); 
        accList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert accList;

        // Case creatation
        Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1);
        tempCase.AccountId = accList[0].Id;
        insert tempCase;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(tempCase);
            CMAFacilityStatusController controller = new CMAFacilityStatusController(stdController);
            controller.getFacilityStatusWrapperList();
            controller.editAllFacilityStatus();
        Test.stopTest();
    }
    
    static testMethod void saveFacilityStatusRecordsTestCase() {
        // Account creation
        List<Account> accList = new List<Account>(); 
        accList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert accList;

        // Account creation
        List<Account> newAccList = new List<Account>(); 
        newAccList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert newAccList;

        // Case creatation
        Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1);
        tempCase.AccountId = accList[0].Id;
        insert tempCase;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(tempCase);
            CMAFacilityStatusController controller = new CMAFacilityStatusController(stdController);
            controller.getFacilityStatusWrapperList();
            controller.newFacilityStatusRecord();
            controller.facilityStatusWrapperList[0].facilityStatus.FRN_Facility__c = newAccList[0].Id;
            controller.facilityStatusWrapperList[0].facilityStatus.Status__c = 'Approved';
            controller.saveFacilityStatusRecords();
        Test.stopTest();
    }
    
    static testMethod void refreshFacilityStatusTestCase() {
        // Account creation
        List<Account> accList = new List<Account>(); 
        accList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert accList;
        
        // Case creatation
        Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1);
        tempCase.AccountId = accList[0].Id;
        insert tempCase;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(tempCase);
            CMAFacilityStatusController controller = new CMAFacilityStatusController(stdController);
            controller.getFacilityStatusWrapperList();
            controller.refreshFacilityStatus();
        Test.stopTest();
    }
    
    static testMethod void deleteFacilityStatusTestCase() {
        // Account creation
        List<Account> accList = new List<Account>(); 
        accList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert accList;
        
        // Account creation
        List<Account> newAccList = new List<Account>(); 
        newAccList.add(CMAFacilityStatusTestDataFactory.createAccountOfRecordTypeFRNfacility(1));
        insert newAccList;
        
        // Case creatation
        Case tempCase = CMAFacilityStatusTestDataFactory.createCaseOfRecordTypeCMA(1);
        tempCase.AccountId = accList[0].Id;
        insert tempCase;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(tempCase);
            CMAFacilityStatusController controller = new CMAFacilityStatusController(stdController);
            controller.getFacilityStatusWrapperList();
            controller.newFacilityStatusRecord();
            controller.facilityStatusWrapperList[0].facilityStatus.FRN_Facility__c = newAccList[0].Id;
            controller.saveFacilityStatusRecords();
            controller.facilityStatusIndexToRemove = 0;
            controller.deleteFacilityStatus();
        Test.stopTest();
    }
}