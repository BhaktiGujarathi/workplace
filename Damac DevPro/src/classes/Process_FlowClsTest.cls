@isTest
private class Process_FlowClsTest {
    
    @isTest static void test_method_one() {
        //try{
        List<Account_SR_Field_Mapping__c> lstCS = new List<Account_SR_Field_Mapping__c>();
        
        Account_SR_Field_Mapping__c CS  = new Account_SR_Field_Mapping__c();
        CS.Name = 'Account_Details_Country__c';
        CS.SR_Field__c ='Account_Details_Country__c';
        CS.RecordType_Name__c = 'Agent_Update';
        CS.Account_Field__c = 'Bank_Country__c';
        lstCS.add(CS);
        
        Account_SR_Field_Mapping__c CS1  = new Account_SR_Field_Mapping__c();
        CS1.Name = 'Account_Details_Country__c1';
        CS1.SR_Field__c ='Account_Details_Country__c';
        CS1.RecordType_Name__c = 'Corporate_Agency';
        CS1.Account_Field__c = 'Bank_Country__c';
        lstCS.add(CS1);
        //insert lstcs;
        
        Account_SR_Field_Mapping__c CS2  = new Account_SR_Field_Mapping__c();
        CS2.Name = 'Account_Details_Country__c2';
        CS2.SR_Field__c ='Account_Details_Country__c';
        CS2.RecordType_Name__c = 'Agent_Registration';
        CS2.Account_Field__c = 'Bank_Country__c';
        lstCS.add(CS2);
        insert lstcs;


        Account acc = InitialiseTestData.getCorporateAccount('Acc-21');
        insert acc ; 

        List<Contact> conList = new List<Contact>();
        Contact con = InitialiseTestData.getCorporateAgencyContact('Process Flow Agency');
        conList.add(con);
        insert conList ; 

        User portalUser  = InitialiseTestData.getPortalUser('portalIdDamac@test.com',con.Id);
        insert portalUser ; 

        
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
        
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
            new List<NSIBPM__Step__c>{
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[0].Id, NSIBPM__SR_Step__c = srStep.id),
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[1].Id, NSIBPM__SR_Step__c = srStep.id)});
                    

        NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
        SR.NSIBPM__Customer__c = acc.Id;
        SR.NSIBPM__Send_SMS_to_Mobile__c = '009715262000';
        SR.NSIBPM__Email__c = 'pavithra@nsigulf.com';
        sr.country_of_sale__c = 'UAE';
        sr.Agency_Type__c = 'Individual';
        sr.ID_Type__c = 'National ID';
        sr.Eligible_to_Sell_in_Dubai__c = true;
        insert SR;
        
        SRTemplateList[0].NSIBPM__SR_RecordType_API_Name__c = 'Agent_Registration';
        update SRTemplateList[0];
        
        DM_List[0].NSIBPM__Code__c = 'PASSPORT_COPY';
        update DM_List[0];
        
        DM_List[1].NSIBPM__Code__c = 'VISA_COPY';
        update DM_List[1];
        
        DM_List[2].NSIBPM__Code__c = 'BROKER_CARD';
        update DM_List[2];
        
        DM_List[3].NSIBPM__Code__c = 'NATIONAL_ID_COPY';
        update DM_List[3];
        
        NSIBPM__SR_Template_Docs__c SrTemplateDoc1 = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc1.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc1.NSIBPM__Document_Master__c = DM_List[0].Id;
        SrTemplateDoc1.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc1.NSIBPM__On_Submit__c = true;        
        insert SrTemplateDoc1;
        
        NSIBPM__SR_Template_Docs__c SrTemplateDoc2 = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc2.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc2.NSIBPM__Document_Master__c = DM_List[1].Id;
        SrTemplateDoc2.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc2.NSIBPM__On_Submit__c = true;        
        insert SrTemplateDoc2;
        
        NSIBPM__SR_Template_Docs__c SrTemplateDoc3 = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc3.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc3.NSIBPM__Document_Master__c = DM_List[2].Id;
        SrTemplateDoc3.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc3.NSIBPM__On_Submit__c = true;        
        insert SrTemplateDoc3;
        
        NSIBPM__SR_Template_Docs__c SrTemplateDoc4 = new NSIBPM__SR_Template_Docs__c();
        SrTemplateDoc4.NSIBPM__SR_Template__c = SRTemplateList[0].Id;
        SrTemplateDoc4.NSIBPM__Document_Master__c = DM_List[3].Id;
        SrTemplateDoc4.NSIBPM__Added_through_Code__c = true;
        SrTemplateDoc4.NSIBPM__On_Submit__c = true;        
        insert SrTemplateDoc4;
        
        Page_Flow__c objPF = InitialiseTestData.createPageFlow();
        insert objPF;
        
        Page__c objPg1 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,1);
        insert objPg1;

        Page__c objPg2 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,2);
        insert objPg2;

        Page__c objPg3 = InitialiseTestData.createPageForPageFlow('Process_Flow',objPF.Id,3);
        insert objPg3;

        Page__c objPg4 = InitialiseTestData.createPageForPageFlow('DAMAC_CompanyPersonnel',objPF.Id,4);
        insert objPg4;

        Page__c objPg5 = InitialiseTestData.createPageForPageFlow('DAMAC_UploadDocuments',objPF.Id,5);
        insert objPg5;

        Page__c objPg6 = InitialiseTestData.createPageForPageFlow('DAMAC_ConfirmRequest',objPF.Id,6);
        insert objPg6;

        Section__c objSec =  InitialiseTestData.createSection('PageblockSection',1,objPg1.Id);
        insert objSec;

        Section__c buttonSec =  InitialiseTestData.createSection('CommandButtonSection',1,objPg1.Id);
        insert buttonSec;

        Section_Detail__c objSecDet = InitialiseTestData.createSectionDetail(objSec.Id,'Agency_Name__c','Input Field');
        insert objSecDet ;

        Section_Detail__c objSecDet1 = InitialiseTestData.createSectionDetail(objSec.Id,'Trade_License_Number__c','Input Field');
        insert objSecDet1 ;

        Section_Detail__c objSecDet2 = InitialiseTestData.createSectionDetail(objSec.Id,'Date_of_Incorporation__c','Input Field');
        insert objSecDet2 ;

        Section_Detail__c objSecDet3 = InitialiseTestData.createSectionDetail(objSec.Id,'Country_of_Incorporation__c','Input Field');
        insert objSecDet3 ;

        Section_Detail__c objSecDet4 = InitialiseTestData.createSectionDetail(objSec.Id,'Agency_Name_Arabic__c','Input Field');
        insert objSecDet4 ;

        Section_Detail__c objSecDet5 = InitialiseTestData.createSectionButton(buttonSec.Id,'Command Button');
        insert objSecDet5 ;

        PageReference Process_Flow = Page.Process_Flow;
       Test.setCurrentPageReference(Process_Flow);
       Process_Flow.getParameters().put('FlowId',objPF.Id);
       Process_Flow.getParameters().put('Type','Agent_Registration');
       Process_Flow.getParameters().put('Id',SR.Id);
       Process_Flow.getParameters().put('PageId',objPg1.Id);
       
        Section_Detail__c SaveBtn = new Section_Detail__c();
        SaveBtn.Section__c = buttonSec.Id;
        SaveBtn.Order__c = 3;
        SaveBtn.Button_Position__c = 'Center';
        SaveBtn.Navigation_Directions__c = 'Previous';
        SaveBtn.Render_By_Default__c = true;
        SaveBtn.Component_Type__c = 'Command Button';
        SaveBtn.Component_Label__c = 'Client';
        SaveBtn.Cancel_Request__c = true;
        insert SaveBtn;
        
        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg2.Id;
        objNextAct.Section_Detail__c = SaveBtn.Id;
        objNextAct.S_No__c = 1;
        insert objNextAct;

        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = buttonSec.Id;
        SecRenRule1.Section_Detail__c = SaveBtn.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Rule_Text_Condition__c = 'NSIBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;
        
        
        Page_Navigation_Rule__c objPNR = new Page_Navigation_Rule__c();
        objPNR.Page__c = objPg3.Id;
        objPNR.Rule_Name__c = 'Test';
        objPNR.Rule_Text_Condition__c = 'NSIBPM__Service_Request__c->Name#!=#Null';
        objPNR.Rule_Condition__c = '1';
        insert objPNR;
        
        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section_Detail__c = SaveBtn.Id;
        objCon.Field_Name__c = 'Name';
        objCon.Object_Name__c = 'NSIBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;
        
        // 1.0
        System.runAs(portalUser){                

                       
        }
            Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
            Apexpages.currentPage().getParameters().put('Id',SR.Id);
            Apexpages.currentPage().getParameters().put('PageId',objPg1.Id);
            
            
            Process_FlowCls objPageFlowcls = new Process_FlowCls();
            objPageFlowcls.prePopulateServiceRequest(SR ,acc.Id,'Corporate_Agency');
            update objPageFlowcls.objSR;
    
            objPageFlowcls.getDyncPgMainPB();
            objPageFlowcls.RePrepareSection();
            objPageFlowcls.getClass();
            objPageFlowcls.stringActionId = SaveBtn.Id;
            objPageFlowcls.DynamicButtonAction();
            objPageFlowcls.strNavigatePageId = objPg2.Id;
            objPageFlowcls.goTopage();
            objPageFlowcls.Redirect_DefaultCustomPage();
            //objPageFlowcls.CommitRecord();
            objPageFlowcls.CancelSR();
            objPageFlowcls.prepare_Page_Description();
            
            
            PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg1.Id;
        PreparePageBlockUtil.PageName = 'Primary Information';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg2.Id;
        PreparePageBlockUtil.ActionId = SaveBtn.Id;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = 'Test Process Flow';
            
        PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg1.Id);
            
        PreparePageBlockUtil objPBU = new PreparePageBlockUtil();
            
        PreparePageBlockUtil.PageName = 'Instructions Page';
        
        PreparePageBlockUtil.PageId = objPg1.Id;
        objPBU.getReviewFinalisePB();
        objPBU.getDyncPgMainPB();

        objPBU.getButtonAction();
        objPBU.getBottomButtonsPB();
        objPBU.getSideBarReference();
            
        PreparePageBlockUtil.getHiddenPageIds(objPF.Id,SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg5.Id);
            
        PreparePageBlockUtil.PageName = 'Value Added Services';
        
        PreparePageBlockUtil.PageId = objPg2.Id;
        objPBU.getReviewFinalisePB();
        objPBU.getDyncPgMainPB();

        PreparePageBlockUtil.ActionId = SaveBtn.Id;
        objPBU.getButtonAction();

        objPBU.getSideBarReference();
        // 1.0
        PreparePageBlockUtil.PageName = 'Primary Information';
        
        PreparePageBlockUtil.PageId = objPg2.Id;
        objPBU.getReviewFinalisePB();
        objPBU.getDyncPgMainPB();

        PreparePageBlockUtil.ActionId = SaveBtn.Id;
        objPBU.getConfirmationPB();
        objPBU.getButtonsPB();
        objPBU.getTopButtonsPB();
        objPBU.getButtonAction();
        objPBU.getBottomButtonsPB();
        objPBU.getSideBarReference();
        
        PreparePageBlockUtil.Cancel_SR(null);
        PreparePageBlockUtil.Cancel_Open_SR(SR.Id);
        
        //}catch(exception ex){}
    }
    
}