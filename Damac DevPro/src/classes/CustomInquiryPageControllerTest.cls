@istest
public class CustomInquiryPageControllerTest{

    static testmethod void CustInqPgCon_Methods(){
    
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
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
        newInquiry.First_name__c = 'Test';
        newInquiry.Last_name__c = 'Lead';
        newInquiry.inquiry_source__c = 'Call Center';
        newInquiry.email__c = 'test@test.com';
        insert newInquiry ;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newInquiry);
        
        PageReference pageRef = Page.CustomInquiryPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('epn', 'ztyQYmPg9CLWOfK9uwpT2GLwU6Leq5wv9ghI0OWcXnA=');
        ApexPages.currentPage().getParameters().put('ext', '0099');
        ApexPages.currentPage().getParameters().put('campaign',v.Name);
        
        CustomInquiryPageController CustInqPgCon = new CustomInquiryPageController(sc);
        CustInqPgCon.inquiry = newInquiry;
        CustInqPgCon.SaveInquiry();
        CustInqPgCon.inquiry = null;
        CustInqPgCon.SaveInquiry();

    }


}