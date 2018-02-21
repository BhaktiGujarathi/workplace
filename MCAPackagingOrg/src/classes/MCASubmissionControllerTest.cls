@isTest
public class MCASubmissionControllerTest {
    
    //Test submission tab controller which is in opportunity
    static testMethod void submissionsTabControllerTest() {
        Account accInstance = new Account();
        accInstance.Name ='TestAccount';
        insert accInstance;
        
        Opportunity  opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCASubmissionsTabController submissionControllerInstance = new MCASubmissionsTabController();
            
            Submission__c submissionInstance = new Submission__c();
            //submissionInstance.Funder__c = accInstance.Id;
            submissionInstance.Status__c ='Approved';
            submissionInstance.Notes__c ='TestNotes';
            //submissionInstance.Highest_Funding_Amt__c =1000;
            //submissionInstance.Longest_Term__c=1;
            submissionInstance.Opportunity__c = opportunityInstance.Id;
            insert submissionInstance;
            submissionControllerInstance.submissions =[select Id from Submission__c where Id =:submissionInstance.Id];
            
            submissionControllerInstance.getContainers();
            
            submissionControllerInstance.submissionList();
            
            submissionInstance.Notes__c = 'testNewNotes';
            //submissionInstance.Highest_Funding_Amt__c =200;
            submissionInstance.Status__c ='Declined';
            update submissionInstance;
            
            list<Submission__c> listNewSubmission = new list<Submission__c>();
            listNewSubmission = [SELECT Id FROM Submission__c where Id =:submissionInstance.Id];
            submissionControllerInstance.newSubmission();
            submissionControllerInstance.updateInlineEditedValue();
            Submission__c subValue = new Submission__c();
            submissionControllerInstance.checkoldAndNewVal();
            subValue.Funder__c = accInstance.Id;
            
            list<Submission__c> listSubmission = new list<Submission__c>();
            listSubmission = [SELECT Id FROM Submission__c where Id =:submissionInstance.Id];
            submissionControllerInstance.save();
            submissionControllerInstance.saveAllSubmissions();
            
            submissionControllerInstance.saveMessage();
            submissionControllerInstance.recordToDelete = submissionInstance.Id;
            submissionControllerInstance.deleteSubmission();
            submissionControllerInstance.refresh();
            
            submissionControllerInstance.editAll();
        Test.stopTest();
    }
    
    //Test offer tab controller which is in opportunity
    static testMethod void offersTabControllerTest() {
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Submission__c submissionInstance = new Submission__c();
        //submissionInstance.Funder__c = accInstance.Id;
        submissionInstance.Status__c ='Approved';
        submissionInstance.Opportunity__c = opportunityInstance.Id;
        insert submissionInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCAOffersTabController offerControllerInstance = new MCAOffersTabController();
            Offer__c offerInstance = new Offer__c ();
            offerInstance.Funder__c = accInstance.Id;
            offerInstance.Opportunity__c = opportunityInstance.Id;
            offerInstance.submission__c = submissionInstance.Id;
            offerInstance.Amount__c = 100;
            offerInstance.Payoff_Amount__c = 252;
            offerInstance.Rate__c = 10;
            insert offerInstance;
            List<Offer__c> listOffer = new List<Offer__c>();
            listOffer = [
                        SELECT Id 
                          FROM Offer__c 
                         WHERE Funder__c =:accInstance.Id 
                           AND Opportunity__c =:opportunityInstance.Id
            ];
            offerControllerInstance.getContainers();
            offerControllerInstance.offerList();
            offerControllerInstance.updateInlineEditedValue();
            offerControllerInstance.save();
            List<Submission__c> listSubmission = new List<Submission__c>();
            listSubmission =[
                            SELECT Id 
                              FROM Submission__c where Opportunity__c =:opportunityInstance.Id
            ];
            offerControllerInstance.getSubmissionNames();
            
            offerInstance.Amount__c = 200;
            offerInstance.Payoff_Amount__c = 122;
            offerInstance.Rate__c = 5;
            update offerInstance;
            offerControllerInstance.newOffer();
            
            Offer__c offerNewInstance = new Offer__c ();
            offerNewInstance.Funder__c = accInstance.Id;
            offerNewInstance.Opportunity__c = opportunityInstance.Id;
            offerNewInstance.submission__c = submissionInstance.Id;
            offerNewInstance.Amount__c = 100;
            insert offerNewInstance;
            
            offerControllerInstance.checkoldAndNewVal();
            
            offerControllerInstance.recordToDelete = offerInstance.Id;
            offerControllerInstance.deleteOffer();
            offerControllerInstance.refresh();
            offerControllerInstance.saveAllOffers();

            
            offerControllerInstance.editAll();         

        Test.stopTest();
    }
    
