public with sharing class ReadinessForPlotHandover{

    public ReadinessForPlotHandover(ApexPages.standardController controller){
        
    }//End constructor
    
    public pagereference init(){
        list<Case> lstCase = new list<Case>();
         string strPageID = ApexPages.currentPage().getParameters().get('id');
         
         for (Case objCase : [Select Id, Plot_Ready_for_Handover__c, Plot_Handover_Status__c From Case Where Id =: strPageID ]) {
             objCase.Plot_Ready_for_Handover__c = true;
             objCase.Plot_Handover_Status__c = 'Preliminary Construction Activities';
             lstCase.add(objCase);
         }
         
         update lstCase;
         
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }
}