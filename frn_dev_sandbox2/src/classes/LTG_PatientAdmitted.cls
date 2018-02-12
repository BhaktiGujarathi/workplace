/**
* Class LTG_PatientAdmitted
*
* Class LTG_PatientAdmitted for the LTG_Patient_Admitted VF page. This class implements the functionality
* to Patient Admitted of Opportunity.
*/
public class LTG_PatientAdmitted
{
    public Opportunity newOpportunity;
    public LTG_PatientAdmitted(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_PatientAdmitted() {
    }
    
    public PageReference LTG_PatientAdmitted() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            Opportunity objOpportunityToUpdate = new Opportunity();
            objOpportunityToUpdate.id = newOpportunity.Id;
            objOpportunityToUpdate.StageName = 'Admitted';            
            try {
                update objOpportunityToUpdate;
                PageReference pageRef;
                pageRef= new PageReference('/'+objOpportunityToUpdate.id);
                pageRef.setRedirect(true);
                return pageRef;
                
            } catch(exception e) {
                System.debug('<<<<<<<<<<<<<<DML failed <<<<<<<<<<<<<<<<'+e);
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