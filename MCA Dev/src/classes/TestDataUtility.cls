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
                                               StageName= 'Underwriting',
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
                                                Status__c = 'Pending',
                                                Type__c = 'Commission'));

            lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Status__c = 'Pending',
                                                Type__c = 'Bonus'));

            lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Status__c = 'Pending',
                                                Type__c = 'Origination Fee'));
        }//for
        return lstReceivable;
    }//End getReceivableRecords

    //Populates and returns a list of Payables records to be used in test classes
    public static List<Payable__c> getPayableRecords(Integer pCount){

        List<Payable__c> lstPayable = new List<Payable__c>();

        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){

            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Status__c = 'Pending',
                                          Type__c = 'Commission'));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Status__c = 'Pending',
                                          Type__c = 'Bonus'));

            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Status__c = 'Pending',
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
                                          Type__c = 'Commission',
                                          Status__c = 'Pending',
                                          Account__c = tempAccInternalISO.id));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Bonus',
                                          Status__c = 'Pending',
                                          Account__c = tempAccInternalISO.id));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Origination Fee',
                                          Status__c = 'Pending',
                                          Account__c = tempAccInternalISO.id));
        }//for
        return lstPayable;
    }//End getPayableRecordsForExternalISO


    public static List<Payable__c> getPayableRecordsForExternalISO(Integer pCount){

        Account tempAccExternalISO = new Account(name = 'Test'/*, External_ISO__c=true*/);
        insert tempAccExternalISO;
        List<Payable__c> lstPayable = new List<Payable__c>();

        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){

            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Commission',
                                          Status__c = 'Pending',
                                          Account__c = tempAccExternalISO.id ));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Bonus',
                                          Status__c = 'Pending',
                                          Account__c = tempAccExternalISO.id ));
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Origination Fee',
                                          Status__c = 'Pending',
                                          Account__c = tempAccExternalISO.id ));
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
        Submission__c submissionInstance;
        for(Integer attachCount = 1; attachCount < = pCount; attachCount++) {
            submissionInstance = new Submission__c();
            submissionInstance.Opportunity__c= oppId;
            listSubmission.add(submissionInstance);
        }//end for
        return listSubmission;
    }//end getSubmissionRecords

    public static List<Syndication__c> getSyndicationRecords(Integer pCount, Id oppId) {
        List<Syndication__c> listSubmission = new List<Syndication__c>();
        Syndication__c syndicateInstance;
        for(Integer attachCount = 1; attachCount < = pCount; attachCount++) {
            syndicateInstance = new Syndication__c();
            syndicateInstance.Opportunity__c= oppId;
            listSubmission.add(syndicateInstance);
        }//end for
        return listSubmission;
    }

    public static List<Stips__c> getStipsRecords(Integer pCount, Id oppId) {
        List<Stips__c> listStips = new List<Stips__c>();
        Stips__c stipInstance;
        for(Integer attachCount = 1; attachCount < = pCount; attachCount++) {
            stipInstance = new Stips__c();
            stipInstance.Opportunity__c= oppId;
            listStips.add(stipInstance);
        }//end for
        return listStips;
    }

    /*public static List<Merchant_Payment__c> getMerchantPaymentRecords(Integer pCount, Id oppId) {
        List<Merchant_Payment__c> listMerchantPayment = new List<Merchant_Payment__c>();
        Merchant_Payment__c merchantPayInstance;
        for(Integer attachCount = 1; attachCount < = pCount; attachCount++) {
            merchantPayInstance = new Merchant_Payment__c();
            merchantPayInstance.Opportunity__c= oppId;
            listMerchantPayment.add(merchantPayInstance );
        }//end for
        return listMerchantPayment;
    }*///end getSubmissionRecords


    public static List<Document> getDocumentRecords(Integer pCount) {
        List<Document> listDocument = new List<Document>();
        Document docInstance;
        //Folder folderInstance = [select id from folder where name = 'Shared Documents'Limit 1];
        for(Integer docCount = 1; docCount <= pCount; docCount++) {
            docInstance = new Document();
            docInstance.Body = Blob.valueOf('Some Text');
            docInstance.ContentType = 'application/pdf';
            docInstance.DeveloperName = 'my_documentCC'+docCount;
            docInstance.IsPublic = true;
            docInstance.Name = 'My Document';
            //docInstance.FolderId = folderInstance.id;
            docInstance.FolderId = UserInfo.getUserId();
            listDocument.add(docInstance);
        }
        return listDocument;
    }

    public static OpportunityContactRole getContactRoleRecord(Id pContactParent, Id pOppParent) {
            OpportunityContactRole conRoleInstance = new OpportunityContactRole();
            conRoleInstance.ContactId = pContactParent;
            conRoleInstance.OpportunityId = pOppParent;

        return conRoleInstance;
    }

    public static List<Transaction__c> getTransactionRecords(Integer pCount)
    {
        List<Transaction__c> listTransaction = new List<Transaction__c>();
        Transaction__c transInstance;
        for(Integer transCount =1; transCount <= pCount; transCount++)
        {
            transInstance = new Transaction__c();
            transInstance.Date__c=System.Today();
            transInstance.status__c='Open';
            transInstance.Pmt_Method__c='Cash';
            transInstance.Bank_Depostied__c = 'Visa';
            listTransaction.add(transInstance);
        }

        return listTransaction;
    }

    public static List<Offer__c> getOfferRecords(
        Integer pCount,
        Id oppId,
        Id subId) {
        List<Offer__c> offers = new List<Offer__c>();
        for(Integer offerCount =1; offerCount <= pCount; offerCount++)
        {
            Offer__c offer = new Offer__c();
            offer.Opportunity__c =oppId;
            offer.Submission__c=subId;
            offers.add(offer);
        }

        return offers;
    }

    /**
    * Get Stips Record
    **/
    public static List<Stips__c> getStipRecords(
        Integer pCount,
        Id oppId) {
        List<Stips__c> stips = new List<Stips__c>();
        for(Integer offerCount =1; offerCount <= pCount; offerCount++)
        {
            Stips__c stip = new Stips__c();
            stip.Name = 'Test';
            stip.Opportunity__c =oppId;
            stips.add(stip);
        }
        return stips;
    }

    /**
     * Get bank statements records
    */
    public static List<Bank_Account__c> getBankStatements(Integer pCount) {
        List<Bank_Account__c> bankStatements = new List<Bank_Account__c>();
        for(Integer bankStatementCount =1; bankStatementCount <= pCount; bankStatementCount++)
        {
            Bank_Account__c bankStatement = new Bank_Account__c();
            bankStatement.Name = 'Test';
            bankStatements.add(bankStatement);
        }
        return bankStatements;
    }

    /**
     * Get Merchnat statements records
    */
    public static List<Credit_Card__c> getMerchntStatements(Integer pCount) {
        List<Credit_Card__c> merchntStatements = new List<Credit_Card__c>();
        for(Integer merchntStatementCount =1; merchntStatementCount <= pCount; merchntStatementCount++)
        {
            Credit_Card__c merchntStatement = new Credit_Card__c();
            merchntStatements.add(merchntStatement);
        }
        return merchntStatements;
    }
}