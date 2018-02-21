@isTest
private class UnderwriterAssignmentTest {
    
    public static Underwriter_Assignment_Template__c[] assignmentTemplateList = null;
    public static Underwriter_Assignment_Template__c assignmentTemplate = null;
    public static Underwriter_Assignment_Rule__c assignmentRule = null;
    public static Underwriter_Assignment_Rule_Entry__c assignmentEntry = null;
    public static Underwriter_Assignment_Rule_Member__c assignmentMember = null;
    public static Opportunity opp = null;
    public static Account acc = null;
    


    @isTest 
    public static void SortOrderTriggerHandler() {
        
        createAssignmentTemplate();
        createAssignmentTemplateList();
        createAssignmentRule();
        createUnderwriterAssignmentRuleEntry();
        createAssignmentRuleMember();

        Underwriter_Assignment_Rule__c failingRule = new Underwriter_Assignment_Rule__c(); 
        failingRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;
        failingRule.Sort_Order__c = 1;
        try {
            insert failingRule;
        }
        catch(Exception ex) {

        }
        
        //System.assertEquals(null, failingRule.Id);
    }

    @isTest 
    public static void testAssignmentRule() { 

        createAccount();
        createOpportunity();
        createAssignmentTemplate();
        createAssignmentRule();
        createUnderwriterAssignmentRuleEntry();
        createAssignmentRuleMember();
        

        assignmentRule = [SELECT Id, Sort_Order__c, Quotas__c, Load_Balancing__c, (SELECT Id, Field_API_Name__c, Operator__c, Value__c FROM Underwriter_Assignment_Rule_Entries__r), (SELECT Id, Underwriter__c, Last_Assignment_Date_Time__c, Quota__c FROM Underwriter_Assignment_Rule_Members__r) FROM Underwriter_Assignment_Rule__c WHERE Id = :assignmentRule.Id];
        
        UnderwriterAssignmentRule controller = new UnderwriterAssignmentRule(assignmentRule);
        
        System.debug(assignmentRule.Underwriter_Assignment_Rule_Entries__r + '   ' + assignmentEntry.Underwriter_Assignment_Rule__c + '  ' + assignmentRule.Id );
        

        //controller.evaluateRule(opp); Constructor has opportunity
        controller.getObjectFields();
        controller.useLoadBalancing = true;
        controller.useQuotas = true;    
        controller.getAssignmentRuleMember();
    }

    @isTest 
    public static void testUnderwriterAssignmentRuleEntry() {

        createAccount();
        createOpportunity();
        createAssignmentTemplate();
        createAssignmentRule();
        createUnderwriterAssignmentRuleEntry();
        createAssignmentRuleMember();

        assignmentEntry.Value__c = 'Id';
        UnderwriterAssignmentRuleEntry controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        //Focus on logical operators
        assignmentEntry.Operator__c = 'not equal to';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Operator__c = 'greater than';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Operator__c = 'less than';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Operator__c = 'greater or equal';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Operator__c = 'less or equal';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Operator__c = 'nothing';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        //Focus on FieldType
        assignmentEntry.Field_API_Name__c = 'McaApp__Origination_Fee__c';
        assignmentEntry.Value__c = '12.50';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Field_API_Name__c = 'cmbla__Completed__c';
        assignmentEntry.Value__c = 'true';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Field_API_Name__c = 'CloseDate';
        assignmentEntry.Value__c = '08/14/2011';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);

        assignmentEntry.Field_API_Name__c = 'McaApp__Factor_Rate__c';
        assignmentEntry.Value__c = '15';
        controller = new UnderwriterAssignmentRuleEntry(assignmentEntry);
        controller.evaluateRuleEntry(opp);



    }

    

    public static void createAssignmentTemplateList() { 
    
        assignmentTemplateList = new Underwriter_Assignment_Template__c[]{};
        insert assignmentTemplateList;
    }
    
    public static void createAssignmentTemplate() {

        assignmentTemplate = new Underwriter_Assignment_Template__c();
        assignmentTemplate.Active__c = true;
        insert assignmentTemplate;
    }
    
    public static void createAssignmentRule() {

        assignmentRule = new Underwriter_Assignment_Rule__c();
        assignmentRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;
        assignmentRule.Sort_Order__c = 1;
        //assignmentRule.Enable_Quotas__c = true;
        //assignmentRule.Enable_Load_Balancing__c = true;

        insert assignmentRule;
    }
    
    public static void createUnderwriterAssignmentRuleEntry() {

        assignmentEntry = new Underwriter_Assignment_Rule_Entry__c();
        assignmentEntry.Underwriter_Assignment_Rule__c = assignmentRule.Id;
        //assignmentEntry.Object_API__c = 'Lead';
        assignmentEntry.Description__c = 'descr';
        assignmentEntry.Field_API_Name__c = 'StageName';
        assignmentEntry.Operator__c = 'equal';
        assignmentEntry.Value__c = 'Prospecting';

        insert assignmentEntry;
    }
    
    public static void createAssignmentRuleMember() {

        assignmentMember = new Underwriter_Assignment_Rule_Member__c();
        assignmentMember.Underwriter_Assignment_Rule__c = assignmentRule.Id;
        assignmentMember.Quota__c = 0;
        insert assignmentMember;
    }
    
    public static void createOpportunity() { 

        opp = new Opportunity();
        opp.Name = 'Test Name';
        opp.StageName = 'Underwriting';
        opp.CloseDate = Date.today();
        opp.AccountId = acc.Id;
        insert opp;
    }

    public static void createAccount() {

        acc = new Account();
        acc.Name = 'test';
        insert acc;
    }


    

}