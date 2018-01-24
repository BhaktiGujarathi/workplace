public with sharing class TabsOpportunityListWrapper {

  public sObject[] records {get; set;}

  public TabsOpportunityListWrapper(sObject[] records) {
    this.records = records;
  }

}