trigger InfectiousDiseaseTrigger on Infectious_Disease__c (Before insert, Before update) {

    TriggerFactory.createAndExecuteHandler(InfectiousDiseaseHandler.class); 
}