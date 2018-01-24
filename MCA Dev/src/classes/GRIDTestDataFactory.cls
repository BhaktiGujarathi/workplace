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

    // method for stip
    public static Stips__c getStipRecord(Id pParentOppId) {
        Stips__c stip = new Stips__c(
            Name = 'Test Stip',
            Opportunity__c = pParentOppId
        );
        return stip;
    }

    /**
     * Create Email Settings custom setting data
     */
    public static FO_Email_Settings__c createCustomSettingRecord(
        String name,
        String fieldSet,
        String objectApIname,
        String replyToField,
        String sendersNameField) {
        FO_Email_Settings__c emailSetting = new FO_Email_Settings__c(
            Name = name,
            Field_Set_API_Name__c = fieldSet,
            ISO__c = true,
            ISO_Sales_Rep__c = true,
            Merchant__c = true,
            Object_API_Name_for_Field_Set__c = objectApIname,
            Reply_to_Address__c = replyToField,
            Sender_s_Name__c = sendersNameField,
            From_Address__c = 'User'
        );
        return emailSetting;
    }
}