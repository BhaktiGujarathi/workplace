global with sharing class LineItemUpdatesProjectBatchable implements Database.Batchable<sObject>{
    
    public String query;
    global string mailContent=' ';
    
     public LineItemUpdatesProjectBatchable() {
        query = 'Select Id,Total_Invoice_Hours__c,Total_Invoiced_Amount__c,'+
                                                  '(Select Fee__c, Hours__c '+
                                                  'From Invoice_Line_Items__r'+ 
                                                  ' where Invoice__r.isSent__c=true OR Invoice__r.isPaid__c=true)'+
                        'From HarvestProject__c';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bContext) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bContext, list<HarvestProject__c> projectScopeList) {
        system.debug('projectScopeList'+projectScopeList);
        List<HarvestProject__c> toUpdateProjectList = new List<HarvestProject__c>();
        decimal totalInvoicedFee=0;
        decimal totalHours=0;
            for (HarvestProject__c objproject: projectScopeList){
                totalInvoicedFee=0;
                totalHours=0;
                for (Line_Item__c objlineitem:objproject.Invoice_Line_Items__r ){
                    totalInvoicedFee=totalInvoicedFee +decimalValue(objlineitem.Fee__c);
                    totalHours=totalHours+decimalValue(objlineitem.Hours__c);
                }
                objproject.Total_Invoice_Hours__c=totalHours;
                objproject.Total_Invoiced_Amount__c=totalInvoicedFee;
                toUpdateProjectList.add(objproject);
            }
            List<Database.SaveResult> results = database.update (toUpdateProjectList, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                          mailContent=mailcontent + 'Error: '+ err.getStatusCode() + ' ' + err.getMessage() +'</br>';
                      }
                 }
            }
      }
    global void finish(Database.BatchableContext bContext) {
      if (mailContent!=' '){
                SendErrorMail.sendErrorLog(mailContent);
      }
    }
    
     public decimal decimalValue(decimal decValue){
        return(decValue!=null?decValue:0);
  } 
}