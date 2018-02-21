@isTest
private class CC_Step_AssignmentTest {
    
    public testMethod static void  assignStepsBPM(){
        
        List<NSIBPM__SR_Template__c> SRTemplateList =  InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});

        List<NSIBPM__Document_Master__c> DM_List = InitialiseTestData.createSRDocMasterRecords(5);
        NSIBPM__SR_Template_Docs__c SrTemplateDoc = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc.NSIBPM__Document_Master__c = DM_List[0].Id;
        SrTemplateDoc.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc.NSIBPM__On_Submit__c = true;
        insert SrTemplateDoc;
        
        List<NSIBPM__Service_Request__c> SRList = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{
        			new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
        											NSIBPM__SR_Template__c = SRTemplateList[0].Id)});
        InitialiseTestData.createSRDocRecords(SRList, DM_List);
       
        NSIBPM__Service_Request__c newSR = [Select Id,NSIBPM__Record_Type_Name__c,recordtype.developername,NSIBPM__Customer__c from NSIBPM__Service_Request__c Where recordtype.developername = 'Agent_Registration' Limit 1 ];
       
         List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
        		new List<NSIBPM__Status__c>{
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_ADDITIONAL_INFO'),
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'MORE_INFO_UPDATED'),
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'REQUESTED_FOR_INFO', Name = 'REQUESTED_FOR_INFO'),
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        			
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        Map<String,NSIBPM__SR_Steps__c> mapSRSteps = new Map<String,NSIBPM__SR_Steps__c>();
        mapSRSteps.put('Test',srStep);
        
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
        	new List<NSIBPM__Step__c>{
        		new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[0].Id, NSIBPM__SR_Step__c = srStep.id),
        		new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[1].Id, NSIBPM__SR_Step__c = srStep.id)});
        Map<String,NSIBPM__Step__c> mapSteps = new Map<String,NSIBPM__Step__c>();
        mapSteps.put('Test',createStepList[0]);
        		
        Map<String,NSIBPM__Service_Request__c> mapSRs = new Map<String,NSIBPM__Service_Request__c>();
        mapSRs.put('Test',SRList[0]);
        
        CC_Step_Assignment ccStepAssignment = new CC_Step_Assignment();
        ccStepAssignment.Assign_Step_Owner_SR_Submit(mapSRs,createStepList,mapSRSteps);
        ccStepAssignment.Assign_Step_Owner_Step_Closure(mapSteps,createStepList,mapSRSteps);
        		
    
    }
    
    

}