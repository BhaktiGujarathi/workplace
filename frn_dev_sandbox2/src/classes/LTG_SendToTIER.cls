/**
* Class LTG_SendToTIER
*
* Class LTG_SendToTIER for the LTG_Send_To_TIER VF page. This class implements the functionality
* to Send To TIER of Opportunity.
*/
public class LTG_SendToTIER
{
    public Opportunity newOpportunity;
    public LTG_SendToTIER(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_SendToTIER() {   
    }
    
    public PageReference LTG_SendToTIER() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            if(newOpportunity.stagename == 'Pending Admission') {
                string opportunityId = HttpCallForOppTier.callPost(newOpportunity.id);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,opportunityId));
                PageReference pageRef;           
                pageRef= new PageReference('/'+newOpportunity.id);
                pageRef.setRedirect(true);
                return pageRef;
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'For sending to tier, the stage of Opportunity must be Pending Admission.'));
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