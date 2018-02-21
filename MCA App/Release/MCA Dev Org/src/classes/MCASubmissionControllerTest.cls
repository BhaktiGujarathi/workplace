@isTest
public class MCASubmissionControllerTest {
	
	//Test submission tab controller which is in opportunity
	static testMethod void submissionsTabControllerTest() {
        Account accInstance = new Account();
        accInstance.Name ='TestAccount';
        insert accInstance;
        system.assertNotEquals(null,accInstance.Id);
        
        Opportunity  opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Test.startTest();
        	Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
        	MCASubmissionsTabController submissionControllerInstance = new MCASubmissionsTabController();
        	
        	Submission__c submissionInstance = new Submission__c();
        	submissionInstance.Funder__c = accInstance.Id;
        	submissionInstance.Status__c ='Approved';
        	submissionInstance.Notes__c ='TestNotes';
        	submissionInstance.Highest_Funding_Amt__c =1000;
        	submissionInstance.Longest_Term__c=1;
        	submissionInstance.Opportunity__c = opportunityInstance.Id;
        	insert submissionInstance;
        	system.assertNotEquals(null, submissionInstance.Id);
        	submissionControllerInstance.submissions =[select Id from Submission__c where Id =:submissionInstance.Id];
        	
        	submissionControllerInstance.getContainers();
        	system.assertEquals(submissionInstance.Id, submissionControllerInstance.submissions[0].Id);
        	
        	submissionControllerInstance.submissionList();
            system.assertEquals(false, submissionControllerInstance.declinedFlag);
        	
        	submissionInstance.Notes__c = 'testNewNotes';
        	submissionInstance.Highest_Funding_Amt__c =200;
        	submissionInstance.Status__c ='Declined';
        	update submissionInstance;
        	system.assertNotEquals(null, submissionInstance.Id);
        	
        	list<Submission__c> listNewSubmission = new list<Submission__c>();
            listNewSubmission = [SELECT Id FROM Submission__c where Id =:submissionInstance.Id];
        	submissionControllerInstance.newSubmission();
        	system.assertEquals(submissionInstance.Id , listNewSubmission[0].Id);
        	submissionControllerInstance.updateInlineEditedValue();
        	Submission__c subValue = new Submission__c();
        	submissionControllerInstance.checkoldAndNewVal();
        	subValue.Funder__c = accInstance.Id;
			system.assertEquals(true ,submissionControllerInstance.isUpdated);
        	
        	list<Submission__c> listSubmission = new list<Submission__c>();
        	listSubmission = [SELECT Id FROM Submission__c where Id =:submissionInstance.Id];
        	submissionControllerInstance.save();
        	submissionControllerInstance.saveAllSubmissions();
        	system.assertEquals(submissionInstance.Id ,listSubmission[0].Id);
        	
        	submissionControllerInstance.saveMessage();
        	submissionControllerInstance.recordToDelete = submissionInstance.Id;
        	submissionControllerInstance.deleteSubmission();
            submissionControllerInstance.refresh();
        	system.assertEquals('false', submissionControllerInstance.inlineEdit );
        	
        	submissionControllerInstance.editAll();
        	system.assertEquals(true ,submissionControllerInstance.editAll);
        Test.stopTest();
    }
    
