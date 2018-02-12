/**
* Class LTG_CounterOffer
*
* Class LTG_CounterOffer for the LTG_Counter_Offer VF page. This class implements the functionality
* to Counter Offer of Opportunity.
*/
public class LTG_CounterOffer
{
    public Quote newQuote;
    public LTG_CounterOffer(ApexPages.StandardController controller) {
        this.newQuote= (Quote)controller.getRecord();
    }
    
    public LTG_CounterOffer() {
    }
    
    public PageReference LTG_CounterOffer() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id,Status__c,Determination_Script_Read_to_Patient__c,OpportunityId from Quote where id =: currentPIId];
        System.debug('newQuote '+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
    
        if(!isLockedFlag) {  
            PageReference pageRef;
            pageRef= new PageReference('/apex/PAW_New_Edit?Clone=Clone&quoteId='+newQuote.Id);
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