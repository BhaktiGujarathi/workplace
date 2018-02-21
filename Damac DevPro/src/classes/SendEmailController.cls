public with sharing class SendEmailController{
    
    public Email_Message__c eMsg{get; set;}
    public Email_Message__c prevEmailMsg{get; set;}
    public Inquiry__c inq{get; set;}
    public List<Attachment> lstAttach{get; set;}
    @TestVisible private String inquiryId;
    
    public SendEmailController(ApexPages.StandardController sc){
      
        inquiryId = ApexPages.currentPage().getparameters().get('id');
        string messageId = ApexPages.currentPage().getparameters().get('msgId');
        
        inq = [Select id, first_name__c, last_name__c, email__c from Inquiry__c where Id =:inquiryId ];
        
        if(messageId != '' && messageId != null)
            prevEmailMsg = [Select id,Description__c,HTML_Version__c,Subject__c from Email_message__c where Inquiry__c =: inquiryId and Id=: messageId order by lastModifiedDate desc limit 1];
        
        eMsg = new Email_Message__c();
        
        if(prevEmailMsg != null){
          eMsg.Subject__c = 'RE:'+prevEmailMsg.Subject__c;
          eMsg.HTML_Version__c = '<br/><br/><br/><br/>--------------------------------------------<br/>'+prevEmailMsg.HTML_Version__c;
        }
        else
          eMsg.HTML_Version__c = '<br/><br/><br/><br/><br/>'+'Inq-Ref:'+inquiryId;
        eMsg.Inquiry__c = inquiryId;
        
        lstAttach = new List<Attachment>();
        for(integer i=0; i<3; i++)
            lstAttach.add(new Attachment());
    }
    
    public PageReference sendEmailTocustomer(){
      
      PageReference inquiryPage = new PageReference('/' + inquiryId);
      inquiryPage.setRedirect(true);
      
      try{
        Id OGRecordTypeId = Schema.SObjectType.Email_message__c.getRecordTypeInfosByName().get('Outgoing').getRecordTypeId();
  
        eMsg.Outgoing__c = true;
        eMsg.RecordTypeId = OGRecordTypeId;
        string plaintext = eMsg.HTML_Version__c.escapeHTML3();
        plaintext = eMsg.HTML_Version__c.escapeHTML4();
        eMsg.Description__c = plainText;
        insert eMsg;
        
        List<Attachment> lst2Insert = new List<Attachment>();
        if(!lstAttach.isEmpty()){
          
          for(Attachment att: lstAttach){
            if(att.name != null){
              att.parentId = eMsg.Id;
              lst2Insert.add(att);
            }
          }
          
          if(!lst2Insert.isEmpty())
            insert lst2Insert;
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setWhatId(inq.id);
        mail.setToAddresses(new List<String>{inq.email__c});
        mail.setSaveAsActivity(false);
        mail.setReplyTo(System.Label.Reply_Email_Address); 
        
        
        if(eMsg.CC_Address__c != null){
            List<string> lstCC = eMsg.CC_Address__c.split(';');
            mail.setCcAddresses(lstCC);
        }
        
        if(eMsg.BCC_Address__c != null){
            List<string> lstBCC = eMsg.BCC_Address__c.split(';');
            mail.setCcAddresses(lstBCC);
        }
        
        mail.setSubject(eMsg.Subject__c);
        mail.setHtmlBody(eMsg.HTML_Version__c);
        mail.setPlaintextBody(eMsg.Description__c);
          
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : lst2Insert){
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        }
        mail.setFileAttachments(fileAttachments);
        
        mails.add(mail);
          
        Messaging.sendEmail(mails);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Email sent successfully.'));
        return inquiryPage;
      }
      catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+'-'+e.getLineNumber()));
        return null;
      }
      
    }
}