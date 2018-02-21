public with sharing class GeneratePenalties{

    public GeneratePenalties(ApexPages.standardController controller){
        
    }//End constructor
    
    public pagereference init(){
        list<Case> lstCase = new list<Case>();
         string strPageID = ApexPages.currentPage().getParameters().get('id');
         
         for (Case objCase : [Select Id, Notice_Period__c, Penalty_Amount__c, Penalty_as_of_date__c From Case Where Id =: strPageID ]) {
             objCase.Notice_Period__c = '1 year';
             objCase.Penalty_Amount__c = 200;
             objCase.Penalty_as_of_date__c = date.today() + 30;
             lstCase.add(objCase);
         }
         
         update lstCase;
         
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }
}