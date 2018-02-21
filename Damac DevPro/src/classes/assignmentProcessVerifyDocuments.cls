public without sharing class assignmentProcessVerifyDocuments{
    @InvocableMethod()
    public static void verifyDocuments(List<Id> ids){
        list<SR_Attachments__c> lstAttachments = [Select Id
                                                        ,isValid__c
                                                        ,SR__c
                                                  from SR_Attachments__c
                                                  where isValid__c = false
                                                  and SR__c IN : ids];
        
    }
}