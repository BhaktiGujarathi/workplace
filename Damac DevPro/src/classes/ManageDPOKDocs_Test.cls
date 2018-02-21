/*
* Test Class for ManageDPOKDocs.
*/
@isTest
private class ManageDPOKDocs_Test {
    @testSetup static void setupData() {
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
        sttempl.NSIBPM__Code__c = 'DOCUMENT_VERIFICATION';
        insert sttempl;
        
        NSIBPM__Status__c stpSt = new NSIBPM__Status__c();
        stpSt.NSIBPM__Code__c = 'DOCS_OK';
        insert stpst;
        
        NSIBPM__Step__c stp = new NSIBPM__Step__c();
        stp.NSIBPM__SR__c = sr.id;
        stp.NSIBPM__Status__c = stpst.id;
        stp.NSIBPM__Step_Template__c = sttempl.id;
        insert stp;
        
        Booking__c  bk = new  Booking__c();
        bk.Deal_SR__c = sr.id;
        insert bk;
        
		NSIBPM__Document_Master__c docmaster = new NSIBPM__Document_Master__c();
        docmaster.NSIBPM__Code__c = 'testdoc';
        docmaster.NSIBPM__Dev_Doc_ID__c = 't4etgrdf';
        insert docmaster;
        
        NSIBPM__SR_Template_Docs__c stempDoc = new NSIBPM__SR_Template_Docs__c();
        stempDoc.NSIBPM__Optional__c = false;
        stempDoc.NSIBPM__Document_Master__c = docmaster.id;
        insert stempDoc;
            
        NSIBPM__SR_Doc__c srdoc = new NSIBPM__SR_Doc__c();
        srdoc.name= 'ppt';
        srdoc.NSIBPM__Service_Request__c = sr.id;
        srdoc.NSIBPM__Status__c = 'Pending Upload';
        srdoc.NSIBPM__SR_Template_Doc__c = stempDoc.id;
        insert srdoc;

    }
    @isTest static void test_method_1() {
        ManageDPOKDocs obj = new ManageDPOKDocs();
        NSIBPM__Service_Request__c sr = [select id,name from NSIBPM__Service_Request__c limit 1];
        NSIBPM__Step__c stp = [select id,name,NSIBPM__SR__c from NSIBPM__Step__c where NSIBPM__SR__c =: sr.id];
        string str = obj.EvaluateCustomCode(sr,stp);
        NSIBPM__SR_Doc__c srdoc = [select id,name from NSIBPM__SR_Doc__c limit 1];
        srdoc.NSIBPM__Status__c = 'Approved';
        update srdoc;
        str = obj.EvaluateCustomCode(sr,stp);
    }
}