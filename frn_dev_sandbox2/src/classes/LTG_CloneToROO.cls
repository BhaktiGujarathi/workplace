/**
* Class LTG_CloneToROO
*
* Class LTG_CloneToROO for the LTG_Clone_To_ROO VF page. This class implements the functionality
* to Clone To IOP of Opportunity.
*/
public class LTG_CloneToROO
{
    public Opportunity newOpportunity;
    public LTG_CloneToROO(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_CloneToROO() {
    }
    
    public PageReference LTG_CloneToROO() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            try {
                Id opportunityId = cloneOpportunity.cloneOpptyRecordType(newOpportunity.Id);
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