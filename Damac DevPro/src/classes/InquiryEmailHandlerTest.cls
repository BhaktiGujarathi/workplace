@isTest 
private class InquiryEmailHandlerTest {

    static testMethod void testMe() {
        
        Account A1 = new Account(Name = 'Test Account', Agency_Type__c = 'Corporate');
        insert A1;
        Contact C1 = new Contact( AccountID = A1.id, FirstName = 'FirstName', LastName = 'LastName', 
        email = 'someaddress@email.com' );
        insert C1;
        Attachment att = new Attachment(Name='textfile.doc',Body=Blob.valueOf('Inq-Ref:'),ParentId = C1.id);
        Insert att;
        Inquiry__c inquiryRec = InitialiseTestData.getInquiryDetails('Inquiry',1234);
        insert inquiryRec;
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
          Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
          // setup the data for the email
          email.subject = 'Test Job Applicant';
          email.fromname = 'FirstName LastName';
          email.plainTextBody = ' Inq-Ref:'+inquiryRec.id;
          env.fromAddress = 'someaddress@email.com';
        
          // add an attachment
          Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
          attachment.body = blob.valueOf('my attachment text');
          attachment.fileName = 'textfile.txt';
          attachment.mimeTypeSubType = 'text/plain';
        
          email.binaryAttachments =
            new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
          // call the email service class and test it with the data in the testMethod
          InquiryEmailHandler emailProcess = new InquiryEmailHandler();
          emailProcess.handleInboundEmail(email, env);
        
          // query for the contact the email service created
          Contact contact = [select id, firstName, lastName, email from contact
            where firstName = 'FirstName' and lastName = 'LastName'];
        
          System.assertEquals(contact.firstName,'FirstName');
          System.assertEquals(contact.lastName,'LastName');
          System.assertEquals(contact.email,'someaddress@email.com');
        
          // find the attachment
          Attachment a = [select name from attachment where parentId = :contact.id];
        
        System.assertEquals(a.name,'textfile.doc');
    }
}