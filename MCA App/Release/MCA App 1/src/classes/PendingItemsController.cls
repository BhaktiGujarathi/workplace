/*
    Author : Vasu Takasi
    Created On : 22nd July 2013
    Class Name : PendingItemsController
    Description : Used in the page called PendingItemsVF 
*/
public with sharing class PendingItemsController {
    public list<Bank_Account__c> lstPendingBankAcc{get;set;}//used to get pending Items 
    public list<Credit_Card__c> lstPendingCreditCards{get;set;}//used to get pending Items
    string accId;
    public String Bankaccountid{get;set;}//used to hold bankaccountid from page 
    public String Creditcardid{get;set;}//used to hold creditcardid from page 
    public String RecType{get;set;}//Record Type added on 8/22/2013
    public String indexofrow{get;set;}//added on 8/22/2013     
    public PendingItemsController(){
        if(ApexPages.currentPage().getParameters().get('id') != Null ){
            accId = ApexPages.currentPage().getParameters().get('id');
        }
        lstPendingBankAcc = new list<Bank_Account__c>();
        lstPendingCreditCards = new list<Credit_Card__c>();
        if(accId != Null && accId != ''){
            lstPendingBankAcc = [select id,name,year__c,month__c,remove__c,Bank_Account_Number__c,Deposits__c,Average_Daily_Balance__c,Number_of_Negative_Days__c,Number_of_NSFs__c,Data_Request__c,Matching_App__c from Bank_Account__c where Account__c = : accId 
                                And (Deposits__c = Null OR Average_Daily_Balance__c = Null OR Number_of_Negative_Days__c = NUll OR Number_of_NSFs__c = Null OR Business_Owner_Name_Same_as_App__c = False OR Address_Same_as_Biz_Home_Address__c = False) Order By Year__c,Month__c];
                                
            lstPendingCreditCards = [select id,name,year__c,month__c,Matching_App__c,Processor_Name__c,remove__c,MID_Account_Number__c ,Number_of_Transactions_All__c,Number_of_Transactions_AMEX_only__c,Total_Net_Processed_All__c,Total_Net_Processed_AMEX_only__c,Data_Request__c
                                    from Credit_Card__c where Account__c = :accId AND (Number_of_Transactions_All__c = Null OR Number_of_Transactions_AMEX_only__c = Null OR Total_Net_Processed_All__c = Null OR Total_Net_Processed_AMEX_only__c = Null) Order By Year__c,Month__c];
                                                                    
        }
    }
    //redirect to BankAccountSummaryVF
    public pageReference redirectSummaryVF(){
        PageReference ref = new pageReference('/apex/BankAccountWizardsummaryVF?id='+accId);
        ref.setRedirect(true);
        return ref;
    }
    
    //upadte BA Records
    Public void updateBankAccounts(){
      try{  
        if( lstPendingBankAcc.size()>0 )
            update lstPendingBankAcc;
      }
      catch(exception e){
        ApexPages.AddMessages(e);
      }
      updateCreditCards(); // Adde by : Ankush : Date :16/09/2013--> added for calling Save the creditcard details.
    }
    //upadte CC Records
    Public void updateCreditCards(){
      try{  
        if( lstPendingCreditCards.size()>0 )
            update lstPendingCreditCards;
      }
      catch(exception e){
        ApexPages.AddMessages(e);
      }
    }
    //Removing and Updating BankAccounts or Credit cards from page    added on 8/22/2013
    public void upadateremovebankcredit(){
        System.debug('Bankaccountid:'+Bankaccountid);
        System.debug('Type:'+RecType);
        System.debug('CreditcardId:'+Creditcardid);
        if(RecType=='bank' && Bankaccountid!=null){ 
                Bank_Account__c bankobj=new Bank_Account__c(id=Bankaccountid,Remove__c=true);
                update bankobj;           
                lstPendingBankAcc.remove(integer.valueOf(indexofrow));
        }
        else if(RecType=='credit' && Creditcardid!=null){
                Credit_Card__c creditobj=new Credit_Card__c(id=Creditcardid,Remove__c=true);
                update creditobj;
                lstPendingCreditCards.remove(integer.valueOf(indexofrow));
            
        }
        
    }
    
}