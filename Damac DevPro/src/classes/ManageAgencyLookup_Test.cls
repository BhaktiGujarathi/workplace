/*
* Test Class for ManageAgencyLookup.
*/
@isTest
private class ManageAgencyLookup_Test {
    @testSetup static void setupData() {
    	Id accRecord = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = accRecord;
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
        sttempl.NSIBPM__Code__c = 'SALES_AUDIT';
        insert sttempl;
        
        NSIBPM__Status__c stpSt = new NSIBPM__Status__c();
        stpSt.NSIBPM__Code__c = 'SALES_AUDIT_REJECTED';
        insert stpst;
        
        NSIBPM__Step__c stp = new NSIBPM__Step__c();
        stp.NSIBPM__SR__c = sr.id;
        stp.NSIBPM__Status__c = stpst.id;
        stp.NSIBPM__Step_Template__c = sttempl.id;
        insert stp;
        
        Booking__c  bk = new  Booking__c();
        bk.Deal_SR__c = sr.id;
        insert bk;
    }
    
    @isTest static void test_method_1() {
        ManageAgencyLookup obj = new ManageAgencyLookup();
        NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
        NSIBPM__Step__c stp = [select id,name,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__SR__c =: sr.id];
        string str = obj.EvaluateCustomCode(sr,stp);
    }
    @isTest static void test_method_2() {
        ManageAgencyLookup obj = new ManageAgencyLookup();
        string str = obj.EvaluateCustomCode(null,null);
    }
}