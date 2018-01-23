@isTest
    public class closeInactiveOpportunityBatch_test{
    private static TestMethod void closeInactiveOpportunityBatch_UnitTest(){ 

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();       
        String rtId1 =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
        String rtId2 =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        
        OpportunityCloseDays__c a = new OpportunityCloseDays__c();
            a.Name= 'Refer Out Only';
            a.LastModifiedDays__c = 10;
            insert a;
        
        Opportunity oppty = new Opportunity();
            oppty.Name = 'testOppty';       
            oppty.CloseDate = system.today();
            oppty.stageName = 'No Activity within 10 Days';
            
            oppty.RecordTypeId = rtId;
            insert oppty;   
            
        OpportunityCloseDays__c a1 = new OpportunityCloseDays__c();
            a1.Name= 'Outpatient Treatment';
            a1.LastModifiedDays__c= 10;
            
            insert a1;
        
        Opportunity oppty1 = new Opportunity();
            oppty1.Name = 'testOppty';      
            oppty1.CloseDate = system.today();
           
            oppty1.stageName = 'No Activity within 10 Days';
            oppty1.RecordTypeId = rtId1;
            insert oppty1;  
        
        OpportunityCloseDays__c a2 = new OpportunityCloseDays__c();
            a2.Name= 'Residential Treatment';
            a2.LastModifiedDays__c= 10;
            
            insert a2;
        
        Opportunity oppty2 = new Opportunity();
            oppty2.Name = 'testOppty';      
            oppty2.CloseDate = system.today();
            oppty2.stageName = 'No Activity within 10 Days';
           
            oppty2.RecordTypeId = rtId2;
            insert oppty2;
        
        Test.startTest();
            closeInactiveOpportunityBatch c = new closeInactiveOpportunityBatch(); 
            String CRON_EXP = '0 0 0 15 3 ? 2022';
        //  Database.executeBatch(c);
            String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        c);
			
        
        Test.stopTest();
        
    }   
    
}