/**
* Class LTG_MarkScriptRead
*
* Class LTG_MarkScriptRead for the LTG_Mark_Script_Read VF page. This class implements the functionality
* to Mark Script Read of Opportunity.
*/
public class LTG_MarkScriptRead
{
    public Quote newQuote;
    public LTG_MarkScriptRead(ApexPages.StandardController controller) {
        this.newQuote= (Quote)controller.getRecord();
    }
    
    public LTG_MarkScriptRead() {
    }
    
    public PageReference LTG_MarkScriptRead() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id,Status__c,Determination_Script_Read_to_Patient__c,OpportunityId from Quote where id =: currentPIId];
        System.debug('newQuote '+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            try {
                if(newQuote.Status__c== 'Open'){
                    Quote quoteToUpdate = new Quote();
                    quoteToUpdate.Id = newQuote.Id;
                    quoteToUpdate.Determination_Script_Read_to_Patient__c = 'Yes';
                    update quoteToUpdate;
                    
                    list<Quote> lstQuote = new list<Quote>();
                    lstQuote = [SELECT Id,OpportunityId from Quote where Id=: newQuote.Id];
                    
                    Opportunity oppToUpdate = new Opportunity();
                    oppToUpdate.Id = lstQuote[0].OpportunityId;
                    oppToUpdate.StageName = 'Determination Delivered';
                    update oppToUpdate;
                    
                    PageReference pageRef;
                    pageRef= new PageReference('/'+quoteToUpdate.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This action is not allowed as status is closed/Cancelled.'));
                    return null;
                }
                
            } catch(exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An un-expected Error has Occurred. Error:'+e));
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