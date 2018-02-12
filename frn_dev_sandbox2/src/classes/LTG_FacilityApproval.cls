/**
* Class LTG_FacilityApproval
*
* Class LTG_FacilityApproval for the LTG_Facility_Approval VF page. This class implements the functionality
* to Facility Approval of Opportunity.
*/
public class LTG_FacilityApproval
{
    public Opportunity newOpportunity;
    public LTG_FacilityApproval(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_FacilityApproval() {
    }
    
    public PageReference LTG_FacilityApproval() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
                string caseRecordType = 'Facility Approval';                
                PageReference pageRef;
                pageRef= new PageReference('/apex/FacilityApprovalVfPage?id='+newOpportunity.Id+'&recType='+caseRecordType);
                pageRef.setRedirect(true);
                return pageRef;
                
            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}