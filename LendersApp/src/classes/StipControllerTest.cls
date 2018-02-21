@isTest
private class StipControllerTest {

    @isTest
    public static void testInitMethod() {


        Account objAccount = StipControllerTest.createAccount();
        insert objAccount;

        Opportunity objOpportunity = StipControllerTest.createOpportunity(objAccount.Id);
        insert objOpportunity;

        VerificationMaster__c objMaster = StipControllerTest.createMaster();
        insert objMaster;

        List<McaApp__Stips__c> lstStip = StipControllerTest.createStip(objOpportunity.Id);
        insert lstStip;

        List<SBUDefaultFilters__c> lstDefaultFilter = StipControllerTest.createDefaultFilter(1);
        insert lstDefaultFilter;

        test.startTest();

        //Test.setCurrentPage(pageRef);
        ApexPages.StandardsetController controller = new ApexPages.StandardsetController(lstStip);

        StipBulkUpdateController  cntrllrObj = new StipBulkUpdateController(controller);
        pageReference pageRef = page.StipBulkUpdate;

        pageRef.getParameters().put('Id',objOpportunity.Id);
        //cntrllrObj.actionLink = pageRef;
        cntrllrObj.myStips = false;
        cntrllrObj.selectedstage = 'Underwriting';
        //cntrllrObj.selectedstatus =lstDefaultFilter[0].StageFilter__c ;
        List<StipBulkUpdateController.StipsWrapper> wrprList = new List<StipBulkUpdateController.StipsWrapper>();

        for (Integer i = 0; i <= lstStip.size(); i++) {

           StipBulkUpdateController.StipsWrapper wrapperObj = new StipBulkUpdateController.StipsWrapper(lstStip[0], 0);
           wrprList.add(wrapperObj);
        }

        List<string> stageList = cntrllrObj.stipStages;
        List<String> statusList = cntrllrObj.stipStatus;

        cntrllrObj.init();
        cntrllrObj.saveStips();
        cntrllrObj.applyFilter();
        cntrllrObj.clearFilter();
        cntrllrObj.stipsWrapperLst = wrprList;
        //cntrllrObj.saveVerifications();
        cntrllrObj.updateRecords();

        test.stopTest();
    }


    private static Account createAccount() {

        // recordtype for account
        RecordType rcrdtypObj = [SELECT Id, Name, SobjectType
                                 FROM RecordType
                                 WHERE Name = 'Bank'
                                 AND SobjectType = 'Account'];

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
        opportunityObj.Underwriting_Stage__c = 'Underwriting';

        return opportunityObj;
    }

    private static VerificationMaster__c createMaster() {

        VerificationMaster__c masterObj = new VerificationMaster__c ();
        masterObj.Name = 'MasterTest';

        return masterObj;
    }

    private static List<McaApp__Stips__c> createStip(Id pOppId) {

        List<McaApp__Stips__c> stiplist = new List<McaApp__Stips__c>();
        McaApp__Stips__c stip = new McaApp__Stips__c();
        stip.McaApp__Opportunity__c = pOppId;
        stipList.add(stip);
        return stipList;
    }

    private static List<SBUDefaultFilters__c> createDefaultFilter(Integer pCount) {

        List<SBUDefaultFilters__c> listDefaultFilter = new List<SBUDefaultFilters__c>();

        for (Integer i = 0; i < pCount; i++) {

            SBUDefaultFilters__c defaultFilter = new SBUDefaultFilters__c();
            defaultFilter.Name = 'Default Filter';
            //defaultFilter.StageFilter__c = true;
            defaultFilter.StatusFilter__c = 'Pending';
            listDefaultFilter.add(defaultFilter);
        }

        return listDefaultFilter;
    }
}