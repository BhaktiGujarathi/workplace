/**
* Class LTG_RAMAssigntoME
*
* Class LTG_RAMAssigntoME for the LTG_RAM_Assign_to_ME VF page. This class implements the functionality
* to RAM Assign to ME of Opportunity.
*/
public class LTG_RAMAssigntoME
{
    public Opportunity newOpportunity;
    public LTG_RAMAssigntoME(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_RAMAssigntoME() {
    }
    
    public PageReference LTG_RAMAssigntoME() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            string isShared = OppShareContr.shareOpportunity(newOpportunity.Id);
            Opportunity objOpportunityToUpdate = new Opportunity();
            if(isShared =='success'){
                objOpportunityToUpdate.id = newOpportunity.Id;
                objOpportunityToUpdate.RAM_Assigned__c = UserInfo.getUserId();
                           
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
            return null;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}