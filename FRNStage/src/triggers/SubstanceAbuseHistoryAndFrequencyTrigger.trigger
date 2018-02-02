trigger SubstanceAbuseHistoryAndFrequencyTrigger on Substance_Abuse_History_and_Frequency__c ( before insert, before update){
    TriggerFactory.createAndExecuteHandler(SubstanceAbuseHistoryAndFrequencyHandler.class); 

}