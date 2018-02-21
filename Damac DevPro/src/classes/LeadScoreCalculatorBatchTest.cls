@istest
public class LeadScoreCalculatorBatchTest{
    static Database.QueryLocator queryLoc;
    static Database.BatchableContext BC; 
    static List<inquiry__c> leads; 

    static testmethod void leadScoreTests(){
        inquiry__c i = new inquiry__c();
        i.first_name__c ='test';
        i.last_name__c ='test';
        i.inquiry_source__c = 'web';
        i.email__c = 'abc@abc.com'; 
        i.Inquiry_Status__c = 'New';
        insert i;
        
        i.Inquiry_Status__c = 'Active';
        update i;
        
        task t = new task();
        t.whatid = i.id;
        insert t;
        
        
        event e = new event();
        e.whatid = i.id;
        e.DurationInMinutes = 10;
        e.ActivityDateTime = system.today();
        e.ActivityDate = system.today().adddays(-1);
        insert e;
        
       
        
       
        
        list<inquiry__c> leadsToscore = new list<inquiry__c>();
        
        leadsToscore.add(i);
                
        test.starttest();
        invokeBatch(leadsToscore);
        test.stoptest();
    
    
    }
    
    
    static void invokeBatch(List<inquiry__c> allleads){
         LeadScoreCalculatorBatch leadscorebatchcls = new LeadScoreCalculatorBatch();
         queryLoc = leadscorebatchcls.start(BC);
         leadscorebatchcls.execute(BC,allleads);
         leadscorebatchcls.finish(BC);
    }


}