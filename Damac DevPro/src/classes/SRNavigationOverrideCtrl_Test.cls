/*
* Test Class for SRNavigationOverrideCtrl.
*/
@isTest
private class SRNavigationOverrideCtrl_Test {
    @testSetup static void setupData() {
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Agent Registration',true,null);
		insert sr;
        NSIBPM__Step__c stp = InitializeSRDataTest.createStep(sr.id,null,null);
        insert stp;
        Page_Flow__c p = InitializeSRDataTest.createPageFlow('test', 'Deal');
        insert p;
        PSRLT__c profilelayoutmapping = InitializeSRDataTest.createProfileSRLayoutMapping(UserInfo.getprofileid(),true);
        insert profilelayoutmapping;
    }
    
    @isTest static void test_method_1() {
        test.startTest();
        {  
        NSIBPM__Service_Request__c sr1 = new NSIBPM__Service_Request__c();
        NSIBPM__Service_Request__c sr = [select id,name,NSIBPM__Customer__c,Country_of_Sale__c,recordtypeid,recordtype.name from NSIBPM__Service_Request__c limit 1];
        ApexPages.StandardController controller = new ApexPages.StandardController(sr1);
        
        Test.setCurrentPage(Page.SRNavigationOverride);
        SRNavigationOverrideCtrl obj = new SRNavigationOverrideCtrl(controller);
        
        apexpages.currentPage().getparameters().put('id',sr.id);
        obj = new SRNavigationOverrideCtrl(controller);
        
        apexpages.currentPage().getparameters().put('retURL',sr.id);
        obj = new SRNavigationOverrideCtrl(controller);
        
        Id RecTypeId = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        obj.RecordtypeName = 'Deal';
        apexpages.currentPage().getparameters().put('RecordType',RecTypeId);
        obj = new SRNavigationOverrideCtrl(controller);
        }
        test.stopTest();
    }  
    @isTest static void test_method_2() {
        test.startTest();
        {
            Id RecTypeId = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Change Joint Buyer').getRecordTypeId();
            NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
            sr.RecordTypeId = RecTypeId;
            ApexPages.StandardController controller = new ApexPages.StandardController(sr);
            SRNavigationOverrideCtrl obj = new SRNavigationOverrideCtrl(controller);
            obj.isinternalUser = true;
            obj.objSR = sr;
            obj.RecordtypeName = 'Change Joint Buyer';
            Pagereference pg = obj.init();
            {
                SRNavigationOverrideCtrl.PageParameters = new Map<string,string>{'test__lkid' => 'test', 'test' => '2345'};
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'View';
                pg = obj.init();
                
                PSRLT__c prf =  [select id,Override__c from PSRLT__c];
                prf.Override__c = false;
                update prf;
                
                pg = obj.init();
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'New';
                pg = obj.init();
                
                delete [select id from PSRLT__c];
                pg = obj.init();
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'View';
                pg = obj.init();
            }
            RecTypeId = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Agent Registration').getRecordTypeId();
            obj.isThruPGFlows = false;
            obj.objSR.recordtypeid = RecTypeId;
            {
           		pg = obj.init();
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'New';
                pg = obj.init();
            }
            obj.isThruPGFlows = true;
            {
           		pg = obj.init();
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'View';
                pg = obj.init();
            }
            PSRLT__c profilelayoutmapping = InitializeSRDataTest.createProfileSRLayoutMapping(UserInfo.getprofileid(),true);
        	insert profilelayoutmapping;
            obj.isThruPGFlows = true;
            {
           		pg = obj.init();
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'New';
                pg = obj.init();
            }
            
            profilelayoutmapping.Override__c = false;
            update profilelayoutmapping;
            {
           		pg = obj.init();
                obj.DetectedMode = 'Edit';
                pg = obj.init();
                obj.DetectedMode = 'View';
                pg = obj.init();
            }
                
        }
        test.stopTest();
    }
}