    //Test offer tab controller which is in opportunity
    static testMethod void offersTabControllerTest() {
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        system.assertNotEquals(null, accInstance.Id);
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Submission__c submissionInstance = new Submission__c();
        submissionInstance.Funder__c = accInstance.Id;
        submissionInstance.Status__c ='Approved';
        submissionInstance.Opportunity__c = opportunityInstance.Id;
        insert submissionInstance;
        system.assertNotEquals(null,submissionInstance.Id);
        
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
            system.assertNotEquals(null, offerInstance.Id);
            List<Offer__c> listOffer = new List<Offer__c>();
            listOffer = [
                        SELECT Id 
                          FROM Offer__c 
                         WHERE Funder__c =:accInstance.Id 
                           AND Opportunity__c =:opportunityInstance.Id
            ];
            offerControllerInstance.getContainers();
            offerControllerInstance.offerList();
            system.assertEquals(offerInstance.Id, listOffer[0].Id);
            offerControllerInstance.updateInlineEditedValue();
            offerControllerInstance.save();
            List<Submission__c> listSubmission = new List<Submission__c>();
            listSubmission =[
                            SELECT Id 
                              FROM Submission__c where Opportunity__c =:opportunityInstance.Id
            ];
            offerControllerInstance.getSubmissionNames();
            system.assertEquals(offerInstance.Id, listOffer[0].Id);
            
            offerInstance.Amount__c = 200;
            offerInstance.Payoff_Amount__c = 122;
            offerInstance.Rate__c = 5;
            update offerInstance;
            offerControllerInstance.newOffer();
            system.assertEquals(offerInstance.Id, listOffer[0].Id);
            
            Offer__c offerNewInstance = new Offer__c ();
            offerNewInstance.Funder__c = accInstance.Id;
            offerNewInstance.Opportunity__c = opportunityInstance.Id;
            offerNewInstance.submission__c = submissionInstance.Id;
            offerNewInstance.Amount__c = 100;
            insert offerNewInstance;
            system.assertNotEquals(null, offerNewInstance.Id);
            
            offerControllerInstance.checkoldAndNewVal();
            system.assertEquals(true, offerControllerInstance.isUpdated);
            
            offerControllerInstance.recordToDelete = offerInstance.Id;
            offerControllerInstance.deleteOffer();
            offerControllerInstance.refresh();
            offerControllerInstance.saveAllOffers();
            system.assertEquals(offerInstance.Id ,listOffer[0].Id);
            
            offerControllerInstance.editAll();
            system.assertEquals(true, offerControllerInstance.editAll );
            
           
            
        Test.stopTest();
    }
    
    //Test stips tab controller which is in opportunity
    static testMethod void stipsTabControllerTest() {
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Submission__c submissionInstance = new Submission__c();
        submissionInstance.Opportunity__c = opportunityInstance.Id;
        insert submissionInstance;
        system.assertNotEquals(null,submissionInstance.Id);
        
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
            system.assertNotEquals(null, stipsInstance.Id);
            stipsControllerInstance.getSubmissionID() ;
            system.assertNotEquals(null, stipsInstance.Id);
            
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
            system.assertEquals(stipsInstance.Id, stipsControllerInstance.stips[0].Id);
        
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
            system.assertEquals(stipsInstance.Id, stipsControllerInstance.newStips[0].Id);
            
            stipsControllerInstance.getSubmissionNames();
            stipsControllerInstance.save();
            stipsControllerInstance.test();
            stipsControllerInstance.updateInlineEditedValue();
           
            Stips__c stipsNewInstance = new Stips__c();
            stipsNewInstance.Name ='TestStips';
            stipsNewInstance.Submission__c = submissionInstance.Id;
            stipsNewInstance.Opportunity__c = opportunityInstance.Id;
            insert stipsNewInstance;
            system.assertNotEquals(null, stipsNewInstance.Id);
            stipsControllerInstance.checkoldAndNewVal();
            system.assertEquals(false, stipsControllerInstance.isUpdated);
            
            stipsControllerInstance.refresh();
            system.assertEquals(true, stipsControllerInstance.isFirst);
            stipsControllerInstance.saveAllStips();
            stipsControllerInstance.editAll();
            system.assertEquals(true, stipsControllerInstance.editAll );
            stipsControllerInstance.recordToDelete = stipsInstance.Id;
            stipsControllerInstance.deleteStip();
            stipsControllerInstance.inlineedit();
            system.assertEquals(true, stipsControllerInstance.editmode);
        Test.stopTest();
    }
    
