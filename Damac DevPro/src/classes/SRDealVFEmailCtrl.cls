public class SRDealVFEmailCtrl {
	
	public Id bookingId {get; set;}
	public Map<String, Booking_Unit__c> bookingUnitsMap {
		get{
			return bookingId != null ? getBookingUnitsDetails(bookingId) : new Map<String, Booking_Unit__c>();
		}
		set;
	}
	public Set<String> bookingUnitIdsSet {	
		get{
			return !bookingUnitsMap.isEmpty() ? bookingUnitsMap.keySet() : new Set<String>();
		} 
		set;
	}
	public Map<String, Payment_Plan__c> bookingUnitPaymentPlanMap{
		get{
			return bookingUnitIdsSet != null && !bookingUnitIdsSet.isEmpty() ? getPaymentPlans(bookingUnitIdsSet) : new Map<String, Payment_Plan__c>();
		}
		set;
	}
	
	public CustomerDetailsWrapper cdwObject {
		get{
			return bookingId != null ? getBuyers(bookingId) : new CustomerDetailsWrapper();
		} 
		set;
	}
	
	public SalesPersonnelDetailWrapper spdwObject {
		get{
			return bookingId != null ? getBookingRelatedDetails(bookingId) : new SalesPersonnelDetailWrapper();	
		}
		set;
	}
	
	@TestVisible private SalesPersonnelDetailWrapper getBookingRelatedDetails(Id bookingId){
		SalesPersonnelDetailWrapper spdwObject;
		for(Booking__c thisBooking : [SELECT Id, Deal_SR__r.Owner.Name, Deal_SR__r.Agent_Name__r.Name,
											 Deal_SR__r.Total_Token_Amount__c 
									  FROM Booking__c 
									  WHERE Id =: bookingId]){ 
			spdwObject = new SalesPersonnelDetailWrapper(thisBooking.Deal_SR__r.Owner.Name, 
														 '', 
														 thisBooking.Deal_SR__r.Agent_Name__r.Name, 
														 thisBooking.Deal_SR__r.Total_Token_Amount__c);
			break;					
		}
		return spdwObject;
	}
	
	@TestVisible private Map<String, Booking_Unit__c> getBookingUnitsDetails(Id bookingId){
		Map<String, Booking_Unit__c> bookingUnitsMap = new Map<String, Booking_Unit__c>();
		for(Booking_Unit__c thisUnit :  [SELECT Id, Name, Booking__c, Selling_Price__c, 
													Unit_Details__c, Inventory__c, Inventory__r.Unit_Type__c, 
													Inventory__r.Area__c, Inventory__r.Special_Price__c,
													Inventory__r.Property_Name_2__c, Requested_Price__c,
													Inventory__r.Area_Sqft_2__c
									 	FROM Booking_Unit__c
									    WHERE Booking__c =: bookingId]){ 
			bookingUnitsMap.put(thisUnit.Id, thisUnit);			
		}	
		return bookingUnitsMap;
	}
	
	@TestVisible private Map<String, Payment_Plan__c> getPaymentPlans(Set<String> selectedBookingUnitIdsSet){
		Map<String, Payment_Plan__c> bookingUnitPaymentPlan = new Map<String, Payment_Plan__c>(); 
		for(Payment_Plan__c thisPaymentPlan : [SELECT Id, Building_ID__c, Name, Booking_Unit__c, Booking_Unit__r.Booking__c,
													  (SELECT Id, Description__c, Milestone_Event__c, 
													          Milestone_Event_Arabic__c, Percent_Value__c,
													          Booking_Unit__c, Modified_Percent_Value__c 
													   FROM Payment_Terms__r)	
					                           FROM Payment_Plan__c 
						                       WHERE Booking_Unit__c IN: selectedBookingUnitIdsSet]){
    		bookingUnitPaymentPlan.put(thisPaymentPlan.Booking_Unit__c, thisPaymentPlan);
    	}
    	return bookingUnitPaymentPlan;
	}
	
	@TestVisible private CustomerDetailsWrapper getBuyers(Id bookingId){
		CustomerDetailsWrapper cdwObject = new CustomerDetailsWrapper();
		for(Buyer__c thisBuyer :  [SELECT Id, Primary_Buyer__c, First_Name__c, First_Name_Read__c, Booking__c
								   FROM Buyer__c 
								   WHERE Booking__c =: bookingId]){ 
			if(thisBuyer.Primary_Buyer__c){
				cdwObject.primaryBuyerName = thisBuyer.First_Name__c;
				cdwObject.primaryBuyerScannedName = thisBuyer.First_Name_Read__c;
			}else{
				cdwObject.jointBuyersName += thisBuyer.First_Name__c+',';	
				cdwObject.jointBuyersScannedName += thisBuyer.First_Name_Read__c+',';
			}	
		}
		for(Booking_Unit__c thisUnit : bookingUnitsMap.values()){
			cdwObject.projectsName += thisUnit.Inventory__r.Property_Name_2__c + ',';	
			cdwObject.totalSellingPrice += thisUnit.Selling_Price__c;
		}
		cdwObject.numberOfUnits = bookingUnitsMap.keySet().size();
		return cdwObject;
	}
	
	public class CustomerDetailsWrapper{
		public String primaryBuyerName {get; set;}
		public String primaryBuyerScannedName {get; set;}
		public String jointBuyersName {get; set;}
		public String jointBuyersScannedName {get; set;}
		public String projectsName {get; set;}
		public Integer numberOfUnits {get; set;}
		public Decimal totalSellingPrice {get; set;}
			
		public CustomerDetailsWrapper(){ 
			primaryBuyerName = '';
			primaryBuyerScannedName = '';
			jointBuyersName = '';
			jointBuyersScannedName = '';
			projectsName = '';
			totalSellingPrice = 0.0;
		}
	}
	
	public class SalesPersonnelDetailWrapper{
		public String pcName {get; set;}
		public String dosName {get; set;}
		public String agentName {get; set;}
		public Decimal requestedTokenAmount {get; set;}
		
		public SalesPersonnelDetailWrapper(){ }
		public SalesPersonnelDetailWrapper(String pcName, String dosName, String agentName, Decimal requestedTokenAmount){
			this.pcName = pcName;
			this.dosName = dosName;	
			this.agentName = agentName;	
			this.requestedTokenAmount = requestedTokenAmount;
		}
	}
}// End of class.