    //Test stips tab controller which is in opportunity
    static testMethod void stipsTabControllerTest() {
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Submission__c submissionInstance = new Submission__c();
        submissionInstance.Opportunity__c = opportunityInstance.Id;
        insert submissionInstance;

        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCAStipsTabController stipsControllerInstance = new MCAStipsTabController();
            Stips__c stipsInstance = new Stips__c();
            stipsInstance.Name ='TestStips';
            stipsInstance.Status__c ='Completed';
            stipsInstance.Requested_by__c ='Test Requested';
            stipsInstance.Submission__c = submissionInstance.Id;
            stipsInstance.Opportunity__c = opportunityInstance.Id;
            insert stipsInstance;

            stipsControllerInstance.getSubmissionID() ;
            
            stipsControllerInstance.stips = [select  Id,
                                                    Recv_d__c,
                                                    Name,
                                                    Type__c,
                                                    Status__c,
                                                    Requested_by__c,
                                                    Date_Requested__c,
                                                    Requirement__c,
                                                    Submission__c,
                                                    Submission__r.Name,
                                                    Submission__r.Status__c,
                                                    Submission__r.Funder__c,
                                                    Submission__r.Funder__r.Name,
                                                    Notes__c from Stips__c where Id = :stipsInstance.Id];
            stipsControllerInstance.getContainers();
            stipsControllerInstance.getStips();
        
            stipsInstance.Status__c ='Completed';
            stipsInstance.Requested_by__c ='Test Requested';
            update stipsInstance;
            stipsControllerInstance.newStips =[
                                                select Id,
                                                       Recv_d__c,
                                                       Name,
                                                       Type__c,
                                                       Status__c,
                                                       Requested_by__c,
                                                       Date_Requested__c,
                                                       Requirement__c,
                                                       Submission__c,
                                                       Submission__r.Name,
                                                       Submission__r.Status__c,
                                                       Submission__r.Funder__c,
                                                       Submission__r.Funder__r.Name,
                                                       Notes__c 
                                                  from Stips__c
                                                 where Id = :stipsInstance.Id
            ];
            stipsControllerInstance.newStip();
            
            stipsControllerInstance.getSubmissionNames();
            stipsControllerInstance.save();
            stipsControllerInstance.test();
            stipsControllerInstance.updateInlineEditedValue();
           
            Stips__c stipsNewInstance = new Stips__c();
            stipsNewInstance.Name ='TestStips';
            stipsNewInstance.Submission__c = submissionInstance.Id;
            stipsNewInstance.Opportunity__c = opportunityInstance.Id;
            insert stipsNewInstance;

            stipsControllerInstance.checkoldAndNewVal();
            
            stipsControllerInstance.refresh();
            stipsControllerInstance.saveAllStips();
            stipsControllerInstance.editAll();

            stipsControllerInstance.recordToDelete = stipsInstance.Id;
            stipsControllerInstance.deleteStip();
            stipsControllerInstance.inlineedit();
        Test.stopTest();
    }
    
