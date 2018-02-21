trigger UnderwriterAssignmentTemplateTrigger on Underwriter_Assignment_Template__c (before insert, before update) {

    UnderwriterAssignmentActiveTemplate underwriterAssignmentActiveTemplate = new UnderwriterAssignmentActiveTemplate(Trigger.new);
    underwriterAssignmentActiveTemplate.checkActiveTemplates();
}