@isTest
public with sharing class DETE_ChangePasswordTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        User user = DETE_DataFactory.getUSerRecord(false);
        insert user;

        system.runAs(user) {
           PageReference pageRef = Page.DETE_ChangePassword;
           Test.setCurrentPage(pageRef);
           //listUser
            // statements to be executed by this test user.
            DETE_ChangePassword testIndex = new DETE_ChangePassword();
            testIndex.newPasswordStr    = 'bw12345#';
            testIndex.oldPasswordStr    = 'bw12345!!';
            testIndex.verifyPasswordStr = 'bw12345!!';
            testIndex.fetchUsername();
            DETE_BaseClass baseController = new DETE_BaseClass();
        }

        Test.stopTest();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Your password has been reset!')) b = true;
        }
        system.assert(b);

    }
}