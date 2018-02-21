/*
 * Test Class for NIPaymentGateway.
 */
@isTest
private class NIPaymentGateway_Test {
    @testSetup static void setupData() {
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',false,null);
        insert sr;
        
        List<string> statuses = new list<string>{'Draft'};
        Map<string,NSIBPM__SR_Status__c> mpsrStatus =  InitializeSRDataTest.createSRStatus(statuses);
        
		Location__c objLoc = InitializeSRDataTest.createLocation('123','Building');
		insert objLoc;       
        
        Inventory__c inv = InitializeSRDataTest.createInventory(objLoc.id);
        insert inv;

        Booking__c bk = InitializeSRDataTest.createBooking(sr.id);
        insert bk;
        
        Booking_Unit__c bu = InitializeSRDataTest.createBookingUnit(bk.id,inv.id);
        bu.Online_Payment_Party__c = 'Third Party';
        insert bu;      
        
        Payment_Plan__c pp = InitializeSRDataTest.createPaymentPlan(bu.id,objLoc.id);
        insert pp;
        
        Buyer__c b = InitializeSRDataTest.createBuyer(bk.id,false);
        B.Account__c = sr.NSIBPM__Customer__c;
        b.Is_3rd_Party__c = true;
        insert b;
        
        List<string> lstDocNames = new list<string>{'Third party consent'};
        List<NSIBPM__Document_Master__c> lstmasdocs = InitializeSRDataTest.createMasterDocs(lstDocNames);
        insert lstmasdocs;
    }
    
    @istest static void test_method1(){
        Test.startTest();
        Booking_Unit__c bu = [select id,name from Booking_Unit__c limit 1];
        Account acc = [select id,name from account limit 1];
        Test.setCurrentPageReference(new PageReference('Page.NI_Payment'));
        system.currentPageReference().getParameters().put('id', bu.id);
        NIPaymentGateway obj = new NIPaymentGateway();
        string paymentResult = NIPaymentGateway.doPay(bu.id,20000);
        List<Schema.FieldSetMember> objsFS = NIPaymentGateway.readFieldSet(null,null);
        try{
            string decryptRes = NIPaymentGateway.decryptResponse('asdaskdjalsjd');
        }
        catch(exception ex){
            
        }
        Test.stopTest();
    }
}