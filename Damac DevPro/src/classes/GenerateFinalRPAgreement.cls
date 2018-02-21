public with sharing class GenerateFinalRPAgreement{
    
  
    
    public GenerateFinalRPAgreement(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
       
        SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
        objSRAtt1.Name = 'Executed Final Rental Pool Agreement'; 
        objSRAtt1.Case__c = strPageID; 
        objSRAtt1.description__c = 'Executed Final Rental Pool Agreement';
        objSRAtt1.type__c = 'PDF';
        insert objSRAtt1;
       
        String strPDfName1 = 'Executed Final Rental Pool Agreement';
       
        Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt1.ID, name= strPDfName1, body = blob.toPdf('Executed Final Rental Pool Agreement'), ContentType='PDF');
        insert objAttachmnt1;
        
        
        Case objCase = [select ID, Rental_Pool_Agreement_Date__c,
                                Rental_Pool_Contract_Start_Date__c, 
                                Status, Rental_Pool_Contract_End_Date__c from Case 
                                where ID =: strPageID];
         
         objCase.RentalPoolAgreementAttachment__c = objAttachmnt1.Id;
         objCase.Status = 'Agreement Executed';
         update objCase;
        
        Task objTask  = new Task();
        objTask.Subject = 'Update commencement date in System';
        objTask.WhatID = strPageID ; 
        objTask.OwnerId = '0050Y0000011z5q';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        objTask.Process_Name__C = 'Rental Pool Agreement';
        insert objTask;

        Task objFinalRPTask = [Select ID,
                                  status
                             from Task
                            where subject =: 'Execute Agreement and release to CRE'
                              and OwnerId =: '0050Y0000011z5x'
                              and WhatID =: strPageID];
        objFinalRPTask.Status = 'Completed';
        update objFinalRPTask;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End GenerateFinalRPAgreement