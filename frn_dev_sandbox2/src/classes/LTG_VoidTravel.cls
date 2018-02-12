/**
* Class LTG_VoidTravel
*
* Class LTG_VoidTravel for the LTG_Void_Travel VF page. This class implements the functionality
* to Void Travel of Opportunity.
*/
public class LTG_VoidTravel
{
    public Opportunity newOpportunity;
    public LTG_VoidTravel(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_VoidTravel() {   
    }
    
    public PageReference LTG_VoidTravel() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,StageName from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
        if(!isLockedFlag)
        {   
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String MyProflieName = PROFILE[0].Name;
            VoidTravelExt.request(newOpportunity.Id,newOpportunity.StageName,MyProflieName);
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