@isTest
public class Test_CustomTaskList {
    static testMethod void myUnitTest(){

        Inquiry__c testInquiry = new Inquiry__c();
        testInquiry.First_Name__c='Test';
        testInquiry.Last_Name__c='Inquiry';
        testInquiry.Email__c = 'test@gmail.com';
        testInquiry.Inquiry_Source__c = 'Facebook';
        insert testInquiry;
        Task testTask = new Task();
        testTask.WhatId = testInquiry.Id;
        testTask.OwnerId = UserInfo.getUserId();
        insert testTask;
        ApexPages.StandardController con = new ApexPages.StandardController(testInquiry);
        CustomTaskList testObj = new CustomTaskList(con);
        
    }

}