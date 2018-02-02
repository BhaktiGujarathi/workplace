trigger LeadTrigger on Lead (before insert,before update,before delete,after insert,after update,after Undelete){
    TriggerFactory.createAndExecuteHandler(LeadHandler.class); 

}