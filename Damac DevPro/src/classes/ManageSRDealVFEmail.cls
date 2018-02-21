global without sharing class ManageSRDealVFEmail implements NSIBPM.CustomCodeExecutable {
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        String retStr = 'Success';
        try{
            for(NSIBPM__Step__c stp : [select id,NSIBPM__Status__c,NSIBPM__Status__r.NSIBPM__Code__c,NSIBPM__SR__c from NSIBPM__Step__c 
                                       where (NSIBPM__Status__r.NSIBPM__Code__c = 'MANAGER_APPROVED' or
                                              NSIBPM__Status__r.NSIBPM__Code__c = 'DOCS_OK') and id=: step.id limit 1]){
                                                  return sendemailtoUser(step.NSIBPM__SR__c,stp.NSIBPM__Status__r.NSIBPM__Code__c);
                                              }
            return 'Success';
        }
        catch(exception ex){
            retStr = ex.getMessage();
            return retStr;
        }
    }
    
    public static string sendemailtoUser(id srid,string stpSRTemplateCode) {
        system.debug('#### send email'+Limits.getQueries());
        Savepoint sp = database.setSavepoint();
        try{
            // SR VF Deal Email : removed this template because of 101 SOQL Error.
            Id Emailtemplateid = [select id,name,developername from emailtemplate where name = 'Notify PC on Manager Approval of Deal'].id;
            List<Id> lstUIds = new List<Id>();
            
            if(stpSRTemplateCode == 'DOCS_OK'){
                lstUIds = label.EmailAddressesDocsOK.split(';');
            }
            else if(stpSRTemplateCode == 'MANAGER_APPROVED'){
                lstUIds = label.EmailAddressesManagerApproved.split(';');
            }
            if(lstUIds == null || lstUIds.isempty()){
                return 'Please configure the \'To Addresses\' in respective custom label and try again!';
            }
            
            List<Messaging.SingleEmailMessage> lstmail = new List<Messaging.SingleEmailMessage>();
            for(id uid : lstUIds){
                //New instance of a single email message
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(uid);
                mail.setTemplateId(Emailtemplateid);
                //mail.setWhatId(srid); 
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setSenderDisplayName('DAMAC Properties');
                mail.setSaveAsActivity(false);  
                lstmail.add(mail);
            }
            system.debug('#### send email'+Limits.getQueries()+' -- '+lstmail.size());
            Messaging.sendEmail(lstmail);
            return 'Success';
        }
        catch(exception ex){
            database.rollback(sp);
            return ex.getMessage();
        }
    }  
}