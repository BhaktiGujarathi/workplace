@isTest
public class OpportunityStageCont_Test{
    static testMethod void test1(){
			Contact con = new Contact();
            con.LastName = 'test';
            con.Social_Security_Number__c = 'test#';
            insert con;
		
        String accRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
            Opportunity opp = new Opportunity ();
            opp.Name = 'TestOpp';
            opp.Probability = 10;
            opp.Contact__c = con.Id ;
            opp.CloseDate = System.today();
            opp.StageName = 'Prospecting';
            opp.RecordTypeId = accRT;
            insert opp;
			
			ApexPages.currentPage().getParameters().put('Id', opp.Id);
            OpportunityStageCont OSC = new OpportunityStageCont();
            OSC.valsText= 'Prospecting:Test';
            OSC.chartYear= 'test';
            OSC.reload();
			OSC.getStages();
			OSC.getStagename();
			
        }
        
}