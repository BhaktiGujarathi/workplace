trigger RiskAssessmentTrigger on Risk_Assessment__c (before insert, before update){
    TriggerFactory.createAndExecuteHandler(RiskAssessmentHandler.class); 

}