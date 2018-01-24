@isTest
private class MerchantStatementSummaryControllerTest {

    /**
    * Test to load all bank statements on page load, which is not filtered based on Account number
    */
    static testMethod void testAllMerchntStatementsOnLoadFromOpp() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Credit_Card__c> merchStatements = TestDataUtility.getMerchntStatements(5);
        for(Credit_Card__c mrchStatmnt : merchStatements) {
            mrchStatmnt.Opportunity__c = opportunity[0].Id;
        }
        insert merchStatements;
        Apexpages.currentPage().getParameters().put('id',opportunity[0].Id);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','false');
        MerchantStatementSummaryController mrchntStatmntController = new MerchantStatementSummaryController();
        System.assertEquals(5, mrchntStatmntController.merchantStatements.size());
        merchStatements[0].MID_Account_Number__c = 'PQR12';
        merchStatements[1].MID_Account_Number__c = ' ';
        update merchStatements;
        System.assertEquals(5, mrchntStatmntController.merchantStatements.size());
    }

    /**
    * Test to load bank statements on page load filter based on bank Account number.
    */
    static testMethod void testfilteredMerchntStatementOnLoadFromAccount() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Credit_Card__c> merchStatements = TestDataUtility.getMerchntStatements(5);
        for(Credit_Card__c mrchStatmnt : merchStatements) {
            mrchStatmnt.Opportunity__c = opportunity[0].Id;
        }
        insert merchStatements;
        merchStatements[0].MID_Account_Number__c = 'PQR12';
        merchStatements[1].MID_Account_Number__c = ' ';
        update merchStatements;
        Apexpages.currentPage().getParameters().put('id',null);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','true');
        MerchantStatementSummaryController mrchntStatmntController = new MerchantStatementSummaryController();
        //System.assertEquals(5, mrchntStatmntController.merchantStatements.size());
    }

    /**
     * Test to cover all page functioanlity while load from opportunity
    */
    static testMethod void testMerchntStatementFromOpp() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Credit_Card__c> merchntStmnts = TestDataUtility.getMerchntStatements(10);
        for(Credit_Card__c merchntStmnt : merchntStmnts) {
            merchntStmnt.Opportunity__c = opportunity[0].Id;
            merchntStmnt.MID_Account_Number__c = 'ABC123';
            merchntStmnt.Month__c = '01 - January';
            merchntStmnt.Year__c = '2016';
        }
        insert merchntStmnts;
        merchntStmnts[0].MID_Account_Number__c = 'PQR12';
        merchntStmnts[1].Month__c = '07 - July';
        merchntStmnts[0].MID_Account_Number__c = 'PQR12';
        update merchntStmnts;
        FO_Sales_Summary__c customSetng = new FO_Sales_Summary__c();
        customSetng.Name = 'Sales Summary';
        customSetng.Custom_Merchant_Statement_Fieldset_API_N__c	 = 'GRIDCreditCardFieldSet';
        customSetng.Override_Grid_Merchant_Statement_Fieldse__c = true;
        insert customSetng;
        Apexpages.currentPage().getParameters().put('id',opportunity[0].Id);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','false');
        MerchantStatementSummaryController mrchntStatmntController = new MerchantStatementSummaryController();
        customSetng.Override_Grid_Merchant_Statement_Fieldse__c = false;
        update customSetng;
        mrchntStatmntController.filterBasedOnMidNo();
        mrchntStatmntController.getmidAccountNos();
        System.assertEquals(10, mrchntStatmntController.merchantStatements.size());
        mrchntStatmntController.midAccountNo = 'PQR12';
        mrchntStatmntController.refreshMerchantStatements();
        System.assertEquals(1, mrchntStatmntController.merchantStatements.size());

        mrchntStatmntController.showNewPopup();
        mrchntStatmntController.newmerchantStatements[0].MID_Account_Number__c = '--New--';
        mrchntStatmntController.setNewOptionPopup();
        mrchntStatmntController.updateAllAccountNos = true;
        mrchntStatmntController.doneForAllMerchntStmnt();

        mrchntStatmntController.showNewPopup();
        mrchntStatmntController.newmerchantStatements[0].MID_Account_Number__c = '--New--';
        mrchntStatmntController.setNewOptionPopup();
        mrchntStatmntController.updateAllAccountNos = false;
        mrchntStatmntController.newMidAccountNumber = 'asd';
        mrchntStatmntController.newRowIndex = 0;
        mrchntStatmntController.newmerchantStatements[mrchntStatmntController.newRowIndex ].MID_Account_Number__c
        = mrchntStatmntController.newMidAccountNumber;
        mrchntStatmntController.doneForAllMerchntStmnt();

        mrchntStatmntController.newSave();
        mrchntStatmntController.showNewPopup();
        mrchntStatmntController.closeNewPopup();
        mrchntStatmntController.errorSave();
        mrchntStatmntController.closeErrorPopup();
        mrchntStatmntController.closeMIDAccountUpdate();
        mrchntStatmntController.merchantStmntIndexToRemove = 0;
        mrchntStatmntController.deleteMerchntStatement();

        mrchntStatmntController.removeNewIndex = 0;
        mrchntStatmntController.removeNewRow();
        mrchntStatmntController.backToParentRecord();
    }

    /**
     * Test to cover all page functioanlity while load from Account.
    */
    static testMethod void testmerchntStatementsFromAccount() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Credit_Card__c> mrchntStatements = TestDataUtility.getMerchntStatements(10);
        for(Credit_Card__c mrchntStatmnt : mrchntStatements) {
            mrchntStatmnt.Opportunity__c = opportunity[0].Id;
            mrchntStatmnt.MID_Account_Number__c = 'ABC123';
        }
        insert mrchntStatements;
        mrchntStatements[0].MID_Account_Number__c = 'PQR12';
        mrchntStatements[1].MID_Account_Number__c = ' ';
        update mrchntStatements;
        FO_Sales_Summary__c customSetng = new FO_Sales_Summary__c();
        customSetng.Name = 'Sales Summary';
        customSetng.Custom_Merchant_Statement_Fieldset_API_N__c	 = 'GRIDCreditCardFieldSet';
        customSetng.Override_Grid_Merchant_Statement_Fieldse__c = true;
        insert customSetng;
        Apexpages.currentPage().getParameters().put('id',null);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','true');
        MerchantStatementSummaryController mrchntStatmntController = new MerchantStatementSummaryController();
        customSetng.Override_Grid_Merchant_Statement_Fieldse__c = false;
        update customSetng;
        mrchntStatmntController.getmidAccountNos();
        System.assertEquals(10, mrchntStatmntController.merchantStatements.size());
        mrchntStatmntController.midAccountNo = 'PQR12';
        mrchntStatmntController.filterBasedOnMidNo();
        mrchntStatmntController.backToParentRecord();
    }
}