/**
* Class LTG_VOBAssignToME
*
* Class LTG_VOBAssignToME for the LTG_VOB_Assign_To_ME VF page. This class implements the functionality
* to VOB Assign To ME of Opportunity.
*/
public class LTG_VOBAssignToME
{
    public Opportunity newOpportunity;
    public LTG_VOBAssignToME(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_VOBAssignToME() {   
    }
    
    public PageReference LTG_VOBAssignToME() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,VOB_Assigned__c from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
        if(!isLockedFlag)
        {   
            opportunity objOpportunity = new opportunity();
            objOpportunity.id = newOpportunity.Id;
            objOpportunity.VOB_Assigned__c = userinfo.getuserid();
            try {
                update objOpportunity;
            } catch (exception e) {
                System.debug('<<<<<<<<<<<<<< DML failed <<<<<<<<<<<<<<<<'+e);
            }
            PageReference pageRef;           
            pageRef= new PageReference('/'+objOpportunity.id);
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