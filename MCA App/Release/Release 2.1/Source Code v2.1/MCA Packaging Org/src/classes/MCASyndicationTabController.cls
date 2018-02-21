public with sharing class MCASyndicationTabController {

  public Syndication__c[] syndications;
  public Container[] containers;

  public Syndication__c[] newSyndications {get; set;}

  public Boolean editAll {get;set;}

  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}

  private Id opportunityId;

  public Decimal amount {get;set;}
  public Decimal servicingFee {get;set;}
  public Decimal commissionFee {get;set;}

  public MCASyndicationTabController() {

    opportunityId = Apexpages.currentPage().getParameters().get('id');

    refresh();
  }

  public Container[] getContainers() {

    amount = 0;
    commissionFee = 0;
    servicingFee = 0;

    syndications = new Syndication__c[] {};
    containers = new Container[] {};

    syndications.addAll(newSyndications);

    for (Syndication__c sy :[SELECT
                                            Id,
                                            Syndication_Amt__c,
                                            Servicing_Fee__c,
                                            Commission_Fee__c,
                                            Disbursment_Schedule__c,
                                            Syndicated_By__c,
                                            Profit_Amount__c,
                                            ROR_per__c,
                                            Syndication_Percentage__c,
                                            Memo__c
                                        FROM Syndication__c
                                        WHERE Opportunity__c = :opportunityId]) {

      syndications.add(sy);

      amount += sy.Syndication_Amt__c != null ? sy.Syndication_Amt__c : 0;
      commissionFee += sy.Commission_Fee__c != null ? sy.Commission_Fee__c : 0;
      servicingFee += sy.Servicing_Fee__c != null ? sy.Servicing_Fee__c : 0;
    }

    for (Integer i = 0; i < syndications.size(); i++) {
      containers.add(new Container(syndications[i], i));
    }

    return containers;

    //return syndications;
  }

  public void newSyndication() {

    newSyndications.add(new Syndication__c(Opportunity__c = opportunityId));
  }

  public void save(){}
  public void refresh() {

    amount = 0;
    commissionFee = 0;
    servicingFee = 0;

    recordToDelete = null;
    editAll = false;

    newSyndications = new Syndication__c[] {};
  }

  public void saveAllSyndications() {

    /*
    Syndication__c[] recordsToUpdate = new Syndication__c[] {};

    for (Syndication__c record :syndications) {

      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdate.add(record);
      }
    }

    */

    upsert syndications;

    refresh();
  }

  public void editAll() {

    refresh();
    editAll = true;
  }

  public void deleteSyndication() {

    if (recordToDelete != null) {
      Syndication__c record = [SELECT Id FROM Syndication__c WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void removeSyndication() {

    if (indexToRemove != null) {

      Container c = null;

      for (Container element :containers) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newSyndications.remove(c.index);
    }

  }

  public class Container {

    public Syndication__c syndication {get;set;}
    public Integer index {get;set;}

    public Container(Syndication__c instance, Integer index) {
      syndication = instance;
      this.index = index;
    }

  }

}