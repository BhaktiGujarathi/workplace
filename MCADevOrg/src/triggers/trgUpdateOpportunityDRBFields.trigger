/*NOTE: Commented TaskHandler2.onInsertUpdateAccountTask as the method is not present in handler and it is throwing run time error : Merul*/
trigger trgUpdateOpportunityDRBFields on Task (After insert,after update) {
    if(Trigger.IsAfter){
        if(Trigger.IsUpdate){
            TaskHandler2.onUpdate(trigger.new,trigger.newMap,trigger.oldmap);
            TaskHandler2.onUpdate2(trigger.new,trigger.newMap,trigger.oldmap);
        } 
        if(Trigger.IsInsert){
            TaskHandler2.onInsert(trigger.new);
        }
       
        //TaskHandler2.onInsertUpdateAccountTask(trigger.new,trigger.newMap,trigger.oldmap);
    }
}