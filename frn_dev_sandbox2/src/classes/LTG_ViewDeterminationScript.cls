/** 
* Class LTG_ViewDeterminationScript
* 
* Class LTG_ViewDeterminationScript for the LTG View Determination Script VF page. This class implements the functionality 
* to ViewDeterminationScript of Quote. 
*/ 
public with sharing class LTG_ViewDeterminationScript
{ 
    public Quote newQuote;
    public LTG_ViewDeterminationScript(ApexPages.StandardController controller) {

    }

    public LTG_ViewDeterminationScript() {           
    }  
    
    public PageReference ViewDeterminationScript() {
        
        string currentQuoteId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id,Determination_Script__c,Assignment_of_Benefits_Script__c,ACA_Policy_Script__c,Aggression__c,Policy_Termed__c,
            Unable_to_Verify_Benefits__c,Coordination_of_Benefits__c,Benefits_Check__c,COBRA_Policy_Script__c,Secondary_Assignment_of_Benefits_Script__c,
            Secondary_ACA_Policy_Script__c,Secondary_Aggression__c,Secondary_Policy_Termed__c,Secondary_Unable_to_Verify_Benefits__c,
            Secondary_Coordination_of_Benefits__c,Secondary_Benefits_Check__c,Secondary_COBRA_Policy_Script__c from Quote where id =: currentQuoteId];
        system.debug('newQuote'+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        system.debug('isLockedFlag '+isLockedFlag );
        if(!isLockedFlag) { 
        
            if(String.isBlank(newQuote.Determination_Script__c)
            && (newQuote.Assignment_of_Benefits_Script__c) == '' 
            && (newQuote.ACA_Policy_Script__c) == '' 
            && (newQuote.Aggression__c) == '' 
            && (newQuote.Policy_Termed__c) == '' 
            && (newQuote.Unable_to_Verify_Benefits__c) == '' 
            && (newQuote.Coordination_of_Benefits__c) == '' 
            && (newQuote.Benefits_Check__c) == ''
            && (newQuote.COBRA_Policy_Script__c) == '' 
            && (newQuote.Secondary_Assignment_of_Benefits_Script__c) == '' 
            && (newQuote.Secondary_ACA_Policy_Script__c ) == ''
            && (newQuote.Secondary_Aggression__c) == ''
            && (newQuote.Secondary_Policy_Termed__c) == ''
            && (newQuote.Secondary_Unable_to_Verify_Benefits__c) == ''
            && (newQuote.Secondary_Coordination_of_Benefits__c) == ''
            && (newQuote.Secondary_Benefits_Check__c) == ''
            && (newQuote.Secondary_COBRA_Policy_Script__c) == ''
            ){ 
                system.debug('in+++++++++++++++');
                ApexPages.Message noScriptMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'No Script Found.');
                ApexPages.addMessage(noScriptMessage);
                system.debug('noScriptMessage'+noScriptMessage);
                return null;
            } else { 
                PageReference pageRef;
                pageRef= new PageReference('/apex/QuotePDF?id='+newQuote.Id);
                system.debug('pageRef'+pageRef);
                pageRef.setRedirect(true);
                return pageRef;
                //setTimeout(function(){ window.parent.location.reload();}, 3000); 
            } 
        }else { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            return null;
        }
    }    
}