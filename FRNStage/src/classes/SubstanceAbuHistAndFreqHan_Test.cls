@isTest
public class SubstanceAbuHistAndFreqHan_Test{
    private static TestMethod void UnitTest(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();     
              
        Opportunity oppty = new Opportunity();
            oppty.Name = 'testOppty';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'Closed Lost';
            oppty.RecordTypeId = rtId;
            insert oppty;
        	update oppty;
            
        Substance_Abuse_History_and_Frequency__c ra  = new Substance_Abuse_History_and_Frequency__c();
		ra.Opportunity__c= oppty.Id;
		insert ra;
		update ra;
		//delete ra;
        
    }   
    
}