@isTest
public class PsyTreatmentHistoryHandlerTest{
    
    public static TestMethod void PsyTreatmentHistoryHandler_UnitTest(){
      
        Contact con = new Contact();
        con.lastName ='test';
        insert con;
    
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Contact__c=con.id;
        insert opp;
     
        Opportunity newOpp= new Opportunity();
        newOpp.Name='test';
        newOpp.CloseDate=system.today();
        newOpp.StageName='Prospecting';
        newOpp.Contact__c=con.id;
        insert newOpp;
     
        Treatment_History__c psd= new Treatment_History__c();
        psd.Opportunity__c = opp.Id;
        psd.Patient__c=con.id;
        insert psd;
        psd.Opportunity__c = newOpp.Id;
        update psd;
        delete psd;
    }
}