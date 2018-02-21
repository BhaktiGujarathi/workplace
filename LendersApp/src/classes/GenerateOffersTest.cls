@isTest
private class GenerateOffersTest {

    private static Opportunity opp = null;
    private static Account account = null;
    private static ProgramMaster__c pMaster = null;
    
    @isTest
    public static void myUnitTest() {

        // TO DO: implement unit test
        createAccount();
        createProgramMaster();
        createOpportunity();
        GenerateOffers.processDetails(opp.id);
    }

    private static void createOpportunity() {

        opp = new Opportunity();
        opp.Name =  'TestOpp';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = Date.today();
        opp.AccountId = account.Id;
        opp.McaApp__ISO__c = account.Id;
        opp.Terms_to_Offer__c = '02';
        opp.ProgramType__c = 'MCA';
        opp.Deal_Rating__c = 'A';
        opp.McaApp__Credit_Score__c = 500;
        opp.McaApp__Gross_monthly_Sales__c = 5000;
        opp.McaApp__Funding_Amount__c = 100;
        opp.Open_Positions__c = 2;
        insert opp;

    }

    private static void createAccount() {

        account = new Account();
        account.Name = 'Test Account'; 
        RecordType[] rt = [SELECT Id, Name, SobjectType, DeveloperName FROM RecordType WHERE Name = 'Bank' AND SobjectType = 'Account'];
        account.RecordType = rt[0];
        account.McaApp__Years_in_Business__c = 5;

        insert account;
    }

    private static void createProgramMaster() {

        pMaster = new ProgramMaster__c();
        pMaster.Active__c = true;
        pMaster.Term__c = 2;
        pMaster.Program_Type__c = 'MCA';
        pMaster.DealScore__c = 'A';
        pMaster.Min_Credit_Score__c = 500;
        pMaster.Min_Monthly_Gross_Sales__c = 5000;
        pMaster.Min_Time_in_business__c = 5;
        pMaster.Min_Offer_Amount__c = 100;
        
        insert pMaster;
    }
}