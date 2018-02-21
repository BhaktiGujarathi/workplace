public with sharing class UnderwriterAssignmentActiveTemplate {

    private Underwriter_Assignment_Template__c[] templates;
    private Underwriter_Assignment_Template__c[] currentActiveTemplate;


    public UnderwriterAssignmentActiveTemplate(Underwriter_Assignment_Template__c[] triggerNew) {
        
        templates = triggerNew;   

        currentActiveTemplate = [SELECT Id
                                   FROM Underwriter_Assignment_Template__c 
                                  WHERE Active__c = TRUE];
    }


    public void checkActiveTemplates() {

        for (Underwriter_Assignment_Template__c template : templates) {

            if (template.Active__c && !currentActiveTemplate.isEmpty() 
                                   && template.Id != currentActiveTemplate.get(0).Id) {

                template.addError('You can only have one active template');
            }
        }   
    }
}