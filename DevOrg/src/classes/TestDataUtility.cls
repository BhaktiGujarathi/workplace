/* 
 * Utility class for populating and returning single / multiple records for the specified Sobject 
 * which would be used as test data for Test classes. Ensures single point of test data creation for 
 * all test classes on this org.
 *
 * Version     Author                     Date              Comments
 * 1.0         Nachiket R. Deshpande      04/11/2014        Initial Draft
 * 1.1         Yogesh Mahajan             11/30/2015        Contact record created
 * 1.2         Yogesh Mahajan             11/30/2015        submission, Account and Attachment record Created
 */

public with sharing class TestDataUtility {
    
    //Populates and returns a list of Opportunity records to be used in test classes
    public static List<Opportunity> getOpportunityRecords(Integer pCount){

        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        for(Integer oppCount = 1; oppCount <= pCount; oppCount++){
        
            lstOpportunity.add(new Opportunity(Name = 'Test Opportunity' + oppCount,
                                               StageName= 'Start Underwriting',
                                               CloseDate = system.today()+ 10));
        }//for
        return lstOpportunity;
    }//End getOpportunityRecords
    
    //Populates and returns a list of Contact records to be used in test classes
    public static List<Contact> getContactRecords(Integer pCount){

        List<Contact> lstContact = new List<Contact>();
        
        for(Integer contactCount = 1; contactCount <= pCount; contactCount ++){
        
            lstContact.add(new Contact(FirstName = 'Test' + contactCount,
                                               LastName = 'Contact'));
        }//for
        return lstContact;
    }//End getContactRecords
    
    //Populates and returns a list of Receivable records to be used in test classes
    public static List<Receivable__c> getReceivableRecords(Integer pCount){

        List<Receivable__c> lstReceivable = new List<Receivable__c>();
        
        for(Integer receivableCount = 1; receivableCount <= pCount; receivableCount++){
        
            lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Type__c = 'Commission'));
            
            lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Type__c = 'Bonus'));
                                                
             lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Type__c = 'Origination Fee'));                                   
        }//for
        return lstReceivable;
    }//End getReceivableRecords
    
    //Populates and returns a list of Payables records to be used in test classes
    public static List<Payable__c> getPayableRecords(Integer pCount){

        List<Payable__c> lstPayable = new List<Payable__c>();
        
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Commission'));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Bonus'));
                                          
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Origination Fee'));                              
        }//for
        return lstPayable;
    }//End getPayableRecords
    
    
    
    public static List<Payable__c> getPayableRecordsForInternalISO(Integer pCount){
        Account tempAccInternalISO = new Account(name = 'Test'/*,Internal_ISO__c=true*/);
        insert tempAccInternalISO;
       
        List<Payable__c> lstPayable = new List<Payable__c>();
        
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Commission',Account__c = tempAccInternalISO.id));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Bonus',Account__c = tempAccInternalISO.id));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Origination Fee',Account__c = tempAccInternalISO.id));                              
        }//for
        return lstPayable;
    }//End getPayableRecordsForExternalISO
    
    
    public static List<Payable__c> getPayableRecordsForExternalISO(Integer pCount){
        
        Account tempAccExternalISO = new Account(name = 'Test'/*, External_ISO__c=true*/);
        insert tempAccExternalISO;
        List<Payable__c> lstPayable = new List<Payable__c>();
       
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Commission', Account__c = tempAccExternalISO.id ));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Bonus', Account__c = tempAccExternalISO.id ));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Origination Fee', Account__c = tempAccExternalISO.id ));                              
        }//for
        return lstPayable;
    }//End getPayableRecordsForInternalISO
    
    
    
    
    //Populates and returns a list of Campaign records to be used in test classes
    public static List<Campaign> getCampaignRecords(Integer pCount){

        List<Campaign> lstCampaign = new List<Campaign>();
        
        for(Integer campCount = 1; campCount <= pCount; campCount++){
        
            lstCampaign.add(new Campaign( Name = 'Test Campaign' + campCount,
                                          IsActive= True));
        }//for
        return lstCampaign;
    }//End getCampaignRecords
    
    //Populates and returns a list of Account records to be used in test classes
    public static List<Account> getAccountRecords(Integer pCount){

        List<Account> lstAccount = new List<Account>();
        
        for(Integer accCount = 1; accCount <= pCount; accCount++){
        
            lstAccount.add(new Account( Name = 'Test Campaign' + accCount));
        }//for
        return lstAccount;
    }//End getAccountRecords
    
    //Populates and returns a list of Lead records to be used in test classes
    public static List<Lead> getLeadRecords(Integer pCount){

        List<Lead> lstLead = new List<Lead>();
        
        for(Integer leadCount = 1; leadCount <= pCount; leadCount++){
        
            lstLead.add(new Lead( Company = 'Test Account',
                                  LastName= 'Test Lead',
                                  LeadSource = 'Web',  
                                  Status = 'Closed - Converted'));
        }//for
        return lstLead;
    }//End getAccountRecords
    
    //Populates and returns a list of Bank Statement records to be used in test classes
    public static List<Bank_Account__c> getBankStatementRecords(Integer pCount, Id pOpportunityId) {
        List<Bank_Account__c> lstBankAccountStatement = new List<Bank_Account__c>();
        for(Integer bnkStatmntCount = 1; bnkStatmntCount <= pCount; bnkStatmntCount++) {
            lstBankAccountStatement.add(new Bank_Account__c(Opportunity__c = pOpportunityId,
                                            Average_Daily_Balance__c = 100 + bnkStatmntCount,
                                            Deposits__c = 5,
                                            Number_of_NSFs__c = 2,
                                            Number_of_Negative_Days__c = 10,
                                            No_Deposits__c = 5,
                                            Year__c = '2015',
                                            Month__c = '01 - January'));
        }
        return lstBankAccountStatement;
    }
    
    //Populates and returns a list of Credit card records to be used in test classes
    public static List<Credit_Card__c> getCreditCardRecords(Integer pCount, Id pAccountId) {
        List<Credit_Card__c> lstCreditCard = new List<Credit_Card__c>();
        for(Integer creditCardCount = 1; creditCardCount <= pCount; creditCardCount++) {
            lstCreditCard.add(new Credit_Card__c(Opportunity__c = pAccountId,
                                            Total_Net_Processed_All__c = 500,
                                            Number_of_Transactions_All__c = 10 + creditCardCount,
                                            Batches__c = 5,
                                            Year__c = '2015',
                                            Month__c = '01 - January'));
        }
        return lstCreditCard;
    }
    
    //Populates and returns a list of Attachment records to be used in test classes
    public static List<Attachment> getattachmentRecords(Integer pCount) {
        List<Attachment> listAttachment = new List<Attachment>();
        for(Integer Count = 1; Count < = pCount; Count++) {
            Attachment attachInstance = new Attachment();
            attachInstance.Name = 'Test Attachmenet'+ Count;
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attachInstance.body = bodyBlob;
            listAttachment.add(attachInstance);
        }//end for
        return listAttachment;
    }//end getattachmentRecords
    
    //Populates and returns a list of Submission__c records to be used in test classes
    public static List<Submission__c> getSubmissionRecords(Integer pCount, Id oppId) {
        List<Submission__c> listSubmission = new List<Submission__c>();
        for(Integer attachCount = 1; attachCount < = pCount; attachCount++) {
            Submission__c submissionInstance = new Submission__c();
            submissionInstance.Opportunity__c= oppId;
            listSubmission.add(submissionInstance);
        }//end for
        return listSubmission;
    }//end getSubmissionRecords

    public static List<Document> getDocumentRecords(Integer pCount) {
        List<Document> listDocument = new List<Document>();
        Folder folderInstance = [select id from folder where name = 'Shared Documents'Limit 1];
        for(Integer docCount = 1; docCount <= pCount; docCount++) {
            Document docInstance = new Document();
            docInstance.Body = Blob.valueOf('Some Text');
            docInstance.ContentType = 'application/pdf';
            docInstance.DeveloperName = 'my_documentCC'+docCount;
            docInstance.IsPublic = true;
            docInstance.Name = 'My Document';
            docInstance.FolderId = folderInstance.id;
            listDocument.add(docInstance);
        }
        return listDocument;
    }
}