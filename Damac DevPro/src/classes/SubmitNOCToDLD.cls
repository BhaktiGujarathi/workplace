public with sharing class SubmitNOCToDLD{
  
    public SubmitNOCToDLD(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        list<Case> lstCase = new list<Case>();
        for(Case objCase : [select ID, Status from Case where ID =: strPageID ]){
           objCase.Status = 'Title Deed Uploaded';
           lstCase.add(objCase);
        }
      update lstCase;
        
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}//End SubmitNOCToDLD