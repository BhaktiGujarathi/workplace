/**
* Class LTG_ACAssignToMe
*
* Class LTG_ACAssignToMe for the VobAssignToMe VF page. This class implements the functionality
* to LTG_ACAssignToMe of Opportunity.
*/
public class LTG_ACAssignToMe
{
    public Opportunity newOpportunity;
    public LTG_ACAssignToMe(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_ACAssignToMe() {
    }
    
    public PageReference LTG_ACAssignToMe() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,AC_Assigned__c from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {    
            string successfullyShared = OppShareContr.shareOpportunity(newOpportunity.Id);  
            Opportunity opportunityToUpdate = new Opportunity();      
            opportunityToUpdate.Id = newOpportunity.Id; 
            opportunityToUpdate.AC_Assigned__c = UserInfo.getUserId(); 
            try{
                update opportunityToUpdate;
                system.debug('opportunityToUpdate'+opportunityToUpdate);                
            } catch (Exception e) {
                system.debug('DML failed --- Error'+e);
                return null;
            }
            PageReference pageRef;
            pageRef= new PageReference('/'+newOpportunity.id);              
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