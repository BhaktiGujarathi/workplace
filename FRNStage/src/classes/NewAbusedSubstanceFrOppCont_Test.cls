@isTest
public class NewAbusedSubstanceFrOppCont_Test {
    
    private static testMethod  void NewAbusedSubstanceFrOppCont_Test(){
        
    Opportunity Opp = new Opportunity();
    Opp.StageName='In Process';
    Opp.Probability=10;
    Opp.CloseDate= system.today();
    Opp.name='test';
    Insert Opp;
    

    
    Abused_Substance__c Asub = new Abused_Substance__c();
    Asub.Opportunity__c= Opp.Id;
    Insert Asub;
    
    NewAbusedSubstanceFrOppCont NAsub = new NewAbusedSubstanceFrOppCont();
    NAsub.save();
    NAsub.Cancel();
    
    }
    }