@isTest(seeAllData=true)
public with sharing class MCABaseTabControllerTest {

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
  
  static testMethod void coverSalesHistoryTabController() {

    setOpportunityParameter();
    MCASalesHistoryTabController controller = new MCASalesHistoryTabController();
    controller.getContainersCards();
    controller.getContainersStatements();
    controller.refresh();
    //controller.saveAll();
    controller.newCredit();
    controller.newStatement();
    controller.getContainersCards();
    controller.getContainersStatements();    
    system.debug(controller.getContainersCards());
    controller.indexToRemove = 0;
    controller.removeCard();
    controller.indexToRemove = 0;
    controller.removeStatement();
    controller.recordToDelete = cc.Id;
    controller.deleteCredit();
    controller.recordToDelete = ba.id;
    controller.deleteStatement();
    controller.editAll();
    
    MCABaseTabController controller1 = new MCABaseTabController('McaApp__Payable__c');
    controller1.objectName = 'McaApp__Payable__c';
    controller1.refresh();
    controller1.editAll();
    controller1.deleteRecord();
    controller1.getRecords();
    controller1.newRecord();
    controller1.newRecord();
    controller1.objectName = 'Bank_Account__c';
    MCABaseTabControllerUtils.getQuery('Bank_Account__c');
    controller1.objectName = 'Credit_Card__c';
    MCABaseTabControllerUtils.getQuery('Credit_Card__c');
    controller1.objectName = 'Submission__c';
    MCABaseTabControllerUtils.getQuery('Submission__c');
    controller1.objectName = 'Offer__c';
    MCABaseTabControllerUtils.getQuery('Offer__c');
    controller1.objectName = 'Stips__c';
    MCABaseTabControllerUtils.getQuery('Stips__c');
    controller1.objectName = 'Payable__c';
    MCABaseTabControllerUtils.getQuery('Payable__c');
    controller1.objectName = 'Receivable__c';
    MCABaseTabControllerUtils.getQuery('Receivable__c');
    controller1.objectName = 'Syndication__c';
    MCABaseTabControllerUtils.getQuery('Syndication__c');
    controller1.objectName = 'Loan_Balance__c';
    MCABaseTabControllerUtils.getQuery('Loan_Balance__c');
    controller1.objectName = 'OpportunityContactRole';
    MCABaseTabControllerUtils.getQuery('OpportunityContactRole');
    controller1.objectName = 'Task';
    MCABaseTabControllerUtils.getQuery('Task');
    controller1.saveAll();
  } 
  
  static testMethod void coverSubmissionsTabController() {

    setOpportunityParameter();
    MCASubmissionsTabController controller = new MCASubmissionsTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.newSubmission();
    controller.getContainers();
    controller.indexToRemove = 0;
    controller.removeSubmission();
    controller.recordToDelete = s.Id;
    controller.deleteSubmission();
    controller.editAll();
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
    controller.removeOffer();
    controller.recordToDelete = o.Id;
    controller.deleteOffer();
    controller.editAll();
  } 
  
  static testMethod void coverCommissionsTabController() {

    setOpportunityParameter();
    MCACommissionsTabController controller = new MCACommissionsTabController();
    controller.getPayables();
    controller.getReceivables();
    controller.refresh();
    //controller.saveAll();
    controller.newPayable();
    controller.newReceivable();
    controller.getPayables();
    controller.getReceivables();    
    controller.indexToRemove = 0;
    controller.removePayable();
    controller.indexToRemove = 0;
    controller.removeReceivable();
    
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
    //controller.saveAll();
    controller.newStip();    
    controller.getContainers();
    controller.indexToRemove = 0;
    controller.removeStip();
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
    controller.newSyndication();    
    controller.getContainers();
    controller.indexToRemove = 0;
    controller.removeSyndication();
    controller.recordToDelete = sy.Id;
    controller.deleteSyndication();
    controller.editAll();
  } 
  
  static testMethod void coverLoansTabController() {


    setOpportunityParameter();
    MCALoanBalanceTabController controller = new MCALoanBalanceTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.newLoanBalance();   
    controller.getContainers();
    controller.indexToRemove = 0;
    controller.removeLoanBalance();
    controller.recordToDelete = lb.Id;
    controller.deleteLoanBalance();
    controller.editAll();  
  }     
  
  static testMethod void coverContactsTabController() {

    setOpportunityParameter();
    MCAContactRolesTabController controller = new MCAContactRolesTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.newContactRole();
    controller.getContainers();
    controller.indexToRemove = 0;
    controller.removeContactRole();
    controller.recordToDelete = ocr.Id;
    controller.deleteContactRole();
    controller.editAll();
  } 
  
  static testMethod void coverTasksTabController() {

    setOpportunityParameter();
    MCATasksTabController controller = new MCATasksTabController();
    controller.getContainers();
    controller.refresh();
    //controller.saveAll();
    controller.newTask();
    controller.getContainers();    
    controller.indexToRemove = 0;
    controller.removeTask();
    controller.editAll();
  }     

  
  private static void setOpportunityParameter() {
    
    createObjects();
    Apexpages.currentPage().getParameters().put('id', objOpportunity.Id);
    
  }

  private static void createObjects() {
  
    objOpportunity = new Opportunity(Name='Opp1', CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
    insert objOpportunity;
    
    Id opportunityId = objOpportunity.Id;
    
    Contact contact = new Contact(LastName = 'Test Contact'); 
    insert contact;
    
    string recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bank').getRecordTypeId();
    
    Account account = new Account(Name = 'Test Account',RecordTypeId = recordTypeId);
    //account.RecordTypeId = recordTypeId;
    insert account;
    
    ba = new Bank_Account__c(Opportunity__c = opportunityId);
    insert ba;
    
    cc = new Credit_Card__c(Opportunity__c = opportunityId);
    insert cc;
    
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
    
  }


}