/*************************Details*************************
Test Class Name       :  trgInsertFundingFromOpptyTest
Associated Trigger    :  trgInsertFundingFromOppty
Details               :  Test Class for Trigger trgInsertFundingFromOppty
Any Comment           :  Done
created date          :  25th Sep 2015
Last modified date    :  25th Sep 2015
**********************************************************/
@istest
public class trgInsertFundingFromOpptyTest{

    public static testmethod void trgInsertFundingFromOpptyTest1(){
    
       Opportunity opp = new opportunity(); 
       opp.name='test1';
  //     opp.stagename='Underwriting';
       opp.stagename='Funded';
       opp.closedate=system.today();
       opp.McaApp__Deal_Entry_Wizard_Check__c=false;
       opp.McaApp__Date_Funded__c = system.today().adddays(-400);
       opp.McaApp__Estimated_Renewal_Date__c = system.today();
       opp.McaApp__Funded_Notes__c = 'for test';
       opp.McaApp__Deal_Type__c ='MCA' ;
       opp.McaApp__Funding_Amount__c =1000;
       opp.McaApp__Payback_Amount__c = 1000;
       opp.McaApp__Term_Months__c = 10;
       opp.McaApp__Factor_Rate__c = 20;
       opp.McaApp__Origination_Fee__c = 100;
       opp.McaApp__Holdback_Percentage__c = 10;
       opp.McaApp__Schedule__c = 'Weekly';
       Test.StartTest();
       insert opp; 
       
           system.assertnotequals(opp.id,null);
           
           PreventOpptyTriggerTwice.firstRun =false;  
           opp.McaApp__Deal_Entry_Wizard_Check__c=true;
           update opp;
           
           Funding_Information__c fi = new Funding_Information__c();  
           fi.Related_Opportunity__c=opp.id;
           fi.Payback_Amount__c = opp.McaApp__Payback_Amount__c;
           fi.Date_Funded__c = opp.McaApp__Date_Funded__c;
           fi.Estimated_Renewal_Date__c=opp.McaApp__Estimated_Renewal_Date__c;
           fi.Bank_Name__c = opp.McaApp__Bank_Name__c;
           fi.Deal_Type__c = opp.McaApp__Deal_Type__c;
           fi.Funding_Amount__c = opp.McaApp__Funding_Amount__c;
           fi.Payback_Amount__c = opp.McaApp__Payback_Amount__c;
           fi.Term_Months__c = opp.McaApp__Term_Months__c;
           fi.Factor_Rate__c = opp.McaApp__Factor_Rate__c;
           fi.Origination_Fee__c = opp.McaApp__Origination_Fee__c;
           fi.Holdback_Percentage__c = opp.McaApp__Holdback_Percentage__c;
           fi.Schedule__c = opp.McaApp__Schedule__c;
           insert fi;
           
           system.assertnotequals(fi.id,null);
       Test.StopTest();
      
    
    }
    
}