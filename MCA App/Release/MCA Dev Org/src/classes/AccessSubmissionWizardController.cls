/**

  ==================================================================================================
    Version     Date            Author              Comment
  ==================================================================================================
    1.0        Nov-16-2015     Yogesh Mahajan      
    1.1        Nov-21-2015     Yogesh Mahajan      

**/

public class AccessSubmissionWizardController {
    public Submission__c submission ;
    public List<Attachment> listAttachment;
    public List<wrapperAttachment> listWrapperAttachment;
    public static String submissionID;
    
    //constructor to instansiate list
    public AccessSubmissionWizardController() {
        listAttachment= new List<Attachment>();
        listWrapperAttachment = new List<wrapperAttachment>();
        submissionID = apexpages.currentpage().getparameters().get('id');
    }
    
    
    //get submissions of opportunity to display fields on page
    public Submission__c getSubmission() {
        system.debug('getSubmission------>'+submission);
        if(submissionID != null) {
            return submission;
        }  else
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, 'Please Provide Submission ID into URL'));
        return null;
    }
    
    //It is used to get submision and related record value.
    public void querySubmission() {
        submission = [Select Id
                               , Opportunity__r.NSFs_avg__c
                               , Opportunity__r.Total_Attachment_Count__c
                               , Opportunity__r.Owner_2__c
                               , Opportunity__r.Owner_1__c
                               , Opportunity__r.Name
                               , Opportunity__r.Avg_Monthly_CC_sales__c
                               , Opportunity__r.AccountId
                               , Opportunity__r.NDBs_avg__c
                               , Opportunity__r.Amount_Requested__c
                               , Opportunity__r.Gross_monthly_Sales__c
                               , Opportunity__r.Bank_Program__c 
                               , Opportunity__c From Submission__c where Id =: submissionID LIMIT 1];
            //return submission;
    }
     
    //get list of attachment into wrapper class and list is display on page
    public list<wrapperAttachment> getlistWrapperAttachment() {
         listWrapperAttachment.clear();
        // system.debug('------>'+submission.Opportunity__c);
         if(submissionID != null && submission <> null && submission.Opportunity__c <> null) {
             //to fetch attachment and add it into wrapper list to display on vf page
             listAttachment = [
                             Select id
                                  , Name
                                  , body
                                  , Description
                                  , LastModifiedDate
                                  , CreatedDate
                               From Attachment
                              where ParentID =: submission.Opportunity__c
            ];
            system.debug('------>'+listAttachment);
            if(listAttachment  != Null) {
                for(Attachment attachInstance :listAttachment) {
                    listWrapperAttachment.add(new wrapperAttachment(attachInstance));
                }
            }
            return listWrapperAttachment;
        }
        return null;
     }
     
    //to get attachments to download from vf page
    @RemoteAction
    public static string getAttachments() {
            Attachment attach = [Select id
                                      , Name
                                      , body
                                      , Description
                                      , LastModifiedDate
                                      , CreatedDate
                                   From Attachment where id =:'00P9000000i3iXhEAI'];
                                      
            return EncodingUtil.base64Encode(attach.body);
    }
    
    //wrapper class for attachments and boolean to select multiple attachment
    public class wrapperAttachment {
        public Boolean isChecked{get; set;}
        public Attachment attachmentInstance{get; set;}
     
        //constructor of wrapper class
        public wrapperAttachment(Attachment attachmentInstance) {
            isChecked = false;
            this.attachmentInstance= attachmentInstance;
        }
    }
    
}