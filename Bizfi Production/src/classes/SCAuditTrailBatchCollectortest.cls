@isTest(seeAllData = false)

public class SCAuditTrailBatchCollectortest
{

static testmethod void testSCAuditTrailBatchCollectorLast7DaysTest() 
{


SCTimeframe_Metric__c tempSCTimeframe = new SCTimeframe_Metric__c(name = 'Application Sent',Last_7_Days__c = 'Last_7_Days_Apps_Sent__c' );
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


Test.startTest();
/*SCAuditTrailBatchCollector c = new SCAuditTrailBatchCollector();
Database.executeBatch(c);*/

SCScheduler.scheduleMe();
Test.stopTest();

}


static testmethod void testSCAuditTrailBatchCollectorLastMonthsTest() 
{


SCTimeframe_Metric__c tempSCTimeframe = new SCTimeframe_Metric__c(name = 'Application Sent',Last_7_Days__c = 'MTD_Apps_Sent__c' );
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
                                                                                system.now().addMonths(-1));



insert tempAT;


Test.startTest();
/*SCAuditTrailBatchCollector c = new SCAuditTrailBatchCollector();
Database.executeBatch(c);*/

SCScheduler.scheduleMe();
Test.stopTest();



}


static testmethod void testSCAuditTrailBatchCollectorYesterdayOrganicSubTest() 
{


SCTimeframe_Metric__c tempSCTimeframe = new SCTimeframe_Metric__c(name = 'Organic Sub',Yesterday__c = 'Yesterday_Organic_Subs__c' );
insert tempSCTimeframe;


Opportunity tempOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Application Sent',CloseDate = system.today()+10);
insert tempOpp;


// TO DO: implement unit test
Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
//generateTestUser(String userName,Profile  profile,String alias,String email)
User userOwner = ATTestDataUtility.generateTestUser('testOld@testorg.com',profile,'standt','standarduser@testorg.com');
insert userOwner;


Audit_trail__c tempAT = ATTestDataUtility.generateTestAuditTrailForStatusChange('Opportunity',
                                                                                null,
                                                                                'Application Sent',
                                                                                'Organic Sub',
                                                                                tempOpp,
                                                                                null,
                                                                                userOwner,
                                                                                system.now().addDays(-1));



insert tempAT;


Test.startTest();
/*SCAuditTrailBatchCollector c = new SCAuditTrailBatchCollector();
Database.executeBatch(c);*/

SCScheduler.scheduleMe();
Test.stopTest();



}




static testmethod void testSCAuditTrailBatchCollectorYesterdayOutBoundCallTest() 
{


SCTimeframe_Metric__c tempSCTimeframe = new SCTimeframe_Metric__c(name = 'Outbound Call',Yesterday__c = 'Yesterday_Dials__c' );
insert tempSCTimeframe;


Opportunity tempOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Application Sent',CloseDate = system.today()+10);
insert tempOpp;


// TO DO: implement unit test
Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
//generateTestUser(String userName,Profile  profile,String alias,String email)
User userOwner = ATTestDataUtility.generateTestUser('testOld@testorg.com',profile,'standt','standarduser@testorg.com');
insert userOwner;


Audit_trail__c tempAT1 = ATTestDataUtility.generateTestAuditTrailForStatusChange('Opportunity',
                                                                                null,
                                                                                'Application Sent',
                                                                                'Outbound Call',
                                                                                tempOpp,
                                                                                null,
                                                                                userOwner,
                                                                                system.now().addDays(-1));



insert tempAT1;


Audit_trail__c tempAT2 = ATTestDataUtility.generateTestAuditTrailForStatusChange('Opportunity',
                                                                                null,
                                                                                'Application Sent',
                                                                                'Outbound Call',
                                                                                tempOpp,
                                                                                null,
                                                                                userOwner,
                                                                                system.now().addDays(-1));



insert tempAT2;


Test.startTest();
/*SCAuditTrailBatchCollector c = new SCAuditTrailBatchCollector();
Database.executeBatch(c);*/

SCScheduler.scheduleMe();
Test.stopTest();



}





static testmethod void testSCAuditTrailBatchCollectorYesterdayLeadTest() 
{


SCTimeframe_Metric__c tempSCTimeframe = new SCTimeframe_Metric__c(name = 'Outbound Call',Yesterday__c = 'Yesterday_Dials__c' );
insert tempSCTimeframe;


Opportunity tempOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Application Sent',CloseDate = system.today()+10);
insert tempOpp;




// TO DO: implement unit test
Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
//generateTestUser(String userName,Profile  profile,String alias,String email)
User userOwner = ATTestDataUtility.generateTestUser('testOld@testorg.com',profile,'standt','standarduser@testorg.com');
insert userOwner;

Lead tempLead = ATTestDataUtility.generateTestLead();
insert tempLead;



Audit_trail__c tempAT1 = new Audit_trail__c(Object__c = 'Lead',
                                            Current_Stage__c = 'Application Sent',
                                            Type__c = 'Owner',
                                            Lead__c = tempLead.id,
                                            New_owner__c = userOwner.id,
                                            Date_Time_change_was_made__c = system.now().addDays(-1));

insert tempAT1;

Test.startTest();
//SCAuditTrailBatchCollector c = new SCAuditTrailBatchCollector();
//Database.executeBatch(c);

SCScheduler.scheduleMe(); 


Test.stopTest();



}

}