    //Test Loan Balance tab controller which is in opportunity
    static testMethod void loanBalanceTabControllerTest() {
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCALoanBalanceTabController loanBalanceControllerInstance = new MCALoanBalanceTabController();
            Loan_Balance__c loanBalanceInstance = new Loan_Balance__c();
            loanBalanceInstance.Funder__c = accInstance.Id;
            loanBalanceInstance.Balance__c = 100;
            loanBalanceInstance.Daily_Payment__c =101;
            loanBalanceInstance.Opportunity__c = opportunityInstance.Id;
            insert loanBalanceInstance;
            
            loanBalanceControllerInstance.loanBalances = [select Id from Loan_Balance__c where ID =:loanBalanceInstance.Id];
            loanBalanceControllerInstance.getContainers(); 
            loanBalanceControllerInstance.loanBalanceList();
            
            loanBalanceInstance.Daily_Payment__c =122;
            loanBalanceInstance.Balance__c = 100;
            update loanBalanceInstance;
            
            loanBalanceControllerInstance.newLoanBalances =[select Id from Loan_Balance__c where Id=:loanBalanceInstance.Id] ;
            Loan_Balance__c loanInstance = new Loan_Balance__c();
            loanInstance.Balance__c = 100;
            loanBalanceControllerInstance.checkoldAndNewVal();
            loanBalanceControllerInstance.saveMessage();
            loanBalanceControllerInstance.newLoanBalance();
            loanBalanceControllerInstance.removeLoanBalance();
            loanBalanceControllerInstance.updateInlineEditedValue();
            
            loanBalanceControllerInstance.refresh();
            loanBalanceControllerInstance.getBankNames();
            loanBalanceControllerInstance.editAll();
            loanBalanceControllerInstance.save();
            loanBalanceControllerInstance.saveAllLoans();
            
            loanBalanceControllerInstance.recordToDelete = loanInstance.Id;
            loanBalanceControllerInstance.deleteLoanBalance() ;
            
        Test.stopTest();
    }
    
    //Test sales History tab controller which is in opportunity
    static testMethod void salesHistoryBankControllerTest() {
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Bank_Account__c bankAccountInstance = new Bank_Account__c();
        bankAccountInstance.Deposits__c = 100;
        bankAccountInstance.Account__c = accInstance.Id;
        bankAccountInstance.Opportunity__c = opportunityInstance.Id;
        insert bankAccountInstance;
        
        Credit_Card__c creditCardInstance = new Credit_Card__c();
        creditCardInstance.Account__c = accInstance.Id;
        creditCardInstance.Opportunity__c = opportunityInstance.Id;
        creditCardInstance.Number_of_Transactions_All__c = 15;
        insert creditCardInstance;

        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCASalesHistoryTabController salesHistoryControllerInstance = new MCASalesHistoryTabController();
            
            salesHistoryControllerInstance.creditCardList = [select Id from Credit_Card__c where ID =:creditCardInstance.Id];
            salesHistoryControllerInstance.getContainersStatements();
            salesHistoryControllerInstance.getContainersCards();
            
            bankAccountInstance.Deposits__c = 100;
            update bankAccountInstance;
            
            salesHistoryControllerInstance.newStatements = [select Id from Bank_Account__c where Id= :bankAccountInstance.Id];
            salesHistoryControllerInstance.newStatement();            
            
            list<Credit_Card__c> checkListCreditCard = new list<Credit_Card__c>();
            checkListCreditCard = [select Id from Credit_Card__c where Id =:creditCardInstance.Id];
            salesHistoryControllerInstance.cardAccountList();
            
            Bank_Account__c bankAccountNewInstance = new Bank_Account__c();
            bankAccountNewInstance.Account__c = accInstance.Id;
            bankAccountNewInstance.Opportunity__c = opportunityInstance.Id;
            insert bankAccountNewInstance;
            
            salesHistoryControllerInstance.checkoldAndNewBankVal();
            salesHistoryControllerInstance.updateInlineEditedBankValue();
            salesHistoryControllerInstance.updateRecords();
            
            creditCardInstance.Number_of_Transactions_All__c = 125;
            update creditCardInstance;
            
            salesHistoryControllerInstance.newCredits = [select Id from Credit_Card__c where Id = :creditCardInstance.Id];
            salesHistoryControllerInstance.newCredit();
            
            Credit_Card__c creditCardNewInstance = new Credit_Card__c();
            creditCardNewInstance.Number_of_Transactions_All__c = 15;
            creditCardNewInstance.Account__c = accInstance.Id;
            creditCardNewInstance.Opportunity__c = opportunityInstance.Id;
            insert creditCardNewInstance;
            
            salesHistoryControllerInstance.checkoldAndNewCardVal();
            salesHistoryControllerInstance.refresh();
            salesHistoryControllerInstance.editAll();
            salesHistoryControllerInstance.saveAllSales();
            salesHistoryControllerInstance.recordToDelete = bankAccountInstance.Id;
            salesHistoryControllerInstance.deleteStatement();
            salesHistoryControllerInstance.recordToDelete = creditCardInstance.Id;
            salesHistoryControllerInstance.deleteCredit();
            salesHistoryControllerInstance.removeCard();
            salesHistoryControllerInstance.removeStatement();
        Test.stopTest();
        
    }
    
