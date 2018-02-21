/*
* Test Class for ManageSRStatusConditionBased
*/
@isTest(seealldata=false)
private class ManageSRStatusConditionBased_Test {
    @testSetup static void setupData() {
        NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
        sr.New_Country_of_Sale__c = 'UAE';
        insert sr;
        
        NSIBPM__Step__c stp = InitializeSRDataTest.createStep(sr.id,null,null);
        insert stp;
        
        List<string> statuses = new list<string>{'UNDER_REVIEW','AWAITING_FFA_AA'};
            Map<string,NSIBPM__SR_Status__c> mpsrStatus =  InitializeSRDataTest.createSRStatus(statuses);
    }
    
    @isTest static void test_method_1() {
        Test.startTest();
        ManageSRStatusConditionBased obj = new ManageSRStatusConditionBased();
        NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
        NSIBPM__Step__c stp = [select id,name,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__SR__c =: sr.id];
        string str = obj.EvaluateCustomCode(sr,stp);
        
        sr.New_Country_of_Sale__c = null;
        ManageSRStatusConditionBased.updateSR(sr);
        str = obj.EvaluateCustomCode(null,null);
        ManageSRStatusConditionBased.updateSR(null);
        Test.stopTest();
    }
}