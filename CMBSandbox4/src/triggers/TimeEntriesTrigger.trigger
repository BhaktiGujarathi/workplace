/* The Trigger will update Developer Name and Developer Company based on the Name present in Person
 * Field of Time Entry Record and will populate Error field when there are multiple contact with
 * Same Contact Name and Account Name or No Contact on creation or Updation of Time Entry record.
 *
 *
 * Revision History:
 *
 * Version         Author                                Date                              Description
 * 1.0             Ajay Singh Solanki                    26/06/2013                        Initial Draft
 */



trigger TimeEntriesTrigger on HarvestTimeEntry__c (before insert, before update, after insert, after update, after delete) {

    TimeEntryTriggerHandler timeEntryHndlr = new TimeEntryTriggerHandler();  //Creating instance of TimeEntryTriggerHandler.

    if(trigger.isBefore && trigger.isInsert){
      /* Calling onInsertPopulateDeveloperNameAndCompany method to popualte Developer Name, Developer Company
       * and Error Field.
       */
      timeEntryHndlr.onInsertPopulateDeveloperNameAndCompany(trigger.new);
    }//End if Before Insert.


    if(trigger.isBefore && trigger.isUpdate){
      /* Calling onUpdatePopulateDeveloperNameAndCompany method to popualte Developer Name, Developer Company
       * and Error Field when record is updated.
       */
      timeEntryHndlr.onUpdatePopulateDeveloperNameAndCompany(trigger.newMap, trigger.oldMap);
    }//End if Before Update.
    
    if(trigger.isAfter) {
        if(trigger.isInsert && CheckRecursive.runOnceForAfter()) {
            new TimeEntryTriggerHandler().onAfterInsert();
        }
        
        if(trigger.isUpdate && CheckRecursive.runOnceForAfter()) {
            new TimeEntryTriggerHandler().onAfterUpdate();
        }
        
        if(trigger.isDelete && CheckRecursive.runOnceForAfter()) {
            new TimeEntryTriggerHandler().onAfterDelete();
        }
    }

}//End TimeEntriesTrigger trigger.