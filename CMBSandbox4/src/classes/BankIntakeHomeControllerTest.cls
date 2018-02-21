@isTest
public with sharing class BankIntakeHomeControllerTest {

    private static Bank__c bank = null;

    @isTest
	public static void coverBankIntakeController() {

        insertBank();
        insertProgram();

        ApexPages.currentPage().getParameters().put('id', bank.Id);

        Test.startTest();

        BankIntakeHomeController controller = new BankIntakeHomeController();
        controller.email = 'test@test.com';
        controller.password = '1234567890';

        controller.login();
        System.assertEquals('BANK', controller.stage);

        controller.addProgram();
        controller.programs[0].record.Restricted_States__c = 'AL';
        controller.save();

        controller.recordMd5 = controller.programs[0].md5;
        controller.showDetailsAction();
        controller.saveModalAction();

        SelectOption[] states = controller.getStates();

        // Auxiliary Methods invocation
        
        controller.getHasErrorMessages();
        controller.getHasSuccessMessages();

        Test.stopTest();
	}

    private static void insertBank() {

        bank = new Bank__c();

        bank.Name = 'Bank Name Test';
        bank.Email__c = 'test@test.com';
        bank.Password__c = '1234567890';
        insert bank;
    }

    private static void insertProgram() {

        Program__c program = new Program__c();
        program.Name = 'Program Name Test';
        program.External_Bank__c = bank.Id;

        insert program;
    }



}