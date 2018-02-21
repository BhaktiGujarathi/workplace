global without sharing class ManageDPOKDocs implements NSIBPM.CustomCodeExecutable {
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        String retStr = 'Success';
        boolean isMandatoryDocsApproved = false;
        for(NSIBPM__Step__c stp : [select id,name,NSIBPM__Status__c,NSIBPM__Status__r.NSIBPM__Code__c,
                                   NSIBPM__SR__c,NSIBPM__SR__r.NSIBPM__Record_Type_Name__c,NSIBPM__Step_Template__c,
                                   NSIBPM__Step_Template__r.NSIBPM__Code__c,NSIBPM__Step_Template__r.NSIBPM__Summary__c
                                   from NSIBPM__Step__c where id =: step.id and NSIBPM__Status__r.NSIBPM__Code__c = 'DOCS_OK' and 
                                   NSIBPM__Step_Template__r.NSIBPM__Code__c = 'DOCUMENT_VERIFICATION']){
                                       isMandatoryDocsApproved = isallDocsApproved(stp.NSIBPM__SR__c);
                                       if(!isMandatoryDocsApproved){
                                           return 'All mandatory documents status should be approved to proceed.';
                                       }
                                       else{
                                           SRUtility.callAsyncReceiptWebservice(step.NSIBPM__SR__c);
                                       }
                                       break;
                                   }
        return retstr;
    }
    
    public static boolean isallDocsApproved(id SRID){
        for(NSIBPM__SR_Doc__c srDoc:[select id from NSIBPM__SR_Doc__c where NSIBPM__SR_Template_Doc__c != null and NSIBPM__SR_Template_Doc__r.NSIBPM__Optional__c = false and id!=null and NSIBPM__Service_Request__c =: SRID and NSIBPM__Status__c != 'Approved' limit 1]){
			return false;
        }
        return true;
    }
}