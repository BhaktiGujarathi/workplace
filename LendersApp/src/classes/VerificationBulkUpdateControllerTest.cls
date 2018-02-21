@isTest
private class VerificationBulkUpdateControllerTest {

    private static Account createAccount() {
        
        // recordtype for account 
        RecordType rcrdtypObj = [Select Id, Name, SobjectType 
                                 From RecordType 
                                 Where name = 'Bank' 
                                 And SobjectType = 'Account'];
        
        Account accountObj = new Account();
        accountObj.Name = 'AccountTest';
        accountObj.RecordtypeId = rcrdtypObj.Id;
        
        return accountObj;
    }
    
    private static Opportunity createOpportunity(Id pAccountId) {

        Opportunity opportunityObj = new Opportunity();
        opportunityObj.Name = 'OpportunityTest'; 
        opportunityObj.AccountId = pAccountId;
        opportunityObj.CloseDate = System.Today()+20;
        opportunityObj.StageName = 'Prospecting';
        
        
        return opportunityObj;
    }
    
    private static VerificationMaster__c createMaster() {

        VerificationMaster__c masterObj = new VerificationMaster__c ();
        masterObj.Name = 'MasterTest';
        
        return masterObj;
    }
    
    private static List<UWVerification__c> createVerification(Integer pCount, Id pOpportunityId, Id pMasterId) {

        List<UWVerification__c> VerificationLst = new List<UWVerification__c>();
         
        for (Integer i = 0; i < pCount; i++) {

            UWVerification__c verificationObj = new UWVerification__c();
            verificationObj.Name = 'VerificationTest';
            verificationObj.Opportunity__c = pOpportunityId;
            verificationObj.VerificationMaster__c = pMasterId;
            verificationObj.Stage__c = 'Underwriting';
            verificationObj.Status__c ='In Progress';
            VerificationLst.add(verificationObj);
        }
        
        return VerificationLst;
    }
    
    private static List<VBUDefaultFilters__c> createDefaultFilter(Integer pCount) {

        List<VBUDefaultFilters__c> listDefaultFilter = new List<VBUDefaultFilters__c>();
        
        for (Integer i = 0; i < pCount; i++) {

            VBUDefaultFilters__c defaultFilter = new VBUDefaultFilters__c();
            defaultFilter.Name ='Default Filter';
            //defaultFilter.StageFilter__c = true;
            defaultFilter.StatusFilter__c = 'Pending';
            listDefaultFilter.add(defaultFilter);
        }

        return listDefaultFilter;
    }
    
    @isTest
    public static void testInitMethod() { 
                
        Account objAccount = VerificationBulkUpdateControllerTest.createAccount();
        insert objAccount;
        
        Opportunity objOpportunity = VerificationBulkUpdateControllerTest.createOpportunity(objAccount.Id);
        insert objOpportunity;
        
        VerificationMaster__c objMaster = VerificationBulkUpdateControllerTest.createMaster();
        insert objMaster;
        
        List<UWVerification__c> lstVerification = VerificationBulkUpdateControllerTest.createVerification(5, objOpportunity.Id, objMaster.Id);
        insert lstVerification;
        
        List<VBUDefaultFilters__c> lstDefaultFilter = VerificationBulkUpdateControllerTest.createDefaultFilter(1);
        insert lstDefaultFilter;
    
        test.startTest();
             
        //Test.setCurrentPage(pageRef);
        ApexPages.StandardsetController controller = new ApexPages.StandardsetController(lstVerification);
        
        VerificationBulkUpdateController cntrllrObj = new VerificationBulkUpdateController(controller);
        pageReference pageRef = page.VerificationBulkUpdate;

        pageRef.getParameters().put('Id',objOpportunity.Id);
        //cntrllrObj.actionLink = pageRef;
        cntrllrObj.myVerifications = true;
        cntrllrObj.selectedstage = 'Underwriting';
        //cntrllrObj.selectedstatus =lstDefaultFilter[0].StageFilter__c ;
        List<VerificationBulkUpdateController.VerificationWrapper> wrprList = new List<VerificationBulkUpdateController.VerificationWrapper>();
    
        for(Integer i = 0; i <= lstVerification.size(); i++) {
           
           VerificationBulkUpdateController.VerificationWrapper wrapperObj = new VerificationBulkUpdateController.VerificationWrapper(lstVerification[0], 0);
           wrprList.add(wrapperObj);
        }
    
        List<String> stageList = cntrllrObj.verificationStages;
        List<String> statusList = cntrllrObj.verificationStatus;
        
        cntrllrObj.init();
        cntrllrObj.saveVerifications();
        cntrllrObj.applyFilter();
        cntrllrObj.clearFilter();
        cntrllrObj.verificationWrapperLst = wrprList;
        //cntrllrObj.saveVerifications();
        cntrllrObj.updateRecords();
                  
        test.stopTest();
    }

}