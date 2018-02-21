@isTest
public with sharing class UnderwriterAssignmentActiveTemplateTest {
    

    @isTest
    public static void testActiveAssignmentTemplate() {

        Underwriter_Assignment_Template__c activeTemplate = new Underwriter_Assignment_Template__c();
        activeTemplate.Name = 'Active Template';
        activeTemplate.Active__c = true;
        insert activeTemplate;

        Underwriter_Assignment_Template__c failingTemplate = new Underwriter_Assignment_Template__c();
        failingTemplate.Name = 'Failing Template';
        failingTemplate.Active__c = true;

        try {
            
            insert failingTemplate;
        }
        catch (Exception e) {}

        System.assertEquals(failingTemplate.Id, null);
    }
}