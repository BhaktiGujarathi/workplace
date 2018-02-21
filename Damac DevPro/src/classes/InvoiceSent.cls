public with sharing class InvoiceSent{
    
    public InvoiceSent(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        list<Booking_Unit__c> lstBU = new list<Booking_Unit__c>();
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        for (Inventory__c objInventory : [Select Id, Building_Location__c ,
												(Select Id, Eligible_For_Early_Handover__c, Approved_By_HOD__c, Early_Handover__c, Handover_Complete__c,
														Handover_Flag__c, Handover_Date__c, Communications_to_be_Sent__c, Final_Invoice__c
												 From Booking_Units__r)
											  From Inventory__c 
											  Where Building_Location__c =: strPageID]) {
				
			
			for (Booking_Unit__c objBU : objInventory.Booking_Units__r) {
					if (objBU.Handover_Flag__c == 'Ready For Handover' && objBU.Early_Handover__c == false &&
						objBU.Handover_Complete__c == false) {
							//setBookingUnitId.add(objBU.Id);
							lstBU.add(objBU);
					}
			}										  
		}
		        
        List<Booking_Unit__c> updateBUs = new List<Booking_Unit__c>();
		for (Booking_Unit__c objBU :lstBU){
			/*if (mapBookingUnitPaymentDate.get(objBU.Id) > objBU.Handover_Date__c){
				objBU.Eligible_For_Early_Handover__c = true;
				updateBUs.add(objBU);
			}*/
			
			objBU.Final_Invoice__c = '200';
			updateBUs.add(objBU);
		}
		
		if (updateBUs != null && updateBUs.size() > 0){
			update updateBUs;
		}
       
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateBUDocs