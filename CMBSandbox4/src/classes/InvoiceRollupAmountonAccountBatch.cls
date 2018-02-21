/*
* Version       Date             Author         Description
*   1.0         05/10/2015       Ashwini S      For Roll up on Account (Total_30_Days_Past_Due__c) from Invoice on daily basis   
* 
*/
global with sharing class InvoiceRollupAmountonAccountBatch implements Database.Batchable < sObject >{
    global final String query;
    global final Integer dayscount;
    global string mailContent=' ';
    public InvoiceRollupAmountonAccountBatch(Integer days, String schedulerQuery){
     dayscount=days;
     query=schedulerQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> lstAcc) {
        decimal totalInvoiced=0;
        try{
            if(lstAcc != null && !lstAcc.isEmpty()){  
                for(Account objAcc: lstAcc){
                    totalInvoiced=0;
                    for(Invoice__c objinvoice : objAcc.Invoices__r){
                        totalInvoiced = totalInvoiced + decimalValue(objinvoice.Total_Amount_Due__c);
                     }
                    if  (dayscount == 30){
                        objAcc.Total_30_Days_Past_Due__c=totalInvoiced;
                    }else if(dayscount == 90){
                        objAcc.Total_90_Days_Past_Due__c=totalInvoiced;
                    }else if(dayscount == 0){
                        objAcc.Total_Past_Due_Invoices__c=totalInvoiced;
                    }else if(dayscount == 60) {
                        objAcc.Total_60_Days_Past_Due__c=totalInvoiced;
                    }
                }
                List<Database.SaveResult> results = Database.update(lstAcc, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                          mailContent=mailcontent + 'Error: '+ err.getStatusCode() + ' ' + err.getMessage() +'</br>';
                        }
                    }
                }
               
            }
        }catch (Exception e) {
            system.Debug('Batch InvoiceRollupAmountonAccountBatch is throwing exception: '+e.getMessage());
        }      
    }
    
    //no processing required hence blank
    global void finish(Database.BatchableContext BC) {
      if (mailContent!=' '){
                SendErrorMail.sendErrorLog(mailContent);
                }
    }
    
    public decimal decimalValue(decimal decValue){
        return(decValue!=null?decValue:0);
    }

}