/**
* Class LTG_StepDown
*
* Class LTG_StepDown for the LTG_Step_Down VF page. This class implements the functionality
* to Step Down of Opportunity.
*/
public class LTG_StepDown
{
    public Opportunity newOpportunity;
    public LTG_StepDown(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_StepDown() {   
    }
    
    public PageReference LTG_StepDown() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            try { 
                opportunity objOpportunity = new opportunity();
                objOpportunity.id = newOpportunity.id; 
                Id opportunityId = OpportunityStepDown.triggerRTCStepDown(newOpportunity.id);                 
                PageReference pageRef;           
                pageRef= new PageReference('/'+opportunityId);
                pageRef.setRedirect(true);
                return pageRef;
            } catch(exception e) { 
                string exc = string.valueof(e);
                if(exc.indexOf('The source opportunity is not in Admitted stage') != -1){ 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The source opportunity is not in Admitted stage'));
                }else { 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error during step down'));
                } 
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