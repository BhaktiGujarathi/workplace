/*
    Class Name : TBN_TestBatchForUpdatingAccount
    Created By : Aditya
    Created on : 01-04-2015
    Description: Test Class for Batch apex class 'TBN_BatchForUpdatingAccountType'
*/
@isTest(SeeAllData = false)
private class TBN_TestBatchForUpdatingAccount 
{
    static testMethod void myUnitTest() 
    {
        //Start a test
        Test.startTest();
        
        RecordType objRecordType = [Select SobjectType, Name, Id From RecordType where SobjectType= 'Referral__c' and Name = 'Inbound Referral' limit 1];
        
       /*  //Create Account Record-1
        Account objAccount1 = new Account();
        objAccount1.Type = 'Active';
        objAccount1.Name = 'Test Account1';
        insert objAccount1;
         */
        /*//Create a Referral Record-1
        Referral__c objReferral1 = new Referral__c();
        objReferral1.Account__c = objAccount1.Id;
        objReferral1.RecordTypeId = objRecordType.Id;
        insert objReferral1;
        
        //Create a Referral Record-2
        Referral__c objReferral2 = new Referral__c();
        objReferral2.Account__c = objAccount1.Id;
        objReferral2.RecordTypeId = objRecordType.Id;
        insert objReferral2;*/
        
        //Create Account Record-2
        Account objAccount2 = new Account();
        objAccount2.Type = 'Active';
        objAccount2.Name = 'Test Account1';
        insert objAccount2;        
        
        //Create a Referral Record-3
        Referral__c objReferral3 = new Referral__c();
        objReferral3.Account__c = objAccount2.Id;
        objReferral3.RecordTypeId = objRecordType.Id;
        insert objReferral3;
        
        //Create a Referral Record-4
        Referral__c objReferral4 = new Referral__c();
        objReferral4.Account__c = objAccount2.Id;
        objReferral4.RecordTypeId = objRecordType.Id;
        insert objReferral4;
        
        //Creating an instance of a batch class 
        TBN_BatchForUpdatingAccountType objRunBatch = new TBN_BatchForUpdatingAccountType();
        Database.executeBatch(objRunBatch);
        system.debug('-------------objAccount2.Type--------' +objAccount2.Type);
        
        //Stop a test
        Test.stopTest();        
    }
}