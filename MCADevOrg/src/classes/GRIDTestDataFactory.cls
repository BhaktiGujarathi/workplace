public with sharing class GRIDTestDataFactory {
     
     // method for Account
     public static Account getAccountRecord() {

        Account accountObj = new Account();
        accountObj = MCAOrgTestDataFactory.getOrgAccountRecord(accountObj, 1);
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
           
        return accountObj;
    }
    
    // method for Opportunity
    public static Opportunity getOpportunityRecord(Id pParentAccId) {
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj = MCAOrgTestDataFactory.getOrgOpportunityRecord(opportunityObj, 1);
        //opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GridTesting').getRecordTypeId();
        opportunityObj.AccountId = pParentAccId;
        
        return opportunityObj;
    }
    
    // method for Submission
    public static Submission__c getSubmissionRecord(Id pParentOppId) {
        Submission__c submissionObj = new Submission__c();
        submissionObj= MCAOrgTestDataFactory.getOrgSubmissionRecord(submissionObj, pParentOppId);
        submissionObj.Opportunity__c = pParentOppId;
        
        return submissionObj;
    }
    // method for contact
    public static Contact getGRIDContactRecord(Id pParentAccId) {
        Contact conObj = new Contact();
        conObj = MCAOrgTestDataFactory.getOrgContactRecord(conObj, 1);
        conObj.AccountId = pParentAccId;
        
        return conObj;
    }
    
    // method for Attchment
    public static Attachment getGRIDAttachmentRecord(Id pParentOppId) {
        Attachment attchmntObj = new Attachment();
        attchmntObj = MCAOrgTestDataFactory.getOrgAttachmentRecord(attchmntObj);
        attchmntObj.ParentId = pParentOppId;
        attchmntObj.Name = 'testAttachment';
        attchmntObj.body = Blob.valueOf('Unit Test Attachment Body');
        
        return attchmntObj;
    }
}