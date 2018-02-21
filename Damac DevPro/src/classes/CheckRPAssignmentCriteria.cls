public with sharing class CheckRPAssignmentCriteria {
	
	public CheckRPAssignmentCriteria(ApexPages.standardController controller){
        
    }//End constructor
    
    public pagereference init(){
        list<Case> lstCase = new list<Case>();
         string strPageID = ApexPages.currentPage().getParameters().get('id');
         
         for (Case objCase : [Select Id, Dues_Cleared__c, NOC_generated_in_last_15_days__c, 
         							Assignment_Fee_Collected__c, FM_Dues_Collected__c From Case Where Id =: strPageID ]) {
             objCase.Dues_Cleared__c = true;
             objCase.NOC_generated_in_last_15_days__c = true;
             objCase.Assignment_Fee_Collected__c = true;
             objCase.FM_Dues_Collected__c = false;
             lstCase.add(objCase);
         }
         
         update lstCase;
         
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }
    
}