/**
* Class LTG_ApproveAndSendToTier
*
* Class LTG_ApproveAndSendToTier for the LTG_Approve_And_Send_To_Tier VF page. This class implements the functionality
* to Approve and Send to Tier of Opportunity.
*/
public class LTG_ApproveAndSendToTier
{
    public Opportunity newOpportunity;
    public LTG_ApproveAndSendToTier(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_ApproveAndSendToTier() {
    }
    
    public PageReference LTG_ApproveAndSendToTier() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            if(newOpportunity.stagename == 'Pending Appointment') {   
                string returnToId = ApproveNSendToTierTaskCreationService.triggerTaskCreationForApproval(newOpportunity.Id);
                string alertMsg = HttpCallForOppTier.callPost(newOpportunity.Id);  
                
                PageReference pageRef;
                pageRef= new PageReference('/'+newOpportunity.id);              
                pageRef.setRedirect(true);
                return pageRef;       
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Stage must be in Pending Appointment in order to approve and send to Tier.')); 
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