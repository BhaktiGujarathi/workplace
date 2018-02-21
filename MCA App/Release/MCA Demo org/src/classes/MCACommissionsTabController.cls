public with sharing class MCACommissionsTabController {
  public Payable__c[] payables;
  public Receivable__c[] receivables;

  public Payable__c[] newPayables {get; set;}
  public Receivable__c[] newReceivables {get; set;}

  public ContainerPayable[] containerPayables;
  public ContainerReceivable[] containerReceivables;

  public Boolean editAll {get;set;}

  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}
  public boolean recAccesss {get;set;}
  public boolean payAccesss {get;set;}
  private Id opportunityId;

  public Decimal payableAmount {get; set;}
  public Decimal receivableAmount {get; set;}

  public Decimal payableAmountDue {get; set;}
  public Decimal receivableAmountDue {get; set;}

  public MCACommissionsTabController() {



    opportunityId = Apexpages.currentPage().getParameters().get('id');
    recAccesss = Schema.sObjectType.Receivable__c.isAccessible();
    payAccesss = Schema.sObjectType.Payable__c.isAccessible();
    system.debug('###recAccesss'+recAccesss);
    system.debug('###payAccesss'+payAccesss);
    refresh();
  }
  
  public String selectPayableStatus{get;set;}
    
    public list<SelectOption> lstselectPayableStatus= new list<SelectOption>();
    
    public list<SelectOption> getselectPayableStatusOption()
    {
        lstselectPayableStatus = new list<SelectOption>();
        //lstSelectOptionAppliedAmmountOpp.add(new SelectOption ('--None--','--None--')); 
        
        // Use DescribeFieldResult object to retrieve status field
        Schema.DescribeFieldResult statusFieldDescription = Payable__c.Status__c.getDescribe();
        
        // For each picklist value, create a new select option
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())    
        {
            lstselectPayableStatus.add(new SelectOption (pickListEntry.getValue(),pickListEntry.getLabel())); 
        }
        return lstselectPayableStatus;
    }
    
    public String selectReceivableStatus{get;set;}
   
    public list<SelectOption> lstselectReceivableStatus= new list<SelectOption>();
   
    public list<SelectOption> getselectReceivableStatusOption()
    {
        lstselectReceivableStatus= new list<SelectOption>();
        //lstSelectOptionAppliedAmmountOpp.add(new SelectOption ('--None--','--None--')); 
        
        // Use DescribeFieldResult object to retrieve status field
        Schema.DescribeFieldResult statusFieldDescription = Receivable__c.Status__c.getDescribe();
        
        // For each picklist value, create a new select option
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())    
        {
            lstselectReceivableStatus.add(new SelectOption (pickListEntry.getValue(),pickListEntry.getLabel())); 
        }
        return lstselectReceivableStatus;
    }


  public ContainerPayable[] getPayables() {

    payableAmount = 0;
    payableAmountDue = 0;

    payables = new Payable__c[] {};
    containerPayables = new ContainerPayable[] {};

    payables.addAll(newPayables);

    for (Payable__c py :[SELECT
                                      Id,
                                      Payback_Funded__c,
                                      Bill_Amount_Due__c,
                                      Percentage__c,
                                      Due_Date__c,
                                      Amount_Due__c,
                                      Account__c,
                                      Type__c,
                                      Status__c,
                                      Memo__c
                                    FROM Payable__c
                                    WHERE Opportunity__c = :opportunityId]) {

          payableAmount += (py.Amount_Due__c == null) ? 0 : py.Amount_Due__c;
          payableAmountDue += (py.Bill_Amount_Due__c == null) ? 0 : py.Bill_Amount_Due__c;
          payables.add(py);
    }

    for (Integer i = 0; i < payables.size(); i++) {
      containerPayables.add(new ContainerPayable(payables[i], i));
    }
    return containerPayables;

    //return payables;
  }

  public void save(){}
  public ContainerReceivable[] getReceivables() {

    receivableAmount = 0;
    receivableAmountDue = 0;

    receivables = new Receivable__c[] {};
    containerReceivables = new ContainerReceivable[] {};

    receivables.addAll(newReceivables);

    for (Receivable__c rc :[SELECT
                                              Id,
                                              Payback_Funded__c,
                                              Amount__c,
                                              Percentage__c,
                                              Due_Date__c,
                                              Amount_Due__c,
                                              Due_From_Account__c,
                                              Type__c,
                                              Status__c,
                                              Memo__c
                                          FROM Receivable__c
                                          WHERE Opportunity__c = :opportunityId]) {

          receivableAmount += rc.Amount__c != null ? rc.Amount__c : 0;
          receivableAmountDue += rc.Amount_Due__c != null ? rc.Amount_Due__c : 0;
      receivables.add(rc);
    }

    for (Integer i = 0; i < receivables.size(); i++) {
      containerReceivables.add(new ContainerReceivable(receivables[i], i));
    }
    return containerReceivables;

    //return receivables;
  }

  public void refresh() {

    recordToDelete = null;
    editAll = false;

      payableAmount = 0;
      receivableAmount = 0;

      payableAmountDue = 0;
      receivableAmountDue = 0;

    newReceivables = new Receivable__c[] {};
    newPayables = new Payable__c[] {};
  }

  public PageReference saveAllCommissions() {

    /*
    Payable__c[] recordsToUpdateOne = new Payable__c[] {};
    Receivable__c[] recordsToUpdateTwo = new Receivable__c[] {};

    for (Payable__c record :payables) {

      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdateOne.add(record);
      }
    }

    for (Receivable__c record :receivables) {

      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdateTwo.add(record);
      }
    }

    upsert recordsToUpdateOne;
    upsert recordsToUpdateTwo;
    */

    upsert payables;
    upsert receivables;


    refresh();

    return null;

  }

  public void editAll() {
    refresh();
    editAll = true;
  }

  public void newPayable() {
    newPayables.add(new Payable__c(Opportunity__c = opportunityId,IsCreatedFromGrid__c = true));
  }

  public void newReceivable() {
    newReceivables.add(new Receivable__c(Opportunity__c = opportunityId,IsCreatedFromGrid__c = true));
  }

  public void deletePayable() {

    if (recordToDelete != null) {
      Payable__c record = [SELECT Id FROM Payable__c WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void deleteReceivable() {

    if (recordToDelete != null) {
      Receivable__c record = [SELECT Id FROM Receivable__c WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void removeReceivable() {

    if (indexToRemove != null) {

      ContainerReceivable c = null;

      for (ContainerReceivable element :containerReceivables) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newReceivables.remove(c.index);
    }

  }

  public void removePayable() {

    if (indexToRemove != null) {

      ContainerPayable c = null;

      for (ContainerPayable element :containerPayables) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newPayables.remove(c.index);
    }

  }

  public class ContainerReceivable {

    public Receivable__c receivable {get;set;}
    public Integer index {get;set;}

    public ContainerReceivable(Receivable__c instance, Integer index) {
      receivable = instance;
      this.index = index;
    }

  }

  public class ContainerPayable {

    public Payable__c payable {get;set;}
    public Integer index {get;set;}

    public ContainerPayable(Payable__c instance, Integer index) {
      payable = instance;
      this.index = index;
    }

  }
  
}