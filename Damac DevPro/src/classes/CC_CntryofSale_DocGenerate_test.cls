/*
 * Test Class for CC_CntryofSale_DocGenerate.
 */
@isTest
private class CC_CntryofSale_DocGenerate_test {
    @testSetup static void setupData() {
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Agent Registration',true,null);
        sr.ID_Type__c = 'Passport';
        insert sr;
        system.debug('-->'+sr.id);
        NSIBPM__Step__c stp = InitializeSRDataTest.createStep(sr.id,null,null);
        insert stp;
        system.debug('-->'+stp.id);
        List<string> ctryofSale = new list<string>{'UAE','KSA'};
        list<Agent_Site__c> agetsites = InitializeSRDataTest.createAgentSites(ctryofSale,sr.NSIBPM__Customer__c);
        agetsites[0].Active__c = false;
        agetsites[1].Active__c = true;
        insert agetsites;
        system.debug('-->'+agetsites.size());
    }
    
    @isTest static void test_method_1() {
        NSIBPM__Service_Request__c sr = [select id,name,NSIBPM__Customer__c,Country_of_Sale__c from NSIBPM__Service_Request__c limit 1];
        NSIBPM__Step__c step = [select id,name,NSIBPM__SR__c from NSIBPM__Step__c limit 1];
        CC_CntryofSale_DocGenerate obj = new CC_CntryofSale_DocGenerate();
        string str = obj.EvaluateCustomCode(sr,step);
        system.debug('---->'+str);
        str = obj.EvaluateCustomCode(null,null);
        delete [select id from Agent_Site__c];
        str = obj.EvaluateCustomCode(sr,step);
    }
     @isTest static void test_method_2() {
         list<Agent_Site__c> lstagesites = [select id,name,active__c from Agent_Site__c];
         for(Agent_Site__c ags : lstagesites){
             ags.active__c = !ags.active__c;
         }
         //update lstagesites;
     }
}