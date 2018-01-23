@isTest
public class TripHandler_Test{
    private static TestMethod void UnitTest(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();     
              
        Opportunity oppty = new Opportunity();
            oppty.Name = 'testOppty';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'Closed Lost';
            oppty.RecordTypeId = rtId;
            insert oppty;   
            
        Trip__c ra  = new Trip__c();
		ra.Opportunity__c= oppty.Id;
		insert ra;
		//update ra;
		//delete ra;
        
    }

 private static TestMethod void UnitTest1(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();     
              
        Opportunity oppty = new Opportunity();
             oppty.Name = 'test';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'Closed Lost';
            oppty.RecordTypeId = rtId;
            insert oppty;   
            
        Trip__c ra  = new Trip__c();
		ra.Opportunity__c= oppty.Id;
		insert ra;
		update ra;
		//delete ra;
        
    }
	
    
}