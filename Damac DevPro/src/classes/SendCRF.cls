public with sharing class SendCRF{

    public SendCRF(ApexPages.standardController controller){
        
    }//End constructor
    
    public pagereference init(){
        list<Case> lstCase = new list<Case>();
         string strPageID = ApexPages.currentPage().getParameters().get('id');
         
         for (Case objCase : [Select Id, Rental_Pool_Termination_Status__c From Case Where Id =: strPageID ]) {
             objCase.Rental_Pool_Termination_Status__c = 'CRF & RPA Executed'; 
             lstCase.add(objCase);
         }
         
         update lstCase;
         
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }
}