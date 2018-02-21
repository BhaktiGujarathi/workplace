public with sharing class VerifyDuesForTD{
  
    public VerifyDuesForTD(ApexPages.standardController controller){
      
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Case> lstCase = new list<Case>();
        For(Case objCase : [select ID,
                                   Penalties_LP_Fee_on_Service_Charges__c,
                                   Other_Dues__c,
                                   Admin_Fee_For_Title_Deed__c,
                                   Overdues_Dues_Towards_Service_Charges__c,
                                   Total_Amount_To_Be_Paid__c
                              from Case
                             where ID =: strPageID ]){
                       
               objCase.Penalties_LP_Fee_on_Service_Charges__c  = 'Done';
               objCase.Other_Dues__c = 'Done';
               objCase.Admin_Fee_For_Title_Deed__c= 'Done';
               objCase.Overdues_Dues_Towards_Service_Charges__c= 'Done';
               objCase.Total_Amount_To_Be_Paid__c= 'None';
               lstCase.add(objCase);
       }//End for
       
       Update lstCase;
       
        Task objTask  = new Task();
        objTask.Subject = 'Verify Payment Dues';
        objTask.WhatID = strPageID ; 
        objTask.OwnerID= '0050Y000001SBsP';
        objTask.status = 'In Progress';
        objTask.priority= 'Medium';
        insert objTask;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End VerifyDuesForTD