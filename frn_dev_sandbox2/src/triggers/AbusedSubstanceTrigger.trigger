trigger AbusedSubstanceTrigger on Abused_Substance__c (before insert,before update,after insert,after update){
    TriggerFactory.createAndExecuteHandler(AbusedSubstanceHandler.class); 
    }