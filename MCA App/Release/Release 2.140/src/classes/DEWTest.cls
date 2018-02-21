@isTest
public with sharing class DEWTest {
    
    static testMethod void testPopulateData() {
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewtestuser@testorg.com');
         
               
        system.RunAs(userObj) {
        
        //ISO account 
        Account objISOAccount = DEWTestDataFactory.getISOAccountRecord();
        objISOAccount.User__c = UserInfo.getUserId();
        insert objISOAccount;
        
        //bank account
        Account objBankAccount = DEWTestDataFactory.getBankAccountRecord();
        insert objBankAccount;
        
        //opportunity
        List<Opportunity> listOpportunity = DEWTestDataFactory.getOpportunityRecordsList(1, objISOAccount.Id, objBankAccount.Id, UserInfo.getUserId());
        insert listOpportunity;
        
        //Program
        Program__c objProgram = DEWTestDataFactory.getProgramRecord(objBankAccount.Id);
        insert objProgram;
        
        //submission
        Submission__c objSubmission = DEWTestDataFactory.getSubmissionRecord(listOpportunity[0].Id, objBankAccount.Id, objProgram.Id);
        insert objSubmission;
        
        //Offer
        Offer__c objOffer = DEWTestDataFactory.getOfferRecord(listOpportunity[0].Id, objSubmission.Id, objBankAccount.Id);
        insert objOffer;
                
        test.startTest();
            Apexpages.Pagereference pageRef = Page.CreateContract;
            test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id',listOpportunity[0].Id);
            pageRef.getParameters().put('stage',listOpportunity[0].StageName);
            pageRef.getParameters().put('accId',listOpportunity[0].AccountId);
            CreateContractController objContrllr = new CreateContractController();
            objcontrllr.populateData();
            objcontrllr.wizardType='Offer';
            objcontrllr.getSubmissionNames();
            pageRef.getParameters().put('offerId',objOffer.Id);
            objcontrllr.selectedOffer();
            objcontrllr.next();
            objcontrllr.previous();
        test.stopTest();
        
        }
        
    }
    
    static testMethod void testGetMethods() {
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewtestuser@testorg.com');
         
               
        system.RunAs(userObj) {
        
        //ISO account 
        Account objISOAccount = DEWTestDataFactory.getISOAccountRecord();
        objISOAccount.User__c = UserInfo.getUserId();
        insert objISOAccount;
        
        //bank account
        Account objBankAccount = DEWTestDataFactory.getBankAccountRecord();
        insert objBankAccount;
        
        //opportunity
        List<Opportunity> listOpportunity = DEWTestDataFactory.getOpportunityRecordsList( 1, objISOAccount.Id, objBankAccount.Id, UserInfo.getUserId());
        insert listOpportunity;
        
        //Program
        Program__c objProgram = DEWTestDataFactory.getProgramRecord(objBankAccount.Id);
        insert objProgram;
        
        //submission
        Submission__c objSubmission = DEWTestDataFactory.getSubmissionRecord(listOpportunity[0].Id, objBankAccount.Id, objProgram.Id);
        insert objSubmission;
        
        //Offer
        Offer__c objOffer = DEWTestDataFactory.getOfferRecord(listOpportunity[0].Id, objSubmission.Id, objBankAccount.Id);
        insert objOffer;
        
        //Payables
        List<Payable__c> listPayable = DEWTestDataFactory.getPayableRecords(listOpportunity[0].Id, objBankAccount.Id, 8);
        insert listPayable;
        
        //Receivables
        List<Receivable__c> listReceivable = DEWTestDataFactory.getReceivableRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listReceivable;
        
        test.startTest();
            Apexpages.Pagereference pageRef = Page.CreateContract;
            test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id',listOpportunity[0].Id);
            pageRef.getParameters().put('stage',listOpportunity[0].StageName);
            pageRef.getParameters().put('accId',listOpportunity[0].AccountId);
            CreateContractController objContrllr = new CreateContractController();
            objContrllr.populateData();
            objcontrllr.wizardType='Receivable';
            objcontrllr.getReceivables();
            objcontrllr.onChangeTermMonth();
            objcontrllr.addRowReceivable();
            objcontrllr.quickSaveReceivable();
        test.stopTest();
        
        }
    }
    
    static testMethod void testNextPreviouMethod() {
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewtestuser@testorg.com');
         
               
        system.RunAs(userObj) {
        //ISO account 
        Account objISOAccount = DEWTestDataFactory.getISOAccountRecord();
        objISOAccount.User__c = UserInfo.getUserId();
        insert objISOAccount;
        
        //bank account
        Account objBankAccount = DEWTestDataFactory.getBankAccountRecord();
        insert objBankAccount;
        
        //opportunity
        List<Opportunity> listOpportunity = DEWTestDataFactory.getOpportunityRecordsList( 1, objISOAccount.Id, objBankAccount.Id, UserInfo.getUserId());
        insert listOpportunity;
        
        //Program
        Program__c objProgram = DEWTestDataFactory.getProgramRecord(objBankAccount.Id);
        insert objProgram;
        
        //submission
        Submission__c objSubmission = DEWTestDataFactory.getSubmissionRecord(listOpportunity[0].Id, objBankAccount.Id, objProgram.Id);
        insert objSubmission;
        
        //Offer
        Offer__c objOffer = DEWTestDataFactory.getOfferRecord(listOpportunity[0].Id, objSubmission.Id, objBankAccount.Id);
        insert objOffer;
        
        //Payables
        List<Payable__c> listPayable = DEWTestDataFactory.getPayableRecords(listOpportunity[0].Id, objBankAccount.Id, 8);
        insert listPayable;
        
        //Receivables
        List<Receivable__c> listReceivable = DEWTestDataFactory.getReceivableRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listReceivable;
        
        test.startTest();
            Apexpages.Pagereference pageRef = Page.CreateContract;
            test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id',listOpportunity[0].Id);
            pageRef.getParameters().put('stage',listOpportunity[0].StageName);
            pageRef.getParameters().put('accId',listOpportunity[0].AccountId);
            CreateContractController objContrllr = new CreateContractController();
            objContrllr.populateData();
            objcontrllr.wizardType='Deal';
            objcontrllr.next();
            objcontrllr.next();
            objcontrllr.next();
            objcontrllr.next();
            objcontrllr.Previous();
            objcontrllr.Previous();
            objcontrllr.Previous();
            objcontrllr.Previous();
            objcontrllr.Previous();
            objContrllr.getbaseUrlOrg();
            objcontrllr.checkAdvCommCall = true;
            objcontrllr.getPayables();
        test.stopTest();
        
        }
        
     }
     
     static testMethod void testAddRowMethods() {
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewtestuser@testorg.com');
         
               
        system.RunAs(userObj) {
        
        //ISO account 
        Account objISOAccount = DEWTestDataFactory.getISOAccountRecord();
        objISOAccount.User__c = UserInfo.getUserId();
        insert objISOAccount;
        
        //bank account
        Account objBankAccount = DEWTestDataFactory.getBankAccountRecord();
        insert objBankAccount;

        //Program
        Program__c objProgram = DEWTestDataFactory.getProgramRecord(objBankAccount.Id);
        insert objProgram;
        
        //opportunity
        List<Opportunity> listOpportunity = DEWTestDataFactory.getOpportunityRecordsList( 1, objISOAccount.Id, objBankAccount.Id, UserInfo.getUserId());
        insert listOpportunity;
        
        //submission
        Submission__c objSubmission = DEWTestDataFactory.getSubmissionRecord(listOpportunity[0].Id, objBankAccount.Id, objProgram.Id);
        insert objSubmission;
        
        //Offer
        Offer__c objOffer = DEWTestDataFactory.getOfferRecord(listOpportunity[0].Id, objSubmission.Id, objBankAccount.Id);
        insert objOffer;
        
        //Payables
        List<Payable__c> listPayable = DEWTestDataFactory.getPayableRecords(listOpportunity[0].Id, objBankAccount.Id, 8);
        insert listPayable;
        
        //Receivables
        List<Receivable__c> listReceivable = DEWTestDataFactory.getReceivableRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listReceivable;
        
        //Syndications
        List<Syndication__c> listSyndication = DEWTestDataFactory.getSyndicationRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listSyndication;
        
        test.startTest();
            Apexpages.Pagereference pageRef = Page.CreateContract;
            test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id',listOpportunity[0].Id);
            pageRef.getParameters().put('stage',listOpportunity[0].StageName);
            pageRef.getParameters().put('accId',listOpportunity[0].AccountId);
            CreateContractController objContrllr = new CreateContractController();
            objContrllr.populateData();
            objcontrllr.wizardType='Offer';
            objContrllr.addRowOffer();
            DEWOfferService.addRowOffer(objContrllr.oppId);
            //objContrllr.offerWrapperList[0].offer.Submission__c = objSubmission.Id;
            //objContrllr.quickSaveOffer();
            pageRef.getParameters().put('delname', 'TestOffer');
            pageRef.getParameters().put('index','1');
            objContrllr.deleteOffer();
            objContrllr.changeWizard();
            objcontrllr.wizardType='Receivable';
            objcontrllr.addRowReceivable();
            objContrllr.quickSaveReceivable();
            pageRef.getParameters().put('index','1');  
            objcontrllr.deletReceivables();
            objContrllr.changeWizard();
            objcontrllr.wizardType='Payable';
            objContrllr.addRowPayable();
            objContrllr.quickSavePayable();
            pageRef.getParameters().put('index','1');             
            objContrllr.deletPayables();
            objcontrllr.wizardType='Syndication';
            objContrllr.addRowSyndication();
            objContrllr.quickSaveSyndication();
            pageRef.getParameters().put('index','1');  
            objContrllr.deletSyndications();
            objContrllr.changeWizard();
            objContrllr.wizardType = 'Preview';
            objContrllr.changeWizard();
            objContrllr.wizardType = 'Payable';
            objContrllr.changeWizard();
            
            objcontrllr.cancel();
            
        test.stopTest();
        }
    }
    
    static testMethod void testOnChangeMethods() {
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewtestuser@testorg.com');
         
               
        system.RunAs(userObj) {
        
        //ISO account 
        Account objISOAccount = DEWTestDataFactory.getISOAccountRecord();
        objISOAccount.User__c = UserInfo.getUserId();
        objISOAccount.Payback_Funded__c = 'Commission Revenue';
        insert objISOAccount;
                
        //bank account
        Account objBankAccount = DEWTestDataFactory.getBankAccountRecord();
        insert objBankAccount;
                
        //Program
        Program__c objProgram = DEWTestDataFactory.getProgramRecord(objBankAccount.Id);
        insert objProgram;
        
        //opportunity
        List<Opportunity> listOpportunity = DEWTestDataFactory.getOpportunityRecordsList(1, objISOAccount.Id, objBankAccount.Id, UserInfo.getUserId());
        listOpportunity[0].Bank_Program__c = objProgram.Id;
        insert listOpportunity;
        
        //submission
        Submission__c objSubmission = DEWTestDataFactory.getSubmissionRecord(listOpportunity[0].Id, objBankAccount.Id, objProgram.Id);
        insert objSubmission;
        
        //Offer
        Offer__c objOffer = DEWTestDataFactory.getOfferRecord(listOpportunity[0].Id, objSubmission.Id, objBankAccount.Id);
        insert objOffer;
        
        //Payables
        List<Payable__c> listPayable = DEWTestDataFactory.getPayableRecords(listOpportunity[0].Id, objBankAccount.Id, 8);
        insert listPayable;
        
        //Receivables
        List<Receivable__c> listReceivable = DEWTestDataFactory.getReceivableRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listReceivable;
        
        //Syndications
        List<Syndication__c> listSyndication = DEWTestDataFactory.getSyndicationRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listSyndication;
        
        
        
        test.startTest();
            Apexpages.Pagereference pageRef = Page.CreateContract;
            test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id',listOpportunity[0].Id);
            pageRef.getParameters().put('stage',listOpportunity[0].StageName);
            pageRef.getParameters().put('accId',listOpportunity[0].AccountId);
            CreateContractController objContrllr = new CreateContractController();
            objContrllr.wizardType='Deal';
            
            objContrllr.populateData();
            objcontrllr.getPayables();
            objcontrllr.getSyndication();
            objcontrllr.getReceivables();
            
            objContrllr.onChangeBankProgram();
            objContrllr.onChangeRenewalEliPer();
            objContrllr.onChangeRecPaybackFunded();
            objContrllr.onChangePayPaybackFunded();
            objContrllr.onChangeRecPercentage();
            objContrllr.onChangePayPercentage();
            objContrllr.refreshOppWrapperMap();
            
            objContrllr.buildReceivableWrapper(objcontrllr.receivableList, UserInfo.getuserID());
            objContrllr.buildSyndicationWrapper(objcontrllr.syndicationList, UserInfo.getuserID());
            objContrllr.buildPayableWrapper(objcontrllr.payableList, UserInfo.getuserID());
            
            objContrllr.checkAdvCommCall = true;
            string labelString = Label.CommissionEngineClassName;
            DEWPayablesService.callCommissionCreatePayable(listOpportunity[0], listOpportunity[0].Id, labelString, objContrllr.checkAdvCommCall, objcontrllr.payableList);
            
        test.stopTest();
        
        }
        
    }
    
    static testMethod void testWrappers() { 
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileObj .Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='dewtestuser@testorg.com');
         
               
        system.RunAs(userObj) {
        
        //ISO account 
        Account objISOAccount = DEWTestDataFactory.getISOAccountRecord();
        objISOAccount.User__c = UserInfo.getUserId();
        objISOAccount.Payback_Funded__c = 'All Revenue';
        insert objISOAccount;
        
        //bank account
        Account objBankAccount = DEWTestDataFactory.getBankAccountRecord();
        insert objBankAccount;
                
        //Program
        Program__c objProgram = DEWTestDataFactory.getProgramRecord(objBankAccount.Id);
        insert objProgram;
        
        //opportunity
        List<Opportunity> listOpportunity = DEWTestDataFactory.getOpportunityRecordsList(1, objISOAccount.Id, objBankAccount.Id, UserInfo.getUserId());
        listOpportunity[0].Bank_Program__c = objProgram.Id;
        insert listOpportunity;
        
        //submission
        Submission__c objSubmission = DEWTestDataFactory.getSubmissionRecord(listOpportunity[0].Id, objBankAccount.Id, objProgram.Id);
        insert objSubmission;
        
        //Offer
        Offer__c objOffer = DEWTestDataFactory.getOfferRecord(listOpportunity[0].Id, objSubmission.Id, objBankAccount.Id);
        insert objOffer;
        //Payables
        List<Payable__c> listPayable = DEWTestDataFactory.getPayableRecords(listOpportunity[0].Id, objBankAccount.Id, 8);
        insert listPayable;
        
        //Receivables
        List<Receivable__c> listReceivable = DEWTestDataFactory.getReceivableRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listReceivable;
        
        //Syndications
        List<Syndication__c> listSyndication = DEWTestDataFactory.getSyndicationRecords(listOpportunity[0].Id, objBankAccount.Id, 3);
        insert listSyndication;
        
        test.startTest();
            Apexpages.Pagereference pageRef = Page.CreateContract;
            test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id',listOpportunity[0].Id);
            pageRef.getParameters().put('stage',listOpportunity[0].StageName);
            pageRef.getParameters().put('accId',listOpportunity[0].AccountId);
            CreateContractController objContrllr = new CreateContractController();
            objContrllr.populateData();
            objcontrllr.getPayables();
            CreateContractController.PayableWrapper  payWrapperObj = new  CreateContractController.PayableWrapper(1, 
                                                                                                     listPayable[0],
                                                                                                               true,
                                                                                                               true,
                                                                                                               true);
                                                                                                                   
            CreateContractController.ReceivableWrapper recWrapperObj = new  CreateContractController.ReceivableWrapper (1, 
                                                                                                         listReceivable[0],
                                                                                                                      true,
                                                                                                                      true,
                                                                                                                      true);
                                                                                                                  
            CreateContractController.SyndicationWrapper syndWrapperObj = new  CreateContractController.SyndicationWrapper(1, 
                                                                                                         listSyndication[0],
                                                                                                                       true,
                                                                                                                       true,
                                                                                                                       true);
        test.stopTest();
        
        }
    }
}