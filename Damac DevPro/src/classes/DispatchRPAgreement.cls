public with sharing class DispatchRPAgreement{
  
    public DispatchRPAgreement(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        string strBookingUnitID; 
        string strRecordTypeName;
       
        Case objCase = [select ID, RecordType.DeveloperName, Booking_Unit__c, AWB_Number__c, Rental_Pool_Agreement_Dispatch_Date__c
                                   from Case where ID =: strPageID ];
          strBookingUnitID = objCase.Booking_Unit__c;
          strRecordTypeName = objCase.RecordType.DeveloperName;
          objCase.AWB_Number__c = 'AWB-14253';
          if (objCase.RecordType.DeveloperName == 'Rental_Pool_Agreement'){
          objCase.Rental_Pool_Agreement_Dispatch_Date__c = date.today();
          }else if (objCase.RecordType.DeveloperName == 'Rental_Pool_Termination'){
          objCase.Rental_Pool_Termination_Dispatched_Date__c= date.today();
          objCase.Status = 'Letter of Termination Dispatched';
          }
          //objCase.Status = 'Closed';
          update objCase;
          
          Task objDispatchTask = new Task();
         if (objCase.RecordType.DeveloperName == 'Rental_Pool_Agreement') {
            Booking_Unit__c objBU = [select ID, Rental_Pool__c, Rental_Pool_Status__c from Booking_Unit__c  where ID =: strBookingUnitID];
            objBU.Rental_Pool_Status__c  = 'Rental Pool Completed';
            objBU.Rental_Pool__c = true;
            update objBU ;
         

        objDispatchTask = [Select ID,
                                  status
                             from Task
                            where subject =: 'Dispatch Executed Agreement To Customer'
                              and OwnerId =: '0050Y000001SBsP'
                              and WhatID =: strPageID];
        objDispatchTask.Status = 'Completed';
        
       }else{
        objDispatchTask = [Select ID,
                                  status
                             from Task
                            where subject =: 'Dispatch Rental Pool Termination Letter'
                              and OwnerId =: '0050Y000001SVjm'
                              and WhatID =: strPageID];
        objDispatchTask.Status = 'Completed';
       }
        update objDispatchTask;
        
        Task objTask  = new Task();
                objTask.Subject = 'Close Rental Pool SR';
                objTask.WhatID = strPageID; 
                objTask.OwnerId = '0050Y000001SBsP';
                objTask.status = 'In Progress';
                objTask.priority= 'Medium';
                if (objCase.RecordType.DeveloperName == 'Rental_Pool_Agreement')
                objTask.Process_Name__C = 'Rental Pool Agreement';
               else if (objCase.RecordType.DeveloperName == 'Rental_Pool_Termination')
                objTask.Process_Name__C = 'Rental Pool Termination';
        insert objTask;
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End DispatchRPAgreement