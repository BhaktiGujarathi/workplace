@isTest
public with sharing class UpdateUserWorkloadTest {
    
    @testSetup
    public static void createLeads() {
        
        Sales_Rep_Report_Card__c scoreCard = new Sales_Rep_Report_Card__c();
        scoreCard.Sales_Rep__c = UserInfo.getUserId();
        insert scoreCard;

        //Lead l = new Lead();
        //l.FirstName = 'Test';
        //l.LastName = 'Lead';
        //l.Company = 'ACME';
        //l.Phone = '(323) 319-3663';
        //insert l;
    }


    @isTest
    public static void UpdateUserWorkloadTest() {
       
        
        Test.startTest();
        
            Lead l = new Lead();
            l.FirstName = 'Test';
            l.LastName = 'Lead 2';
            l.Company = 'ACME';
            l.Phone = '(323) 319-3663';
            insert l;

        Test.stopTest();

        Sales_Rep_Report_Card__c scoreCard = [SELECT Lead_Count__c FROM Sales_Rep_Report_Card__c WHERE Sales_Rep__c = :UserInfo.getUserId()];
        System.assertEquals(1, scoreCard.Lead_Count__c);
    }
}