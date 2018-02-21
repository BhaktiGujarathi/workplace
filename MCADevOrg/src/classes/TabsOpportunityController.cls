public with sharing class TabsOpportunityController {

  public TabsOpportunityWrapper wrapper {get; set;}
  
  public TabsOpportunityController(Apexpages.Standardcontroller std) {
  
    Opportunity opportunity = TabsOpportunityControllerUtils.getOpportunity(std.getId());
    wrapper = new TabsOpportunityWrapper(opportunity);  
  }
  
  public TabsOpportunityListWrapper getSubmissions() {
    return wrapper.submissions;
  }

}