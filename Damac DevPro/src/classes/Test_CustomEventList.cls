@isTest
public class Test_CustomEventList {
    static testMethod void myUnitTest(){

        Inquiry__c testInquiry = new Inquiry__c();
        testInquiry.First_Name__c='Test';
        testInquiry.Last_Name__c='Inquiry';
        testInquiry.Email__c = 'test@gmail.com';
        testInquiry.Inquiry_Source__c = 'Facebook';
        insert testInquiry;
        Event testEvent = new Event();
        testEvent.WhatId = testInquiry.Id;
        testEvent.OwnerId = UserInfo.getUserId();
        testEvent.DurationInMinutes = 10;
        testEvent.ActivityDateTime = System.now();
        insert testEvent;
        ApexPages.StandardController con = new ApexPages.StandardController(testInquiry);
        CustomEventList testObj = new CustomEventList(con);
        
    }

}