/*************************Details*************************
Test Class Name       :  trgUpdateFundingSectionOfOpportunityTest 
Associated Trigger    :  trgUpdateFundingSectionOfOpportunity
Details               :  Test Class for Trigger trgUpdateFundingSectionOfOpportunity
Any Comment           :  Done
created date          :  25th Sep 2015
Last modified date    :  25th Sep 2015
**********************************************************/
@istest
public class trgUpdateFundingSectionOfOpportunityTest {

    public static testmethod void trgUpdateFundingSectionOfOpportunityTest1(){
    
    RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Vendor' Limit 1];
       account acc=new account(name='test',recordtypeid=rt.id);
       Opportunity opp = new opportunity(); 
       opp.name='test';
       opp.stagename='Funded';
       opp.closedate=system.today();

       opp.McaApp__Payback_Amount__c = 9;
       opp.McaApp__Date_Funded__c = system.today().adddays(-400);
       opp.McaApp__Estimated_Renewal_Date__c=system.today().adddays(-200);
       opp.McaApp__Bank_Name__c = acc.id;
       opp.McaApp__Funded_Notes__c = 'Notes';
       opp.McaApp__Deal_Type__c = 'ACH';
       opp.McaApp__Funding_Amount__c = 500;
       opp.McaApp__Payback_Amount__c = 500;
       opp.McaApp__Term_Months__c = 5;
       opp.McaApp__Factor_Rate__c = 10;
       opp.McaApp__Origination_Fee__c = 50;
       opp.McaApp__Holdback_Percentage__c = 5;
       opp.McaApp__Schedule__c = 'Daily';


       Test.Starttest();
           insert opp; 
           
           system.assertnotequals(opp.id,null);
        
           Funding_Information__c fi = new Funding_Information__c();  
           fi.Related_Opportunity__c=opp.id;
           fi.Date_Funded__c = system.today().adddays(-400);
           fi.Estimated_Renewal_Date__c = system.today();
           fi.Bank_Name__c =acc.id ;
           fi.Funded_Notes__c = 'for test';
           fi.Deal_Type__c ='ACH' ;
           fi.Funding_Amount__c =1000;
           fi.Payback_Amount__c = 1000;
           fi.Term_Months__c = 10;
           fi.Factor_Rate__c = 20;
           fi.Origination_Fee__c = 100;
           fi.Holdback_Percentage__c = 10;
           fi.Schedule__c = 'Daily';
           insert fi; 
           
           system.assertnotequals(fi.id,null);
                
           opp.McaApp__Payback_Amount__c = fi.Payback_Amount__c;
           opp.McaApp__Date_Funded__c = fi.Date_Funded__c;
           opp.McaApp__Estimated_Renewal_Date__c=fi.Estimated_Renewal_Date__c;
           opp.McaApp__Bank_Name__c = fi.Bank_Name__c;
           opp.McaApp__Funded_Notes__c = fi.Funded_Notes__c;
           opp.McaApp__Deal_Type__c = fi.Deal_Type__c;
           opp.McaApp__Funding_Amount__c = fi.Funding_Amount__c;
           opp.McaApp__Payback_Amount__c = fi.Payback_Amount__c;
           opp.McaApp__Term_Months__c = fi.Term_Months__c;
           opp.McaApp__Factor_Rate__c = fi.Factor_Rate__c;
           opp.McaApp__Origination_Fee__c = fi.Origination_Fee__c;
           opp.McaApp__Holdback_Percentage__c = fi.Holdback_Percentage__c;
           opp.McaApp__Schedule__c = fi.Schedule__c;
           update opp;
       Test.Stoptest();  
       
    }

}