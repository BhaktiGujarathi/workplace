@isTest
private class TaskHandlerTest {

    static testMethod void TestUpdateChatterFeedPost() {
        Test.startTest();
        Opportunity OppRecord1 = new Opportunity(Name = 'Rocky1', CloseDate = system.today(), 
                                                 StageName = 'Application Sent', //ForecastCategoryName = 'Pipeline',
                                                 Amount = 1000);
        insert OppRecord1;
        
        list<Task> lstTempTasksSubjectEmail = new list<Task>();
        for(Integer index = 1; index <= 100; index++){
            lstTempTasksSubjectEmail.add(new Task(WhatId = OppRecord1.Id,
                                     Status = 'Not Started', 
                                     Priority = 'High',
                                     Subject = 'Pending Items for'));
         
        }       
        insert lstTempTasksSubjectEmail;
        
        list<Task> lstTempTasksSubjectCall = new list<Task>();
        for(Integer index = 0; index <= 100; index++){
            lstTempTasksSubjectCall.add(new Task(WhatId = OppRecord1.Id,
                                                 OwnerId = UserInfo.getUserId(), 
                                                 Status = 'Not Started', 
                                                 Priority = 'Normal',
                                                 Subject = 'Pending Items for'));
         
        }       
        insert lstTempTasksSubjectCall;
        
        Stips__c stipsRecord = new Stips__c(Name = 'TestStips' , Opportunity__C = OppRecord1.Id);
        insert stipsRecord;
        
        
        List<FeedItem> feeditemLst = [Select Type,ParentId,Id 
                                      From FeedItem 
                                      where ParentId =: OppRecord1.Id];
                                      
       system.assertEquals(feeditemLst.size(), 201);
       Test.stopTest();
    }
}