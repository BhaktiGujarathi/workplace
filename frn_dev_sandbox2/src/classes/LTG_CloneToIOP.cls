/**
* Class LTG_CloneToIOP
*
* Class LTG_CloneToIOP for the LTG_Clone_To_IOP VF page. This class implements the functionality
* to Clone To IOP of Opportunity.
*/
public class LTG_CloneToIOP
{
    public Opportunity newOpportunity;
    public LTG_CloneToIOP(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_CloneToIOP() {
    }
    
    public PageReference LTG_CloneToIOP() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            try {
                Id opportunityId = cloneOpportunity.cloneOutPatOppty(newOpportunity.Id);
                PageReference pageRef;
                pageRef= new PageReference('/'+opportunityId);
                pageRef.setRedirect(true);
                return pageRef;
                
            } catch(exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Current FRN IOP Facility does not exist or does not match filter criteria.'));
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