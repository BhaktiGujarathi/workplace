Public without sharing class ContactHighlightPanelController
{
    public List<Contact> lstContact{get; set;}
    
    public ContactHighlightPanelController(ApexPages.StandardController controller)
    {}
    public void findContact()
    {
    Id contactId = ApexPages.currentPage().getParameters().get('id');
     lstContact = [Select Id,AccountId,Account.Name,Image_del__c,Email from Contact where Id =: contactId];
    
   system.debug('#####lstCase '+lstContact );
   system.debug('#####caseId '+contactId );
    //return lstCase[0];
    }
}