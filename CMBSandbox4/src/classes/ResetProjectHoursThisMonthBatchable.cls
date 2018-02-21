global with sharing class ResetProjectHoursThisMonthBatchable implements Database.Batchable<sObject> {

    public String query;
    global string mailContent=' ';
    public ResetProjectHoursThisMonthBatchable() {
        query = 'Select Name, Id, Hours_This_Month__c,Hours_Credited_This_Month__c, Hours_Previous_Month__c From HarvestProject__c';
    }
    global Database.QueryLocator start(Database.BatchableContext bContext) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bContext, list<HarvestProject__c> projectScopeList) {
        List<HarvestProject__c> toUpdateProjectList = new List<HarvestProject__c>();
        for(HarvestProject__c projectObj :projectScopeList) {
            projectObj.Hours_Previous_Month__c = projectObj.Hours_This_Month__c;
            projectObj.Hours_This_Month__c = 0;
            projectObj.Hours_Credited_This_Month__c=0;
            toUpdateProjectList.add(projectObj);
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
}