    //Test Loan Balance tab controller which is in opportunity
    static testMethod void loanBalanceTabControllerTest() {
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        system.assertNotEquals(null, accInstance.Id);
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCALoanBalanceTabController loanBalanceControllerInstance = new MCALoanBalanceTabController();
            Loan_Balance__c loanBalanceInstance = new Loan_Balance__c();
            loanBalanceInstance.Funder__c = accInstance.Id;
            loanBalanceInstance.Balance__c = 100;
            loanBalanceInstance.Daily_Payment__c =101;
            loanBalanceInstance.Opportunity__c = opportunityInstance.Id;
            insert loanBalanceInstance;
            system.assertNotEquals(null,loanBalanceInstance.Id);
            loanBalanceControllerInstance.loanBalances = [select Id from Loan_Balance__c where ID =:loanBalanceInstance.Id];
            loanBalanceControllerInstance.getContainers(); 
            loanBalanceControllerInstance.loanBalanceList();
            system.assertEquals(loanBalanceInstance.Id, loanBalanceControllerInstance.loanBalances[0].Id);
            
            loanBalanceInstance.Daily_Payment__c =122;
            loanBalanceInstance.Balance__c = 100;
            update loanBalanceInstance;
            system.assertNotEquals(null, loanBalanceInstance.Id);
            
            loanBalanceControllerInstance.newLoanBalances =[select Id from Loan_Balance__c where Id=:loanBalanceInstance.Id] ;
            Loan_Balance__c loanInstance = new Loan_Balance__c();
            loanInstance.Balance__c = 100;
            loanBalanceControllerInstance.checkoldAndNewVal();
            system.assertEquals(true ,loanBalanceControllerInstance.isUpdated);
            loanBalanceControllerInstance.saveMessage();
            loanBalanceControllerInstance.newLoanBalance();
            loanBalanceControllerInstance.removeLoanBalance();
            system.assertEquals(loanBalanceInstance.Id,loanBalanceControllerInstance.newLoanBalances[0].Id);
            loanBalanceControllerInstance.updateInlineEditedValue();
            
            loanBalanceControllerInstance.refresh();
            loanBalanceControllerInstance.getBankNames();
            loanBalanceControllerInstance.editAll();
            system.assertEquals(true, loanBalanceControllerInstance.editAll );
            loanBalanceControllerInstance.save();
            loanBalanceControllerInstance.saveAllLoans();
            system.assertEquals(loanBalanceInstance.Id, loanBalanceControllerInstance.loanBalances[0].Id);
            
            loanBalanceControllerInstance.recordToDelete = loanInstance.Id;
            loanBalanceControllerInstance.deleteLoanBalance() ;
            
        Test.stopTest();
    }
    
