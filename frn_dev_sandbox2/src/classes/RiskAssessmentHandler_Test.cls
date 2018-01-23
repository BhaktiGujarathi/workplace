@isTest
public class RiskAssessmentHandler_Test{
    private static TestMethod void UnitTest(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();     
              
		Contact con = new Contact();
        con.lastName ='test';
        insert con;
		
        Opportunity oppty = new Opportunity();
            oppty.Name = 'testOppty';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'Closed Lost';
			oppty.Contact__c=con.id;
            oppty.RecordTypeId = rtId;
            insert oppty;
			update oppty;
                
        Clinical_Assessment__c cac = new Clinical_Assessment__c();
            cac.Opportunity__c = oppty.Id;
            insert cac;
            
        Risk_Assessment__c ra  = new Risk_Assessment__c();
            ra.Clinical_Assessment__c= cac.Id;
            insert ra;
            update ra;
        //delete ra;
        
    }   
    
}