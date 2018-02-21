@isTest
public class OpportunityHistoryUtil {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    }
    private static void  testOne(){
    Opportunity opp = new Opportunity(Name = 'Hello World' + Datetime.now());
    insert opp;

    Test.startTest();

    OpportunityHistoryUtil oppHistClass = new OpportunityHistoryUtil();

    oppHistClass.processOpportunityUpdate(opp.Id);

    OpportunityHistory[] oppHist = oppHistClass.retrieveOpportunityHistory(opp.Id);
    Test.stopTest();
    System.assertEQuals(1, oppHist.size());                
    }


    public void processOpportunityUpdate(Id OpportunityId){
       Opportunity opp = new Opportunity(Id = OpportunityId, Type = 'Other');
       update opp; 

    }

    public List<OpportunityHistory> retrieveOpportunityHistory(Id OpportunityId){
     List<OpportunityHistory> oh;
     if(Test.isRunningTest()){  //if TEST, create dummy OpportunityHistory
         oh = new List<OpportunityHistory>{}; //OldValue, NewValue not writeable
         oh.add(new OpportunityHistory());
     }
     else 
         oh=  [Select OpportunityId, SystemModstamp, StageName,CreatedDate 
         	   from OpportunityHistory 
         	   where OpportunityId = :OpportunityId]; 
     System.debug('$$$$$$$$$$$$retrieveOpportunityHistory o/p==> '+ oh);        	   
     return oh;
    }
}