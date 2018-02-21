/*
    Author : Vasu Takasi
    Created On: 20th Jun 2013
    Class Name:AccountLookupController
    Descrition : Used in AccountLookupVF to create new Account for Account Lookup field
*/
public with sharing class AccountLookupController {
    public Account objAccount {get;set;}
    public AccountLookupController(){
        objAccount=new Account();
        assignRecordtype();
    }
    public void assignRecordtype(){
        try{
        RecordType objRecType = [select Id from RecordType where Name = 'Merchant Processor/Bank' and sObjectType = 'Account' and isActive = true];
        if(objRecType.id != Null) 
            objAccount.RecordTypeId = objRecType.Id;
        }   
         catch(exception e){
            ApexPages.addMessages(e);
         }
    }
    public void saveAccount(){
     try{   
        if( objAccount != null ){
            
            insert objAccount;
        }
      }
      catch(exception e)
      {
        ApexPages.addMessages(e);
      } 
    }
}