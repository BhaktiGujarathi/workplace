public with sharing class MCAOrgTestDataFactory { 
    
    public static Account getOrgAccountRecord(Account pAcc, Integer pIterator) {
        pAcc.Name = 'TestAccount' +pIterator;        
        
        return pAcc;        
    }
    
    public static Opportunity getOrgOpportunityRecord(Opportunity pOpp, Integer pIterator) {
        pOpp.Name = 'TestOpportunity' +pIterator;
        pOpp.CloseDate = System.Today() +pIterator;
        pOpp.StageName = 'Prospecting';
        
        return pOpp;
    }
    
    public static Offer__c getOrgOfferRecord(Offer__c pOffer, Id pOppParent, Id pSubmissionParent) {
        pOffer.Opportunity__c = pOppParent;
        pOffer.Submission__c = pSubmissionParent;
        
        return pOffer;
    }
    
    public Static Submission__c getOrgSubmissionRecord(Submission__c pSubmission, Id pOppParent) {
        pSubmission.Opportunity__c = pOppParent;
 
        return pSubmission;
    }
    
    public Static Program__c getOrgProgramRecord(Program__c pProgram) {
        pProgram.Name = 'TestProgram';
            
        return pProgram;
    }
    
    public static Payable__c getOrgPayableRecord(Payable__c pPayable) {
        pPayable.Percentage__c = 10;
        pPayable.Deal_Amount_Used__c = 10000;
        pPayable.Payback_Funded__c = 'Funded';
        pPayable.Amount_Due__c = 1000;
        
        return pPayable;
    }
    
    public static Receivable__c getOrgReceivableRecord(Receivable__c pReceivable) {
        pReceivable.Percentage__c = 10;
        pReceivable.Deal_Amount_Used__c = 10000;
        pReceivable.Payback_Funded__c = 'Funded';
        pReceivable.Amount__c = 1000;
        
        return pReceivable;
    }
    
    public static Syndication__c getOrgReceivableRecord(Syndication__c pSyndication, Id pOppParent) {
        pSyndication.Opportunity__c = pOppParent;
        
        return pSyndication;
    }
}