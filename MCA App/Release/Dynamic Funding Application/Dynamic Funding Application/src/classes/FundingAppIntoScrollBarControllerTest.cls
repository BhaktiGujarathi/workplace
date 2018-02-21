/* 
*  Test class for Funding Application Page Displayed in Scroll bar.
*  Revision History: 
* 
*  Version           Author                 Date                 Description 
*  1.0               Yogesh Mahajan         12-Jan-2016           Initial Draft[]
**/


@isTest
private class FundingAppIntoScrollBarControllerTest {

    static testMethod void multipleAccountTest() {
        List<Account> listAccToInsert = createAccountRecord(10);
        insert listAccToInsert;
        FundingAppIntoScrollBarController controllerInstance = new FundingAppIntoScrollBarController();
        
        controllerInstance.searchTextBoxValue = 'Test';
        controllerInstance.searchAccountValue();
        System.assertEquals(true, controllerInstance.flag);
        
        controllerInstance.searchTextBoxValue = 'NewSearch';
        controllerInstance.searchAccountValue();
        System.assertEquals(false, controllerInstance.flag);
        System.assertEquals(true, controllerInstance.showMsg);
        
        controllerInstance.displayMultipleAccount();
        controllerInstance.getlistAccounts();
        controllerInstance.displayFundingApplication();
    }
    
    static testMethod void singleAccountTest() {
        Account accObj = new Account();
        accObj.Name = 'AccountTest';
        accObj.Phone = '1245';
        insert accObj;
        System.assertNotEquals(null, accObj.Id);
        FundingAppIntoScrollBarController controllerInstance = new FundingAppIntoScrollBarController();
        controllerInstance.searchTextBoxValue = 'AccountTest';
        controllerInstance.searchAccountValue();
        System.assertEquals(true, controllerInstance.isValue);
        controllerInstance.searchTextBoxValue = '';
        controllerInstance.searchAccountValue();
        controllerInstance.displayFundingApplication();
    }
    
    public static List<Account> createAccountRecord(integer pCount) {
        List<Account> listAccount = new List<Account>();
        for(Integer accCount = 0; accCount <= pCount; accCount++ ) {
            Account accObj = new Account();
            accObj.Name = 'Test'+accCount;
            accObj.Phone = '123456';
            accObj.Website = 'www.test.com';
            accObj.McaApp__Legal_Name__c = 'TestLegal';
            listAccount.add(accObj);
        }
        return listAccount;
    }
}