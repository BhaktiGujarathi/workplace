@isTest
public with sharing class UnderwriterValidatorTest {
	
	@isTest 
	public static void fieldTypeIsString() {

		User user = [SELECT Id FROM User WHERE IsActive = true AND Id <> :UserInfo.getUserId() AND Name <> 'Kevin Lee' LIMIT 1];

        Underwriter_Assignment_Template__c assignmentTemplate = new Underwriter_Assignment_Template__c();
        assignmentTemplate.Name = 'Test Template';
        insert assignmentTemplate;

        Underwriter_Assignment_Rule__c assignmentRule = new Underwriter_Assignment_Rule__c();
        assignmentRule.Sort_Order__c = 1;
        assignmentRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;
        insert assignmentRule;


		Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry = new Underwriter_Assignment_Rule_Entry__c();


		//Test first the cases WHERE everything should be fine.
		//assignmentRuleEntry.Object_API__c = '';
		assignmentRuleEntry.Operator__c   = 'equals';
		assignmentRuleEntry.Field_API_Name__c  = 'Interviewee__c';
		assignmentRuleEntry.Value__c      = 'TEST';
		assignmentRuleEntry.Underwriter_Assignment_Rule__c = [SELECT Id FROM Underwriter_Assignment_Rule__c WHERE Id =: assignmentRule.Id LIMIT 1][0].Id;

		insert assignmentRuleEntry;

		assignmentRuleEntry.Operator__c   = 'not equal to';

		update assignmentRuleEntry;

		assignmentRuleEntry.Operator__c   = 'contains';

		update assignmentRuleEntry;


		//Should fail here
		try {

			assignmentRuleEntry.Operator__c   = 'greater than';

			update assignmentRuleEntry; 

		} 
		catch (Exception e) {

			system.assert(true);
		}
	}

	@isTest 
	public static void fieldTypeIsDate() {

		User user = [SELECT Id FROM User WHERE IsActive = true AND Id <> :UserInfo.getUserId() AND Name <> 'Kevin Lee' LIMIT 1];

        Underwriter_Assignment_Template__c assignmentTemplate = new Underwriter_Assignment_Template__c();
        assignmentTemplate.Name = 'Test Template';
        insert assignmentTemplate;

        Underwriter_Assignment_Rule__c assignmentRule = new Underwriter_Assignment_Rule__c();
        assignmentRule.Sort_Order__c = 1;
        assignmentRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;

        insert assignmentRule;

		Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry = new Underwriter_Assignment_Rule_Entry__c();

		//Test first the cases WHERE everything should be fine.
		//assignmentRuleEntry.Object_API__c = 'Lead';
		assignmentRuleEntry.Operator__c   = 'equals';
		assignmentRuleEntry.Field_API_Name__c  = 'McaApp__Current_Balance_Date__c';
		assignmentRuleEntry.Value__c      = '01/15/1983';
		assignmentRuleEntry.Underwriter_Assignment_Rule__c = [SELECT Id FROM Underwriter_Assignment_Rule__c WHERE Id =: assignmentRule.Id LIMIT 1][0].Id;

		insert assignmentRuleEntry;

		assignmentRuleEntry.Operator__c   = 'not equal to';

		update assignmentRuleEntry;

		
		assignmentRuleEntry.Operator__c   = 'greater than';

		update assignmentRuleEntry; 

		//Should fail here
		try{
		
			assignmentRuleEntry.Operator__c   = 'contains';

			update assignmentRuleEntry;
			
		} 
		catch (Exception e) {

			system.assert(true);

		}

	}

	@isTest 
	public static void fieldTypeIsBoolean() {

		User user = [SELECT Id FROM User WHERE IsActive = true AND Id <> :UserInfo.getUserId() AND Name <> 'Kevin Lee' LIMIT 1];

        Underwriter_Assignment_Template__c assignmentTemplate = new Underwriter_Assignment_Template__c();
        assignmentTemplate.Name = 'Test Template';
        insert assignmentTemplate;

        Underwriter_Assignment_Rule__c assignmentRule = new Underwriter_Assignment_Rule__c();
        assignmentRule.Sort_Order__c = 1;
        assignmentRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;

        insert assignmentRule;

		Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry = new Underwriter_Assignment_Rule_Entry__c();

		//Test first the cases WHERE everything should be fine.
		//assignmentRuleEntry.Object_API__c = 'Lead';
		assignmentRuleEntry.Operator__c   = 'equals';
		assignmentRuleEntry.Field_API_Name__c  = 'McaApp__Bank_Statements__c';
		assignmentRuleEntry.Value__c      = 'true';
		assignmentRuleEntry.Underwriter_Assignment_Rule__c = [SELECT Id FROM Underwriter_Assignment_Rule__c WHERE Id =: assignmentRule.Id LIMIT 1][0].Id;

		insert assignmentRuleEntry;

		assignmentRuleEntry.Operator__c   = 'not equal to';

		update assignmentRuleEntry;

		
		assignmentRuleEntry.Operator__c   = 'equals';

		update assignmentRuleEntry; 

		//Should fail here
		try {
		
			assignmentRuleEntry.Operator__c   = 'contains';

			update assignmentRuleEntry;
			
		}
		catch(Exception e) {

			system.assert(true);
		}
	}	

	@isTest 
	public static void fieldTypeIsNumeric() {

		User user = [SELECT Id FROM User WHERE IsActive = true AND Id <> :UserInfo.getUserId() AND Name <> 'Kevin Lee' LIMIT 1];

        Underwriter_Assignment_Template__c assignmentTemplate = new Underwriter_Assignment_Template__c();
        assignmentTemplate.Name = 'Test Template';
        insert assignmentTemplate;

        Underwriter_Assignment_Rule__c assignmentRule = new Underwriter_Assignment_Rule__c();
        assignmentRule.Sort_Order__c = 1;
        assignmentRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;

        insert assignmentRule;

		Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry = new Underwriter_Assignment_Rule_Entry__c();

		//Test first the cases WHERE everything should be fine.
		//assignmentRuleEntry.Object_API__c = 'Lead';
		assignmentRuleEntry.Operator__c   = 'equals';
		assignmentRuleEntry.Field_API_Name__c  = 'McaApp__Factor_Rate__c';
		assignmentRuleEntry.Value__c      = '6757647';
		assignmentRuleEntry.Underwriter_Assignment_Rule__c = [SELECT Id FROM Underwriter_Assignment_Rule__c WHERE Id =: assignmentRule.Id LIMIT 1][0].Id;

		insert assignmentRuleEntry;

		assignmentRuleEntry.Operator__c   = 'not equal to';

		update assignmentRuleEntry;

		
		assignmentRuleEntry.Operator__c   = 'greater than';

		update assignmentRuleEntry; 

		//Should fail here
		try {
		
			assignmentRuleEntry.Operator__c   = 'contains';

			update assignmentRuleEntry;
			
		}
		catch (Exception e) {

			system.assert(true);
		}
	}



	@isTest 
	public static void fieldTypeIsDateTime() {
		
		User user = [SELECT Id FROM User WHERE IsActive = true AND Id <> :UserInfo.getUserId() AND Name <> 'Kevin Lee' LIMIT 1];

        Underwriter_Assignment_Template__c assignmentTemplate = new Underwriter_Assignment_Template__c();
        assignmentTemplate.Name = 'Test Template';
        insert assignmentTemplate;

        Underwriter_Assignment_Rule__c assignmentRule = new Underwriter_Assignment_Rule__c();
        assignmentRule.Sort_Order__c = 1;
        assignmentRule.Underwriter_Assignment_Template__c = assignmentTemplate.Id;

        insert assignmentRule;

		Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry = new Underwriter_Assignment_Rule_Entry__c();

		//Test first the cases WHERE everything should be fine.
		//assignmentRuleEntry.Object_API__c = 'Lead';
		assignmentRuleEntry.Operator__c   = 'equals';
		assignmentRuleEntry.Field_API_Name__c  = 'Date_Interview__c';
		assignmentRuleEntry.Value__c      = '3/14/2016 6:39 AM';
		assignmentRuleEntry.Underwriter_Assignment_Rule__c = [SELECT Id FROM Underwriter_Assignment_Rule__c WHERE Id =: assignmentRule.Id LIMIT 1][0].Id;

		insert assignmentRuleEntry;

		assignmentRuleEntry.Operator__c   = 'not equal to';

		update assignmentRuleEntry;

		
		assignmentRuleEntry.Operator__c   = 'greater than';

		update assignmentRuleEntry; 

		//Should fail here
		try {
		
			assignmentRuleEntry.Operator__c   = 'contains';

			update assignmentRuleEntry;
			
		}
		catch (Exception e) {

			system.assert(true);
		}

	}



}