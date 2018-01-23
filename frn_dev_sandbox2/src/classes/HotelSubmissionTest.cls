@isTest
public class HotelSubmissionTest {
    static testMethod void testMethod1()
    {
      Hotel__c testHotel = new Hotel__c();
      testHotel.Guest_First_Name__c='test';
      insert testHotel;
      
      Test.StartTest();
      
      PageReference pageRef = Page.hotelsubmission;
      pageRef.getParameters().put('id', String.valueOf(testHotel.Id));
      Test.setCurrentPage(pageRef);
      
      HotelSubmission testHotReq = new HotelSubmission();
      
      testHotReq.save();
      Test.StopTest();
      }

}