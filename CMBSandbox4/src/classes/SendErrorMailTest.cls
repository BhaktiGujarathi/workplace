@isTest    
private class SendErrorMailTest {
    
    static testMethod void testSendErrorMailMethod() {
        String msgStr = 'This is a test Email';
        SendErrorMail.sendErrorLog(msgStr);
    }
}