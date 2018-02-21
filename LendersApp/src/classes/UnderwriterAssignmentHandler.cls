public with sharing class UnderwriterAssignmentHandler {

    private UnderwriterAssignmentRule[] assignmentRules;
    private Opportunity opportunity;


    public UnderwriterAssignmentHandler(Opportunity opportunity) {
        
        assignmentTemplates();
        queryOpportunity(opportunity.Id); 
    }


    public void assign() {

        UnderwriterAssignmentRuleMember assignmentRuleMember;

        for (UnderwriterAssignmentRule assignmentRule : assignmentRules) {

            if (assignmentRule.evaluateRule(opportunity)) {

                assignmentRuleMember = assignmentRule.getAssignmentRuleMember();

                if (assignmentRuleMember != null) {
                    
                    break;
                }
            }
        }

        if (assignmentRuleMember != null) {

            opportunity.Underwriter__c = assignmentRuleMember.underwriter;
            //system.assert(false, 'RULEMEMBER NOT NULL ' + opportunity.Id + opportunity.Underwriter__c);

            opportunity.Underwriter_Assignment_Rule_Member__c = assignmentRuleMember.id;
            opportunity.Reassign_Underwriter__c = false;

            update opportunity;

            assignmentRuleMember.updateRecord();
        }
    }


    private void assignmentTemplates() {

        assignmentRules = new UnderwriterAssignmentRule[]{};

        for (Underwriter_Assignment_Rule__c assignmentRule : [SELECT Sort_Order__c,
                                                                     Quotas__c,
                                                                     Load_Balancing__c,

                                                                     (SELECT Field_API_Name__c,
                                                                             Operator__c,
                                                                             Value__c
                                                                        FROM Underwriter_Assignment_Rule_Entries__r),

                                                                     (SELECT Underwriter__c,
                                                                             Quota__c,
                                                                             Last_Assignment_Date_Time__c
                                                                        FROM Underwriter_Assignment_Rule_Members__r
                                                                        WHERE Underwriter__r.Underwriter_Reassignment_Enabled__c = true                                                   
                                                                    ORDER BY Last_Assignment_Date_Time__c ASC NULLS FIRST)

                                                                FROM Underwriter_Assignment_Rule__c
                                                               WHERE Underwriter_Assignment_Template__r.Active__c = true
                                                            ORDER BY Sort_Order__c ASC]) {

            assignmentRules.add(new UnderwriterAssignmentRule(assignmentRule));
        }
    }


    private void queryOpportunity(String opportunityId) {

        Set<String> opportunityFields = new Set<String>();

        for (UnderwriterAssignmentRule assignmentRule : assignmentRules) {

            opportunityFields.addAll(assignmentRule.getObjectFields());
        }


        String query = 'SELECT Id ';

        for (String field : opportunityFields) {

            query += ', ' + field;
        }

        query += ' FROM Opportunity WHERE Id =: opportunityId';

        
        for (Opportunity o : (Opportunity[]) Database.query(query)) {

            opportunity = o;
        }
    }
}