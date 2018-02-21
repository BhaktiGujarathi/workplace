@isTest
public with sharing class CreateContractControllerTest {
       
    
    static testMethod void testForAddRowReceivableForOriginationFeeType() {
      
        //create Account
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Commission Revenue',recordTypeID=[select id from recordtype where sobjectType='Account' and DeveloperName='Merchant'].id);
        insert objAccount; 
        
        //Create Programme 
        Program__c objProgramme = new Program__c(Name='Test Programme',Renewal_Eligibility__c = 10.0 );
        insert objProgramme;
        
        //Create Opportunity
        Opportunity objOppo = new Opportunity(Name='TestOpp',Term_Months__c = 1,Bank_Program__c = objProgramme.Id, AccountId = objAccount.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo; 
        
        Opportunity opp = [select OwnerId from Opportunity where id=: objOppo.Id];
        system.debug('###objOppo.OwnerId'+opp.OwnerId);
        objAccount.User__c = opp.OwnerId;
        update objAccount;
        system.debug('###objAccount'+objAccount);
        
        //create submission
        Submission__c objSubmission = new Submission__c(Opportunity__c=objOppo.Id, Status__c='UW',Program__c=objProgramme.Id);
        insert objSubmission;
        
        // Create offer related to Opportunity
        Offer__c objoffer1 = new Offer__c(Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id ,Origination_fee__c=1000.00,Amount__c = 10);
        insert objoffer1;
        
        
        
        //create Receivables related to Opportunity
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id, Opportunity__c=objOppo.Id,Type__c = 'Commission');
        insert objInvoice;
        
        //create Payable related to Opportunity
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00, Opportunity__c=objOppo.Id );
        insert objBill;
        
       
        Opportunity objOppo1 = new Opportunity(Name='TestOpp',Term_Months__c = 1, AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo1;
        
        Syndication__c objsyndication = new Syndication__c(Commission_Fee__c = 10,Syndication_Amt__c = 100,Servicing_Fee__c = 200,Opportunity__c = objOppo.Id);
        insert objsyndication;
        
        
        
        Test.startTest();
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
        
    
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);
       
        CreateContractController controller=new CreateContractController();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        controller.selOfferId = objoffer1.id;
        controller.populateData();
        //System.assertequals(controller.wizardType,CreateContractController.OFFER_SCREEN);
        controller.wizardType='Offer';
        controller.next();
        controller.getSubmissionNames();
        
        controller.recordTypeId = '';
        controller.newFlag ='';
       // System.assertequals(controller.wizardType,CreateContractController.DEAL_SCREEN);
        controller.next();
        
         
        Test.stopTest();
        
    }
    
    
    
    static testMethod void testStatisticsDataForOpportunity2Cover() {
        //create Account
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'All Revenue');
        insert objAccount;  
        
        //Create Opportunity
        Opportunity objOppo = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo; 
        Opportunity opp = [select OwnerId from Opportunity where id=: objOppo.Id];
        system.debug('###objOppo.OwnerId'+opp.OwnerId);
        objAccount.User__c = opp.OwnerId;
        update objAccount;
        system.debug('###objAccount'+objAccount);
        //Create Programme 
        Program__c objProgramme = new Program__c(Name='Test Programme',Renewal_Eligibility__c = 10.0);
        insert objProgramme;
        
        //create submission
        Submission__c objSubmission = new Submission__c(Opportunity__c=objOppo.Id, Status__c='UW',Program__c=objProgramme.Id);
        insert objSubmission;
        
        // Create offer related to Opportunity
        Offer__c objoffer1 = new Offer__c(Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer1;
        
        Offer__c objoffer2 = new Offer__c( Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer2;
        
        //create Receivables related to Opportunity
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id, Opportunity__c=objOppo.Id,Payback_Funded__c = 'Payback',Percentage__c = 10,Type__c = 'Commission');
        insert objInvoice; 
        
        //create Payable related to Opportunity
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00, Opportunity__c=objOppo.Id );
        insert objBill;
        
       
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo1;
        
        
        Test.startTest();
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
        
    
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);
       
        CreateContractController controller=new CreateContractController();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        
        controller.populateData();
       // System.assertequals(controller.wizardType,CreateContractController.OFFER_SCREEN);
        controller.wizardType='Offer';
        controller.next();
        controller.getSubmissionNames();
        
        controller.recordTypeId = '';
        controller.newFlag ='';
       // System.assertequals(controller.wizardType,CreateContractController.DEAL_SCREEN);
        controller.next();
        
     
       
         
         //Adding the Origin Fee logic
         controller.receivableList.add(new Receivable__c(Type__c = 'Origination Fee',Amount__c =2000,Due_From_Account__c = objAccount.Id));
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayableOrgFee = new Payable__c(Type__c='Origination Fee',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Origination Fee',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayableOrgFee ;
        controller.payableList.add(objPayableOrgFee );
        controller.onChangePayPercentage();
        controller.onChangeTermMonth();
        
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayable = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayable;
        controller.payableList.add(objPayable);
        controller.onChangePayPaybackFunded();
        controller.onChangePayPercentage();
        controller.quickSavePayable();
      
        
        Syndication__c objSynd = new Syndication__c(Syndication_Amt__c = 1000,Servicing_Fee__c = 2500,Syndicated_By__c = objAccount.Id);
        controller.syndication = objSynd;
        controller.syndicationList.add(objSynd);
        controller.quickSaveSyndication();
       // System.assertequals(1,controller.syndicationList.size());
        
       // Contract objContract = new Contract();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        controller.AccountId = ''+ objAccount.Id;
        controller.save();
        
        controller.changeWizard();
        PageReference cancelPageRef = controller.cancel();
      //  System.assertEquals(cancelPageRef.getUrl(), '/'+objOppo.Id);
        
        controller.addRowOffer();
      //  System.assertEquals(3,controller.offerWrapperList.size());
        
        controller.addRowReceivable();
       // System.assertEquals(2,controller.receivableList.size());
        Receivable__c objreceivable1 = new Receivable__c();
        objreceivable1.Type__c = 'Bonus';
        objreceivable1.Amount__c =2000;
        objreceivable1.Payback_Funded__c = 'Funded';
        objreceivable1.Due_From_Account__c = objAccount.Id;
        controller.objOpp = objOppo;
        controller.receivableList.add(objreceivable1);
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.next();
       
        controller.addRowPayable();
       // Integer int3 =  controller.payableList.size();  
       // System.assertEquals(int3,controller.payableList.size());
        Payable__c objPayable1 = new Payable__c();
        objPayable1.Type__c='Bonus';
        objPayable1.Amount_Due__c = 100;
        objPayable1.Account__c = objAccount.Id;
        objPayable1.Payback_Funded__c = 'Funded';
        controller.payable = objPayable;
        controller.payableList.add(objPayable1);
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.next();
        
        
        controller.rowNum = 2;
        PageReference pageRef = Page.CreateContract;
        pageRef.getParameters().put('index','2');
        ApexPages.currentPage().getParameters().put('index','2');
        controller.deleteOffer();
        controller.deletPayables();
        controller.deletReceivables();
        controller.deletSyndications();
        System.currentPagereference().getParameters().put('Id',objOppo.Id);
        System.currentPagereference().getParameters().put('offerId',objoffer2.Id);
        
        controller.selectedOffer();
        
       
       
        Test.stopTest();
       
    }   
    
    static testMethod void testStatisticsDataForOpportunityCommissionRevenue() {
        //create Account
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Commission Revenue');
        insert objAccount;  
        
        //Create Programme 
        Program__c objProgramme = new Program__c(Name='Test Programme',Renewal_Eligibility__c = 10.0);
        insert objProgramme;
        
        //Create Opportunity
        Opportunity objOppo = new Opportunity(Name='TestOpp',Bank_Program__c = objProgramme.Id, AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo; 
        Opportunity opp = [select OwnerId from Opportunity where id=: objOppo.Id];
        system.debug('###objOppo.OwnerId'+opp.OwnerId);
        objAccount.User__c = opp.OwnerId;
        update objAccount;
        system.debug('###objAccount'+objAccount);
        
        
        //create submission
        Submission__c objSubmission = new Submission__c(Opportunity__c=objOppo.Id, Status__c='UW',Program__c=objProgramme.Id);
        insert objSubmission;
        
        // Create offer related to Opportunity
        Offer__c objoffer1 = new Offer__c(Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer1;
        
        Offer__c objoffer2 = new Offer__c( Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer2;
        
        //create Receivables related to Opportunity
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id, Opportunity__c=objOppo.Id,Payback_Funded__c = 'Payback',Percentage__c = 10,Type__c = 'Commission');
        insert objInvoice; 
        
        //create Payable related to Opportunity
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00, Opportunity__c=objOppo.Id );
        insert objBill;
        
       
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo1;
        
         // Create Contract
      /*  Contract contract = new Contract(AccountId=objAccount.Id,Status='Draft',ContractTerm = 2, Opportunity__c = objOppo1.Id);
        insert contract;*/
        
        Test.startTest();
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
        
    
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);
       
        CreateContractController controller=new CreateContractController();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        
        controller.populateData();
       // System.assertequals(controller.wizardType,CreateContractController.OFFER_SCREEN);
        controller.wizardType='Offer';
        controller.next();
        controller.getSubmissionNames();
        
        controller.recordTypeId = '';
        controller.newFlag ='';
       // System.assertequals(controller.wizardType,CreateContractController.DEAL_SCREEN);
        controller.next();
        
        controller.onChangeBankProgram();
        
      /*  Receivable__c objreceivable = new Receivable__c(Type__c = 'Bonus',Amount__c =2000,Payback_Funded__c = 'Funded',Due_From_Account__c = objAccount.Id);
       
        controller.objOpp = objOppo;
        controller.receivable = objreceivable;
        controller.receivableList.add(objreceivable);
        controller.onChangeRecPercentage();
        controller.onChangeRecPaybackFunded();
        controller.quickSaveReceivable();
        system.debug(controller.receivableList);*/
     //   System.assertequals(1,controller.receivableList.size());
       
       
         
         //Adding the Origin Fee logic
         controller.receivableList.add(new Receivable__c(Type__c = 'Origination Fee',Amount__c =2000,Due_From_Account__c = objAccount.Id));
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayableOrgFee = new Payable__c(Type__c='Origination Fee',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Origination Fee',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayableOrgFee ;
        controller.payableList.add(objPayableOrgFee );
        controller.onChangePayPercentage();
        
        
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayable = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayable;
        controller.payableList.add(objPayable);
        controller.onChangePayPaybackFunded();
        controller.onChangePayPercentage();
        controller.quickSavePayable();
       /* 
        //FOR PAYABLE FUNDED and type bonus WITH ID. 
        Payable__c objPayableWithID = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
        insert objPayableWithID;
        ApexPages.currentPage().getParameters().put('payId',objPayableWithID.id);
        controller.payable = objPayableWithID ;
        controller.payableList.add(objPayableWithID );
        controller.onChangePayPaybackFunded();
        controller.onChangePayPercentage();
        controller.quickSavePayable();
      
        */
        //System.assertequals(1,controller.payableList.size());
        
        Syndication__c objSynd = new Syndication__c(Syndication_Amt__c = 1000,Servicing_Fee__c = 2500,Syndicated_By__c = objAccount.Id);
        controller.syndication = objSynd;
        controller.syndicationList.add(objSynd);
        controller.quickSaveSyndication();
        //System.assertequals(1,controller.syndicationList.size());
        
       // Contract objContract = new Contract();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        controller.AccountId = ''+ objAccount.Id;
        controller.save();
        
        controller.changeWizard();
        PageReference cancelPageRef = controller.cancel();
        //System.assertEquals(cancelPageRef.getUrl(), '/'+objOppo.Id);
        
        controller.addRowOffer();
      //  System.assertEquals(3,controller.offerWrapperList.size());
        
        controller.addRowReceivable();
       // System.assertEquals(2,controller.receivableList.size());
        Receivable__c objreceivable1 = new Receivable__c();
        objreceivable1.Type__c = 'Bonus';
        objreceivable1.Amount__c =2000;
        objreceivable1.Payback_Funded__c = 'Funded';
        objreceivable1.Due_From_Account__c = objAccount.Id;
        controller.objOpp = objOppo;
        controller.receivableList.add(objreceivable1);
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.next();
       
        controller.addRowPayable();
       // Integer int3 =  controller.payableList.size();  
       // System.assertEquals(int3,controller.payableList.size());
        Payable__c objPayable1 = new Payable__c();
        objPayable1.Type__c='Bonus';
        objPayable1.Amount_Due__c = 100;
        objPayable1.Account__c = objAccount.Id;
        objPayable1.Payback_Funded__c = 'Funded';
        controller.payable = objPayable;
        controller.payableList.add(objPayable1);
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.next();
        /* 
        controller.addRowSyndication();
        Syndication__c objSynd1 = new Syndication__c();
        objSynd1.Syndication_Amt__c = 1000;
        objSynd1.Servicing_Fee__c = 2500;
        objSynd1.Syndicated_By__c = objAccount.Id;
        controller.syndicationList.add(objSynd1);
        controller.wizardType = CreateContractController.SYNDICATION_SCREEN;
        controller.next();
        controller.previous();
        controller.wizardType = CreateContractController.SYNDICATION_SCREEN;
        controller.previous();
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.previous();
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.previous();
        controller.wizardType = CreateContractController.DEAL_SCREEN;
        controller.previous();*/
        
        controller.rowNum = 2;
        PageReference pageRef = Page.CreateContract;
        pageRef.getParameters().put('index','2');
        ApexPages.currentPage().getParameters().put('index','2');
        controller.deleteOffer();
        controller.deletPayables();
        controller.deletReceivables();
        controller.deletSyndications();
        System.currentPagereference().getParameters().put('Id',objOppo.Id);
        System.currentPagereference().getParameters().put('offerId',objoffer2.Id);
        
        controller.selectedOffer();
        
       
       
        Test.stopTest();
       
    }   
    
    
    static testMethod void testStatisticsDataForOpportunityFunded() {
      
        //create Account
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Funded');
        insert objAccount;   
        
        //Create Opportunity
        Opportunity objOppo = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo; 
        Opportunity opp = [select OwnerId from Opportunity where id=: objOppo.Id];
        system.debug('###objOppo.OwnerId'+opp.OwnerId);
        objAccount.User__c = opp.OwnerId;
        update objAccount;
        system.debug('###objAccount'+objAccount);
        //Create Programme 
        Program__c objProgramme = new Program__c(Name='Test Programme',Renewal_Eligibility__c = 10.0);
        insert objProgramme;
        
        //create submission
        Submission__c objSubmission = new Submission__c(Opportunity__c=objOppo.Id, Status__c='UW',Program__c=objProgramme.Id);
        insert objSubmission;
        
        // Create offer related to Opportunity
        Offer__c objoffer1 = new Offer__c(Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer1;
        
        Offer__c objoffer2 = new Offer__c( Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer2;
        
        //create Receivables related to Opportunity
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id, Opportunity__c=objOppo.Id,Payback_Funded__c = 'Payback',Percentage__c = 10,Type__c = 'Commission');
        insert objInvoice; 
        
        //create Payable related to Opportunity
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00, Opportunity__c=objOppo.Id );
        insert objBill;
        
       
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo1;
        
         
        
        Test.startTest();
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
        
    
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);
       
        CreateContractController controller=new CreateContractController();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        
        controller.populateData();
       // System.assertequals(controller.wizardType,CreateContractController.OFFER_SCREEN);
        controller.wizardType='Offer';
        controller.next();
        controller.getSubmissionNames();
        
        controller.recordTypeId = '';
        controller.newFlag ='';
       // System.assertequals(controller.wizardType,CreateContractController.DEAL_SCREEN);
        controller.next();
        controller.addRowReceivable();
        controller.addRowPayable();
     
       
         
         //Adding the Origin Fee logic
         controller.receivableList.add(new Receivable__c(Type__c = 'Origination Fee',Amount__c =2000,Due_From_Account__c = objAccount.Id));
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayableOrgFee = new Payable__c(Type__c='Origination Fee',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Origination Fee',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayableOrgFee ;
        controller.payableList.add(objPayableOrgFee );
        controller.onChangePayPercentage();
        
        
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayable = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayable;
        controller.payableList.add(objPayable);
        controller.onChangePayPaybackFunded();
        controller.onChangePayPercentage();
        controller.quickSavePayable();
       
        //System.assertequals(1,controller.payableList.size());
        
        Syndication__c objSynd = new Syndication__c(Syndication_Amt__c = 1000,Servicing_Fee__c = 2500,Syndicated_By__c = objAccount.Id);
        controller.syndication = objSynd;
        controller.syndicationList.add(objSynd);
        controller.quickSaveSyndication();
      //  System.assertequals(1,controller.syndicationList.size());
        
       // Contract objContract = new Contract();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        controller.AccountId = ''+ objAccount.Id;
        controller.save();
        
        controller.changeWizard();
        PageReference cancelPageRef = controller.cancel();
       // System.assertEquals(cancelPageRef.getUrl(), '/'+objOppo.Id);
        
        controller.addRowOffer();
      //  System.assertEquals(3,controller.offerWrapperList.size());
        
        controller.addRowReceivable();
       // System.assertEquals(2,controller.receivableList.size());
        Receivable__c objreceivable1 = new Receivable__c();
        objreceivable1.Type__c = 'Bonus';
        objreceivable1.Amount__c =2000;
        objreceivable1.Payback_Funded__c = 'Funded';
        objreceivable1.Due_From_Account__c = objAccount.Id;
        controller.objOpp = objOppo;
        controller.receivableList.add(objreceivable1);
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.next();
       
        controller.addRowPayable();
       // Integer int3 =  controller.payableList.size();  
       // System.assertEquals(int3,controller.payableList.size());
        Payable__c objPayable1 = new Payable__c();
        objPayable1.Type__c='Bonus';
        objPayable1.Amount_Due__c = 100;
        objPayable1.Account__c = objAccount.Id;
        objPayable1.Payback_Funded__c = 'Funded';
        controller.payable = objPayable;
        controller.payableList.add(objPayable1);
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.next();
        
        
        controller.rowNum = 2;
        PageReference pageRef = Page.CreateContract;
        pageRef.getParameters().put('index','2');
        ApexPages.currentPage().getParameters().put('index','2');
        controller.deleteOffer();
        controller.deletPayables();
        controller.deletReceivables();
        controller.deletSyndications();
        System.currentPagereference().getParameters().put('Id',objOppo.Id);
        System.currentPagereference().getParameters().put('offerId',objoffer2.Id);       
        controller.selectedOffer();
        
       
       
        Test.stopTest();
       
    }   
    
    static testMethod void testStatisticsDataForOpportunity2CoverPayback() {
        
        //create Account
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Payback');
        insert objAccount;   
        
        //Create Opportunity
        Opportunity objOppo = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo; 
        Opportunity opp = [select OwnerId from Opportunity where id=: objOppo.Id];
        system.debug('###objOppo.OwnerId'+opp.OwnerId);
        objAccount.User__c = opp.OwnerId;
        update objAccount;
        system.debug('###objAccount'+objAccount);
        //Create Programme 
        Program__c objProgramme = new Program__c(Name='Test Programme',Renewal_Eligibility__c = 10.0);
        insert objProgramme;
        
        //create submission
        Submission__c objSubmission = new Submission__c(Opportunity__c=objOppo.Id, Status__c='UW',Program__c=objProgramme.Id);
        insert objSubmission;
        
        // Create offer related to Opportunity
        Offer__c objoffer1 = new Offer__c(Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer1;
        
        Offer__c objoffer2 = new Offer__c( Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id,Amount__c = 10);
        insert objoffer2;
        
        //create Receivables related to Opportunity
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id, Opportunity__c=objOppo.Id,Payback_Funded__c = 'Payback',Percentage__c = 10,Type__c = 'Commission');
        insert objInvoice; 
        
        //create Payable related to Opportunity
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00, Opportunity__c=objOppo.Id );
        insert objBill;
        
       
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo1;
        
      
        Test.startTest();
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
        
    
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);
       
        CreateContractController controller=new CreateContractController();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        
        controller.populateData();
       // System.assertequals(controller.wizardType,CreateContractController.OFFER_SCREEN);
        controller.wizardType='Offer';
        controller.next();
        controller.getSubmissionNames();
        
        controller.recordTypeId = '';
        controller.newFlag ='';
       // System.assertequals(controller.wizardType,CreateContractController.DEAL_SCREEN);
        controller.next();
        
    
       
         
         //Adding the Origin Fee logic
         controller.receivableList.add(new Receivable__c(Type__c = 'Origination Fee',Amount__c =2000,Due_From_Account__c = objAccount.Id));
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayableOrgFee = new Payable__c(Type__c='Origination Fee',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Origination Fee',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayableOrgFee ;
        controller.payableList.add(objPayableOrgFee );
        controller.onChangePayPercentage();
        
        
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayable = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayable;
        controller.payableList.add(objPayable);
        controller.onChangePayPaybackFunded();
        controller.onChangePayPercentage();
        controller.quickSavePayable();
      
        
        Syndication__c objSynd = new Syndication__c(Syndication_Amt__c = 1000,Servicing_Fee__c = 2500,Syndicated_By__c = objAccount.Id);
        controller.syndication = objSynd;
        controller.syndicationList.add(objSynd);
        controller.quickSaveSyndication();
       // System.assertequals(1,controller.syndicationList.size());
        
       // Contract objContract = new Contract();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        controller.AccountId = ''+ objAccount.Id;
        controller.save();
        
        controller.changeWizard();
        PageReference cancelPageRef = controller.cancel();
     //   System.assertEquals(cancelPageRef.getUrl(), '/'+objOppo.Id);
        
        controller.addRowOffer();
      //  System.assertEquals(3,controller.offerWrapperList.size());
        
        controller.addRowReceivable();
       // System.assertEquals(2,controller.receivableList.size());
        Receivable__c objreceivable1 = new Receivable__c();
        objreceivable1.Type__c = 'Bonus';
        objreceivable1.Amount__c =2000;
        objreceivable1.Payback_Funded__c = 'Funded';
        objreceivable1.Due_From_Account__c = objAccount.Id;
        controller.objOpp = objOppo;
        controller.receivableList.add(objreceivable1);
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.next();
       
        controller.addRowPayable();
       // Integer int3 =  controller.payableList.size();  
       // System.assertEquals(int3,controller.payableList.size());
        Payable__c objPayable1 = new Payable__c();
        objPayable1.Type__c='Bonus';
        objPayable1.Amount_Due__c = 100;
        objPayable1.Account__c = objAccount.Id;
        objPayable1.Payback_Funded__c = 'Funded';
        controller.payable = objPayable;
        controller.payableList.add(objPayable1);
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.next();
      
        
        controller.rowNum = 2;
        PageReference pageRef = Page.CreateContract;
        pageRef.getParameters().put('index','2');
        ApexPages.currentPage().getParameters().put('index','2');
        controller.deleteOffer();
        controller.deletPayables();
        controller.deletReceivables();
        controller.deletSyndications();
        System.currentPagereference().getParameters().put('Id',objOppo.Id);
        System.currentPagereference().getParameters().put('offerId',objoffer2.Id);
        
        controller.selectedOffer();
        
       
  
        Test.stopTest();
       
    }   
    
    static testMethod void testStatisticsDataForOpportunityForSubmissionAndOffer() {
    
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Payback',recordTypeID=[select id from recordtype where sobjectType='Account' and DeveloperName='Merchant'].id);
        insert objAccount;    
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo1;
        
    
        Test.startTest();
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
       
        CreateContractController controller=new CreateContractController();
        
        Submission__c objSubmission1 = new Submission__c(Opportunity__c=objOppo1.Id, Status__c='UW');
        insert objSubmission1;
        Offer__c objoffer3 = new Offer__c(Opportunity__c=objOppo1.Id, Submission__c=objSubmission1.Id,Amount__c = 10);
        insert objoffer3;
       
        controller.OppId = ''+objOppo1.Id;
        controller.objOpp = objOppo1;
        controller.populateData();
        System.currentPagereference().getParameters().put('Id',objOppo1.Id);
        System.currentPagereference().getParameters().put('offerId','');
        controller.selectedOffer();
        
        controller.wizardType = 'Preview';
        controller.changeWizard();
        
        controller.objOpp.Deal_Entry_Wizard_Check__c = false;
        controller.populateData();
        Test.stopTest();
       
    
    
    
    }
    
    static testMethod void testStatisticsDataForOpportunityAddSyndicate() {
    
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Funded',recordTypeID=[select id from recordtype where sobjectType='Account' and DeveloperName='Merchant'].id);
        insert objAccount;    
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo1;
        
       Test.startTest();
        
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
       
        CreateContractController controller=new CreateContractController();
        
        controller.addRowSyndication();
        Syndication__c objSynd1 = new Syndication__c();
        objSynd1.Syndication_Amt__c = 1000;
        objSynd1.Servicing_Fee__c = 2500;
        objSynd1.Syndicated_By__c = objAccount.Id;
        controller.syndicationList.add(objSynd1);
        controller.wizardType = CreateContractController.SYNDICATION_SCREEN;
        controller.next();
        controller.previous();
        controller.wizardType = CreateContractController.SYNDICATION_SCREEN;
        controller.previous();
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.previous();
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.previous();
        controller.wizardType = CreateContractController.DEAL_SCREEN;
        controller.previous();
    
    
       Test.stopTest();
    }
    
    
     static testMethod void testStatisticsDataForOpportunityForRecevaibleMethod() {
      
      
       Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Commission Revenue',recordTypeID=[select id from recordtype where sobjectType='Account' and DeveloperName='Merchant'].id);
        insert objAccount;   
      Opportunity objOppo = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo; 
      
      Test.startTest();
     
       Apexpages.Pagereference P = Page.CreateContract;
       test.setCurrentPage(p);
       
        CreateContractController controller=new CreateContractController();
        
     
        Receivable__c objreceivable = new Receivable__c(Type__c = 'Bonus',Amount__c =2000,Payback_Funded__c = 'Funded',Due_From_Account__c = objAccount.Id);
       
        controller.objOpp = objOppo;
        controller.receivable = objreceivable;
        controller.receivableList.add(objreceivable);
        controller.onChangeRecPaybackFunded();
        controller.onChangeRecPercentage();
        controller.quickSaveReceivable();
        controller.wizardType = CreateContractController.SYNDICATION_SCREEN;
        controller.changeWizard();
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.changeWizard();
        controller.wizardType = CreateContractController.RECEIVABLE_SCREEN;
        controller.changeWizard();
        controller.wizardType = CreateContractController.DEAL_SCREEN;
        controller.changeWizard();
        controller.wizardType = CreateContractController.OFFER_SCREEN;
        controller.changeWizard();
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.changeWizard();
     
      Test.stopTest();
     }
     
     
     static testMethod void testStatisticsDataForOpportunityForPayableOriginationFee() {
     
     
      Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Commission Revenue',recordTypeID=[select id from recordtype where sobjectType='Account' and DeveloperName='Merchant'].id);
      insert objAccount; 
        
     Test.startTest();
     
      Apexpages.Pagereference P = Page.CreateContract;
       test.setCurrentPage(p);
       
        CreateContractController controller=new CreateContractController();
        
       //Adding the Origin Fee logic
         controller.receivableList.add(new Receivable__c(Type__c = 'Origination Fee',Amount__c =2000,Due_From_Account__c = objAccount.Id));
         
        //FOR PAYABLE FUNDED and type bonus WITHOUT id. 
        Payable__c objPayableOrgFee = new Payable__c(Type__c='Origination Fee',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Origination Fee',Wizard_Check__c=false,Percentage__c = 10);
        controller.payable = objPayableOrgFee ;
        controller.payableList.add(objPayableOrgFee );
        controller.onChangePayPercentage();
        
     
     Test.stopTest();
     
     }
     
     static testMethod void testStatisticsDataForOpportunityForPayableWithID() {
        
      Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy',User__c = UserInfo.getUserId(),Payback_Funded__c = 'Commission Revenue',recordTypeID=[select id from recordtype where sobjectType='Account' and DeveloperName='Merchant'].id);
      insert objAccount; 
        
         Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id,Term_Months__c = 1, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50,Payback_Amount__c = 100);
        insert objOppo1;
         
        Test.startTest();
        Apexpages.Pagereference P = Page.CreateContract;
       test.setCurrentPage(p);
       
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);
       
        CreateContractController controller=new CreateContractController();
        controller.OppId = ''+objOppo1.Id;
        controller.objOpp = objOppo1;
       
       
        Payable__c objPayableWithID = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
        insert objPayableWithID;
        ApexPages.currentPage().getParameters().put('payId',objPayableWithID.id);
        controller.payable = objPayableWithID ;
        controller.payableList.add(objPayableWithID);
        controller.onChangePayPaybackFunded();
        controller.calculateNetCommissionRevenue(objOppo1);
        controller.calculateNetOriginationFees(objOppo1);
        controller.onChangePayPercentage();
        controller.quickSavePayable();
        Test.stopTest();
     
     }
     /*
      static testMethod void testOnChangeDueToAccountPayable() 
      {
      
      
       Account objAccount = new Account(Name='TestAcc', Type='External', Industry='Energy');
       insert objAccount; 
      
       Payable__c objPayableWithID = new Payable__c(Type__c='Bonus',Amount_Due__c = 100,Account__c = objAccount.Id,Payback_Funded__c = 'Funded',Wizard_Check__c=false,Percentage__c = 10);
       //insert objPayableWithID;
       CreateContractController controller=new CreateContractController();
       controller.payablelist.add(objPayableWithID);
       Test.startTest();
       
       
       
       controller.onChangeDueToAccountPayable();
       Test.stopTest();
       
      
      }
     
     */
     static testMethod void testTreateNullAsZeroMethod(){
         Decimal val;
         CreateContractController controller=new CreateContractController();

         controller.treateNullAsZero(val);
         
     }
     
         
}