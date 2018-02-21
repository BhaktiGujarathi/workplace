public with sharing class UnitsForEarlyHandover {
	
	public UnitsForEarlyHandover(ApexPages.standardController controller){
       
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
    	List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();
    	set<Id> setBookingUnitId = new Set<Id>();
    	map<Id, Date> mapBookingUnitPaymentDate = new map<Id, Date>();
    	
    	for (Inventory__c objInventory : [Select Id, Building_Location__c ,
												(Select Id, Eligible_For_Early_Handover__c, Approved_By_HOD__c, Early_Handover__c, Handover_Complete__c,
														Handover_Flag__c, Handover_Date__c
												 From Booking_Units__r)
											  From Inventory__c 
											  Where Building_Location__c =: strPageID]) {
				
			
			for (Booking_Unit__c objBU : objInventory.Booking_Units__r) {
					if (objBU.Handover_Flag__c == 'Ready For Handover' && objBU.Early_Handover__c == false &&
						objBU.Handover_Complete__c == false) {
							setBookingUnitId.add(objBU.Id);
							lstBookingUnit.add(objBU);
					}
			}										  
		}
		
		for (Payment_Terms__c objPT : [Select Id, Payment_Date__c, Booking_Unit__c 
										From Payment_Terms__c Where Booking_Unit__c IN: setBookingUnitId] ) {
			if (mapBookingUnitPaymentDate.containsKey(objPT.Booking_Unit__c)) {
					Date paymentDate = mapBookingUnitPaymentDate.get(objPT.Booking_Unit__c);
					if (objPT.Payment_Date__c > paymentDate) {
						mapBookingUnitPaymentDate.put(objPT.Booking_Unit__c, objPT.Payment_Date__c);
					}
				} else {
					mapBookingUnitPaymentDate.put(objPT.Booking_Unit__c, objPT.Payment_Date__c);
				}		
		}
		
		List<Booking_Unit__c> updateBUs = new List<Booking_Unit__c>();
		for (Booking_Unit__c objBU :lstBookingUnit){
			if (mapBookingUnitPaymentDate.get(objBU.Id) > objBU.Handover_Date__c){
				objBU.Eligible_For_Early_Handover__c = true;
				updateBUs.add(objBU);
			}
		}
		
		if (updateBUs != null && updateBUs.size() > 0){
			update updateBUs;
		}
		
	   pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
    }
    
}