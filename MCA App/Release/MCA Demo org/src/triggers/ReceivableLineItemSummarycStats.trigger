trigger ReceivableLineItemSummarycStats on Receivable_Line_Item_Summary__c(after insert, after update, after delete, after undelete) {
    try {
      List<sObject> so = Database.query('SELECT Id FROM hoopla__Field__c');
      String changeType = Trigger.isInsert ? 'insert' : Trigger.isUpdate ? 'update' : Trigger.isDelete ? 'delete' : 'undelete';
      hoopla.NotifierGlobal.processNotifications('Receivable_Line_Item_Summary__cStats', Trigger.newMap, Trigger.oldMap, changeType);
    }
    catch(Exception e) {
      //Package suspended, uninstalled or expired, exit gracefully.
    }
}