    //Test Comissions tab controller which is in opportunity
    static testMethod void commissionsTabControllerTest() {
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCACommissionsTabController commissionsControllerInstanceTest = new MCACommissionsTabController();
            Payable__c payableInstance = new Payable__c();
            payableInstance = MCAOrgTestDataFactory.getOrgPayableRecord(payableInstance);
            payableInstance.Payback_Funded__c = 'test';
            payableInstance.Opportunity__c = opportunityInstance.Id;
            payableInstance.Account__c = accInstance.Id;
            payableInstance.Memo__c ='Test Memo';
            payableInstance.Status__c = 'Open';
            insert payableInstance;
            
            list<Payable__c> checkListPayable = new list<Payable__c>();
            checkListPayable = [select Id from Payable__c where Id =:payableInstance.Id];
            commissionsControllerInstanceTest.payableList();
            
            commissionsControllerInstanceTest.payables  = [select Id from Payable__c where Id =:payableInstance.Id];
            
            commissionsControllerInstanceTest.getPayables();            
            
            Receivable__c receivableInstance = new Receivable__c();
            receivableInstance = MCAOrgTestDataFactory.getOrgReceivableRecord(receivableInstance);
            receivableInstance.Opportunity__c = opportunityInstance.Id;
            receivableInstance.Memo__c ='Test Memo';
            insert receivableInstance;
            
            list<Receivable__c> checkListReceivable = new list<Receivable__c>();
            checkListReceivable =[select Id from Receivable__c where Id =:receivableInstance.Id];
            commissionsControllerInstanceTest.receivablesList();
            
            commissionsControllerInstanceTest.receivables  =[select Id from Receivable__c where Id =:receivableInstance.Id];
            commissionsControllerInstanceTest.getReceivables();
            
            commissionsControllerInstanceTest.save();
            commissionsControllerInstanceTest.saveAllCommissions();
            commissionsControllerInstanceTest.refresh();
            
            commissionsControllerInstanceTest.editAll();
            commissionsControllerInstanceTest.updateRecord();
            commissionsControllerInstanceTest.updateInlineEditedPayableValue();
            payableInstance.Memo__c ='Testnew Memo';
            update payableInstance;

            commissionsControllerInstanceTest.newPayables =[select Id from Payable__c where Id =:payableInstance.Id];
            commissionsControllerInstanceTest.newPayable();
            commissionsControllerInstanceTest.checkoldAndNewPayableVal();
            commissionsControllerInstanceTest.updateInlineEditedReceValue();
            receivableInstance.Memo__c ='Test new Receivable Memo';
            update receivableInstance;
            
            commissionsControllerInstanceTest.newReceivables =[select Id from Receivable__c where Id =:ReceivableInstance.Id];
            commissionsControllerInstanceTest.newReceivable();
            commissionsControllerInstanceTest.checkoldAndNewReceivableVal();
            commissionsControllerInstanceTest.getselectPayableStatusOption();
            commissionsControllerInstanceTest.getselectReceivableStatusOption();
            commissionsControllerInstanceTest.recordToDelete = payableInstance.Id;
            commissionsControllerInstanceTest.deletePayable();
            commissionsControllerInstanceTest.recordToDelete = ReceivableInstance.Id;
            commissionsControllerInstanceTest.deleteReceivable();
            
        Test.stopTest();
    }
    //Test syndication tab controller which is in opportunity
    static testMethod void syndicationControllerTest() {
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCASyndicationTabController syndicationTabControllerInstance = new MCASyndicationTabController();
            Syndication__c syndicationInstance = new Syndication__c();
            syndicationInstance.Opportunity__c = opportunityInstance.Id;
            syndicationInstance.Syndication_Amt__c = 10;
            syndicationInstance.Servicing_Fee__c = 20;
            syndicationInstance.Memo__c = 'Test Memo';
            insert syndicationInstance;
            
            syndicationTabControllerInstance.syndications = [select Id from Syndication__c where Id = :syndicationInstance.Id];
            syndicationTabControllerInstance.syndicationList();
            syndicationTabControllerInstance.getContainers();           
            
            syndicationInstance.Servicing_Fee__c = 20;
            syndicationInstance.Memo__c = 'Test Memo';
            update syndicationInstance;

            syndicationTabControllerInstance.newSyndications = [select Id from Syndication__c where Id = :syndicationInstance.Id];
            syndicationTabControllerInstance.saveMessage();
            syndicationTabControllerInstance.newSyndication();
            syndicationTabControllerInstance.removeSyndication();
            Syndication__c syndicationNewInstance = new Syndication__c();
            syndicationTabControllerInstance.checkoldAndNewVal();
            syndicationNewInstance.Opportunity__c = opportunityInstance.Id;
            
            syndicationTabControllerInstance.updateInlineEditedValue();
            syndicationTabControllerInstance.save();
            syndicationTabControllerInstance.saveAllSyndications();
            
            syndicationTabControllerInstance.refresh();
            syndicationTabControllerInstance.editAll();
            syndicationTabControllerInstance.recordToDelete = syndicationInstance.Id;
            syndicationTabControllerInstance.deleteSyndication();
            
        Test.stopTest();
    }
    
