@isTest
private class BankAccountSummaryControllerTest {

    /**
    * Test to load all bank statements on page load, which is not filtered based on Account number
    */
    static testMethod void testAllBankStatementsOnLoadFromOpp() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Bank_Account__c> bankStatements = TestDataUtility.getBankStatements(5);
        for(Bank_Account__c bnkStatmnt : bankStatements) {
            bnkStatmnt.Opportunity__c = opportunity[0].Id;
        }
        insert bankStatements;
        Apexpages.currentPage().getParameters().put('id',opportunity[0].Id);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','false');
        BankAccountSummaryController bnkStatmntController = new BankAccountSummaryController();
        System.assertEquals(5, bnkStatmntController.bankStmntLst.size());
        bankStatements[0].Bank_Account_Number__c = 'PQR12';
        bankStatements[1].Bank_Account_Number__c = ' ';
        update bankStatements;
        System.assertEquals(5, bnkStatmntController.bankStmntLst.size());
    }

    /**
    * Test to load bank statements on page load filter based on bank Account number.
    */
    static testMethod void testfilteredBankStatementsOnLoadFromAccount() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Bank_Account__c> bankStatements = TestDataUtility.getBankStatements(5);
        for(Bank_Account__c bnkStatmnt : bankStatements) {
            bnkStatmnt.Opportunity__c = opportunity[0].Id;
            bnkStatmnt.Bank_Account_Number__c = 'ABC123';
        }
        insert bankStatements;
        bankStatements[0].Bank_Account_Number__c = 'PQR12';
        bankStatements[1].Bank_Account_Number__c = ' ';
        update bankStatements;
        Apexpages.currentPage().getParameters().put('id',null);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','true');
        BankAccountSummaryController bnkStatmntController = new BankAccountSummaryController();
        System.assertEquals(5, bnkStatmntController.bankStmntLst.size());
    }

    /**
     * Test to cover all page functioanlity while load from opportunity
    */
    static testMethod void testBankStatementsFromOpp() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Bank_Account__c> bankStatements = TestDataUtility.getBankStatements(10);
        for(Bank_Account__c bnkStatmnt : bankStatements) {
            bnkStatmnt.Opportunity__c = opportunity[0].Id;
            bnkStatmnt.Bank_Account_Number__c = 'ABC123';
            bnkStatmnt.Month__c = '01 - January';
            bnkStatmnt.Year__c = '2016';
        }
        insert bankStatements;
        bankStatements[0].Bank_Account_Number__c = 'PQR12';
        bankStatements[1].Month__c = '07 - July';
        bankStatements[0].Bank_Account_Number__c = 'PQR12';
        update bankStatements;
        FO_Sales_Summary__c customSetng = new FO_Sales_Summary__c();
        customSetng.Name = 'Sales Summary';
        customSetng.Custom_Bank_Statement_Fieldset_API_Name__c = 'SalesSummaryBankStmnt';
        customSetng.Override_Grid_Bank_Statement_Fieldset__c = true;
        insert customSetng;
        Apexpages.currentPage().getParameters().put('id',opportunity[0].Id);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','false');
        BankAccountSummaryController bnkStatmntController = new BankAccountSummaryController();
        customSetng.Override_Grid_Bank_Statement_Fieldset__c = false;
        update customSetng;
        bnkStatmntController.filterByBankAccountNo();
        bnkStatmntController.getlstBankAccNos();
        System.assertEquals(10, bnkStatmntController.bankStmntLst.size());
        bnkStatmntController.bankAccountNo = 'PQR12';
        bnkStatmntController.refreshBankStatements();
        System.assertEquals(1, bnkStatmntController.bankStmntLst.size());

        bnkStatmntController.showNewPopupBankStmnt();
        bnkStatmntController.newBankStmntLst[0].Bank_Account_Number__c = '--New--';
        bnkStatmntController.setNewOptionBnkPopup();
        bnkStatmntController.updateAllAccountNos = true;
        bnkStatmntController.doneForAllBankStments();

        bnkStatmntController.showNewPopupBankStmnt();
        bnkStatmntController.newBankStmntLst[0].Bank_Account_Number__c = '--New--';
        bnkStatmntController.setNewOptionBnkPopup();
        bnkStatmntController.updateAllAccountNos = false;
        bnkStatmntController.newBankAccountNumber = 'asd';
        bnkStatmntController.newRowIndex = 0;
        bnkStatmntController.newBankStmntLst[bnkStatmntController.newRowIndex ].Bank_Account_Number__c
        = bnkStatmntController.newBankAccountNumber;
        bnkStatmntController.doneForAllBankStments();

        bnkStatmntController.newSaveBankStmnt();
        bnkStatmntController.showNewPopupBankStmnt();
        bnkStatmntController.closeNewBankStmntPopup();
        bnkStatmntController.bankStmntLst[0].Average_Daily_Balance__c = 400;
        bnkStatmntController.errorSaveBankStmnt();
        bnkStatmntController.bankStmntLst[0].Average_Daily_Balance__c = 100;
        bnkStatmntController.errorSaveBankStmnt();
        bnkStatmntController.closeErrorPopup();
        bnkStatmntController.closeBankAccountPopup();
        bnkStatmntController.bankStmntIndexToRemove = 0;
        bnkStatmntController.deleteBankStatement();

        bnkStatmntController.removeNewIndex = 0;
        bnkStatmntController.removeNewRow();
        bnkStatmntController.backToParentRecord();
    }

    /**
     * Test to cover all page functioanlity while load from Account.
    */
    static testMethod void testBankStatementsFromAccount() {
        Account account = new Account(Name='Test Account');
        insert account;
        List<Opportunity> opportunity = TestDataUtility.getOpportunityRecords(1);
        insert opportunity;
        opportunity[0].accountId = account.Id;
        update opportunity[0];
        List<Bank_Account__c> bankStatements = TestDataUtility.getBankStatements(10);
        for(Bank_Account__c bnkStatmnt : bankStatements) {
            bnkStatmnt.Opportunity__c = opportunity[0].Id;
            bnkStatmnt.Bank_Account_Number__c = 'ABC123';
        }
        insert bankStatements;
        bankStatements[0].Bank_Account_Number__c = 'PQR12';
        bankStatements[1].Bank_Account_Number__c = ' ';
        update bankStatements;
        FO_Sales_Summary__c customSetng = new FO_Sales_Summary__c();
        customSetng.Name = 'Sales Summary';
        customSetng.Custom_Bank_Statement_Fieldset_API_Name__c = 'SalesSummaryBankStmnt';
        customSetng.Override_Grid_Bank_Statement_Fieldset__c = true;
        insert customSetng;
        Apexpages.currentPage().getParameters().put('id',null);
        Apexpages.currentPage().getParameters().put('accId',opportunity[0].accountId);
        Apexpages.currentPage().getParameters().put('isAccountView','true');
        BankAccountSummaryController bnkStatmntController = new BankAccountSummaryController();
        customSetng.Override_Grid_Bank_Statement_Fieldset__c = false;
        update customSetng;
        bnkStatmntController.getlstBankAccNos();
        System.assertEquals(10, bnkStatmntController.bankStmntLst.size());
        bnkStatmntController.bankAccountNo = 'PQR12';
        bnkStatmntController.filterByBankAccountNo();
        bnkStatmntController.backToParentRecord();
    }
}