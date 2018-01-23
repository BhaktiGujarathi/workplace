@isTest
private class OpportunitiesCustomerInteractionLogTest 
{
 
    Static testMethod void OpportunitiesCustomerInteractionLog_Test()
    {
        Opportunity opp =new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today();
         insert opp;
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        ApexPages.StandardController asd = new ApexPages.StandardController(opp);
        OpportunitiesCustomerInteractionLog lcu = new OpportunitiesCustomerInteractionLog(asd);
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