    //Test offer tab controller which is in opportunity
    static testMethod void contactRoleControllerTest() {
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Contact contactInstance = new Contact();
        contactInstance.LastName = 'Test';
        contactInstance.Email = 'test@abc.com';
        contactInstance.Phone ='123455';
        insert contactInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCAContactRolesTabController  contactRoleControllerInstance = new MCAContactRolesTabController ();
            
            OpportunityContactRole oportunityContactInstance = new OpportunityContactRole();
            oportunityContactInstance.OpportunityId = opportunityInstance.Id;
            oportunityContactInstance.ContactId = contactInstance.Id;
            oportunityContactInstance.Role = 'Decision Maker';
            insert oportunityContactInstance;

            contactRoleControllerInstance.contactRoles = [select Id from OpportunityContactRole where Id =:oportunityContactInstance.Id];
            contactRoleControllerInstance.contactList = [select Id from Contact where Id= :contactInstance.Id];
            contactRoleControllerInstance.getContainers();
            
            list<OpportunityContactRole> checkOpportunityContactRoleList = new list<OpportunityContactRole>();
            checkOpportunityContactRoleList =[select Id from OpportunityContactRole where Id =:oportunityContactInstance.Id];
            
            contactRoleControllerInstance.getContactList();
            
            contactRoleControllerInstance.getOppContactRoleList();
          
            oportunityContactInstance.isPrimary = true;
            update oportunityContactInstance;            
            
            OpportunityContactRole oportunityContactNewInstance = new OpportunityContactRole();
            oportunityContactNewInstance.OpportunityId = opportunityInstance.Id;
            oportunityContactNewInstance.ContactId = contactInstance.Id;
            oportunityContactNewInstance.isPrimary = true;
            insert oportunityContactNewInstance;
            
            contactRoleControllerInstance.checkoldAndNewVal();
            contactRoleControllerInstance.saveMessage();
            contactRoleControllerInstance.newContactList = [select Id from Contact where Id= :contactInstance.Id];
            contactRoleControllerInstance.updateInlineEditedValue() ;
            contactRoleControllerInstance.newContactRole();
            contactRoleControllerInstance.indexToRemove = 0;
            contactRoleControllerInstance.removeRoles();
            contactRoleControllerInstance.save();
            contactRoleControllerInstance.saveAll();
            contactRoleControllerInstance.refresh();
            
            contactRoleControllerInstance.editAll();
            contactRoleControllerInstance.recordToDelete = oportunityContactInstance.Id;
            contactRoleControllerInstance.deleteContactRole();
            
        Test.stopTest();
    }
    
