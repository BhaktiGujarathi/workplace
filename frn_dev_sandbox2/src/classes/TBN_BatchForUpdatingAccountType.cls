/*
    Class Name : TBN_BatchForUpdatingAccountType
    Created By : Aditya 
    Created on : 01-04-2015
    Description: Batch Class to update the Update the Type field of Account from 'Active' to 'Inactive' that has been created more than 90 days.
*/
global class TBN_BatchForUpdatingAccountType implements Database.Batchable<sObject>
{
    //Batch Constructor
    global TBN_BatchForUpdatingAccountType()
    {
        //Do Nothing
    }
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        String query = 'SELECT Id,Type, (SELECT Id,Account__c,CreatedDate FROM Referrals__r where RecordType.Name=\'Inbound Referral\' ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Account.Type = \'Active\'';
        return Database.getQueryLocator(query);
    }
   
    //Execute Method
    global void execute(Database.BatchableContext BC, List<Account> lstAccount)
    {
         //Create a list of Account records to update
         list<Account> lstAccountsToUpdate = new list<Account>();
         
         //Date Time variable to hold date and time 90 days before
         Datetime last90Days = Datetime.now().addDays(-90); 
         
         //Iterate on the Account and make the Account type Inactive for the Referral created greater than 90 days
         for(Account objAccount : lstAccount)
         {
             if(objAccount.Referrals__r==null || objAccount.Referrals__r.isEmpty())
             {
                    objAccount.Type = 'Inactive';
                    
                    //Adding it to a list 
                    lstAccountsToUpdate.add(objAccount);
             }
             else
             {
                 //Iterate over the Referral records to fetch the referrals pertaining to that Active Account
                 for(Referral__c  objReferral : objAccount.Referrals__r)
                 {  
                    //Comparision
                    if(objReferral.CreatedDate < last90Days)                 
                    {                 
                        objAccount.Type = 'Inactive';
                    
                        //Adding it to a list 
                        lstAccountsToUpdate.add(objAccount);
                    }
                 }
             }
          }            
         
         //Perform DML operations
         if(!lstAccountsToUpdate.isEmpty())
            update lstAccountsToUpdate;
    }
    
    //Finish Method
    global void finish(Database.BatchableContext BC)
    {
        
    }
}