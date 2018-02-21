public with sharing class DocumentsApprovedByCRE{
    
  
    
    public DocumentsApprovedByCRE(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        
        Task objTask  = new Task();
        objTask.Subject = 'Execute Agreement and release to CRE';
        objTask.WhatID = strPageID ; 
        objTask.OwnerId = '0050Y000001SBxE';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask;

        /*Case objCase = [Select ID, Agreement_Commencement_Date__c from Case where ID =: strPageID];
        objCase.Agreement_Commencement_Date__c = date.Today();
        update objCase;*/
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End UploadTDDocument