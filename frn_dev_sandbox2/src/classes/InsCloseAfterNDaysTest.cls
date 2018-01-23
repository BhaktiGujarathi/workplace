@isTest
public class InsCloseAfterNDaysTest
{


    static testMethod void testMethod1()
    {

        date d = system.today().addDays(Integer.valueof(Label.InsCloseAfterNDays.trim()));


        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Prospecting';
        opp.CloseDate = system.today().addDays(15);
        opp.Step_Down__c = False;
        insert opp;

        Patient_Insurance__c pat = new Patient_Insurance__c();
        pat.Date_Benefits_Check_Completed__c = d.addDays(-5);
        pat.Opportunity__c = opp.id;
        pat.VOB_status__c = 'Benefits Submitted';
        insert pat;

        Pay_Agreement_Worksheet__c payAgree =  new Pay_Agreement_Worksheet__c();
        payAgree.Patient_Insurance__c = pat.ID;
        insert payAgree;

        Quote qote = new Quote(name = 'Test',opportunityID = opp.ID);
        qote.Pay_Agreement_Worksheet__c  = payAgree.id;
        insert qote;

        Test.startTest();

           InsCloseAfterScheduler.scheduleMe();

        Test.stopTest();
    }




}