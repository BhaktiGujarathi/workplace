@isTest
private class TasksToInquiryMapping_Test {

    static testMethod void myUnitTest() {
    	
    	Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='CTIInin1@testorg.com');
        System.runAs(u2){    
        Virtual_Number__c v = new Virtual_Number__c();
        v.Active__c = true;
        v.name = '123';
        v.End_Date__c = System.today().addDays(60);
        v.Start_Date__c = System.today().addDays(-60);
        insert v;
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
    
        JO_Campaign_Virtual_Number__c vn = new JO_Campaign_Virtual_Number__c();
        vn.Related_Campaign__c = camp.id;
        vn.Related_Virtual_Number__c = v.id;
        insert vn;
        
        
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '0099';
        pcUser.Languages_Known__c = 'English';
        insert pcUser ;
        
        Assigned_PC__c assignPC = InitialiseTestData.assignPCToCampaign(pcUser.Id,camp.Id);
        assignPC.Start_Date__c = System.today().addDays(-60);
        assignPC.end_date__c = System.today().addDays(60);
        insert assignPC ;
        
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry.Campaign__c = camp.Id ;  
        insert newInquiry ;
        
	        Task newTask = new Task(Status='Not Started',Priority = 'Normal',Task_Due_Date__c = Date.today().addDays(1),Subject='Test',Campaign_Number__c='123',User_Ext_No__c = '0099',Calling_Number__c = '091705789088');
	        insert newTask;
        }
        String sch = '0 0 23 * * ?';
        system.schedule('Test Account Sales Calculator Check', sch, new TasksToInquiryMappingScheduler());
    }
}