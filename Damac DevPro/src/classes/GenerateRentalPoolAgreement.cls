public with sharing class GenerateRentalPoolAgreement{
    
  
    
    public GenerateRentalPoolAgreement(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name = 'Rental Pool Agreement'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'Rental Pool Agreement';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
       
        String strPDfName1 = 'CRF';
       
        string strBookingUnitID;
        
        Case objCase = [select ID, Booking_Unit__c, Rental_Pool_Agreement_Date__c,
                                Rental_Pool_Contract_Start_Date__c, 
                                Status, Rental_Pool_Contract_End_Date__c from Case 
                                where ID =: strPageID];
         strBookingUnitID = objCase.Booking_Unit__c; 
         objCase.Rental_Pool_Agreement_Date__c = date.Today();
         objCase.Rental_Pool_Contract_Start_Date__c = date.Today();
         objCase.Rental_Pool_Contract_End_Date__c = date.Today() + 365;
         
         objCase.Status = 'Agreement Generated';
         update objCase;
        
        Booking_Unit__c objBU = [select ID, Rental_Pool_Start_Date__c, Rental_Pool_End_Date__c
                                  from Booking_Unit__c  where ID =: strBookingUnitID ];
        objBU.Rental_Pool_Start_Date__c = date.Today();
        objBU.Rental_Pool_End_Date__c = date.Today() + 365;
        update objBU ;
        
        list<Task> lstTask = new list<task>();
        for (Task TaskObj : [Select Id, Subject, Process_Name__c, status, WhatID From Task 
        						Where WhatID =: strPageID And Process_Name__c = 'Rental Pool Assignment' 
        						And Subject = 'Generate Rental Pool Agreement' ]) {
        		TaskObj.status = 'Completed';
        		lstTask.add(TaskObj);	
        }
        
        if (lstTask != null && lstTask.size() > 0) {
        	update lstTask;
        }
                 
        Task objTask  = new Task();
        objTask.Subject = 'Rental Pool Agreement Review & Obtain Customer Signature';
        objTask.WhatID = strPageID ; 
        objTask.OwnerId = '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        objTask.Process_Name__c = 'Rental Pool Assignment';
        insert objTask;

        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End UploadTDDocument