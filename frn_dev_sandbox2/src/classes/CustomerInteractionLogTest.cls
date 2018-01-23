@isTest
private class CustomerInteractionLogTest 
{
 
    Static testMethod void CustomerInteractionLog_Test()
    {
        case cs =new case();
        cs.Status = 'Escalated';
        cs.Origin = 'Phone';
         insert cs;
        ApexPages.currentPage().getParameters().put('id',cs.id);
        
        ApexPages.StandardController asd = new ApexPages.StandardController(cs);
        CustomerInteractionLog lcu = new CustomerInteractionLog(asd);
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