@isTest
private class DAMAC_CompanyPersonnelUpdateCntlrTest {
    
     @isTest static void test_method_one() {
        Test.startTest();
        Page_Flow__c pageFlow1 = InitialiseTestData.createPageFlow();
        insert pageFlow1 ;

        Page__c page1 = InitialiseTestData.createPageForPageFlow('Process_Flow',pageFlow1.Id,1);
        insert page1;

        List<NSIBPM__SR_Template__c> SRTemplateList =  InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});

        List<NSIBPM__Service_Request__c> SRList  = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{
                    new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
                                                    NSIBPM__SR_Template__c = SRTemplateList[0].Id)});
                                                    
        NSIBPM__Service_Request__c serviceRequest = SRList[0];
        List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
                new List<NSIBPM__Status__c>{
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_ADDITIONAL_INFO'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'MORE_INFO_UPDATED'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'AWAITING_FFA_AA'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
        Account agency1 = InitialiseTestData.getCorporateAccount('Agency129');
        insert agency1; 
        
        Contact newCont = new Contact();
        newCont.LastName = 'Agency129';
        newCont.AccountId = agency1.Id ;
        insert newCont ; 
        
        User portalUser  = InitialiseTestData.getPortalUser('portalIdDamac1@test.com',newCont.Id);
        insert portalUser ; 
        
        
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
            new List<NSIBPM__Step__c>{
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[0].Id, NSIBPM__SR_Step__c = srStep.id),
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[1].Id, NSIBPM__SR_Step__c = srStep.id)});

        List<Amendment__c> amdList = new List<Amendment__c>();
       for(integer i=0;i<5;i++){
           Amendment__c newAmd =  new Amendment__c();
           if(i==0){
               newAmd.Owner__c = true;
               newAmd.Shareholding__c =100;
           }
           newAmd.Authorised_Signatory__c = true;
           newAmd.Agent_Representative__c =true;
           newAmd.Portal_Administrator__c = true;
           newAmd.Email__c ='test'+i+'@test.com';
           newAmd.ID_Type__c = 'Visa';
           amdList.add(newAmd);           
       }
       
       insert amdList;
       
        List<NSIBPM__Document_Master__c> DM_List = InitialiseTestData.createSRDocMasterRecords(5);
        NSIBPM__SR_Template_Docs__c SrTemplateDoc = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc.NSIBPM__Document_Master__c = DM_List[0].Id;
        SrTemplateDoc.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc.NSIBPM__On_Submit__c = true;
        insert SrTemplateDoc;
        
         Amendment__c newAmd1 =  new Amendment__c();
           newAmd1.Authorised_Signatory__c = true;
           newAmd1.Agent_Representative__c =true;
           newAmd1.Portal_Administrator__c = true;
           newAmd1.Email__c ='test34@test.com';
           newAmd1.ID_Type__c = 'Visa';
           insert newAmd1 ;
           
        Section__c sec = new Section__c();
        sec.page__c = page1.id;
        insert sec;
        
        Section_Detail__c d = new Section_Detail__c();
        d.section__c = sec.id;
        d.Navigation_Directions__c = 'Forward';
        insert d;

        Test.setCurrentPageReference(new PageReference('Page.Process_Flow')); 
        System.currentPageReference().getParameters().put('Type', 'Agent_Registration');
        System.currentPageReference().getParameters().put('FlowId', String.valueOf(pageFlow1.Id));
        System.currentPageReference().getParameters().put('PageId', String.valueOf(page1.Id));
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(serviceRequest);
        DAMAC_CompanyPersonnelUpdateCntlr updatePage = new DAMAC_CompanyPersonnelUpdateCntlr(sc);
        
        updatePage.currAmdId = newAmd1.Id ;
        updatePage.getAllAmendments();
         updatePage.createAmd();
        updatePage.editAmd();
        updatePage.cancel();
        updatePage.init();
        updatePage.save();
        updatePage.createDocuments(amdList[0]);
        updatePage.deleteSRDocs(amdList[0],'Upsert');
        updatePage.deleteSRDocs(amdList[0],'Edit');
        updatePage.validateAmendment(amdList[0]); 
        updatePage.createSRDoc('Test Doc',SrTemplateDoc,amdList[0].Id);
        updatePage.disableContact(newCont.Id,amdList[0]);
        updatePage.validateAmendment(amdList[0]);
         updatePage.deleteAmd();
         updatePage.strNavigatePageId = page1.id;
         updatePage.goTopage();
         updatePage.EditSectionDetails();
         updatePage.strActionId = d.id;
         updatePage.DynamicButtonAction();
         updatePage.getDyncPgMainPBBottom();
         updatePage.getDyncPgMainPBSection();
        updatePage.getDyncPgMainPB(); 
        Test.stopTest();
    }
    

}