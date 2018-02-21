@isTest
public with sharing class TestOpportunityHandler {
    public static testMethod void testStatusUpdate()
    {
        Account objAccount = new Account(Name='Test', Type='Customer - Direct');
        insert objAccount; 
        
        Opportunity objOpportunity = new Opportunity(Name='Opp1', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
        insert objOpportunity;
        
        Opportunity objOpportunity1 = new Opportunity(Name='Opp2', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
        insert objOpportunity1;
        
        Opportunity objOpportunity2 = new Opportunity(Name='Opp3', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
        insert objOpportunity2;
        
        Opportunity objOpportunity3 = new Opportunity(Name='Opp4', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
        insert objOpportunity3;
        
        Contract objContract = new Contract(AccountId=objAccount.Id, Opportunity__c=objOpportunity.Id, Stage__c='Eligible for Renewal' );
        insert objContract;
        
        Contract objContract1 = new Contract(AccountId=objAccount.Id, Opportunity_Renewal__c=objOpportunity1.Id, Stage__c='Eligible for Renewal' );
        insert objContract1;
        
        Contract objContract2 = new Contract(AccountId=objAccount.Id, Opportunity__c=objOpportunity2.Id, Opportunity_Renewal__c=objOpportunity3.Id, Stage__c='Eligible for Renewal' );
        insert objContract2;
        
        Test.startTest();                               
        objOpportunity.StageName = 'Funded';
        update objOpportunity;     
        
        Contract objContract3 = [select c.Stage__c, c.Opportunity__c, c.Id 
                                        FROM Contract c
                                        where c.Id =: objContract.Id limit 1];
        
        System.assertEquals('Funded',objContract3.Stage__c);        
                
        objOpportunity1.StageName = 'Funded';
        update objOpportunity1;
        
        Contract objContract4 = [select c.Stage__c, c.Opportunity__c, c.Id 
                                        FROM Contract c
                                        where c.Id =: objContract1.Id limit 1];
                                        
        System.assertEquals('Closed/Renewed',objContract4.Stage__c);
        
        objOpportunity2.StageName = 'Funded';
        update objOpportunity2;
        objOpportunity3.StageName = 'Funded';        
        update objOpportunity3;
        
        Contract objContract5 = [select c.Stage__c, c.Opportunity__c, c.Id 
                                        FROM Contract c
                                        where c.Id =: objContract2.Id limit 1];
                                        
        System.assertEquals('Closed/Renewed',objContract5.Stage__c);
        
        Test.stopTest();
    }
}