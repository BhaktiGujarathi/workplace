/**
* Class LTG_TransitionToIOP
*
* Class LTG_TransitionToIOP for the LTG_Transition_To_IOP VF page. This class implements the functionality
* to Transition To IOP of Opportunity.
*/
public class LTG_TransitionToIOP
{
    public Opportunity newOpportunity;
    public LTG_TransitionToIOP(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_TransitionToIOP() {   
    }
    
    public PageReference LTG_TransitionToIOP() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
        //var result = confirm("Transferring will close this opportunity and create a new IOP opportunity. Are you sure you would like to proceed?");
        if(!isLockedFlag)
        {  
            try { 
                opportunity objOpportunity = new opportunity();
                objOpportunity.id = newOpportunity.id; 
                Id opportunityId = OpportunityTransition.triggerTransitionToIOP(newOpportunity.id);                 
                PageReference pageRef;           
                pageRef= new PageReference('/'+opportunityId);
                pageRef.setRedirect(true);
                return pageRef;
            } catch(exception e) { 
                string exc = string.valueof(e);
                if(exc.indexOf('Opportunity is closed') != -1){ 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Transition cannot proceed as opportunity is closed.'));
                }else { 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error occured while performing transition operation.'));
                } 
                return null;
            }          
        }
        else if(isLockedFlag)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
        return null;
    }
}