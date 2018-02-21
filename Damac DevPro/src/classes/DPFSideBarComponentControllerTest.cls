@isTest
private class DPFSideBarComponentControllerTest {
    
     public static testmethod void testSideBarController(){
         
         Page_Flow__c objPF = InitialiseTestData.createPageFlow();
        insert objPF;
        
        Page__c objPg1 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,1);
        insert objPg1 ;
        
         
         NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
        List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
        		new List<NSIBPM__Status__c>{
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_ADDITIONAL_INFO'),
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'MORE_INFO_UPDATED'),
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'AWAITING_FFA_AA'),
        			new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        
        List<NSIBPM__SR_Template__c> SRTemplateList =  InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});
        List<NSIBPM__Service_Request__c> SRList = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{
        			new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
        											NSIBPM__SR_Template__c = SRTemplateList[0].Id)});
        											
       Account agency1 = InitialiseTestData.getCorporateAccount('Agency1256');
       insert agency1; 
       
        Contact newCont = new Contact();
        newCont.LastName = 'Agency1256';
        newCont.AccountId = agency1.Id ;
        insert newCont ;  											
        											
       NSIBPM__Service_Request__c serviceRequestObject = SRList[0] ; 
       serviceRequestObject.NSIBPM__Customer__c = agency1.Id ;
       serviceRequestObject.Last_Name__c = 'test User' ;
       update serviceRequestObject ; 
       
       PageReference Process_Flow = Page.Process_Flow;
       Test.setCurrentPageReference(Process_Flow);
       Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
       Apexpages.currentPage().getParameters().put('Id',serviceRequestObject.Id);
       Apexpages.currentPage().getParameters().put('PageId',objPg1.Id);
       
       DPFSideBarComponentController cont = new DPFSideBarComponentController();
       cont.getLstPageWrap();
       cont.getStepPages();
       
       
         
     }
}