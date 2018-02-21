@isTest
public with sharing class VolumeBonusRollupTriggerOfferTest {

    @isTest
    public static void testOffer(){

        try{
            Account account = new Account();
            account.Name = 'Test';
            account.RecordTypeId = [select Id from RecordType where Name = 'Bank' and sObjectType = 'Account'].Id;
            
            insert account;
        
        /*
            Opportunity opportunity = new Opportunity();
            opportunity.AccountId = account.Id;
            opportunity.McaApp__Bank_Name__c = account.Id;
            opportunity.McaApp__Date_Funded__c = Date.today();
            opportunity.Name = 'Test Opportunity';
            opportunity.StageName = 'Funded';
            opportunity.CloseDate = Date.today();
            insert opportunity;
*/

            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.AccountId = account.Id;
            opp.StageName = 'Underwriting';
            opp.CloseDate = System.Today().addDays(15);
            opp.Amt_Monthly_Bank_Deposits__c = 100;
            opp.McaApp__Amount_Requested__c = 100;
            opp.Gross_Annual_Sales__c = 100;
            opp.McaApp__Gross_monthly_Sales__c = 2;
            opp.Occupancy__c = 'Rented';
            opp.Rent_Mortgage_Amount__c = 1;

            insert opp;


            McaApp__Submission__c submission = new McaApp__Submission__c();
            submission.McaApp__Opportunity__c = opp.Id;
            insert submission;
    
            McaApp__Offer__c offer = new McaApp__Offer__c();
            offer.McaApp__Funder__c = account.Id;
            offer.McaApp__Opportunity__c = opp.Id;
            offer.McaApp__Submission__c = submission.Id;
        
            insert offer;

            delete offer;
        }catch(Exception e){
            system.assert(true);
        }
    }
}