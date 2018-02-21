trigger OpportunityTrigger on Opportunity (after insert, after update) {

        OpportunityHandler controller = new OpportunityHandler();
        if(Trigger.isAfter && Trigger.isUpdate){
            
                controller.onAfterUpdate(trigger.oldMap, trigger.New);
        }
        
}