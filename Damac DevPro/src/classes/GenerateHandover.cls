public with sharing class GenerateHandover {

    public GenerateHandover(ApexPages.standardController controller){
      
        
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
		//List<SR_Attachments__c> lstSRAttach = new List<SR_Attachments__c>();
		list<Attachment> lstAttach = new list<Attachment>();
		list<Task> lstTask = new list<Task>();
		for (Booking_Unit__c objBU : lstBU) {        	
        	String strPDfName1 = 'Handover Pack';
       		Attachment objAttachmnt1 = new Attachment(parentId = objBU.ID, name= strPDfName1, body = blob.toPdf('Handover Pack'), ContentType='PDF');
       		lstAttach.add(objAttachmnt1);
       		
       		Task objTask = new Task();
			objTask.Subject = 'Send Handover Package';
			objTask.Status = 'Not Started';
			objTask.Priority = 'Medium';
			objTask.ownerId = '0050Y000001SC4L';
			objTask.WhatId = objBU.Id;
			objTask.Process_Name__c = 'Handover';
			lstTask.add(objTask);      		
		}
       	        
        insert lstAttach ;
        insert lstTask;
        
		pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
    	newpg.setRedirect(true);
       	return newpg;		
    }
    
        
}