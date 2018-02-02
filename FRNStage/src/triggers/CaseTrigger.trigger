trigger CaseTrigger on Case (before insert,before update,after insert) {
    TriggerFactory.createAndExecuteHandler(CaseHandler.class);

}