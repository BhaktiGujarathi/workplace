/**
* Class LTG_GenerateInsuranceDocumentation
*
* Class LTG_GenerateInsuranceDocumentation for the LTG_Generate_Insurance_Documentation VF page. This class implements the functionality
* to Generate Insurance Documentation of Opportunity.
*/
public class LTG_GenerateInsuranceDocumentation
{
    public Opportunity newOpportunity;
    public LTG_GenerateInsuranceDocumentation(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_GenerateInsuranceDocumentation() {
    }
    
    public PageReference LTG_GenerateInsuranceDocumentation() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            list<Quote> lstQuotes = new list<Quote>();
            lstQuotes = [Select Id From Quote Where OpportunityId =: newOpportunity.id  AND Select_as_Final_Quote__c = true];
            
            if(lstQuotes.size() > 0) {  
                PageReference pageRef;
                pageRef= new PageReference('/apex/NAC_OpportunityPage?id='+newOpportunity.Id+'&Qid='+lstQuotes[0].Id);
                pageRef.setRedirect(true);
                return pageRef;
            } 
            else { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There has not been a quote selected as final for this opportunity.'));
                return null;
            } 
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}