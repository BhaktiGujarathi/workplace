/* Trigger to Reflect the Roll-up of Amount of Recivables and Payables from  Opportunity
 * on to fields of campaign
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/06/2014                              Initial Draft
 */ 




trigger OpportunityTrigger on Opportunity (after delete, after insert, after update, before insert, before update) {
    
    OpportunityTriggerHandler OpportunityHandler = new OpportunityTriggerHandler();
    
    if(trigger.isAfter){
        
        if(trigger.isInsert){
            
            OpportunityHandler.OnAfterInsert(trigger.oldMap,trigger.newMap,trigger.old, trigger.new);
        }
        
        if(trigger.isUpdate){
            OpportunityHandler.OnAfterUpdate(trigger.oldMap,trigger.newMap,trigger.old, trigger.new);
            //OpportunityHandler.updatePreviousOpportunity(trigger.new);
        } 
        
        if(trigger.isDelete){
            OpportunityHandler.OnAfterDelete(trigger.oldMap,trigger.newMap,trigger.old, trigger.new);
        } 
    }
    
    if(trigger.isBefore){
        OpportunityHandler.onBefore(trigger.new);
    }
}