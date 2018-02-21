@istest
public class CancelDealRejectionStepsTest{


    static testmethod void CancelDealRejectionSteps_Methods(){
    
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        NSIBPM__SR_Template__c SRTemplate = new NSIBPM__SR_Template__c();
        srtemplate.NSIBPM__SR_RecordType_API_Name__c = 'Deal';
        insert SRTemplate;
        
        Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
        sr.NSIBPM__Customer__c = a.id;
        sr.RecordTypeId = RecType1;
        sr.Agency__c = a.id;
        sr.NSIBPM__SR_Template__c = SRTemplate.id;
        sr.Agency_Type__c = 'Corporate';
        insert sr;
        
        NSIBPM__Step_Template__c sttempl = new NSIBPM__Step_Template__c();
        sttempl.NSIBPM__Step_RecordType_API_Name__c = 'Deal';
        sttempl.NSIBPM__Code__c = 'CANCELLED';
        insert sttempl;
        
        NSIBPM__Status__c stpSt = new NSIBPM__Status__c();
        stpSt.NSIBPM__Code__c = 'CANCELLED';
        stpSt.NSIBPM__Type__c  = 'Start';
        insert stpst;
        
        NSIBPM__Step__c stp = new NSIBPM__Step__c();
        stp.NSIBPM__SR__c = sr.id;
        stp.NSIBPM__Status__c = stpst.id;
        stp.NSIBPM__Step_Template__c = sttempl.id;
        insert stp;
        
        NSIBPM__Step_Template__c sttempl1 = new NSIBPM__Step_Template__c();
        sttempl1.NSIBPM__Step_RecordType_API_Name__c = 'Deal';
        sttempl1.NSIBPM__Code__c = 'DEAL';
        insert sttempl1;
        
        NSIBPM__Status__c stpSt1 = new NSIBPM__Status__c();
        stpSt1.NSIBPM__Code__c = 'DEAL';
        stpSt1.NSIBPM__Type__c  = 'Start';
        insert stpst1;
        
        NSIBPM__Step__c stp1 = new NSIBPM__Step__c();
        stp1.NSIBPM__SR__c = sr.id;
        stp1.NSIBPM__Status__c = stpst1.id;
        stp1.NSIBPM__Step_Template__c = sttempl1.id;
        insert stp1;
    
        test.starttest();
            CancelDealRejectionSteps obj = new CancelDealRejectionSteps();
            string str = obj.EvaluateCustomCode(sr,stp);
        test.stoptest();
    
    }

}