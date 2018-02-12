/**
* Class LTG_CreateMessage
*
* Class LTG_CreateMessage for the LTG_Create_Message VF page. This class implements the functionality
* to Create Message of Opportunity.
*/
public class LTG_CreateMessage
{
    public Quote newQuote;
    public LTG_CreateMessage(ApexPages.StandardController controller) {
        this.newQuote= (Quote)controller.getRecord();
    }
    
    public LTG_CreateMessage() {
    }
    
    public PageReference LTG_CreateMessage() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id,Status__c,Determination_Script_Read_to_Patient__c,OpportunityId from Quote where id =: currentPIId];
        System.debug('newQuote '+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
    
        if(!isLockedFlag) {  
            PageReference pageRef;
            pageRef= new PageReference('/apex/CreateNoteCommentPage?id='+newQuote.Id);
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