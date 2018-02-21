/*
* Test Class for AutoCreateSteps
*/
@isTest
private class AutoCreateSteps_Test {
    @testSetup static void setupData() {
        List<string> srstatuses = new list<string>{'Approved,Pending,Rejected'};
        Map<string,NSIBPM__SR_Status__c> mpsrStatus =  InitializeSRDataTest.createSRStatus(srstatuses);
        
        List<string> stpstatuses = new list<string>{'Manager Approved','Booking Docs Under Review'};
        Map<string,NSIBPM__Status__c> stepStatuses = InitializeSRDataTest.createStepStatus(stpstatuses);
        
        List<SRAC__c> lstsrc = new List<SRAC__c>();
        lstsrc.add(new SRAC__c(name='test1',Step_No__c=50,SR_Status_Code__c='Approved',Step_Status_Code__c='Booking Docs Under Review'));
        insert lstsrc;
        
		List<SRStpMD__c> lsttoinsert = new List<SRStpMD__c>();   
        lsttoinsert.add(new SRStpMD__c (name='1',Is_Excluded__c = false,SR_Step_Master_Code__c='MANAGER_APPROVAL',Final_Status_Name_Code__c = 'Manager Approved'));
        insert lsttoinsert;
        
        NSIBPM__SR_Template__c srTemplate = InitializeSRDataTest.createSRTemplate('Deal');
        insert srTemplate;
        
        NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Deal',false,null);
        sr.ID_Type__c = null;
        sr.NSIBPM__SR_Template__c = srTemplate.id;
        sr.IPMS_Registration_Status__c = 'test1';
        insert sr;
        
        
        List<NSIBPM__Step_Template__c> lstSteptemplate = new List<NSIBPM__Step_Template__c>();
		lstSteptemplate.add(new NSIBPM__Step_Template__c(NSIBPM__Code__c = 'MANAGER_APPROVAL',NSIBPM__Step_RecordType_API_Name__c='Deal'));
        lstSteptemplate.add(new NSIBPM__Step_Template__c(NSIBPM__Code__c = 'DOCUMENT_VERIFICATION',NSIBPM__Step_RecordType_API_Name__c='Deal'));
        insert lstSteptemplate;
            
        List<NSIBPM__SR_Steps__c> lstSRSteps = new List<NSIBPM__SR_Steps__c>();
        lstSRSteps.add(new NSIBPM__SR_Steps__c(NSIBPM__Step_No__c = 40,NSIBPM__SR_Template__c = srTemplate.id,NSIBPM__Step_Template__c = lstSteptemplate[0].id));
        lstSRSteps.add(new NSIBPM__SR_Steps__c(NSIBPM__Step_No__c = 50,NSIBPM__SR_Template__c = srTemplate.id,NSIBPM__Step_Template__c = lstSteptemplate[1].id));
        insert lstSRSteps;
        
    }
    
    @isTest static void test_method_1() {
		Test.startTest();
        NSIBPM__Service_Request__c sr = [select id,name,IPMS_Registration_Status__c from NSIBPM__Service_Request__c limit 1];
        Map<Id,string> mpSRIMPSRegCode = new Map<Id,string>();
        mpSRIMPSRegCode.put(sr.id,sr.IPMS_Registration_Status__c);
        Map<string,NSIBPM__Status__c> mpstepstatuses = new Map<string,NSIBPM__Status__c>();
        List<NSIBPM__Status__c> lststepstatuses = (List<NSIBPM__Status__c>)SRUtility.getRecords('NSIBPM__Status__c', '');
        for(NSIBPM__Status__c stpstatus : lststepstatuses){
            mpstepstatuses.put(stpstatus.name,stpstatus);
            mpstepstatuses.put(stpstatus.NSIBPM__Code__c,stpstatus);
        }
        
        Map<string,NSIBPM__SR_Status__c> mpsrstatuses = new Map<string,NSIBPM__SR_Status__c>();
        List<NSIBPM__SR_Status__c> lstSRstatuses = (List<NSIBPM__SR_Status__c>)SRUtility.getRecords('NSIBPM__SR_Status__c', '');
        for(NSIBPM__SR_Status__c srstatus : lstSRstatuses){
            mpsrstatuses.put(srstatus.NSIBPM__Code__c,srstatus);
        }
        
        List<NSIBPM__SR_Steps__c> lstSRSteps = (List<NSIBPM__SR_Steps__c>)SRUtility.getRecords('NSIBPM__SR_Steps__c', ' where NSIBPM__SR_Template__r.NSIBPM__SR_RecordType_API_Name__c =\'Deal\' order by NSIBPM__Step_No__c asc');
        system.debug('--lstSRSteps->'+lstSRSteps.size()+'-->');
        
        string str = '(';
        for(NSIBPM__SR_Steps__c srStep : lstSRSteps){
            str += '\''+srStep.NSIBPM__Step_Template__c+'\',';
        }
        str = str.substring(0,str.length()-1);
        str += ')';
        List<NSIBPM__Step_Template__c> lstStpTemplate = (List<NSIBPM__Step_Template__c>)SRUtility.getRecords('NSIBPM__Step_Template__c', ' where id in '+str );
        system.debug('---lstStpTemplate>'+lstStpTemplate.size()+'-->');
        
        Map<id,NSIBPM__Step_Template__c> mpstptemplate = new Map<id,NSIBPM__Step_Template__c>();
        for(NSIBPM__Step_Template__c sttemp : lstStpTemplate){
            mpstptemplate.put(sttemp.id,sttemp);
        }
        system.debug('---mpstptemplate>'+mpstptemplate);
        AutoCreateSteps.createsteps(mpSRIMPSRegCode,lstSRSteps,mpstptemplate,mpstepstatuses,mpsrstatuses);
        Test.stopTest();
    }
    @isTest static void test_method_2() {
		Test.startTest();
        Database.executeBatch(new AutoCreateSteps());
        Test.stopTest();
    }
}