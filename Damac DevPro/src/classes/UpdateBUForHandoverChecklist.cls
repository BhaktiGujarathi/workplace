public with sharing class UpdateBUForHandoverChecklist {
	
	@InvocableMethod (label='' description='')
	public static void updateBU (List<Id> listBuildingId) {
		List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();
		for (Inventory__c objInventory : [Select Id, Building_Location__c ,
												(Select Id, Handover_Readiness_Checklist__c, JOPD_Area__c 
												 From Booking_Units__r)
											  From Inventory__c 
											  Where Building_Location__c IN: listBuildingId]) {
			lstBookingUnit.addAll(objInventory.Booking_Units__r);						  	
		}
		
		list<Booking_Unit__c> updatedBU = new list<Booking_Unit__c>();
		for (Booking_Unit__c objBU : lstBookingUnit){
			if (objBU.JOPD_Area__c != null){
				objBU.Handover_Readiness_Checklist__c = true;
				updatedBU.add(objBU);
			}
		}
		
		if (updatedBU != null && updatedBU.size()> 0){
			update updatedBU;
		}
		
	}
    
}