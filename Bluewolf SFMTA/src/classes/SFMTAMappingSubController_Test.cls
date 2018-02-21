@isTest
private class SFMTAMappingSubController_Test {
    static final String CASE_NUMBER = 'caseNumber';
    static final String USER_ID = 'userId';
    static final String IS_INTERNAL = 'internal';
    static final String YES = 'yes';

    static testmethod void SFMTAMappingSubController_Init_Valid(){
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Contact setupContact = (Contact)new SObjectBuilder(Contact.SObjectType)
            .create()
            .getRecord();
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.ContactId, setupContact.Id)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;

        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        SFMTAMappingSubController testResult = new SFMTAMappingSubController();

        Test.startTest();
			testResult.init();
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.caseId, 'caseId should be set to the url param given');
        System.assertEquals(caseNumber, testResult.caseNumber, 'caseNumber should be set to the url param given');
    } 
}