    //Test sales History tab controller which is in opportunity
    static testMethod void salesHistoryBankControllerTest() {
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        system.assertNotEquals(null, accInstance.Id);
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Bank_Account__c bankAccountInstance = new Bank_Account__c();
        bankAccountInstance.Deposits__c = 100;
        bankAccountInstance.Account__c = accInstance.Id;
        bankAccountInstance.Opportunity__c = opportunityInstance.Id;
        insert bankAccountInstance;
        system.assertNotEquals(null, bankAccountInstance.Id);
        
        Credit_Card__c creditCardInstance = new Credit_Card__c();
        creditCardInstance.Account__c = accInstance.Id;
        creditCardInstance.Opportunity__c = opportunityInstance.Id;
        creditCardInstance.Number_of_Transactions_All__c = 15;
        insert creditCardInstance;
        system.assertNotEquals(null, creditCardInstance.Id);
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCASalesHistoryTabController salesHistoryControllerInstance = new MCASalesHistoryTabController();
            
            salesHistoryControllerInstance.creditCardList = [select Id from Credit_Card__c where ID =:creditCardInstance.Id];
            salesHistoryControllerInstance.getContainersStatements();
            salesHistoryControllerInstance.getContainersCards();
            system.assertEquals(creditCardInstance.Id, salesHistoryControllerInstance.creditCardList[0].Id);
            
            bankAccountInstance.Deposits__c = 100;
            update bankAccountInstance;
            system.assertNotEquals(null, bankAccountInstance.Id);
            
            salesHistoryControllerInstance.newStatements = [select Id from Bank_Account__c where Id= :bankAccountInstance.Id];
            salesHistoryControllerInstance.newStatement();
            system.assertEquals(bankAccountInstance.Id, salesHistoryControllerInstance.newStatements[0].Id);
            
            
            list<Credit_Card__c> checkListCreditCard = new list<Credit_Card__c>();
            checkListCreditCard = [select Id from Credit_Card__c where Id =:creditCardInstance.Id];
            salesHistoryControllerInstance.cardAccountList();
            system.assertEquals(creditCardInstance.Id, checkListCreditCard[0].Id);
            
            Bank_Account__c bankAccountNewInstance = new Bank_Account__c();
            bankAccountNewInstance.Account__c = accInstance.Id;
            bankAccountNewInstance.Opportunity__c = opportunityInstance.Id;
            insert bankAccountNewInstance;
            system.assertNotEquals(null , bankAccountNewInstance.Id);
            
            salesHistoryControllerInstance.checkoldAndNewBankVal();
            system.assertEquals(false, salesHistoryControllerInstance.isUpdatedBank);
            salesHistoryControllerInstance.updateInlineEditedBankValue();
            salesHistoryControllerInstance.updateRecords();
            system.assertEquals(false, salesHistoryControllerInstance.isUpdatedCard);
            
            creditCardInstance.Number_of_Transactions_All__c = 125;
            update creditCardInstance;
            system.assertNotEquals(null, creditCardInstance.Id);
            
            salesHistoryControllerInstance.newCredits = [select Id from Credit_Card__c where Id = :creditCardInstance.Id];
            salesHistoryControllerInstance.newCredit();
            system.assertEquals(creditCardInstance.Id, salesHistoryControllerInstance.newCredits[0].Id);
            
            Credit_Card__c creditCardNewInstance = new Credit_Card__c();
            creditCardNewInstance.Number_of_Transactions_All__c = 15;
            creditCardNewInstance.Account__c = accInstance.Id;
            creditCardNewInstance.Opportunity__c = opportunityInstance.Id;
            insert creditCardNewInstance;
            system.assertNotEquals(null, creditCardNewInstance.Id);
            salesHistoryControllerInstance.checkoldAndNewCardVal();
            system.assertEquals(true, salesHistoryControllerInstance.isUpdatedCard );
            salesHistoryControllerInstance.refresh();
            salesHistoryControllerInstance.editAll();
            system.assertEquals(true, salesHistoryControllerInstance.editAll);
            salesHistoryControllerInstance.saveAllSales();
            system.assertEquals(creditCardInstance.Id, salesHistoryControllerInstance.creditCardList[0].Id);
            system.assertEquals(creditCardInstance.Id, checkListCreditCard[0].Id);
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
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Account accInstance = new Account();
        accInstance.Name='TestAccount';
        insert accInstance;
        system.assertNotEquals(null, accInstance.Id);
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCACommissionsTabController commissionsControllerInstanceTest = new MCACommissionsTabController();
            Payable__c payableInstance = new Payable__c();
            payableInstance.Payback_Funded__c = 'test';
            payableInstance.Opportunity__c = opportunityInstance.Id;
            payableInstance.Percentage__c = 20;
            payableInstance.Account__c = accInstance.Id;
            payableInstance.Memo__c ='Test Memo';
            payableInstance.Status__c = 'Open';
            insert payableInstance;
            system.assertNotEquals(null, payableInstance.Id);
            
            list<Payable__c> checkListPayable = new list<Payable__c>();
            checkListPayable = [select Id from Payable__c where Id =:payableInstance.Id];
            commissionsControllerInstanceTest.payableList();
            system.assertEquals(payableInstance.Id, checkListPayable[0].Id);
            
            commissionsControllerInstanceTest.payables  = [select Id from Payable__c where Id =:payableInstance.Id];
            
            commissionsControllerInstanceTest.getPayables();
            system.assertEquals(payableInstance.Id, commissionsControllerInstanceTest.payables[0].Id);
            
            
            Receivable__c receivableInstance = new Receivable__c();
            receivableInstance.Opportunity__c = opportunityInstance.Id;
            receivableInstance.Percentage__c = 10;
            receivableInstance.Amount__c  = 200;
            receivableInstance.Memo__c ='Test Memo';
            insert receivableInstance;
            system.assertNotEquals(null, receivableInstance.Id);
            
            list<Receivable__c> checkListReceivable = new list<Receivable__c>();
            checkListReceivable =[select Id from Receivable__c where Id =:receivableInstance.Id];
            commissionsControllerInstanceTest.receivablesList();
            system.assertEquals(receivableInstance.Id, checkListReceivable[0].Id);
            
            commissionsControllerInstanceTest.receivables  =[select Id from Receivable__c where Id =:receivableInstance.Id];
            commissionsControllerInstanceTest.getReceivables();
            system.assertEquals(receivableInstance.Id, commissionsControllerInstanceTest.receivables[0].Id);
            
            commissionsControllerInstanceTest.save();
            commissionsControllerInstanceTest.saveAllCommissions();
            system.assertEquals(receivableInstance.Id, checkListReceivable[0].Id);
            commissionsControllerInstanceTest.refresh();
            system.assertEquals(true, commissionsControllerInstanceTest.isFirstReceivable);
            system.assertEquals(true, commissionsControllerInstanceTest.isFirstPayable);
            
            commissionsControllerInstanceTest.editAll();
            system.assertEquals(true, commissionsControllerInstanceTest.editAll);
            
            commissionsControllerInstanceTest.updateRecord();
            commissionsControllerInstanceTest.updateInlineEditedPayableValue();
            
            payableInstance.Memo__c ='Testnew Memo';
            update payableInstance;
            system.assertNotEquals(null, payableInstance.Id);
            commissionsControllerInstanceTest.newPayables =[select Id from Payable__c where Id =:payableInstance.Id];
            commissionsControllerInstanceTest.newPayable();
            system.assertEquals(payableInstance.Id, commissionsControllerInstanceTest.newPayables[0].Id);
            commissionsControllerInstanceTest.checkoldAndNewPayableVal();
            system.assertEquals(true, commissionsControllerInstanceTest.isUpdatedPayable );
            commissionsControllerInstanceTest.updateInlineEditedReceValue();
            
            receivableInstance.Memo__c ='Test new Receivable Memo';
            update receivableInstance;
            system.assertNotEquals(null, receivableInstance.Id);
            commissionsControllerInstanceTest.newReceivables =[select Id from Receivable__c where Id =:ReceivableInstance.Id];
            commissionsControllerInstanceTest.newReceivable();
            system.assertEquals(ReceivableInstance.Id, commissionsControllerInstanceTest.newReceivables[0].Id);
            
            commissionsControllerInstanceTest.checkoldAndNewReceivableVal();
            system.assertEquals(true, commissionsControllerInstanceTest.isUpdatedReceivable);
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
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCASyndicationTabController syndicationTabControllerInstance = new MCASyndicationTabController();
            Syndication__c syndicationInstance = new Syndication__c();
            syndicationInstance.Opportunity__c = opportunityInstance.Id;
            syndicationInstance.Syndication_Amt__c = 10;
            syndicationInstance.Servicing_Fee__c = 20;
            syndicationInstance.Memo__c = 'Test Memo';
            insert syndicationInstance;
            system.assertNotEquals(null, syndicationInstance.Id);
            
            syndicationTabControllerInstance.syndications = [select Id from Syndication__c where Id = :syndicationInstance.Id];
            syndicationTabControllerInstance.syndicationList();
            syndicationTabControllerInstance.getContainers();
            system.assertEquals(syndicationInstance.Id,syndicationTabControllerInstance.syndications[0].Id);
            
            
            syndicationInstance.Servicing_Fee__c = 20;
            syndicationInstance.Memo__c = 'Test Memo';
            update syndicationInstance;
            system.assertNotEquals(null, syndicationInstance.Id);
            syndicationTabControllerInstance.newSyndications = [select Id from Syndication__c where Id = :syndicationInstance.Id];
            syndicationTabControllerInstance.saveMessage();
            syndicationTabControllerInstance.newSyndication();
            system.assertEquals(syndicationInstance.Id, syndicationTabControllerInstance.newSyndications[0].Id);
            syndicationTabControllerInstance.removeSyndication();
            Syndication__c syndicationNewInstance = new Syndication__c();
            syndicationTabControllerInstance.checkoldAndNewVal();
            syndicationNewInstance.Opportunity__c = opportunityInstance.Id;
            system.assertEquals(false, syndicationTabControllerInstance.isUpdated );
            
            syndicationTabControllerInstance.updateInlineEditedValue();
            syndicationTabControllerInstance.save();
            syndicationTabControllerInstance.saveAllSyndications();
            system.assertEquals(syndicationInstance.Id,syndicationTabControllerInstance.syndications[0].Id);
            
            syndicationTabControllerInstance.refresh();
            system.assertEquals(true, syndicationTabControllerInstance.isFirst);
            syndicationTabControllerInstance.editAll();
            system.assertEquals(true, syndicationTabControllerInstance.editAll);
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
        system.assertNotEquals(null,opportunityInstance.Id);
        
        Contact contactInstance = new Contact();
        contactInstance.LastName = 'Test';
        contactInstance.Email = 'test@abc.com';
        contactInstance.Phone ='123455';
        insert contactInstance;
        system.assertNotEquals(null,contactInstance.Id);
        
        Test.startTest();
            Id opportunityId = Apexpages.currentPage().getParameters().put('id',opportunityInstance.Id);
            MCAContactRolesTabController  contactRoleControllerInstance = new MCAContactRolesTabController ();
            
            OpportunityContactRole oportunityContactInstance = new OpportunityContactRole();
            oportunityContactInstance.OpportunityId = opportunityInstance.Id;
            oportunityContactInstance.ContactId = contactInstance.Id;
            oportunityContactInstance.Role = 'Decision Maker';
            insert oportunityContactInstance;
            system.assertNotEquals(null, oportunityContactInstance.Id);
            contactRoleControllerInstance.contactRoles = [select Id from OpportunityContactRole where Id =:oportunityContactInstance.Id];
            contactRoleControllerInstance.contactList = [select Id from Contact where Id= :contactInstance.Id];
            contactRoleControllerInstance.getContainers();
            system.assertEquals(contactInstance.Id, contactRoleControllerInstance.contactList[0].Id);
            system.assertEquals(oportunityContactInstance.Id, contactRoleControllerInstance.contactRoles[0].Id);
            
            list<OpportunityContactRole> checkOpportunityContactRoleList = new list<OpportunityContactRole>();
            checkOpportunityContactRoleList =[select Id from OpportunityContactRole where Id =:oportunityContactInstance.Id];
            
            contactRoleControllerInstance.getContactList();
            system.assertEquals(contactInstance.Id, contactRoleControllerInstance.contactList[0].Id);
            
            contactRoleControllerInstance.getOppContactRoleList();
            system.assertEquals(oportunityContactInstance.Id, checkOpportunityContactRoleList[0].Id);
            
            
            
            oportunityContactInstance.isPrimary = true;
            update oportunityContactInstance;
            system.assertNotEquals(null,oportunityContactInstance.Id);
            
            
            OpportunityContactRole oportunityContactNewInstance = new OpportunityContactRole();
            oportunityContactNewInstance.OpportunityId = opportunityInstance.Id;
            oportunityContactNewInstance.ContactId = contactInstance.Id;
            oportunityContactNewInstance.isPrimary = true;
            insert oportunityContactNewInstance;
            system.assertNotEquals(null, oportunityContactNewInstance.Id);
            contactRoleControllerInstance.checkoldAndNewVal();
            system.assertEquals(true, contactRoleControllerInstance.isUpdated);
            
            contactRoleControllerInstance.saveMessage();
            contactRoleControllerInstance.newContactList = [select Id from Contact where Id= :contactInstance.Id];
            contactRoleControllerInstance.updateInlineEditedValue() ;
            contactRoleControllerInstance.newContactRole();
            system.assertEquals(contactInstance.Id,contactRoleControllerInstance.newContactList[0].Id);
            contactRoleControllerInstance.indexToRemove = 0;
            
            contactRoleControllerInstance.removeRoles();
            
            contactRoleControllerInstance.save();
            contactRoleControllerInstance.saveAll();
            system.assertEquals(oportunityContactInstance.Id, checkOpportunityContactRoleList[0].Id);
            contactRoleControllerInstance.refresh();
            system.assertEquals(true, contactRoleControllerInstance.isFirst);
            
            contactRoleControllerInstance.editAll();
            system.assertEquals(true, contactRoleControllerInstance.editAll);
            contactRoleControllerInstance.recordToDelete = oportunityContactInstance.Id;
            contactRoleControllerInstance.deleteContactRole();
            //system.assertEquals(null, oportunityContactInstance.Id);
            
        Test.stopTest();
    }
    
