trigger BehavioralSocialHistoryTrigger on Behavioral_Social_History__c (before insert, before update){
    TriggerFactory.createAndExecuteHandler(BehavioralSocialHistoryHandler.class); 

}