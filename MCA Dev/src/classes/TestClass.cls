public with sharing class TestClass{
    public TestClass(ApexPages.StandardController stdController) {
        Schema.DescribeSObjectResult dsr = EmailStatus.SObjectType.getDescribe(); 
        system.debug('****'+dsr);
        Contact contact = [select id from Contact where Name =: 'Test 1'];
        system.debug('***Contact**'+contact );
          string query = 'select TimesOpened from '+dsr.getName()+' where WhoId ='+ '\'' + contact.Id +'\'' ; //0039000000zKYRj';
          system.debug('***Status****'+ query );
        EmailStatus status = Database.query(query);
       //[select TimesOpened from EmailStatus where WhoId =: '0039000000zKYRj'];
        system.debug('***Status****'+ status );
    }
}