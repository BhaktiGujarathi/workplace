@isTest
private class NewInquiryController_Test {

    static testMethod void myUnitTest() {
        Test.startTest();
            Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
            Id CorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
            ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;
            ID consultantId = [ Select id,UserType from Profile where name = 'Property Consultant'].id;
            ID adminProfileID = [ Select id,UserType from Profile where name = 'System Administrator'].id;
            ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
            
            Profile p1 = [SELECT Id FROM Profile WHERE Name='Property Consultant']; 
            Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
            NewInquiryController thisInquiry = new NewInquiryController();
            Test.setMock(HttpCalloutMock.class, new MockHttpCalloutClass());
                thisInquiry.fieldValidation = false;
                thisInquiry.recaptchaVerification();
                System.assertEquals(true , thisInquiry.captchaVerified);
            
            User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
                LocaleSidKey='en_US', ProfileId = p1.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser9@testorg.com');
            User u2 = new User(Alias = 'standt2', Email='standarduser3@testorg.com', userRoleId=adminRoleId, isActive = true,
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p2.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='admin8@testorg.com');
            
            System.runAs(u2) {
                PageReference gspPage = Page.NewInquiry;
                Test.setCurrentPage(gspPage);
                Campaign__c camp = new Campaign__c();
                camp.RecordTypeId = RSRecordTypeId;
                camp.Campaign_Name__c='Test Campaign';
                camp.start_date__c = System.today();
                camp.end_date__c = System.Today().addDays(30);
                camp.Marketing_start_date__c = System.today();
                camp.Marketing_end_date__c = System.Today().addDays(30);
                insert camp;
                
                NewInquiryController newInquiry = new NewInquiryController();
                newInquiry.inquiryObj = new Inquiry__c(First_Name__c = 'Damac',Last_Name__c='Damac',Mobile_CountryCode__c='India:0091',
                                                        Mobile_Phone_Encrypt__c='000198372937232',Email__c='Damac@damac.com',
                                                        Preferred_Language__c = 'English',Campaign__c=camp.id);
                newInquiry.saveInquiry();
                //Assigning test Page
                ApexPages.currentPage().getParameters().put('location', 'India');
                
                
                NewInquiryController newInquiry1 = new NewInquiryController();
                newInquiry1.inquiryObj = new Inquiry__c(First_Name__c = 'Damac',Last_Name__c='Damac',Mobile_CountryCode__c='India:0091',
                                                        Mobile_Phone_Encrypt__c='0078298372937232',Email__c='Damac@damac.com',
                                                        Preferred_Language__c = 'English',Campaign__c=camp.id);             
                newInquiry1.saveInquiry();
                
                
            }
        Test.stopTest();
    }
}