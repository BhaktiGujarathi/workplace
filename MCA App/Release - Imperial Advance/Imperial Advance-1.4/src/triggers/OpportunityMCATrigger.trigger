trigger OpportunityMCATrigger on Opportunity (after insert, after update) {

    OpportunityHandler controller = new OpportunityHandler();
        if(Trigger.isAfter && Trigger.isUpdate){

                controller.onAfterUpdate(trigger.oldMap, trigger.New);
        }
        if(Trigger.isAfter && Trigger.isInsert){

                controller.onAfterInsert(trigger.New);
        }
}