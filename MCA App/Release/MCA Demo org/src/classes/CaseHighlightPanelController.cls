Public without sharing class CaseHighlightPanelController
{
    public List<Case> lstCase{get; set;}
    
    public CaseHighlightPanelController(ApexPages.StandardController controller)
    {}
    public void findCase()
    {
    Id caseId = ApexPages.currentPage().getParameters().get('id');
     lstCase = [Select Id,AccountId,ContactId, Account.Name,Contact.Image_del__c, Contact.Email from Case where Id =: caseId];
    
    system.debug('#####lstCase '+lstCase);
    system.debug('#####caseId '+caseId);
    //return lstCase[0];
    }
}