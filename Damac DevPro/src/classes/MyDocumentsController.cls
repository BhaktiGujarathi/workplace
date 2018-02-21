public with sharing class MyDocumentsController {
    public Id personAccountId{get; set{
            personAccountId = value;  
            attachmentListMethod();
        }}
    public List<SR_Attachments__c> attachmentList {get; set;}
    public MyDocumentsController () {
        attachmentList = new List<SR_Attachments__c>();
    }
    public void attachmentListMethod() {
        attachmentList = [
            SELECT Name 
                 , isValid__c 
              FROM SR_Attachments__c 
             WHERE Case__c IN (SELECT Id 
                                 FROM Case 
                                WHERE AccountId = :personAccountId
                              )
        ];
        //return attachmentList;
    }
}