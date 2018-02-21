/* 
*  Apex controller to display button and search text box for Account in salesforce.
*  Revision History: 
* 
*  Version           Author                 Date                 Description 
*  1.0               Yogesh Mahajan         12-Jan-2016           Initial Draft[]
**/

public with sharing class FundingAppIntoScrollBarController {
    
    public string searchTextBoxValue    {get; set;}
    public List<Account> listAccount    {get; set;}
    public List<Account> listAccounts;
    public boolean flag                 {get; set;}
    public Boolean isValue              {get; set;}
    public string AccountName           {get; set;}
    public string errorMessage          {get;set;}
    public boolean showMsg              {get; set;}
    public String theValue              {get;set;}
    
    //constructor
    public FundingAppIntoScrollBarController() {
        searchTextBoxValue = '';
        listAccount = new List<Account>();
        listAccounts = new List<Account>();
        flag = false;
        isValue = false;
        showMsg = false;
        system.debug('getUrl() : '+ApexPages.currentPage().getUrl());
    }// end FundingAppIntoScrollBarController()
    
    //get list account when multiple accounts in list
    public List<Account> getlistAccounts() {
        listAccounts.clear();
        AccountName = ApexPages.currentPage().getParameters().get('pgeRefAccount');
        listAccounts = [SELECT Id
                           , Name
                           , Website
                           , Phone
                           , BillingStreet
                           , BillingCity
                           , BillingCountry
                           , BillingState
                           , BillingPostalCode
                          FROM Account 
                          WHERE Name like :('%'+AccountName+'%') 
                                OR McaApp__Legal_Name__c LIKE :('%'+AccountName+'%')];
        return listAccounts;
    }//end getlistAccounts()
    
    //action of search button to display account which is search
    public void searchAccountValue() {
        listAccount.clear();
        listAccount = [SELECT Id
                             , Name
                             , McaApp__Legal_Name__c
                             , BillingStreet
                             , BillingCity
                             , BillingCountry
                             , BillingState
                             , BillingPostalCode
                          FROM Account 
                          WHERE Name like :('%'+searchTextBoxValue+'%')
                                OR McaApp__Legal_Name__c LIKE :('%'+searchTextBoxValue+'%')];
        
        if(listAccount.size() > 1 && listAccount != null && searchTextBoxValue != null) {
            listAccount.clear();
            isValue = false;
            flag = true;
            showMsg = false;
            
        } else if(listAccount.size() > 0 && searchTextBoxValue != null){
            isValue = true;
            flag = false;
            showMsg = false;
            
        }else if(listAccount == null || listAccount.size() ==0 || searchTextBoxValue != null) {
            showMsg = true;
            isValue = false;
            flag = false;
            errorMessage = 'No match found. Please click New Application.';
        }// end else - if
    }//  end searchAccountValue()
    
    //Displayed list of multiple account after search
    public pageReference displayMultipleAccount() {
        AccountName = ApexPages.currentPage().getParameters().get('NameParamAcc');
        PageReference pageRef = Page.FundingAppMultipleAccount;
        pageRef.getParameters().put('pgeRefAccount', AccountName);
        pageRef.setRedirect(true);
        return pageRef;
    }// end displayMultipleAccount()
    
    //redirect to funding application page when clicked on new application button
    public pageReference displayFundingApplication() {
            
        if(searchTextBoxValue != '' && searchTextBoxValue != null) {
            PageReference newPage = new PageReference('/apex/mcaextension1__Funding_Application_Tab?id=&accId=&newApplication=true&accountName='+searchTextBoxValue+'&rURL='+theValue);
            newPage.setRedirect(true);
            return newPage;
        } else  {
            PageReference newPage = new PageReference('/apex/mcaextension1__Funding_Application_Tab?id=&accId=&newApplication=true&rURL='+theValue);
            newPage.setRedirect(true);
            return newPage;
        }//end else - if
    }// End displayFundingApplication()
}// end class