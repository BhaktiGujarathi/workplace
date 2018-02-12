/**
* Class LTG_SelectAsFinal
*
* Class LTG_SelectAsFinal for the LTG_Select_As_Final VF page. This class implements the functionality
* to Select As Final of Opportunity.
*/
public class LTG_SelectAsFinal
{
    public Quote newQuote;
    public LTG_SelectAsFinal(ApexPages.StandardController controller) {
        this.newQuote= (Quote)controller.getRecord();
    }
    
    public LTG_SelectAsFinal() {
    }
    
    public PageReference LTG_SelectAsFinal() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id,Status__c,Determination_Script_Read_to_Patient__c,OpportunityId from Quote where id =: currentPIId];
        System.debug('newQuote '+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            
    
        if(!isLockedFlag) {  
            if(newQuote.Status__c== 'Open'){
                list<string> lstQuoteIds = SelectFinalQuoteOnOpty.getOpportunity(newQuote.Id);
                if(lstQuoteIds.size() >0 ){
                    
                    if(lstQuoteIds[1] != 'no'){
                        
                        string redirect = SelectFinalQuoteOnOpty.QuoteSelection(newQuote.Id, lstQuoteIds[0]);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.confirm,'Opportunity has been updated.'));
                        
                        list<opportunity> lstOpportunity = new list<opportunity>();
                        opportunity objOpportunity = new opportunity();
                        objOpportunity.id = lstQuoteIds[0];
                        objOpportunity.StageName = 'Facility Selected';
                        lstOpportunity.add(objOpportunity);
                        try {
                            update lstOpportunity;                
                        } catch(exception e) {
                            System.debug('<<<<<<<<<<<<<< DML Failed <<<<<<<<<<<<<<<<'+e);
                        }                                            
                        PageReference pageRef;
                        pageRef= new PageReference('/'+newQuote.Id);
                        pageRef.setRedirect(true);
                        return pageRef;                            
                    } 
                    return null;
                }
                return null;
            }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This action is not allowed as status is closed/Cancelled.'));
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