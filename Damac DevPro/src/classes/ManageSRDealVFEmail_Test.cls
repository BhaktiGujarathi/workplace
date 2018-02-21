/*
* Test Class for ManageSRDealVFEmail,SRDealVFEmailCtrl
*/
@isTest
private class ManageSRDealVFEmail_Test {
    @testSetup static void setupData() {
        
        NSIBPM__SR_Template__c srtemplate = InitializeSRDataTest.createSRTemplate('Deal');
        insert srtemplate;
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',false,srtemplate.id);
        sr.Agency_Type__c = 'Corporate';
        insert sr;        
        
        NSIBPM__Step_Template__c stptemplate = InitializeSRDataTest.createStepTemplate('Deal','MANAGER_APPROVAL');
        insert stptemplate;
        
        List<string> statuses = new List<string>{'MANAGER_APPROVED'};
        Map<string,NSIBPM__Status__c> mpstepstatus = InitializeSRDataTest.createStepStatus(statuses);
        
        NSIBPM__Step__c stp  =  InitializeSRDataTest.createStep(sr.id,mpstepstatus.values()[0].id,stptemplate.id);
        insert stp;
    }
    
     @isTest static void test_method_1() {
        Test.startTest();
        {
            ManageSRDealVFEmail obj = new ManageSRDealVFEmail();
            NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
            NSIBPM__Step__c stp = [select id,name,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__SR__c =: sr.id];
            string str = obj.EvaluateCustomCode(sr,stp);
            ManageSRDealVFEmail.sendemailtouser(sr.id,'DOCS_OK');
            ManageSRDealVFEmail.sendemailtouser(sr.id,'MANAGER_APPROVED');
            ManageSRDealVFEmail.sendemailtouser(null,null);
            NSIBPM__Status__c stpSt = new NSIBPM__Status__c();
            stpSt.NSIBPM__Code__c = 'MG_App';
            insert stpst;
            stp.NSIBPM__Status__c = stpst.id;
            update stp;
            str = obj.EvaluateCustomCode(sr,stp);
            str = obj.EvaluateCustomCode(null,null);
            ManageSRDealVFEmail.sendemailtouser(null,null);
        }
        Test.stopTest();
        
    }
}