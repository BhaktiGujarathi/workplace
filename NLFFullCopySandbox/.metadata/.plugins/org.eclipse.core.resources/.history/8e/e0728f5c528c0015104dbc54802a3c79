@isTest(seeAllData = false)

public class SCSalesRepMetricsDisplayControllertest
{

static testmethod void SCSalesRepMetricsDisplayControllerTest1() 
{


    SCTimeframe_Metric__c tempSCTimeframe = new SCTimeframe_Metric__c(name = 'Application Sent',Last_7_Days__c = 'Last_7_Days_Apps_Sent__c',order__c = 0 );
    insert tempSCTimeframe;
    
    
    Opportunity tempOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Application Sent',CloseDate = system.today()+10);
    insert tempOpp;
    
    // TO DO: implement unit test
    Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
    //generateTestUser(String userName,Profile  profile,String alias,String email)
    User userOwner = ATTestDataUtility.generateTestUser('testOld@testorg.com',profile,'standt','standarduser@testorg.com');
    insert userOwner;
        
    Audit_trail__c tempAT = ATTestDataUtility.generateTestAuditTrailForStatusChange('Opportunity',
                                                                                'Application Sent',
                                                                                 null,
                                                                                'Status / Stage',
                                                                                 tempOpp,
                                                                                 null,
                                                                                 userOwner,
                                                                                 system.now()-5);
    insert tempAT;
    
    Sales_Rep_Report_Card__c salesRepReportCardInst = new Sales_Rep_Report_Card__c();
    insert salesRepReportCardInst;
    
    
    
    Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.SCSalesRepCardChart'));
        System.currentPageReference().getParameters().put('id', salesRepReportCardInst.id);

        ApexPages.StandardController stdHR = new ApexPages.StandardController(salesRepReportCardInst);
        SCSalesRepMetricsDisplayController displayCltr = new SCSalesRepMetricsDisplayController(stdHR);
        
        displayCltr.onload();
    Test.stopTest();
    
}

}