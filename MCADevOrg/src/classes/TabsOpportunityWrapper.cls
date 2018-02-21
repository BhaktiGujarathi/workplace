public with sharing class TabsOpportunityWrapper {

  public TabsOpportunityListWrapper submissions;

  public TabsOpportunityWrapper(Opportunity opportunity) {
  
    submissions = new TabsOpportunityListWrapper(opportunity.Submissions__r);
  }

}