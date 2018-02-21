/**********************************************************************************************
Class to assign value to record to satisfy thet system validations and other mandatory fields.

**********************************************************************************************/
public with sharing class MCAOrgTestDataFactory { 
    
    // method for Account
    public static Account getOrgAccountRecord(Account pAcc, Integer pIterator) {
        pAcc.Name = 'TestAccount' +pIterator;        
        
        return pAcc;        
    }
    
    // method for Contact
    public static Contact getOrgContactRecord(Contact pCon, Integer pIterator) {
        pCon.LastName = 'TestContact' +pIterator;
        
        return pCon;
    }
    
    // method for Opportunity
    public static Opportunity getOrgOpportunityRecord(Opportunity pOpp, Integer pIterator) {
        pOpp.Name = 'TestOpportunity' +pIterator;
        pOpp.CloseDate = System.Today() +pIterator;
        pOpp.StageName = 'Prospecting';
        
        return pOpp;
    }
    
    // method for Offers
    public static Offer__c getOrgOfferRecord(Offer__c pOffer, Id pOppParent, Id pSubmissionParent) {
        pOffer.Opportunity__c = pOppParent;
        pOffer.Submission__c = pSubmissionParent;
        
        return pOffer;
    }
    
    // method for submission
    public Static Submission__c getOrgSubmissionRecord(Submission__c pSubmission, Id pOppParent) {
        pSubmission.Opportunity__c = pOppParent;
 
        return pSubmission;
    }
    
    // method for submission
    public Static Syndication__c getOrgSyndiactionRecord(Syndication__c pSyndication, Id pOppParent) {
        pSyndication.Opportunity__c = pOppParent;
 
        return pSyndication;
    }
    
    // method for Program
    public Static Program__c getOrgProgramRecord(Program__c pProgram) {
        pProgram.Name = 'TestProgram';
            
        return pProgram;
    }
    
    // method for payable
    public static Payable__c getOrgPayableRecord(Payable__c pPayable) {
        pPayable.Percentage__c = 10;
        pPayable.Deal_Amount_Used__c = 10000;
        pPayable.Payback_Funded__c = 'Funded';
        pPayable.Amount_Due__c = 1000;
        
        return pPayable;
    }
    
    // method for recievable
    public static Receivable__c getOrgReceivableRecord(Receivable__c pReceivable) {
        pReceivable.Percentage__c = 10;
        pReceivable.Deal_Amount_Used__c = 10000;
        pReceivable.Payback_Funded__c = 'Funded';
        pReceivable.Amount__c = 1000;
        
        return pReceivable;
    }
    
    public static Attachment getOrgAttachmentRecord(Attachment pAttachment) {
    
        return pAttachment;
    }
    
    public static EmailTemplate getOrgEmailTemplate(EmailTemplate pEmailTemplate) {
        pEmailTemplate.isActive = true;
        pEmailTemplate.Name = 'TestEmailTemplate';
        pEmailTemplate.DeveloperName = 'TestEmailTemplate';
        pEmailTemplate.TemplateType = 'text';
        pEmailTemplate.FolderId = UserInfo.getUserId();
        
        return pEmailTemplate;
    }
        
}