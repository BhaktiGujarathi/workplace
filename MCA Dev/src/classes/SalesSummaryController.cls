public with sharing class SalesSummaryController {

    public String parentNameHeading {get;set;}
    public String OpportunityId;
    public String accountId;
    public String isAccountView;

    public SalesSummaryController() {
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        accountId = Apexpages.currentPage().getParameters().get('accId');
        isAccountView = ApexPages.currentPage().getParameters().get('isAccountView');
        if(opportunityId != null && opportunityId != '' && isAccountView == 'false')
        {
            fetchOpportunities(opportunityId);
        }
        else
        {
            fetchAccounts(accountId);
        }
    }

    public void fetchOpportunities(Id oppId) {
        Opportunity opportunity = [SELECT ID, Name FROM Opportunity WHERE Id = :oppId];
        parentNameHeading = opportunity.Name;
    }

    public void fetchAccounts(Id accId) {
        Account account = [SELECT Id, Name FROM Account WHERE Id = :accId];
        parentNameHeading = account.Name;
    }

}