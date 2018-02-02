@isTest
public class CloseInactiveOppBatch_Test{
    static testmethod void test1(){
    	Opportunity opp1 = new Opportunity(Name = 'Test Opportunity',StageName='Counter Offer Requested', CloseDate= Date.today(), RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId());
    	insert opp1;
    	Opportunity opp2 = new Opportunity(Name = 'Test Opportunity1',StageName='Prospecting', CloseDate= Date.today(), RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId());
    	insert opp2;
    	Opportunity opp3 = new Opportunity(Name = 'Test Opportunity2',StageName='Prospecting', CloseDate= Date.today(), RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId());
    	insert opp3;
    	OpportunityCloseDays__c ResTreatment = new OpportunityCloseDays__c(Name = 'Residential Treatment', LastModifiedDays__c = 0);
    	insert ResTreatment;
    	OpportunityCloseDays__c OutTreatment = new OpportunityCloseDays__c(Name = 'Outpatient Treatment', LastModifiedDays__c = 0);
    	insert OutTreatment;
    	OpportunityCloseDays__c OutReferral = new OpportunityCloseDays__c(Name = 'Refer Out Only', LastModifiedDays__c = 1);
    	insert OutReferral;

    	update opp1;
		String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new closeInactiveOpportunityBatch());
    	Database.executeBatch(new closeInactiveOpportunityBatch());
    }
}