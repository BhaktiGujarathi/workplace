/*
* Test Class for ManageBuyersController.
*/
@isTest
private class ManageBuyersController_Test {
    @testSetup static void setupData() {
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Change Joint Buyer',true,null);
        insert sr;
        
        Booking__c bk = InitializeSRDataTest.createBooking(sr.NSIBPM__Parent_SR__c);
        insert bk;
        
        Buyer__c br = InitializeSRDataTest.createBuyer(bk.id,false);
        insert br;
    }
    
    @isTest static void test_method_1() {
        NSIBPM__Service_Request__c sr = [select id,name,NSIBPM__Record_Type_Name__c from NSIBPM__Service_Request__c where NSIBPM__Record_Type_Name__c = 'Deal' limit 1];
        NSIBPM__Service_Request__c sr1 = [select id,name,NSIBPM__Record_Type_Name__c from NSIBPM__Service_Request__c where NSIBPM__Record_Type_Name__c = 'Change_Joint_Buyer' limit 1];
        Amendment__c amd = new Amendment__c(Service_Request__c = sr1.id,First_Name__c='test',Last_Name__c='tset');
        insert amd;
        
        Test.setCurrentPageReference(new PageReference('page.ManageBuyersvf')); 
        ManageBuyersController obj = new ManageBuyersController();
        
        System.currentPageReference().getParameters().put('id', sr1.id);
        obj = new ManageBuyersController();
        
        System.currentPageReference().getParameters().put('id', sr.id);
        obj = new ManageBuyersController();
        
        obj.selectedRecord = [select id,name from Booking__c limit 1].id;
        pagereference pg = obj.onBookingSelection();
        obj.selectedRecord = 'NONE';
        pg = obj.onBookingSelection();
        obj.newBuyer = amd;
        pagereference pg1 = obj.save();
        obj.newBuyer = null;
        pg1 = obj.save();
        pagereference pg2 = obj.cancel();
        pagereference pg4 = obj.AddNew();
        obj.buyrID = amd.id;
        pagereference pg5 = obj.BuyrDelete();
        pagereference pg6 = obj.Edit();
        pagereference pg7 = obj.BuyrDeleteUNDO();
        pagereference pg3 = obj.Proceed();
        obj.objSR = null;
        pg3 = obj.Proceed();
        pg3 = obj.GoBack();
        obj.returnURLID = null;
        pg3 = obj.GoBack();
    }
}