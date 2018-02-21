/* Trigger to Reflect the Roll-up of Amount of Recivables and Payables from  Opportunity
 * on to fields of campaign
 * 
 * Revision History:
 *   
 * Version         Author                         Date(dd/mm/yyyy)               Description
 * 1.0             Nachiket R. Deshpande          11/06/2014                     Initial Draft
 * 1.1             Yogesh Mahajan                 10/08/2016                     Initial Draft
 */ 
trigger OpportunityTrigger on Opportunity (after delete, after insert, after update, before insert, before update,after undelete) {
    
    OpportunityTriggerHandler OpportunityHandler = new OpportunityTriggerHandler();
    
    if(trigger.isAfter){
        //if record is Inserted fire the following trigger condition
        if(trigger.isInsert && CheckRecursive.runOnceForAfter()){
            system.debug('*** IS INSERT ****');
            OpportunityHandler.OnAfterInsert(trigger.oldMap,trigger.newMap,trigger.old, trigger.new);
            system.debug('*** OpportunityHandler ****'+OpportunityHandler);
        }
        //if record is Updated fire the following trigger condition
        if(trigger.isUpdate && CheckRecursive.runOnceForAfter()){
            system.debug('*** IS UPDATE ****');
            OpportunityHandler.OnAfterUpdate(trigger.oldMap,trigger.newMap,trigger.old, trigger.new);
            //OpportunityHandler.updatePreviousOpportunity(trigger.new);
        } 
        //if record is Deleted fire the following trigger condition
        /*if(trigger.isDelete && CheckRecursive.runOnceForAfter()){
            system.debug('*** IS DELETE ****');
            OpportunityHandler.OnAfterDelete(trigger.oldMap,trigger.newMap,trigger.old, trigger.new);
            system.debug('*** TRIGGER FIRED ****');
            list<RollupService.fieldDefinition> fieldDefinitions = 
            new list<RollupService.fieldDefinition> {
                new RollupService.fieldDefinition('COUNT','Id','Count_Of_Opportunities1__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions,trigger.old,'Opportunity','AccountId','Account','');
        }
        //if record is Inserted,Updated or Undeleted fire the following trigger condition
        if((trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) && CheckRecursive.runOnceForAfter()) {
            system.debug('*** TRIGGER FIRED ****');
            list<RollupService.fieldDefinition> fieldDefinitions = 
            new list<RollupService.fieldDefinition> {
                new RollupService.fieldDefinition('COUNT','Id','Count_Of_Opportunities1__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions,trigger.new,'Opportunity','AccountId','Account','');
        }*/
   }
   OpportunityHandler handler = new OpportunityHandler();
   if(trigger.isBefore && CheckRecursive.runOnceForBefore()){
       OpportunityHandler.onBefore(trigger.new);
       if(trigger.isInsert) {
           handler.onBeforeInsert();
       }
       if(trigger.isUpdate) {
           handler.onBeforeUpdate(trigger.oldMap, trigger.new);
       }
        
    }
}