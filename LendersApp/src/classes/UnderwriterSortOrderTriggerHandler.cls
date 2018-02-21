public with sharing class UnderwriterSortOrderTriggerHandler {
	public UnderwriterSortOrderTriggerHandler() {}


    public static Boolean preventUpdate = false;
    private static boolean run = true;

    private List<Underwriter_Assignment_Rule__c> allTheRulesList = new List<Underwriter_Assignment_Rule__c>();
    private Map<Id, Underwriter_Assignment_Rule__c> assignmentRulesToUpdate = new Map<Id, Underwriter_Assignment_Rule__c>();
    private Map<id, List<Underwriter_Assignment_Rule__c>> rulesPerTemplateMap = new Map<id, List<Underwriter_Assignment_Rule__c>>();
    private Set<Id> assignmentRuleIds = new Set<Id>();  


    public static boolean runOnce() {
        
        if (run) {
        
            run = false;
            return true;
        }
        else {
        
            return run;
        }
    }


    public void reorder(List<Underwriter_Assignment_Rule__c> triggerNew, Map<Id,Underwriter_Assignment_Rule__c> triggerOldMap, boolean isInsert) {
        
        List<Underwriter_Assignment_Rule__c> newRules = new List<Underwriter_Assignment_Rule__c>();
        
        //Taking the objects out of the context of the trigger
        for (Underwriter_Assignment_Rule__c assignmentRule : triggernew) {
            
            newRules.add(assignmentRule);
        }

        for (Underwriter_Assignment_Rule__c assignmentRule : newRules) {
            
            assignmentRuleIds.add(assignmentRule.Underwriter_Assignment_Template__c);
        }

        allTheRulesList = [SELECT Name, Sort_Order__c, Underwriter_Assignment_Template__c 
                             FROM Underwriter_Assignment_Rule__c 
                            WHERE Underwriter_Assignment_Template__c IN: assignmentRuleIds 
                         ORDER BY Sort_Order__c limit 5000];

        for (Id templateId : assignmentRuleIds) {
            
            List<Underwriter_Assignment_Rule__c> assignmentRulesForThisTemplate = new List<Underwriter_Assignment_Rule__c>();
            
            for (Underwriter_Assignment_Rule__c assignmentRule : allTheRulesList) {
                
                if (assignmentRule.Underwriter_Assignment_Template__c == templateId) {
                    
                    assignmentRulesForThisTemplate.add(assignmentRule);
                }
            }

            rulesPerTemplateMap.put(templateId, assignmentRulesForThisTemplate);
        }

        for (Underwriter_Assignment_Rule__c assignmentRule : newRules) {
            
            List<Underwriter_Assignment_Rule__c> assignmentRulesForThisTemplate = new List<Underwriter_Assignment_Rule__c>();
            Underwriter_Assignment_Rule__c oldAssignmentRule = new Underwriter_Assignment_Rule__c();

            if (rulesPerTemplateMap.containsKey(assignmentRule.Underwriter_Assignment_Template__c)) {
                
                assignmentRulesForThisTemplate = rulesPerTemplateMap.get(assignmentRule.Underwriter_Assignment_Template__c);
            }

            for (Underwriter_Assignment_Rule__c rule : assignmentRulesForThisTemplate) {
            
                if (!isInsert) { //Then it is update

                    if (triggerOldMap.containsKey(assignmentRule.Id)) {
                        
                        oldAssignmentRule = triggerOldMap.get(assignmentRule.Id);   
                    }

                    // If the record being moved have the same order number as the record being looped
                    // but at the same time the record being looped has a higher order than the other record had before being moved
                    if(rule.Sort_Order__c == assignmentRule.Sort_Order__c && rule.Sort_Order__c > oldAssignmentRule.Sort_Order__c){
                    
                        // move the record being looped towards the begining of the order.
                        rule.Sort_Order__c--;
                    
                        // If the record being moved have the same order number as the record being looped
                        // but at the same time the record being looped has a lower order than the other record had before being moved
                    }
                    else if(rule.Sort_Order__c == assignmentRule.Sort_Order__c && rule.Sort_Order__c < oldAssignmentRule.Sort_Order__c){
                        
                        // move the record being looped towards the end of the order.
                        rule.Sort_Order__c++;
                    }
                    else if (rule.Sort_Order__c < assignmentRule.Sort_Order__c && rule.Sort_Order__c > oldAssignmentRule.Sort_Order__c) {
                        
                        // move the record being looped towards the begining of the order.
                        rule.Sort_Order__c--;
                    }
                    else if (rule.Sort_Order__c > assignmentRule.Sort_Order__c && rule.Sort_Order__c < oldAssignmentRule.Sort_Order__c) {
                        
                        // move the record being looped towards the end of the order.
                        rule.Sort_Order__c++;
                    }
                }
                else {
                    
                    if (rule.Sort_Order__c >= assignmentRule.Sort_Order__c) {
                       
                        // move the record being looped towards the end of the order.
                        rule.Sort_Order__c++;
                    }
                }

                if (!assignmentRulesToUpdate.containsKey(rule.id) && rule.Id != assignmentRule.Id) {
                    
                    assignmentRulesToUpdate.put(rule.id, rule);
                }
            }   
        }

        update assignmentRulesToUpdate.values();
    }
}