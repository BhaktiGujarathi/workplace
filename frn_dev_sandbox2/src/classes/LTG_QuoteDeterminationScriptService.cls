/** 
* Class LTG_QuoteDeterminationScriptService
* 
* Class LTG_QuoteDeterminationScriptService for the LTG_Edit_Script, LTG_View_Determination_Script, LTG_Print_PDF VF page. 
* This class implements the functionality to Edit Script, Print PDF, View Determination Script of Quote. 
*/ 
public with sharing class LTG_QuoteDeterminationScriptService
{ 
    public Quote newQuote;
    public LTG_QuoteDeterminationScriptService(ApexPages.StandardController controller) {

    }

    public LTG_QuoteDeterminationScriptService() {           
    }  
    
    public PageReference EditScript() {
        string currentQuoteId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id,status__c from Quote where id =: currentQuoteId];
        system.debug('newQuote'+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        system.debug('isLockedFlag '+isLockedFlag );
        if(!isLockedFlag) { 
        
            if(newQuote.Status__c== 'Open'){
                PageReference pageRef;
                pageRef= new PageReference('/apex/EditScriptPage?Id='+newQuote.Id);
                system.debug('pageRef'+pageRef);
                pageRef.setRedirect(true);
                return pageRef;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This action is not allowed as status is closed/Cancelled.'));
                return null;
            }
            
        }else { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            return null;
        }
    }  
    
    public PageReference PrintPDF() {
        string currentQuoteId = ApexPages.CurrentPage().getparameters().get('id');
        newQuote =  [select id from Quote where id =: currentQuoteId];
        system.debug('newQuote'+newQuote);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newQuote.Id);
        system.debug('isLockedFlag '+isLockedFlag );
        if(!isLockedFlag) { 
            PageReference pageRef; 
            pageRef= new PageReference('/apex/PrintQuotePDF?id='+newQuote.Id);
            system.debug('pageRef'+pageRef);
            pageRef.setRedirect(true);
            return pageRef;            
        }else { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            return null;
        }
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
        
            if((String.isEmpty(newQuote.Determination_Script__c))
            && (String.isEmpty(newQuote.Assignment_of_Benefits_Script__c)) 
            && (String.isEmpty(newQuote.ACA_Policy_Script__c)) 
            && (String.isEmpty(newQuote.Aggression__c))
            && (String.isEmpty(newQuote.Policy_Termed__c))
            && (String.isEmpty(newQuote.Unable_to_Verify_Benefits__c))
            && (String.isEmpty(newQuote.Coordination_of_Benefits__c))
            && (String.isEmpty(newQuote.Benefits_Check__c))
            && (String.isEmpty(newQuote.COBRA_Policy_Script__c)) 
            && (String.isEmpty(newQuote.Secondary_Assignment_of_Benefits_Script__c)) 
            && (String.isEmpty(newQuote.Secondary_ACA_Policy_Script__c ))
            && (String.isEmpty(newQuote.Secondary_Aggression__c))
            && (String.isEmpty(newQuote.Secondary_Policy_Termed__c))
            && (String.isEmpty(newQuote.Secondary_Unable_to_Verify_Benefits__c))
            && (String.isEmpty(newQuote.Secondary_Coordination_of_Benefits__c))
            && (String.isEmpty(newQuote.Secondary_Benefits_Check__c))
            && (String.isEmpty(newQuote.Secondary_COBRA_Policy_Script__c))
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