@isTest
private class NSI_Ctrl_StepTransitionsTest {

    public static List<NSIBPM__Service_Request__c> createServiceRequestList = new List<NSIBPM__Service_Request__c>();
    private static List<NSIBPM__SR_Template__c> createSrTemplateList = new List<NSIBPM__SR_Template__c>();  
    private static List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
    private static List<NSIBPM__Transition__c> createStepTransitionList = new List<NSIBPM__Transition__c>();
    private static List<NSIBPM__Step__c> createStepList = new List<NSIBPM__Step__c>();
    private static List<Group> createGroupList = new List<Group>();
    private static List<NSIBPM__SR_Status__c> createSrStatusList = new List<NSIBPM__SR_Status__c>(); 

    private static void init(){
        createSrTemplateList = InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});
        createSrStatusList = InitialiseTestData.createSrStatusRecords(new List<NSIBPM__SR_Status__c>{new NSIBPM__SR_Status__c(Name = 'Completed', NSIBPM__Code__c = 'Completed')});
        createServiceRequestList = 
            InitialiseTestData.createtestServiceRequestRecords(
                new List<NSIBPM__Service_Request__c>{
                    new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
                                                    NSIBPM__SR_Template__c = createSrTemplateList[0].Id)});
        createStatus = InitialiseTestData.createStatusRecords(
                new List<NSIBPM__Status__c>{
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_ADDITIONAL_INFO'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'MORE_INFO_UPDATED'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'DOCS_SENT', Name = 'DOCS_SENT'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'AWAITING_FFA_AA'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
        createStepList = InitialiseTestData.createTestStepRecords(
            new List<NSIBPM__Step__c>{
                new NSIBPM__Step__c(NSIBPM__SR__c = createServiceRequestList[0].id, NSIBPM__Status__c = createStatus[0].Id, NSIBPM__SR_Step__c = srStep.id),
                new NSIBPM__Step__c(NSIBPM__SR__c = createServiceRequestList[0].id, NSIBPM__Status__c = createStatus[1].Id, NSIBPM__SR_Step__c = srStep.id)});
        
        createStepTransitionList = 
            InitialiseTestData.createTransitionRecords(
                new List<NSIBPM__Transition__c> {new NSIBPM__Transition__c(NSIBPM__From__c = createStatus[1].Id, NSIBPM__To__c = createStatus[0].Id)});
        InitialiseTestData.createStepTransitionRecords(
            new List<NSIBPM__Step_Transition__c>{
                new NSIBPM__Step_Transition__c(NSIBPM__SR_Step__c = srStep.Id, NSIBPM__Transition__c = createStepTransitionList[0].Id, NSIBPM__SR_Status_Internal__c = createSrStatusList[0].Id, NSIBPM__SR_Status_External__c = createSrStatusList[0].Id)});
    }
    
    /*
    * Step Transition for a Community User  
    */
    static testMethod void testForCommunity() {
        init();
        PageReference pageRef = Page.NSI_Page_StepTransition;
        System.Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('Id', createServiceRequestList[0].Id);
        System.currentPageReference().getParameters().put('StepId', createStepList[1].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(createServiceRequestList[0]);
        NSI_Ctrl_StepTransitions controllerObject = new NSI_Ctrl_StepTransitions(sc);  
        controllerObject.userType = 'Community'; 
        controllerObject.Check_Permissions();
        controllerObject.selTransition = createStatus[0].Id;
        controllerObject.SaveChanges();
    }

    /*
    * Step Transition for a Salesforce User  
    */
     static testMethod void testForSalesforceUser() {
        init();
        PageReference pageRef = Page.NSI_Page_StepTransition;
        System.Test.setCurrentPageReference(pageRef);
        System.currentPageReference().getParameters().put('Id', createServiceRequestList[0].Id);
        System.currentPageReference().getParameters().put('StepId', createStepList[1].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(createServiceRequestList[0]);
        NSI_Ctrl_StepTransitions controllerObject = new NSI_Ctrl_StepTransitions(sc);   
        controllerObject.Check_Permissions();
        controllerObject.selTransition = createStatus[0].Id;
        controllerObject.SaveChanges();
    }

    /*
    * Step Transition for a Queue
    */
    static testMethod void testForQueue() {
        createGroupList = InitialiseTestData.createGroupRecords(new List<Group>{new Group()});
        QueueSobject testQueue = new QueueSObject(QueueId = createGroupList[0].Id, SobjectType = 'NSIBPM__Step__c');
        insert testQueue;
        List<User> userList = InitialiseTestData.createTestUserRecords(new List<User>{new User()});
        System.runAs(userList[0]) {
            init();
            createStepList[1].OwnerId = createGroupList[0].Id;
            update createStepList;
            PageReference pageRef = Page.NSI_Page_StepTransition;
            System.Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('Id', createServiceRequestList[0].Id);
            System.currentPageReference().getParameters().put('StepId', createStepList[1].Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(createServiceRequestList[0]);
            NSI_Ctrl_StepTransitions controllerObject = new NSI_Ctrl_StepTransitions(sc);   
            controllerObject.Check_Permissions();
            controllerObject.selTransition = createStatus[0].Id;            
            controllerObject.SaveChanges();
        }
    }
    
    
}