    //Test Task tab controller which is in opportunity
    static testMethod void taskTabControllerTest() {
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.Name='TestOpportunity';
        opportunityInstance.CloseDate = System.today();
        opportunityInstance.StageName = 'Prospecting';
        insert opportunityInstance;
        system.assertNotEquals(null,opportunityInstance.Id);
        
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
            system.assertEquals(taskInstance.Id, taskControllerInstance.tasks[0].Id);
            
            taskControllerInstance.updateInlineEditedValue();
            taskInstance.Status ='Open';
            update taskInstance;
            system.assertNotEquals(null, taskInstance.Id);
            taskControllerInstance.newTasks = [select Id from Task where Id = :taskInstance.Id];
            
            taskControllerInstance.newTask();
            system.assertEquals(taskInstance.Id,taskControllerInstance.newTasks[0].Id);
        
            taskControllerInstance.save();
            taskControllerInstance.saveAllTasks();
            system.assertEquals(taskInstance.Id, taskControllerInstance.tasks[0].Id);
            
            Task taskNewInstance = new Task();
            taskNewInstance.Subject ='Test Task';
            taskNewInstance.Status ='Open';
            taskNewInstance.Description ='Test description';
            taskNewInstance.WhatId = opportunityInstance.Id;
            insert taskNewInstance;
            system.assertNotEquals(null, taskNewInstance.Id);
            
            taskControllerInstance.checkoldAndNewVal();
            system.assertEquals(true, taskControllerInstance.isUpdated );
            
            taskControllerInstance.refresh();
            system.assertEquals(true, taskControllerInstance.isFirst );
            taskControllerInstance.editAll();
            system.assertEquals(true, taskControllerInstance.editAll );
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
        system.assertNotEquals(null,opportunityInstance.Id);
        
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
            system.assertNotEquals(null, attachmentInstance.Id);
            
            attachmentControllerInstance.attachments = [select Id from Attachment where Id =:attachmentInstance.Id];
            attachmentControllerInstance.getContainers();
            system.assertEquals(attachmentInstance.Id, attachmentControllerInstance.attachments[0].Id);
            attachmentControllerInstance.refresh();
            system.assertEquals(false, attachmentControllerInstance.editAll );
            attachmentInstance.Description='Test upsert attachment Description';
            upsert attachmentInstance;
            attachmentControllerInstance.saveAllAttachments();
            system.assertEquals(attachmentInstance.Id, attachmentControllerInstance.attachments[0].Id);
            
            attachmentControllerInstance.editAll();
            system.assertEquals(true, attachmentControllerInstance.editAll );
            attachmentControllerInstance.recordToDelete = attachmentInstance.Id;
            attachmentControllerInstance.deleteAttachment();
            
        Test.stopTest();
    }
}