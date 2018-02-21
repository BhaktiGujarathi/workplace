/* 
 * Revision History: Test Class for Loan Balance tab Controller, tab is on Dynamic Funding 
 * Applicatiuon
 *   
 * Version          Author                          Date                        Description
 * 1.0              Yogesh Mahajan                  26/02/2016                  Initial Draft
 */ 

@isTest
private class MCALoanBalanceTabControllerTest {
    
    static testMethod void loanBalanceValidTest() {
        System.Test.startTest();
	        List<Opportunity> lstOpp = MCALoanBalanceTabControllerTest.createListOpportunity(5);
	        insert lstOpp;
	        System.assertNotEquals(null, lstOpp);
	        Account objAcc = MCALoanBalanceTabControllerTest.createAccount();
	        insert objAcc;
	        System.assertNotEquals(null, objAcc);
	        
	        List<McaApp__Loan_Balance__c> listLoanBalance = MCALoanBalanceTabControllerTest.createLoanBalance(2, lstOpp[0].Id, objAcc.Id);
	        insert listLoanBalance;
	        System.assertNotEquals(null, listLoanBalance);
	    System.Test.stopTest();
        
        Apexpages.currentPage().getParameters().put('newApplication', 'false');
        MCALoanBalanceTabController controller = new MCALoanBalanceTabController();
        Apexpages.currentPage().getParameters().put('oppId', lstOpp[0].Id);
        
        controller.loanBalanceList();
        controller.newLoanBalance();
        controller.getContainers();
        controller.saveMessage();
        
        listLoanBalance[0].McaApp__Active__c = false;
        listLoanBalance[0].McaApp__Balance__c = 41;
        update listLoanBalance[0];
        controller.newLoanBalance();
        controller.updateInlineEditedValue();
        controller.editAll();
        List<RecordType> bankRecordTypeId = [Select Name, Id From RecordType where Name = 'Bank'];
        controller.getBankNames();
        controller.refresh();
        controller.save();
        controller.saveAllLoans();
        controller.indexToRemove  = 1;
        controller.recordToDelete =listLoanBalance[0].Id;
        controller.removeLoanBalance();
        controller.deleteLoanBalance();
        controller.getContainers();
    }

    static testMethod void loanBalanceInValidTest() {
        Apexpages.currentPage().getParameters().put('newApplication', 'true');
        MCALoanBalanceTabController controller = new MCALoanBalanceTabController();
        controller.saveMessage();
        controller.deleteLoanBalance();
        controller.saveAllLoans();
        controller.newLoanBalance();
        controller.getContainers();
    }
    
    //create test record for opportunity
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
    
    //create test record for Account
     public static Account createAccount() {
         Account objAcc = new Account(Name = 'Test Account');
         return objAcc;
     }
     
    //create test record for loan balance
    public static List<McaApp__Loan_Balance__c> createLoanBalance(Integer pCount, Id  oppId, Id funderId) {
        List<McaApp__Loan_Balance__c> listLoanBalance = new List<McaApp__Loan_Balance__c>();
        for(Integer countOpp =0; countOpp < pCount; countOpp++) {
            McaApp__Loan_Balance__c objLoanBalance = new McaApp__Loan_Balance__c();
            objLoanBalance.McaApp__Opportunity__c = oppId;
            objLoanBalance.McaApp__Funder__c = funderId;
            objLoanBalance.McaApp__Active__c = true;
            objLoanBalance.McaApp__Balance__c = 10;
            listLoanBalance.add(objLoanBalance);
        }
        return listLoanBalance;
    }
}