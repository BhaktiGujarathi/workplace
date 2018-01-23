@isTest
public class BehavioralSocialHistoryHandler_Test{
    private static TestMethod void UnitTest(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();     
              
		Contact con = new Contact();
		con.LastName ='test';
		insert con;
		
        Opportunity oppty = new Opportunity();
			oppty.Contact__c = con.Id;
            oppty.Name = 'testOppty';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'Closed Lost';
            oppty.RecordTypeId = rtId;
            insert oppty;  
           
        Clinical_Assessment__c cac = new Clinical_Assessment__c();
            cac.Opportunity__c = oppty.Id;
           insert cac;
           
        Behavioral_Social_History__c ra  = new Behavioral_Social_History__c();
        ra.Clinical_Assessment__c= cac.Id;
        oppty.Contact__c =con.id;
		
        insert ra;     
        delete ra;
        undelete ra;
		//update ra;
        
    }   
    private static TestMethod void UnitTest1(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();     
              
		Contact con = new Contact();
		con.LastName ='test';
		insert con;
		
        Opportunity oppty = new Opportunity();
			oppty.Contact__c = con.Id;
            oppty.Name = 'testOppty';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'Closed Lost';
            oppty.RecordTypeId = rtId;
            insert oppty;  
           
        Clinical_Assessment__c cac = new Clinical_Assessment__c();
            cac.Opportunity__c = oppty.Id;
           insert cac;
           
        Behavioral_Social_History__c ra  = new Behavioral_Social_History__c();
        ra.Clinical_Assessment__c= cac.Id;
        oppty.Contact__c =con.id;
		
        insert ra;     
        delete ra;
        undelete ra;
		update ra;
        
    }   
}