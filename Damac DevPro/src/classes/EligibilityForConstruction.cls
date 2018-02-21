public with sharing class EligibilityForConstruction{

    public EligibilityForConstruction(ApexPages.standardController controller){
        
    }//End constructor
    
    public pagereference init(){
        list<Case> lstCase = new list<Case>();
         string strPageID = ApexPages.currentPage().getParameters().get('id');
         
         for (Case objCase : [Select Id, Plot_Handover_Status__c, PDC__c, Minimum_Payment_Done__c From Case Where Id =: strPageID ]) {
             objCase.Plot_Handover_Status__c = 'Check Eligibility for Construction';
             objCase.PDC__c = 'Provided'; 
             objCase.Minimum_Payment_Done__c = true;
             lstCase.add(objCase);
         }
         
         update lstCase;
         
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }
}