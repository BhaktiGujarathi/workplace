/*
 * Description: Batch class which creates Invoice records if it satisfies following conditions :
 * 1. Projects must have atleast one Estimates record.
 * 2. Project record status must be open.
 * 3. Project Type should be set to 'Monthly Supported'.
 *
 * Revision History: 
 *
 * Version     Author           Date         Description 
 * 1.0         Ashwini Singh    25/01/2016   Initial Draft
 */
public with sharing class InvoiceCreationFromProjectsBatch implements Database.Batchable<sObject>{
    public static final string STR_HOURS = 'Hours';
    //public static final string STR_MONTHLY_SUPPORT = 'Monthly Support';
    
    public String picklistValueStr = Label.ProjectTypeValueforBatch;
    public List<String> picklistValueList = picklistValueStr.Split(',');
    
    public string mailContent=' ';

    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select h.ProjectType__c, 
                                                h.Name, 
                                                h.Id, 
                                                h.Archived__c, 
                                                h.Account__c, 
                                                h.Opportunity__c, 
                                                h.ProjectHourlyRate__c, 
                                                h.Opportunity__r.Billing_Contact__c,
                                               (Select Id, Name From Estimates__r) 
                                         From HarvestProject__c h 
                                         where h.Archived__c = false 
                                         and h.ProjectType__c IN :picklistValueList
                                         //and h.ProjectType__c =: STR_MONTHLY_SUPPORT
                                         and h.CreatedDate = today]);
        
    }

    public void execute(Database.BatchableContext BC, list<HarvestProject__c> lstProject){
        try{
            if(lstProject != null && !lstProject.isEmpty()){ 
               List<Invoice__c> lstInsertInvoice = new List<Invoice__c>();
               for(HarvestProject__c objProject : lstProject){
                    if(objProject.Estimates__r.size() != 0){
                        Invoice__c objInvoice = new Invoice__c();
                        objInvoice.Invoice_Type__c = STR_HOURS;
                        objInvoice.Billing_Contact__c = objProject.Opportunity__r.Billing_Contact__c;
                        objInvoice.Account__c = objProject.Account__c;
                        objInvoice.Invoice_Type__c = objProject.Account__c;
                        objInvoice.Opportunity__c = objProject.Opportunity__c;
                        objInvoice.Rate__c = objProject.ProjectHourlyRate__c;
                        objInvoice.Description__c = Label.INTERNAL_DESCRIPTION_OF_INVOICE_FOR_PROJECT;
                        lstInsertInvoice.add(objInvoice);
                    }
               }
               if(lstInsertInvoice != null && !lstInsertInvoice.isEmpty()){
                    List<Database.SaveResult> results = database.update (lstInsertInvoice, false);
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){
                                mailContent=mailcontent + 'Error: '+ err.getStatusCode() + ' ' 
                                            + err.getMessage() +'</br>';
                            }
                        }
                    }
               }
           }
        }
        catch(Exception genException){
           system.debug('----genException---'+genException);
        }
    }

    public void finish(Database.BatchableContext BC){
       if (mailContent!=' '){
                SendErrorMail.sendErrorLog(mailContent);
       }
    }
}