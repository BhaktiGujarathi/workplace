public class ProofofPaymentController {
    public transient List<BookingUnitWrapper> lstBookingUnitWrapper {get;set;}
    public string strAccID;
    public List<Booking_Unit__c> listBookingUnit;
    public class BookingUnitWrapper
    {
	    public transient Booking_Unit__c objBookingUnit {get;set;}
	    public transient Boolean blnIsChecked {get;set;}
	    public transient String  strMatch {get;set;}
    }
    public ProofofPaymentController(){
    	strAccID = ApexPages.currentPage().getParameters().get('AccountId');
    	
    	BookingUnits();
    }
    
    private void BookingUnits(){
    	lstBookingUnitWrapper = new List<BookingUnitWrapper>();
    	listBookingUnit = new List<Booking_Unit__c>();
    	listBookingUnit = [SELECT Id,Name,Registration_ID__c,Inventory__r.Unit__c
                                   ,Inventory__r.Property_Name_2__c
                                   ,Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c
                                   ,Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c
                                   ,Inventory__r.Anticipated_Completion_Date__c
                                   ,Inventory__r.Property__r.Name
                                   ,Inventory__r.Property__c,Unit_Details__c
                           FROM Booking_Unit__c 
                           WHERE Booking__r.Account__c =: strAccID];
                           
        if(!listBookingUnit.isEmpty()){
        	for(Booking_Unit__c objBooking :listBookingUnit){
        		BookingUnitWrapper objWrapBook = new BookingUnitWrapper();
        		objWrapBook.objBookingUnit = objBooking;
        		lstBookingUnitWrapper.add(objWrapBook);
        	}
        	
        }
    	
    }
}