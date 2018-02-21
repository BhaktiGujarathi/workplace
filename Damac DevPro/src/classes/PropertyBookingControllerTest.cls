/**************************************************************************************************
* Name               : PropertyBookingControllerTest                                              *
* Description        : Test class for PropertyBookingController.                                  *
* Created Date       : 20/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      20/04/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest 
private class PropertyBookingControllerTest {
	
	private static String wizardLevel = 'Level 1';
	private static List<NSIBPM__SR_Template__c> createSrTemplateList = new List<NSIBPM__SR_Template__c>();
	private static List<NSIBPM__SR_Status__c> createSrStatusList = new List<NSIBPM__SR_Status__c>();
	private static List<NSIBPM__Service_Request__c> createServiceRequestList = new List<NSIBPM__Service_Request__c>();
	private static List<Booking__c> createBookingList = new List<Booking__c>();
	private static List<Booking_Unit__c> createBookingUnitList = new List<Booking_Unit__c>();
	private static List<Buyer__c> createBuyerList = new List<Buyer__c>();
	
	private static void setup() {
		createSrTemplateList = InitialiseTestData.createTestTemplateRecords(
			new List<NSIBPM__SR_Template__c>{
				new NSIBPM__SR_Template__c()});
        createSrStatusList = InitialiseTestData.createSrStatusRecords(
        	new List<NSIBPM__SR_Status__c>{
    			new NSIBPM__SR_Status__c(Name = 'Draft', NSIBPM__Code__c = 'Draft'), 
    			new NSIBPM__SR_Status__c(Name = 'Submitted', NSIBPM__Code__c = 'Submitted')});
        createServiceRequestList = 
        	InitialiseTestData.createtestServiceRequestRecords(
        		new List<NSIBPM__Service_Request__c>{
        			new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal'),
        										   NSIBPM__SR_Template__c = createSrTemplateList[0].Id,
        										   Booking_Wizard_Level__c = wizardLevel)});
        createBookingList = 
        	InitialiseTestData.createBookingRecords(
        		new List<Booking__c>{
        			new Booking__c(Deal_SR__c = createServiceRequestList[0].Id)});
        Location__c loc=new Location__c();
	    loc.Location_ID__c='123';
	    insert loc;
	    Inventory__c inv = new Inventory__c();
	    inv.Unit_Location__c=loc.id;
	    insert inv;
        createBookingUnitList = 
        	InitialiseTestData.createBookingUnitRecords(
        		new List<Booking_Unit__c>{
        			new Booking_Unit__c(Booking__c = createBookingList[0].Id, Inventory__c = inv.Id)});
       	createBuyerList = 
        	InitialiseTestData.createBuyerRecords(
        		new List<Buyer__c>{
        			new Buyer__c(Booking__c = createBookingList[0].Id)});
    }
	
	
    static testMethod void testDataPrepopulation() {
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		System.currentPageReference().getParameters().put('id', createServiceRequestList[0].Id); 	  
		PropertyBookingController pbcObject = new PropertyBookingController(); 
    }
    
     static testMethod void testUnitSelection() {
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		PropertyBookingController pbcObject = new PropertyBookingController(); 
		pbcObject.selectUnits();
    }
    
    static testMethod void testCreatePortfolio() {
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		PropertyBookingController pbcObject = new PropertyBookingController(); 
		pbcObject.createPortfolio();
    }
    
    static testMethod void testSelectPaymentPlan() {
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		PropertyBookingController pbcObject = new PropertyBookingController(); 
		pbcObject.selectPaymentPlan();
    }
    
     static testMethod void testSelectPaymentMethod() {
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		PropertyBookingController pbcObject = new PropertyBookingController(); 
		pbcObject.selectPaymentMethod();
    }
    
    static testMethod void testSubmitBooking() {
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		PropertyBookingController pbcObject = new PropertyBookingController(); 
		pbcObject.submitBooking();
    }
    
     static testMethod void testUnitSelectionOnSubmission() {
     	PropertyBookingController pbcObject = new PropertyBookingController();
     	pbcObject.availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 5';
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		System.currentPageReference().getParameters().put('id', createServiceRequestList[0].Id); 	  
		pbcObject.selectUnits();
    }
    
    static testMethod void testCreatePortfolioOnSubmission() {
    	PropertyBookingController pbcObject = new PropertyBookingController();
    	pbcObject.availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 5';
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		System.currentPageReference().getParameters().put('id', createServiceRequestList[0].Id); 	  
		pbcObject.createPortfolio();
    }
    
    static testMethod void testSelectPaymentPlanOnSubmission() {
    	PropertyBookingController pbcObject = new PropertyBookingController();
    	pbcObject.availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 5';
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		System.currentPageReference().getParameters().put('id', createServiceRequestList[0].Id); 	  
		pbcObject.selectPaymentPlan();
    }
    
     static testMethod void testSelectPaymentMethodOnSubmission() {  
     	PropertyBookingController pbcObject = new PropertyBookingController();
     	pbcObject.availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 5';
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		System.currentPageReference().getParameters().put('id', createServiceRequestList[0].Id); 	  
		pbcObject.selectPaymentMethod();
    }
    
    static testMethod void testSubmitBookingOnSubmission() {
    	PropertyBookingController pbcObject = new PropertyBookingController();
    	pbcObject.availableInventoriesList.dealRecord.Booking_Wizard_Level__c = 'Level 5';
    	setup();
    	Test.setCurrentPageReference(new PageReference('Page.PropertyBooking')); 
		System.currentPageReference().getParameters().put('id', createServiceRequestList[0].Id); 	  
		pbcObject.submitBooking();
    }
}// End of class.