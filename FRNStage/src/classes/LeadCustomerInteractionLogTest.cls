@isTest
private class LeadCustomerInteractionLogTest 
{
 
    Static testMethod void LeadCustomerInteractionLog_Test()
    {
        Lead ld =new Lead();
        ld.LastName = 'test';
        ld.Company = 'test1';
        ld.Status = 'Contacted';
        insert ld;
        ApexPages.currentPage().getParameters().put('id',ld.id);
        
        ApexPages.StandardController asd = new ApexPages.StandardController(ld);
        LeadCustomerInteractionLog lcu = new LeadCustomerInteractionLog(asd);
        lcu.updateWhoWhatId();
        //lcu.initializeTask();
        lcu.setCallAttachedData();
        lcu.setCallEndData();
        lcu.save();
        lcu.ANI='test1';
        lcu.CallType='test2';
        lcu.statusMessage='test3';
        
    }   
}