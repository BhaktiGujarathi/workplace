@isTest
private class CallLoggingTest {
	/**
	*Test method for Todays completed task and previous NotCompleted taask
	*/
    static testMethod void testCallLoggingNotCompletedTsk() {
    	Test.StartTest();
    	//Account 
        Account objAccount = CallLoggingTestDataFactory.getAccountRecord();
        objAccount.User__c = UserInfo.getUserId();
        System.debug('>>>objISOAccount :'+objAccount);
        insert objAccount;
        
        //Opportunity
        List<Opportunity> listOpportunity = CallLoggingTestDataFactory.getOpportunityRecordsList(3,objAccount.Id,UserInfo.getUserId());
        System.debug('>>>listOpportunity :'+listOpportunity);
        insert listOpportunity;
        
        //Task : NULL
        List<Task> listTask = new List<Task>();
        //Task : completed and Not-Completed
        listTask = CallLoggingTestDataFactory.getTaskRecordsNotCompleted(3,listOpportunity);
        System.debug('>>>listTask :'+listTask);
        insert listTask;
        Test.StopTest();
    }
    /**
	*Test Method For Todays In-Progress task and Previous NotCompleted Task
	*/
    static testMethod void testCallLoggingPendingTask() {
    	Test.StartTest();
        //Account 
        Account objAccount = CallLoggingTestDataFactory.getAccountRecord();
        objAccount.User__c = UserInfo.getUserId();
        System.debug('>>>objISOAccount :'+objAccount);
        insert objAccount;
        
        //Opportunity
        List<Opportunity> listOpportunity = CallLoggingTestDataFactory.getOpportunityRecordsList(200,objAccount.Id,UserInfo.getUserId());
        System.debug('>>>listOpportunity :'+listOpportunity);
        insert listOpportunity;
        
        //Task : NULL
        List<Task> listTask = new List<Task>();
        //Task : completed and Not-Completed
        listTask = CallLoggingTestDataFactory.getTaskRecordsPending(200,listOpportunity);
        System.debug('>>>listTask :'+listTask);
        insert listTask;
        Test.StopTest();
    }
    /**
	*Test Method For Todays In-Progress task and Previous NotCompleted Task
	*/
    static testMethod void testCallLoggingDeferredTask() {
    	Test.StartTest();
        //Account 
        Account objAccount = CallLoggingTestDataFactory.getAccountRecord();
        objAccount.User__c = UserInfo.getUserId();
        System.debug('>>>objISOAccount :'+objAccount);
        insert objAccount;
        
        //Opportunity
        List<Opportunity> listOpportunity = CallLoggingTestDataFactory.getOpportunityRecordsList(200,objAccount.Id,UserInfo.getUserId());
        System.debug('>>>listOpportunity :'+listOpportunity);
        insert listOpportunity;
        
        //Task : NULL
        List<Task> listTask = new List<Task>();
        //Task : completed and Not-Completed
        listTask = CallLoggingTestDataFactory.getTaskRecordsDeferred(200,listOpportunity);
        System.debug('>>>listTask :'+listTask);
        insert listTask;
        Test.StopTest();
    }
}