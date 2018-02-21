public with sharing class UnitEligibilityForHandover {
	
	public UnitEligibilityForHandover(ApexPages.standardController controller){
       
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
    	List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();
    	for (Inventory__c objInventory : [Select Id, Building_Location__c ,
												(Select Id, DSR_Flag__c, Dispute_Flag__c, Default__c, Offers_Available__c, 
														Document_Received__c, Deposit_Received__c, Mortgage__c, Booking_Undergoing_Termination__c, 
														Dispute__c, Litigation__c, Approved_By_HOD__c, Early_Handover__c, Handover_Complete__c,
														Handover_Flag__c
												 From Booking_Units__r)
											  From Inventory__c 
											  Where Building_Location__c =: strPageID]) {
			lstBookingUnit.addAll(objInventory.Booking_Units__r);											  
		}
		
		list<Booking_Unit__c> updateBU = new list<Booking_Unit__c>();
		for (Booking_Unit__c objBU : lstBookingUnit) {
			if (objBU.Approved_By_HOD__c == true && objBU.Handover_Complete__c == false
				&& objBU.Early_Handover__c == false) {
					objBU.Dispute_Flag__c = 'No';
					objBU.Default__c = false;
					objBU.Document_Received__c = true;
					objBU.Deposit_Received__c = true;
					objBU.Mortgage__c = false;
					objBU.Booking_Undergoing_Termination__c = false;
					objBU.Dispute__c = false;
					objBU.Litigation__c = false;
					objBU.Handover_Flag__c = 'Ready For Handover';
					updateBU.add(objBU);				
			}
		}
		
		if (updateBU != null && updateBU.size()>0){
			update updateBU;
		}
		
	   pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
    }
    
}