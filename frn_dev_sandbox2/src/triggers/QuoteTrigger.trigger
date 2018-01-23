trigger QuoteTrigger on Quote (after undelete, after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(QuoteHandler.class);
   // TriggerFactory.createAndExecuteHandler(QuoteDeterminationScriptService.class);
}