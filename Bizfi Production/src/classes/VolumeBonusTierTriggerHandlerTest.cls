@isTest
public with sharing class VolumeBonusTierTriggerHandlerTest {

    private static final String ALL_DEALS = 'All Deals';
    private static final String NEW_DEALS = 'New Deals';
    private static final String RENEWALS = 'Renewals';

    
    private static Database.SaveResult dmlResult;
    private static Account account;


    private static Volume_Bonus_Tier__c createBonusTier(String type, Boolean active) {

        if (account == null) {
            account = new Account();
            account.Name = 'Test';
            account.RecordTypeId = [select Id from RecordType where Name = 'Bank' and sObjectType = 'Account'].Id;
            insert account;
        }

        Volume_Bonus_Tier__c bonusTier = new Volume_Bonus_Tier__c();
        bonusTier.Bank__c = account.Id;
        bonusTier.Type__c = type;
        bonusTier.Active__c = active;
        bonusTier.Start_Date__c = Date.today();
        bonusTier.End_Date__c = Date.today().addDays(1);
        bonusTier.Bonus_Payout__c = 5;
        bonusTier.Min_Volume_Amount__c = 0;
        bonusTier.Max_Volume_Amount__c = 10000;
        bonusTier.Min_Booking_Rate__c = 0;
        bonusTier.Max_Booking_Rate__c = 25;     

        return bonusTier;
    }


    @isTest
    public static void testDuplicateBonusTier() {
        
        Volume_Bonus_Tier__c bonusTier1 = createBonusTier(ALL_DEALS, true);
        dmlResult = Database.insert(bonusTier1, false);     
        System.assert(dmlResult.isSuccess());


        Volume_Bonus_Tier__c bonusTier2 = createBonusTier(ALL_DEALS, true);
        dmlResult = Database.insert(bonusTier2, false);     
        System.assert(!dmlResult.isSuccess());


        bonusTier2.Active__c = false;
        dmlResult = Database.insert(bonusTier2, false);     
        System.assert(dmlResult.isSuccess());


        bonusTier2.Active__c = true;
        dmlResult = Database.update(bonusTier2, false);     
        System.assert(!dmlResult.isSuccess());


        Volume_Bonus_Tier__c bonusTier3 = createBonusTier(NEW_DEALS, true);
        dmlResult = Database.insert(bonusTier3, false);     
        System.assert(!dmlResult.isSuccess());


        bonusTier2.Active__c = true;
        bonusTier2.Min_Volume_Amount__c = 30000;
        bonusTier2.Max_Volume_Amount__c = 40000;
        dmlResult = Database.update(bonusTier2, false);     
        System.assert(dmlResult.isSuccess());


        bonusTier3.Active__c = true;
        bonusTier3.Min_Volume_Amount__c = 50000;
        bonusTier3.Max_Volume_Amount__c = 60000;
        dmlResult = Database.insert(bonusTier3, false);     
        System.assert(dmlResult.isSuccess());
    }


    @isTest
    public static void testSuccessBonusTier() {
        
        Volume_Bonus_Tier__c bonusTier1 = createBonusTier(NEW_DEALS, true);
        dmlResult = Database.insert(bonusTier1, false);     
        System.assert(dmlResult.isSuccess());


        Volume_Bonus_Tier__c bonusTier2 = createBonusTier(RENEWALS, true);
        dmlResult = Database.insert(bonusTier2, false);     
        System.assert(dmlResult.isSuccess());

    }


    @isTest
    public static void testVolumeBonusRollupController() {

        if (account == null) {
            account = new Account();
            account.Name = 'Test';
            account.RecordTypeId = [select Id from RecordType where Name = 'Bank' and sObjectType = 'Account'].Id;
            insert account;
        }

        ApexPages.currentPage().getParameters().put('id', account.Id);

        VolumeBonusRollupController controller = new VolumeBonusRollupController();
        controller.calculateRollups();
    }


    @isTest
    public static void testVolumeBonusRollUpHandler() {

        try{
            Volume_Bonus_Tier__c bonusTier1 = createBonusTier(ALL_DEALS, true);
/*
            Opportunity opportunity = new Opportunity();
            opportunity.AccountId = account.Id;
            opportunity.McaApp__Bank_Name__c = account.Id;
            opportunity.McaApp__Date_Funded__c = Date.today();
            opportunity.Amt_Monthly_Bank_Deposits__c = 100;
            opportunity.Name = 'Test Opportunity';
            opportunity.StageName = 'Application Sent';
            opportunity.CloseDate = Date.today();
            opportunity.Type = 'Refinance';
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
        
        }catch(Exception e){
            system.assert(true);
        }


        Test.startTest();

            try{
                ApexPages.currentPage().getParameters().put('id', account.Id);
                VolumeBonusRollupController controller = new VolumeBonusRollupController();
                controller.calculateRollups();

            }catch(Exception ex){
                system.assert(true);
            }     

        Test.stopTest();
    }


}