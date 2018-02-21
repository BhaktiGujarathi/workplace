trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) {

        
    if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'OpportunityTrigger'].IsActivate__c == true){
        OpportunityHandler controller = new OpportunityHandler();
        if(Trigger.isAfter && Trigger.isUpdate){
            
                controller.onAfterUpdate(trigger.oldMap, trigger.New);
        }
    }
    
    OpportunityHandler handler = new OpportunityHandler();
    if(trigger.isBefore && CheckRecursive.runOnceForBefore()){
       
       if(trigger.isInsert) {
           handler.onBeforeInsert();
       }
       if(trigger.isUpdate) {
           handler.onBeforeUpdate();
       }
        
    }
}