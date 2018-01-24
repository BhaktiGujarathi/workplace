public with sharing class DETE_ContactUsController extends DETE_BaseClass {
    public Case stdCase                                                                 {get; set;}
    static final String EMAIL_TEMPLATE_NAME = 'DETE_Contact Us';
    static final String EMAIL_SUBJECT = 'Delaware Joblink Contact Us';

    public DETE_ContactUsController() {
        stdCase = new Case();
    }

    public void saveCommunityCase() {
        stdCase.CommunityCase__c= true;
        stdCase.Recipient_Email__c = Label.DETE_AlertEmailAddress;
        Contact contactObj = new Contact();
        try {
            if(String.isNotBlank(stdCase.First_Name__c) && String.isNotBlank(stdCase.SuppliedEmail) ){
                contactObj.LastName = stdCase.First_Name__c;
                contactObj.Email = stdCase.SuppliedEmail;
                insert contactObj;
                insert stdCase;
                sendMail(stdCase, contactObj);
                delete contactObj;
                ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.Confirm, 'Your details have been mailed successfully!');
                ApexPages.addMessage(msgStr);
            } else {
                ApexPages.Message msgStr;
                if(String.isNotBlank(stdCase.First_Name__c))
                    msgStr = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in First Name in order to successfully submit your details!');
                else
                    msgStr = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in Email address in order to successfully submit your details!');
                ApexPages.addMessage(msgStr);
            }
        }
        catch (Exception exObj) {
            ApexPages.Message msgStr = new ApexPages.Message(ApexPages.Severity.ERROR, +exObj.getMessage());
            ApexPages.addMessage(msgStr);
        }
    }
    
    public void sendMail(Case pCase, Contact pContact) {
        list<EmailTemplate> listEmailTemplate = new list<EmailTemplate>();
        listEmailTemplate = [Select Name,
                                    Id,
                                    Body
                             From EmailTemplate
                             Where Name =: EMAIL_TEMPLATE_NAME
                             limit 1
                            ];
        if (!listEmailTemplate.isEmpty()) {
            Id templateId = listEmailTemplate[0].Id;
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
            message.setTargetObjectId(pContact.Id);
            message.setToAddresses(new list<string>{Label.DETE_AlertEmailAddress});
            message.setTemplateId(templateId);
            message.setWhatId(pCase.Id);
            message.setTreatTargetObjectAsRecipient(false);
            allMails.add(message);
            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails);
        }
    }
}