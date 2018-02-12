/**
* Class LTG_ViewNAC
*
* Class LTG_ViewNAC for the LTG_View_NAC VF page. This class implements the functionality
* to LTG_View_NAC of Opportunity.
*/
public class LTG_ViewNAC
{
    public Opportunity newOpportunity;
    public LTG_ViewNAC(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_ViewNAC() {   
    }
    
    public PageReference LTG_ViewNAC() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
        //var result = confirm("Transferring will close this opportunity and create a new IOP opportunity. Are you sure you would like to proceed?");
        if(!isLockedFlag)
        {                           
            PageReference pageRef;           
            pageRef= new PageReference('/apex/Generate_NAC_page?id='+newOpportunity.id);
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