public class BenefitsRelatedCasesExt{    
    public list<Case> caseList{get;set;}
    public boolean showTable {get;set;} 
    public string parameter {get;set;}
    
    public BenefitsRelatedCasesExt(ApexPages.StandardController controller) {
        caseList = new list<Case>();
        showTable = false;

        String benifitId = ApexPages.CurrentPage().getparameters().get('id');
        String opptyId =  [select id, Patient_Insurance__c, Patient_Insurance__r.Opportunity__c  from Insurance_Benefit__c where Id=: benifitId].Patient_Insurance__r.Opportunity__c;
            system.debug('benifitId____________________________'+benifitId);
            system.debug('opptyId______________________________'+opptyId);
            
            if(opptyId != null){
                caseList = [SELECT Id,CaseNumber, AccountId, Account.Name, CreatedDate, Opportunity__c, Status, Subject FROM Case WHERE Opportunity__c=: opptyId ORDER by CreatedDate DESC];
                    system.debug('caseList______________________________'+caseList);
                    if(caseList!=null) {
                        showTable = true;
                        system.debug('showTable______________________________'+showTable);                      
                    }
                    
            }       
        
    } 
    public PageReference caseDetail(){
        PageReference p = new PageReference('/'+parameter );
        p.setRedirect(true);
        return p;
    }
}