    //Test Task tab controller which is in opportunity
    static testMethod void taskTabControllerTest() {
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCATasksTabController taskControllerInstance = new MCATasksTabController();
            Task taskInstance = new Task();
            taskInstance.Subject ='Test Task';
            taskInstance.Status ='Completed';
            taskInstance.Description ='Test description';
            taskInstance.WhatId = opportunityInstance.Id;
            insert taskInstance;
            system.assertNotEquals(null, taskInstance.Id);
            taskControllerInstance.tasks = [select Id from Task where Id = :taskInstance.Id];
            taskControllerInstance.getContainers();
            taskControllerInstance.taskList();
            
            taskControllerInstance.updateInlineEditedValue();
            taskInstance.Status ='Open';
            update taskInstance;
            
            taskControllerInstance.newTasks = [select Id from Task where Id = :taskInstance.Id];         
            taskControllerInstance.newTask();
            taskControllerInstance.save();
            taskControllerInstance.saveAllTasks();
            
            Task taskNewInstance = new Task();
            taskNewInstance.Subject ='Test Task';
            taskNewInstance.Status ='Open';
            taskNewInstance.Description ='Test description';
            taskNewInstance.WhatId = opportunityInstance.Id;
            insert taskNewInstance;
            
            taskControllerInstance.checkoldAndNewVal();
            
            taskControllerInstance.refresh();
            taskControllerInstance.editAll();
            taskControllerInstance.recordToDelete = taskInstance.Id;
            taskControllerInstance.deleteTask();
            
        Test.stopTest();
    }
    
    //Test Attachment tab controller which is in opportunity
    static testMethod void attachmentTabControllerTest() {
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCAAttachmentTabController attachmentControllerInstance = new MCAAttachmentTabController();
            Blob b = Blob.valueOf('Test Data'); 
            Attachment attachmentInstance = new Attachment();
            attachmentInstance.Name ='Test attachment';
            attachmentInstance.Description='Test attachment Description';
            attachmentInstance.ParentId = opportunityInstance.Id;
            attachmentInstance.Body = b;
            insert attachmentInstance;
           
            attachmentControllerInstance.attachments = [select Id from Attachment where Id =:attachmentInstance.Id];
            attachmentControllerInstance.getContainers();
            attachmentControllerInstance.refresh();
            attachmentInstance.Description='Test upsert attachment Description';
            upsert attachmentInstance;
           
            attachmentControllerInstance.saveAllAttachments();
            attachmentControllerInstance.editAll();
            attachmentControllerInstance.recordToDelete = attachmentInstance.Id;
            attachmentControllerInstance.deleteAttachment();
            
        Test.stopTest();
    }
}