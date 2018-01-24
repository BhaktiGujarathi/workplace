public with sharing class DEWTestDataFactory { 
    
    public static Account getISOAccountRecord() {
        RecordType recordtypeObj = [Select SobjectType, 
                                          Name, 
                                          Id 
                                   From RecordType 
                                   Where SobjectType = 'Account' 
                                   AND Name = 'ISO'];
                                          
        /*Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewuser@testorg.com');*/
         
        Account accountObj = new Account();
               
       // system.RunAs(userObj) {

            accountObj  = MCAOrgTestDataFactory.getOrgAccountRecord(accountObj, 1);
            accountObj.RecordTypeId = recordtypeObj.Id;
            //accountObj.User__c = UserInfo.getUserId();
            accountObj.Type = 'Internal';
            accountObj.Payback_Funded__c = 'Payback';

       // }
        return accountObj;
    }
    
    public static Account getBankAccountRecord() {
        RecordType recordtypeObj = [Select SobjectType, 
                                          Name, 
                                          Id 
                                   From RecordType 
                                   Where SobjectType = 'Account' 
                                   AND Name = 'Bank'];

                Account accountObj = new Account();
                accountObj = MCAOrgTestDataFactory.getOrgAccountRecord(accountObj, 1);
                accountObj.RecordTypeId = recordtypeObj.Id;
           
        return accountObj;
    }
    
    public static List<Opportunity> getOpportunityRecordsList(Integer pCount, Id pParentId, Id pBankParent, Id pOwnerId) {
        RecordType recordtypeObj = [Select SobjectType, 
                                           Name, 
                                           Id 
                                    From RecordType 
                                    Where SobjectType = 'Opportunity' 
                                    AND Name = 'Default'];
        
        List<Opportunity> opportunityList = new List<Opportunity>();
                
        for(Integer i = 0; i < pCount; i++) {
            Opportunity opportunityObj = new Opportunity();
            opportunityObj = MCAOrgTestDataFactory.getOrgOpportunityRecord(opportunityObj, i);
            opportunityObj.RecordTypeId = recordtypeObj.Id;
            opportunityObj.AccountId = pParentId;
            opportunityObj.Bank_Name__c = pBankParent;
            opportunityObj.Funding_Amount__c = 10000;
            opportunityObj.Total_Commissions_Receivable__c = 2000;
            opportunityObj.Total_Origination_Fees_Receivable__c = 3000;
            opportunityObj.Payback_Amount__c = 500;
            opportunityObj.OwnerId = pOwnerId;
            opportunityList.add(opportunityObj);
        }
        return opportunityList;
    }
    
    public static Offer__c getOfferRecord(Id pOppParent, Id pSubmissionParent, Id pFunderParent) {
        
        Offer__c offerObj = new Offer__c();
        offerObj = MCAOrgTestDataFactory.getOrgOfferRecord(offerObj, pOppParent, pSubmissionParent);
        offerObj.Deal_Type__c = 'MCA';
        offerObj.Amount__c = 40000;
        offerObj.Payoff_Amount__c = 1500;
        offerObj.Payment_Amt__c = 2500;
        offerObj.Rate__c = 10;
        offerObj.Funder__c = pFunderParent;
        
        return offerObj;
    }
    
    public static Submission__c getSubmissionRecord(Id pOppParent, Id pFunderParent, Id pProgramParent) {
        Submission__c submissionObj = new Submission__c();
        submissionObj = MCAOrgTestDataFactory.getOrgSubmissionRecord(submissionObj, pOppParent);
        submissionObj.Funder__c = pFunderParent;
        submissionObj.Date_Submitted__c = System.Today() - 20;
        submissionObj.Status__c = 'UW';
        submissionObj.Status_Date__c = System.Today() - 15;
        //submissionObj.Notes__c = 'Test Notes';
        //submissionObj.Highest_Funding_Amt__c = 2500;
        //submissionObj.Longest_Term__c = 10;
        submissionObj.Program__c = pProgramParent;
        
        return submissionObj;
    }
    
    public static Program__c getProgramRecord(Id pFunderParent, Id pEmailTemplateId) {
        Program__c programObj = new Program__c();
        programObj = MCAOrgTestDataFactory.getOrgProgramRecord(programObj);
        programObj.Submission_Email__c = 'testemail@gmail.com';
        programObj.Bank__c = pFunderParent;
        programObj.Email_Template_Id__c = pEmailTemplateId;
        return  programObj;
    }

    public static List<Payable__c> getPayableRecords(Id pOppParent, Id pAccParent, Integer pCount) {
        List<Payable__c> payableList = new List<Payable__c>();
        
        for(Integer i = 0; i < pCount; i++) {
            Payable__c payableObj = new Payable__c();
            payableObj = MCAOrgTestDataFactory.getOrgPayableRecord(payableObj);
            payableObj.Account__c = pAccParent;
            payableObj.Opportunity__c = pOppParent;
            payableObj.Status__c = 'Open - Ready to Pay';
            payableObj.Percentage__c = 10;
            
            payableObj.Wizard_Check__c = false;
            if(i == 0) {
                payableObj.Payback_Funded__c = 'Funded';
            } else if(i == 1) {
                payableObj.Payback_Funded__c = 'Payback';
            } else if(i == 2) {
                payableObj.Payback_Funded__c = 'Net Funded Amount';
            } else if(i == 3) {
                payableObj.Payback_Funded__c = 'Net Commission Revenue';
            } else if(i == 4) {
                payableObj.Payback_Funded__c = 'Net Origination Fee';
            } else if(i == 5) {
                payableObj.Payback_Funded__c = 'Commission Revenue';
            } else if(i == 6) {
                payableObj.Payback_Funded__c = 'All Revenue';
            } else if(i == 7){
                payableObj.Payback_Funded__c = 'Origination Fee';
            } else {
                payableObj.Payback_Funded__c = '';
            }
            payableList.add(payableObj);
        }
        
        return payableList;
    }
    
    public static List<Receivable__c> getReceivableRecords(Id pOppParent, Id pAccParent, Integer pCount) {
        List<Receivable__c> receivableList = new List<Receivable__c>();
        
        for(Integer i = 0; i < pCount; i++) {
            Receivable__c receivableObj = new Receivable__c();
            receivableObj = MCAOrgTestDataFactory.getOrgReceivableRecord(receivableObj);
            receivableObj.Due_From_Account__c = pAccParent;
            receivableObj.Opportunity__c = pOppParent;
            receivableObj.Status__c = 'Open - Ready to Pay';
            receivableObj.Type__c = 'Bonus';
            receivableObj.Percentage__c = 10;
            
            if(i == 0) {
                receivableObj.Payback_Funded__c = 'Funded';
                receivableObj.Type__c = 'Commission';
            } else if(i == 1) {
                receivableObj.Payback_Funded__c = 'Payback';
                receivableObj.Type__c = 'Bonus';
            } else if(i == 2) {
                receivableObj.Payback_Funded__c = 'Net Funded Amount';
            }
                       
            receivableList.add(receivableObj);
        }
        
        return receivableList;
    }
    
    public static List<Syndication__c> getSyndicationRecords(Id pOppParent, Id pAccParent, Integer pCount) {
        List<Syndication__c> syndicationList = new List<Syndication__c>();
        
        for(Integer i = 0; i < pCount; i++) {
            Syndication__c syndicationObj = new Syndication__c();
            syndicationObj = MCAOrgTestDataFactory.getOrgSyndiactionRecord(syndicationObj, pOppParent);
            syndicationObj.Syndication_Amt__c = (1000*i);
            syndicationObj.Servicing_Fee__c = (500*i);
            syndicationObj.Syndicated_By__c = pAccParent;
            syndicationList.add(syndicationObj);
        }
        
        return syndicationList; 
    }
    
    public static EmailTemplate getEmailTemplateRecord() {
        EmailTemplate emailTemplateObj = new EmailTemplate();
        emailTemplateObj = MCAOrgTestDataFactory.getOrgEmailTemplate(emailTemplateObj);
        
        return emailTemplateObj;
    }
}