public class OpportunityTriggerHandler{

    public static void checkAssignmentRuleMemberForCapacity(List<Opportunity> opportunitiesNew) {

        for (Opportunity myOpportunity : opportunitiesNew) {

            if (myOpportunity.get('Count_Against_Pipeline__c') != NULL) {

                if (!myOpportunity.Count_Against_Pipeline__c) {
                	
                    myOpportunity.Underwriter_Assignment_Rule_Member__c = null;
                }   
            }
        }
    }       
}