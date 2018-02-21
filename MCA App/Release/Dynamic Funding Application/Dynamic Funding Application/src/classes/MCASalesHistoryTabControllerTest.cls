/* 
 * Revision History: Test Class for Sales History tab Controller, tab is on Dynamic Funding 
 * Applicatiuon
 *   
 * Version          Author                          Date                        Description
 * 1.0              Yogesh Mahajan                  26/02/2016                  Initial Draft
 */ 
@isTest
private class MCASalesHistoryTabControllerTest {
    static testMethod void salesHistoryBankValidTest() {
        System.Test.startTest();
            List<Opportunity> lstOpp = createListOpportunity(5);
            insert lstOpp;
            System.assertNotEquals(null, lstOpp);
            
            Account objAcc = createAccount();
            insert objAcc;
            System.assertNotEquals(null, objAcc);
            
            McaApp__Bank_Account__c objBankAccount = createBankRecord(objAcc.Id, lstOpp[0].Id);
            insert objBankAccount;
            System.assertNotEquals(null, objBankAccount);
            
            McaApp__Bank_Account__c objBankAccount1 = createBankRecord(objAcc.Id, lstOpp[0].Id);
            insert objBankAccount1;
            System.assertNotEquals(null, objBankAccount1);
            
            McaApp__Credit_Card__c objCreditCard = createCreditCardRecord(objAcc.Id, lstOpp[0].Id);
            insert objCreditCard;
            System.assertNotEquals(null, objCreditCard);
            
            McaApp__Credit_Card__c objCreditCard1 = createCreditCardRecord(objAcc.Id, lstOpp[0].Id);
            insert objCreditCard1;
            System.assertNotEquals(null, objCreditCard1);
        System.Test.stopTest();
        
        Apexpages.currentPage().getParameters().put('newApplication' , 'false');
        MCASalesHistoryTabController controller = new MCASalesHistoryTabController();
        Apexpages.currentPage().getParameters().put('oppId', lstOpp[0].Id);
        
        objBankAccount.McaApp__Deposits__c = 200;
        objBankAccount.McaApp__Include_in_average__c = false;
        update objBankAccount;
        
        controller.cardAccountList();
        controller.newCredit();
        controller.getContainersCards();
        objCreditCard.McaApp__Number_of_Transactions_All__c = 10;
        update objCreditCard;
        
        controller.bankAccountList();
        controller.newStatement();
        controller.getContainersStatements();
        controller.updateInlineEditedCardValue();
        controller.updateInlineEditedBankValue();
        controller.saveAllSales();
        controller.save();
        controller.editAll();
        controller.indexToRemove =0;
        controller.indexToRemoveCredit = 0;
        controller.indexToRemoveStatement =0;
        controller.removeStatement();
        controller.removeCard();
        controller.recordToDelete= objCreditCard1.Id;
        controller.deleteCredit();
        controller.recordToDelete= objBankAccount1.Id;
        controller.deleteStatement();
        controller.getContainersStatements();
        controller.getContainersCards();
    }
    
    static testMethod void salesHistoryInValidTest() {
        System.Test.startTest();
            List<Opportunity> lstOpp = createListOpportunity(5);
            insert lstOpp;
            System.assertNotEquals(null, lstOpp);
            
            Account objAcc = createAccount();
            insert objAcc;
            System.assertNotEquals(null, objAcc);
            
            McaApp__Bank_Account__c bankAccountInstance = new McaApp__Bank_Account__c();
            bankAccountInstance.McaApp__Deposits__c = 100;
            bankAccountInstance.McaApp__Account__c = objAcc.Id;
            bankAccountInstance.McaApp__Include_in_average__c = false;
            bankAccountInstance.McaApp__Opportunity__c = lstOpp[0].Id;
            insert bankAccountInstance;
        System.Test.stopTest();
        
        Apexpages.currentPage().getParameters().put('newApplication' , 'false');
        MCASalesHistoryTabController controller = new MCASalesHistoryTabController();
        controller.getContainersStatements();
        controller.getContainersCards();
        controller.refresh();
        controller.updateInlineEditedBankValue();
        controller.saveAllSales();
        controller.deleteCredit();
        controller.deleteStatement();
    }
    
    static testMethod void salesHistoryInValid1Test() {
        Apexpages.currentPage().getParameters().put('newApplication' , 'true');
        MCASalesHistoryTabController controller = new MCASalesHistoryTabController();
        controller.newCredit();
        controller.newStatement();
        controller.updateInlineEditedBankValue();
    }
    
    //create test data for opportunity
    public static List<Opportunity> createListOpportunity(Integer pCount) {
        List<Opportunity> lstOpp = new List<Opportunity>();
        for(Integer countOpp =0; countOpp < pCount; countOpp++) {
            Opportunity objOpp = new Opportunity();
            objOpp.Name = 'Test '+countOpp;
            objOpp.CloseDate = System.today(); 
            objOpp.StageName='Prospecting';
            lstOpp.add(objOpp);
        }
        return lstOpp;
    }
    
    //create test data for account
     public static Account createAccount() {
         Account objAcc = new Account(Name = 'Test Account');
         return objAcc;
     }
    
    //create test data for bank account
    public static McaApp__Bank_Account__c createBankRecord(Id accId, Id opportunityId) {
        McaApp__Bank_Account__c bankAccountInstance = new McaApp__Bank_Account__c();
        bankAccountInstance.McaApp__Deposits__c = 100;
        bankAccountInstance.McaApp__Account__c = accId;
        bankAccountInstance.McaApp__Include_in_average__c = true;
        bankAccountInstance.McaApp__Year__c = '1';
        bankAccountInstance.McaApp__Opportunity__c = opportunityId;
        bankAccountInstance.McaApp__Month__c = '5';
        return bankAccountInstance;
    }
    
    //Create test data for credit card sales
    public static McaApp__Credit_Card__c createCreditCardRecord(Id accId, Id opportunityId) {
        
        McaApp__Credit_Card__c creditCardInstance = new McaApp__Credit_Card__c();
        creditCardInstance.McaApp__Account__c = accId;
        creditCardInstance.McaApp__Opportunity__c = opportunityId;
        creditCardInstance.McaApp__Number_of_Transactions_All__c = 15;
        creditCardInstance.McaApp__Year__c = '2';
        creditCardInstance.McaApp__Month__c = '2';
        return creditCardInstance;
    }
}