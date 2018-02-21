@isTest
private class AccountingCalendarMonthTriggerTest{

    static TestMethod void insertAccountingCalendarMonthTest(){

        List<Accounting_Calendar_Month__c> acmList = new List<Accounting_Calendar_Month__c>();

        Test.StartTest();

        for(Integer i = 0; i < 10; i++){
            Accounting_Calendar_Month__c acm = new Accounting_Calendar_Month__c();

            acmList.add(acm);            
        }
        
        insert acmList;

        for(Integer i = 0; i < 5; i++){        
        
            acmList[i].locked__c = true;

            update acmList;        
        }

        delete acmList[0];

        Test.StopTest();

    }

}