@isTest
private class SFMTAMappingController_Test {
	static final String CASE_NUMBER = 'caseNumber';
    static final String USER_ID = 'userId';
    static final String IS_INTERNAL = 'internal';
    static final String YES = 'yes';
    static final String CITIZEN = 'Citizen';

    static testmethod void constructor_recordTypeBikeParking() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Bike Parking'
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isBikeParking, 'isBikeParking should match the expected result');
    }

    static testmethod void constructor_recordTypeColorCurbs() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Color Curbs' 
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isColorCurb, 'isColorCurb should match the expected result');
        System.assertEquals(false, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }

    static testmethod void constructor_recordTypeDriveWayRedTip() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Driveway Red Tip' 
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isColorCurb, 'isColorCurb should match the expected result');
        System.assertEquals(false, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }

    static testmethod void constructor_recordTypeTemporarySigns() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Temporary Signs'
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isTempSign, 'isTempSign should match the expected result');
        System.assertEquals(false, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }

    static testmethod void constructor_recordTypeSpecialEvents() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Special Events'
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isStreetClosure, 'isStreetClosure should match the expected result');
        System.assertEquals(false, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }

    static testmethod void constructor_recordTypeBlockParty() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Block Party'
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isStreetClosure, 'isStreetClosure should match the expected result');
        System.assertEquals(false, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }

    static testmethod void constructor_recordTypeSpecialEventsReadOnly() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Special Events Read-Only'
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isStreetClosure, 'isStreetClosure should match the expected result');
        System.assertEquals(true, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }

    static testmethod void constructor_recordTypeBlockPartyReadOnly() {
        User setupUser = (User)new SObjectBuilder(User.SObjectType)
            .create()
            .getRecord();
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE Name = 'Block Party Read-Only'
            LIMIT 1
        ].Id;
        Case setupCase = (Case)new SObjectBuilder(Case.SObjectType)
            .put(Case.RecordTypeId, recordTypeId)
            .create()
            .getRecord();
        String caseNumber = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        PageReference pageRef = ApexPages.CurrentPage();
        pageRef.getParameters().put(CASE_NUMBER, caseNumber);
        pageRef.getParameters().put(USER_ID, setupUser.Id);
        pageRef.getParameters().put(IS_INTERNAL, YES);

        Test.startTest();
            SFMTAMappingController testResult = new SFMTAMappingController(null);
        Test.stopTest();

        System.assertEquals(YES, testResult.isInternal, 'isInternal should be set to the url param given');
        System.assertEquals(setupCase.Id, testResult.currentCase.Id, 'currentCase should be set to the url param given');
        System.assertEquals(setupUser.Id, testResult.currentUser.Id, 'currentUser should be set to the url param given');
        System.assertEquals(CITIZEN, testResult.profileName, 'profileName should be set to the url param given');
        System.assertEquals(true, testResult.isStreetClosure, 'isStreetClosure should match the expected result');
        System.assertEquals(true, testResult.isReadOnly, 'isReadOnly should match the expected result');
    }
}