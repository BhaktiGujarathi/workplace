public with sharing class OpportunityService {

    //constructor
    public OpportunityService() {}
    
    
     /**
     * when opportunity stage changed then populate its date for respective field 
     * and boolean variable to true
     */
    public void trackOpportunityStage(List<Opportunity> opportunities) {
        Map<String, String> stageToDateFieldMap = StatusFieldMapping.OPPORTUNITY_STAGE_DATE_FIELD_MAP;
        Map<String, String> stageToBooleanFieldMap = StatusFieldMapping.OPPORTUNITY_IS_STAGE_FIELD_MAP; 
        for(Opportunity opportunity :opportunities) {
            if(stageToDateFieldMap.containsKey(opportunity.StageName)) {
                opportunity.put(stageToDateFieldMap.get(opportunity.StageName), system.now());
            }
            if(stageToBooleanFieldMap.containsKey(opportunity.StageName)) {
                opportunity.put(stageToBooleanFieldMap.get(opportunity.StageName), true);
            }
        }
    }
}