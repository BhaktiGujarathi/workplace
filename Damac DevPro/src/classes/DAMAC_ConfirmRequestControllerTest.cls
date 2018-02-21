@isTest
private class DAMAC_ConfirmRequestControllerTest {
    
    static Account acc ; 
    static Amendment__c amendment ;
    static NSIBPM__Service_Request__c serviceRequest ; 
    
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
        serviceRequest = SRList[0];
        List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
            new List<NSIBPM__Status__c>{
                new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_ADDITIONAL_INFO'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'MORE_INFO_UPDATED'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'AWAITING_FFA_AA'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
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
        
        Page_Flow__c objPF = InitialiseTestData.createPageFlow();
        insert objPF;
        
        Page__c objPg1 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,1);
        insert objPg1;
        
        List<Section__c> lstsec = new list<Section__c>();
        lstsec.add(InitialiseTestData.createSection('PageblockSection',1,objPg1.Id));
        insert lstsec;
        Section_Detail__c secdetail = new Section_Detail__c(Navigation_Directions__c = 'Forward',Section__c = lstsec[0].id);
        insert secdetail;
        
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);
        Process_Flow.getParameters().put('FlowId',pageFlow1.Id);
        Process_Flow.getParameters().put('Type','Agent_Registration');
        Process_Flow.getParameters().put('Id',serviceRequest.Id);
        Process_Flow.getParameters().put('PageId',page1.Id);
        
        
        NSIBPM__SR_Status__c srst = new NSIBPM__SR_Status__c();
        srst.name = 'Submitted';
        srst.NSIBPM__Code__c = 'Submitted';
        insert srst;
        
        DAMAC_ConfirmRequestController confirmPage = new DAMAC_ConfirmRequestController();
        confirmpage.strNavigatePageId = page1.Id;
        confirmPage.goTopage();
        confirmPage.EditSectionDetails();
        confirmPage.getDyncPgMainPB();
        confirmPage.getDyncPgMainPBSection();
        confirmPage.getDyncPgMainPBBottom();
        confirmPage.DynamicButtonAction();
        confirmPage.strActionId = secdetail.id;
        confirmPage.DynamicButtonAction();
        
        //confirmPage.CommitRecord();
        Test.stopTest();
    }
    
    @isTest static void test_method_three() {
        Test.startTest();
        
        Page_Flow__c objPF = InitialiseTestData.createPageFlow();
        insert objPF;
        
        Page__c objPg1 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,1);
        insert objPg1;
        
        List<Section__c> lstsec = new list<Section__c>();
        lstsec.add(InitialiseTestData.createSection('PageblockSection',1,objPg1.Id));
        insert lstsec;
        
        set<string> stFieldAPI = new set<string>{'agency_short_name__c','date_of_incorporation__c','country_of_incorporation_new__c',
            'city_of_incorporation_new__c','iban_ifsc_swift_sort__c','p_o_box_zip_postal_code__c','trade_license_expiry_date__c','trade_license_number__c','agency_type__c','orn_number__c','rera_expiry_date__c','p_o_box_no__c','zip_postal_code__c','iban_number__c','ifsc_code__c','swift_code__c','sort_code__c','first_name__c',
            'last_name__c','id_type__c','id_expiry_date__c','id_number__c','nationality__c','broker_card_number__c','broker_card_expiry_date__c','agency_name__c','id_issue_date__c'};
                List<Section_Detail__c> lstsecDetails = new List<Section_Detail__c>();
        
        NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
        sr.Agency_Type__c = 'Corporate';
        sr.Trade_License_Number__c = 'test';
        insert sr;
        
        for(string strFld : stFieldAPI){
            Section_Detail__c secDetails = new Section_Detail__c();
            secDetails.Field_API_Name__c = strFld;
            secDetails.Section__c = lstsec[0].id;
            secDetails.Mark_it_as_Required__c = true;
            secDetails.Component_Type__c = 'Input Field';
            lstsecDetails.add(secDetails);
        }
        insert lstsecDetails;
        
        
        PageReference Process_Flow = Page.DAMAC_ConfirmRequest;
        Test.setCurrentPageReference(Process_Flow);
        Process_Flow.getParameters().put('FlowId',objPF.Id);
        Process_Flow.getParameters().put('Id',sr.Id);
        
        DAMAC_ConfirmRequestController confirmPage = new DAMAC_ConfirmRequestController();
        confirmPage.CheckforMandatoryFields();
        
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        Test.startTest();
        
        Page_Flow__c objPF = InitialiseTestData.createPageFlow();
        insert objPF;
        
        Page__c objPg1 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,1);
        insert objPg1;
        
        List<Section__c> lstsec = new list<Section__c>();
        lstsec.add(InitialiseTestData.createSection('PageblockSection',1,objPg1.Id));
        insert lstsec;
        
        set<string> stFieldAPI = new set<string>{'agency_short_name__c','date_of_incorporation__c','country_of_incorporation_new__c',
            'city_of_incorporation_new__c','iban_ifsc_swift_sort__c','p_o_box_zip_postal_code__c','trade_license_expiry_date__c','trade_license_number__c','agency_type__c','orn_number__c','rera_expiry_date__c','p_o_box_no__c','zip_postal_code__c','iban_number__c','ifsc_code__c','swift_code__c','sort_code__c','first_name__c',
            'last_name__c','id_type__c','id_expiry_date__c','id_number__c','nationality__c','broker_card_number__c','broker_card_expiry_date__c','agency_name__c','id_issue_date__c'};
                List<Section_Detail__c> lstsecDetails = new List<Section_Detail__c>();
        
        NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
        insert sr;
        for(string strFld : stFieldAPI){
            Section_Detail__c secDetails = new Section_Detail__c();
            secDetails.Field_API_Name__c = strFld;
            secDetails.Section__c = lstsec[0].id;
            secDetails.Mark_it_as_Required__c = true;
            secDetails.Component_Type__c = 'Input Field';
            lstsecDetails.add(secDetails);
        }
        insert lstsecDetails;
        PageReference Process_Flow = Page.DAMAC_ConfirmRequest;
        Test.setCurrentPageReference(Process_Flow);
        Process_Flow.getParameters().put('FlowId',objPF.Id);
        Process_Flow.getParameters().put('Id',sr.Id);
        
        DAMAC_ConfirmRequestController confirmPage = new DAMAC_ConfirmRequestController();
        confirmPage.CheckforMandatoryFields();
        
        try{
            confirmPage.CommitRecord();
        }catch(exception ex){
            
        }
        Test.stopTest();
    }
    
    
}