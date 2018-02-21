@isTest(seeAllData=true)
public with sharing class MCABaseTabControllerTest {
/*
  private static Opportunity objOpportunity = null;
  private static Bank_Account__c  ba = null;  
  private static Credit_Card__c cc = null;
  private static Submission__c s = null;
  private static Offer__c o = null;
  private static Task t = null;
  private static OpportunityContactRole ocr = null;
  private static Loan_Balance__c lb = null;
  private static Syndication__c sy = null;
  private static Stips__c st = null;
  private static Payable__c py = null;  
  private static Receivable__c rc = null; 
  
  static testmethod void coverBasetabcontroller(){
      objOpportunity = new Opportunity(Name='Opp1', CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
    insert objOpportunity;
    
    Id opportunityId = objOpportunity.Id;
    
    Contact contact = new Contact(LastName = 'Test Contact'); 
    insert contact;
    
    Recordtype obRCType=[SELECT Id FROM RecordType WHERE Name = 'Bank'];
    Account account = new Account(Name = 'Test Account', RecordtypeId=obRCType.id);
    insert account;
    
    py = new Payable__c(Opportunity__c = opportunityId);
    insert py;
    
     st = new Stips__c(Opportunity__c = opportunityId);
    insert st;
    
    MCABaseTabController controller= new MCABaseTabController('Stips__c');
    MCABaseTabControllerUtils controllerUtil=new MCABaseTabControllerUtils();
    controller.getRecords();
    controller.refresh();
    controller.editAll();
    controller.saveAll();
    controller.newRecords();
    controller.newRecord();
    //controller.saveAll();
    controller.deleteRecord();
    MCABaseTabControllerUtils.getObjectFields('Bank_Account__c');
    MCABaseTabControllerUtils.getObjectFields('Credit_Card__c');
    MCABaseTabControllerUtils.getObjectFields('Submission__c');
    MCABaseTabControllerUtils.getObjectFields('Offer__c');
    MCABaseTabControllerUtils.getObjectFields('Stips__c');
    MCABaseTabControllerUtils.getObjectFields('Payable__c');
    MCABaseTabControllerUtils.getObjectFields('Receivable__c');
    MCABaseTabControllerUtils.getObjectFields('Syndication__c');
    MCABaseTabControllerUtils.getObjectFields('Loan_Balance__c');
    MCABaseTabControllerUtils.getObjectFields('OpportunityContactRole');
    MCABaseTabControllerUtils.getObjectFields('Task');
    
  }
  
  static testMethod void coverSalesHistoryTabController() {

    setOpportunityParameter();
    MCASalesHistoryTabController controller = new MCASalesHistoryTabController();
    controller.getContainersCards();
    controller.getContainersStatements();
    controller.refresh();
    //controller.saveAll();
    controller.saveAllSales();
    controller.newCredit();
    controller.newStatement();
    controller.getContainersCards();
    controller.getContainersStatements();    
    system.debug(controller.getContainersCards());
    controller.indexToRemove = 0;
    controller.removeCard();
    controller.indexToRemove = 0;
    //controller.removeStatement();
    controller.recordToDelete = cc.Id;
    controller.deleteCredit();
    controller.recordToDelete = ba.id;
    controller.deleteStatement();
    controller.editAll();
  } 
  
  

  static testMethod void coverSubmissionsTabController() {

    setOpportunityParameter();
    MCASubmissionsTabController controller = new MCASubmissionsTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.saveAllSubmissions();
    controller.newSubmission();
    controller.getContainers();
    controller.indexToRemove = 0;
    //controller.removeSubmission();
    controller.recordToDelete = s.Id;
    controller.deleteSubmission();
    controller.editAll();
    controller.newSubmission();
    controller.saveAllSubmissions();
    controller.getContainers();
    controller.submissionIndex =0;
    controller.setSubmissionStatus();
    controller.updateInlineEditedValue();
    controller.checkoldAndNewVal();
  } 

  static testMethod void coverOfferTabController() {

    setOpportunityParameter();
    MCAOffersTabController controller = new MCAOffersTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.newOffer();
    controller.getContainers();
    controller.indexToRemove = 0;
    //controller.removeOffer();
    controller.recordToDelete = o.Id;
    controller.deleteOffer();
    //controller.editAll();
  } 

  static testMethod void coverCommissionsTabController() {

    setOpportunityParameter();
    MCACommissionsTabController controller = new MCACommissionsTabController();
    controller.getPayables();
    controller.getReceivables();
    controller.refresh();
    //controller.saveAll();
    controller.saveAllCommissions();
    controller.newPayable();
    controller.newReceivable();
    controller.getPayables();
    controller.getReceivables();  
    controller.newPayable();
    controller.indexToRemove = 0;    
    //controller.removePayable();
    controller.newReceivable();
    controller.indexToRemove = 0;
    //controller.removeReceivable();
    controller.recordToDelete = py.Id;
    controller.deletePayable();
    controller.recordToDelete = rc.Id;
    controller.deleteReceivable();
    controller.editAll();
    
  } 
  
  static testMethod void coverStipsTabController() {

    setOpportunityParameter();
    MCAStipsTabController controller = new MCAStipsTabController();
    controller.getContainers();
    controller.refresh();
    controller.save();
    controller.saveAllStips();
    controller.newStip();    
    controller.getContainers();
    controller.indexToRemove = 0;
    //controller.removeStip();
    controller.recordToDelete = st.Id;
    controller.deleteStip();
    controller.editAll();
  }           

  static testMethod void coverSyndicationsTabController() {


    setOpportunityParameter();
    MCASyndicationTabController controller = new MCASyndicationTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.saveAllSyndications();
    controller.newSyndication();    
    controller.getContainers();
    controller.indexToRemove = 0;
    //controller.removeSyndication();
    controller.recordToDelete = sy.Id;
    controller.deleteSyndication();
    controller.editAll();
  } 

  static testMethod void coverLoansTabController() {


    setOpportunityParameter();
    MCALoanBalanceTabController controller = new MCALoanBalanceTabController();
    controller.getContainers();
    controller.refresh();
    controller.saveAllLoans();
    controller.newLoanBalance();
    controller.getContainers();
    controller.indexToRemove = 0;
    //controller.removeLoanBalance();
    controller.recordToDelete = lb.Id;
    controller.deleteLoanBalance();
    controller.editAll();
    controller.newLoanBalance();
    controller.isFirst=false;
    controller.getContainers();
    controller.checkoldAndNewVal();
    controller.updateInlineEditedValue();
  }

  static testMethod void coverContactsTabController() {
    setOpportunityParameter();
    MCAContactRolesTabController controller = new MCAContactRolesTabController();
    controller.getContainers();
    controller.refresh();
    controller.getContainers();
    controller.contactindex = 0;
    controller.contactFetch();
    controller.saveAll();
    controller.newContactRole();
    controller.getContainers();
    controller.indexToRemove = 0;
    //controller.removeContactRole();
    controller.recordToDelete = ocr.Id;
    controller.deleteContactRole();
    controller.editAll();
    controller.getContainers();
    controller.updateInlineEditedValue();
    //controller.newContactRole();
    controller.saveAll(); 
    //system.debug('>>>mapIDANDOppContactRole'+controller.mapIDANDOppContactRole);
    
  } 

  static testMethod void coverTasksTabController() {

    setOpportunityParameter();
    MCATasksTabController controller = new MCATasksTabController();
    controller.getContainers();
    controller.refresh();
    controller.saveAllTasks();
    controller.getContainers();
    controller.indexToRemove = 0;
    controller.taskList();
    controller.editAll();
    controller.save();
    controller.getContainers();
    controller.editAll = false;
    controller.isUpdated = true;
    controller.newTask();
    controller.getContainers();
    controller.saveAllTasks();
    controller.updateInlineEditedValue();
    controller.checkoldAndNewVal();
    controller.deleteTask();
  }
 
  private static void setOpportunityParameter() {
    
    createObjects();
    Apexpages.currentPage().getParameters().put('id', objOpportunity.Id);
    
  }

  private static void createObjects() {
  
    objOpportunity = new Opportunity(Name='Opp1', CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
    insert objOpportunity;
    
    Id opportunityId = objOpportunity.Id;
    
    // query to get id
    Contact contact = new Contact(LastName = 'Test Contact'); 
    insert contact;
    
    Recordtype obRCType=[SELECT Id FROM RecordType WHERE Name = 'Bank'];
    
    Account account = new Account(Name = 'Test Account',RecordtypeId=obRCType.id);
    insert account;
    
    ba = new Bank_Account__c(Opportunity__c = opportunityId);
    insert ba;
    
    cc = new Credit_Card__c(Opportunity__c = opportunityId);
    insert cc;
    
    s = new Submission__c(Opportunity__c = opportunityId, Status__c = 'Declined');
    insert s;
    
    s = new Submission__c(Opportunity__c = opportunityId,  Status__c = 'Approved');
    insert s;
    
    s = new Submission__c(Opportunity__c = opportunityId);
    insert s;
    
    o = new Offer__c(Opportunity__c = opportunityId, Submission__c = s.Id);
    insert o;
    
    t = new Task(WhatId = opportunityId, Status= 'Not Started', Priority = 'Normal');
    //insert t;
    
    ocr = new OpportunityContactRole(OpportunityId = opportunityId, ContactId = contact.Id);
    insert ocr;
    
    lb = new Loan_Balance__c(Opportunity__c = opportunityId, Funder__c = account.Id);
    insert lb;
    
    sy = new Syndication__c(Opportunity__c = opportunityId);
    insert sy;
    
    st = new Stips__c(Opportunity__c = opportunityId);
    insert st;
    
    py = new Payable__c(Opportunity__c = opportunityId);
    insert py;
    
    rc = new Receivable__c(Opportunity__c = opportunityId);
    insert rc;
    
  }*/

}