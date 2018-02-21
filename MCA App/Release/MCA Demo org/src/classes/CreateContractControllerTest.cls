public with sharing class CreateContractControllerTest {
    static testMethod void testStatisticsDataForOpportunity() {
        //create Account
        Account objAccount = new Account(Name='TestAcc', Type='Analyst', Industry='Energy');
        insert objAccount; 
        
        //Create Opportunity
        Opportunity objOppo = new Opportunity(Name='TestOpp', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo; 
        Opportunity opp = [select OwnerId from Opportunity where id=: objOppo.Id];
        system.debug('###objOppo.OwnerId'+opp.OwnerId);
        objAccount.User__c = opp.OwnerId;
        update objAccount;
        system.debug('###objAccount'+objAccount);
        //Create Programme 
        Program__c objProgramme = new Program__c(Name='Test Programme');
        insert objProgramme;
        
        //create submission
        Submission__c objSubmission = new Submission__c(Opportunity__c=objOppo.Id, Status__c='UW',Program__c=objProgramme.Id);
        insert objSubmission;
        
        // Create offer related to Opportunity
        Offer__c objoffer1 = new Offer__c(Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id);
        insert objoffer1;
        
        Offer__c objoffer2 = new Offer__c( Opportunity__c=objOppo.Id, Submission__c=objSubmission.Id);
        insert objoffer2;
        
        //create Receivables related to Opportunity
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id, Opportunity__c=objOppo.Id);
        insert objInvoice;
        
        //create Payable related to Opportunity
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00, Opportunity__c=objOppo.Id );
        insert objBill;
        
       
        Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo1;
        
         // Create Contract
        Contract contract = new Contract(AccountId=objAccount.Id,Status='Draft',ContractTerm = 2, Opportunity__c = objOppo1.Id);
        insert contract;
        
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
        System.assertequals(controller.wizardType,CreateContractController.OFFER_SCREEN);
        controller.wizardType='Offer';
        controller.next();
        System.assertequals(controller.wizardType,CreateContractController.DEAL_SCREEN);
        controller.next();
         
        Receivable__c objreceivable = new Receivable__c();
        objreceivable.Type__c = 'Bonus';
        objreceivable.Amount__c =2000;
        objreceivable.Payback_Funded__c = 'Funded';
        objreceivable.Due_From_Account__c = objAccount.Id;
        controller.objOpp = objOppo;
        controller.receivable = objreceivable;
        controller.receivableList.add(objreceivable);
        controller.quickSaveReceivable();
        controller.onChangeRecPercentage();
        controller.onChangeRecPaybackFunded();
        system.debug(controller.receivableList);
        System.assertequals(1,controller.receivableList.size());
         
        Payable__c objPayable = new Payable__c();
        objPayable.Type__c='Bonus';
        objPayable.Amount_Due__c = 100;
        objPayable.Account__c = objAccount.Id;
        objPayable.Payback_Funded__c = 'Funded';
        controller.payable = objPayable;
        controller.payableList.add(objPayable);
        controller.quickSavePayable();
        controller.onChangePayPercentage();
        controller.onChangePayPaybackFunded();
        System.assertequals(1,controller.payableList.size());
        
        Syndication__c objSynd = new Syndication__c();
        objSynd.Syndication_Amt__c = 1000;
        objSynd.Servicing_Fee__c = 2500;
        objSynd.Syndicated_By__c = objAccount.Id;
        controller.syndication = objSynd;
        controller.syndicationList.add(objSynd);
        controller.quickSaveSyndication();
        System.assertequals(1,controller.syndicationList.size());
        
        Contract objContract = new Contract();
        controller.OppId = ''+objOppo.Id;
        controller.objOpp = objOppo;
        controller.AccountId = ''+ objAccount.Id;
        controller.save();
        
        controller.changeWizard();
        PageReference cancelPageRef = controller.cancel();
        System.assertEquals(cancelPageRef.getUrl(), '/'+objOppo.Id);
        
        controller.addRowOffer();
        System.assertEquals(3,controller.offerWrapperList.size());
        
        controller.addRowReceivable();
        System.assertEquals(2,controller.receivableList.size());
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
        System.assertEquals(2,controller.payableList.size());
        Payable__c objPayable1 = new Payable__c();
        objPayable1.Type__c='Bonus';
        objPayable1.Amount_Due__c = 100;
        objPayable1.Account__c = objAccount.Id;
        objPayable1.Payback_Funded__c = 'Funded';
        controller.payable = objPayable;
        controller.payableList.add(objPayable1);
        controller.wizardType = CreateContractController.PAYABLE_SCREEN;
        controller.next();
         
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
        controller.prevOfferid = objoffer2.Id;
        controller.selectedOffer();
        
        /*Opportunity objOppo1 = new Opportunity(Name='TestOpp', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert objOppo1;
        
         Apexpages.Pagereference P = Page.CreateContract;
         test.setCurrentPage(p);
        
    
        p.getParameters().put('Id',objOppo1.Id);
        p.getParameters().put('stage',objOppo1.StageName);
        p.getParameters().put('accId',objOppo1.AccountId);*/
       
        Submission__c objSubmission1 = new Submission__c(Opportunity__c=objOppo1.Id, Status__c='UW');
        insert objSubmission1;
        Offer__c objoffer3 = new Offer__c(Opportunity__c=objOppo1.Id, Submission__c=objSubmission1.Id);
        insert objoffer3;
       
        controller.OppId = ''+objOppo1.Id;
        controller.objOpp = objOppo1;
        controller.populateData();
        System.currentPagereference().getParameters().put('Id',objOppo.Id);
        System.currentPagereference().getParameters().put('offerId','');
        controller.selectedOffer();
        
        controller.wizardType = 'Preview';
        controller.changeWizard();
        Test.stopTest();
        
    }
}