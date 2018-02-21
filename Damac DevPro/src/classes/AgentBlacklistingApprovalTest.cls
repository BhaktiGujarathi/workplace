/*
* Name : Pavithra Gajendra
* Date : 02/08/2017
* Purpose : Test class for invoking approval process on click of a buttton 
* Company : NSI Gulf
* 
*/
@isTest
private class AgentBlacklistingApprovalTest {

    public static Account acc ; 
    
    @isTest static void blacklistAgency() {
        Test.startTest();
        acc = InitialiseTestData.getCorporateAccount('Test Agency1');
        insert acc ; 
        AgentBlacklistingApproval.submitAgentBlacklistApprovalRequest(acc.Id);
        Test.stopTest();
    }
    
    @isTest static void terminateAgency() {
        Test.startTest();
        acc = InitialiseTestData.getCorporateAccount('Test Agency2');
        insert acc ; 
        AgentBlacklistingApproval.submitAgentTerminateApprovalRequest(acc.Id);
        Test.stopTest();
    }

    @isTest static void unBlacklistAgency() {
        Test.startTest();
        acc = InitialiseTestData.getBlacklistedAccount('Test Agency3');
        insert acc ; 
        AgentBlacklistingApproval.submitAgentUnBlacklistApprovalRequest(acc.Id);
        Test.stopTest();
    }
    
    @isTest static void unTerminateAgency() {
        Test.startTest();
        acc = InitialiseTestData.getTerminatedAccount('Test Agency4');
        insert acc ; 
        AgentBlacklistingApproval.submitAgentUnTerminateApprovalRequest(acc.Id);
        Test.stopTest();
    }
    
}