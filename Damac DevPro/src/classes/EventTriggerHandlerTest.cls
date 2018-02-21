@istest
public class EventTriggerHandlerTest{

    static testmethod void EventTriggerHandler_Methods(){
    
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '0099';
        pcUser.Languages_Known__c = 'English';        
        insert pcUser ;
        
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        
        newInquiry.First_name__c = 'Test';        
        newInquiry.Last_name__c = 'Lead';
        newInquiry.inquiry_source__c = 'Call Center';
        newInquiry.email__c = 'TEST@TEST.COM';
        newInquiry.Phone_Unique_key__c = 'ABC';
        newInquiry.Email_Unique_key__c = 'TEST@TEST.COM';
        newInquiry.Inquiry_Score__c = 'Hot';
        insert newInquiry ;
        
        task t = new task();
        t.whatid = newInquiry.id;
        t.User_Ext_No__c = '0099';
        t.status = 'Completed';
        insert t;
        
        Event ev = new Event();
        ev.whatid = newInquiry.id;
        ev.User_Ext_No__c = '0099';
        ev.DurationInMinutes = 10;
        ev.ActivityDateTime = system.today();
        ev.Status__c = 'Completed';
        ev.type = 'Visit to Sales Office';        
        insert ev;
        
        Event ev1 = new Event();
        ev1.whatid = newInquiry.id;
        ev1.User_Ext_No__c = '0099';
        ev1.DurationInMinutes = 10;
        ev1.ActivityDateTime = system.today();
        ev1.Status__c = 'Completed';
        ev1.type = 'Face to Face';
        insert ev1;
        update t;
        
        ev.type='Call';
        update ev;
    
    
    
    
    }
}