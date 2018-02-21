@isTest
private class DAMAC_UploadDocumentsTest {

    @testSetup static void setupData() {
        Page_Flow__c pf = new Page_Flow__c();
        pf.Name = 'Pre-Approval';
        pf.Flow_Description__c   = 'Pre-Approval - Company Formation';
        pf.Master_Object__c  = 'NSIBPM__Service_Request__c';
        pf.Record_Type_API_Name__c  = 'RAKFTZ_Pre_Approval';
        pf.Requirements__c = 'Test';
        insert pf;

        Page__c page = new Page__c();
        page.No_Quick_navigation__c = true;
        page.Is_Custom_Component__c = true; 
        page.Migration_Rec_Id__c  = '';
        page.Page_Description__c = 'PRE-APPROVAL FOR VISA SERVICES';
        page.Page_Flow__c = pf.id;
        page.Page_Order__c = 1;
        page.Page_Title__c = 'Package';
        
        page.Render_By_Default__c = true;
        page.VF_Page_API_Name__c = 'Process_Flow';
        page.What_Id__c = '';
        insert page;

        Section__c  sec = new Section__c();
        sec.Name = 'Section name';
        sec.Order__c = 1;
        sec.Section_Title__c = 'Sectoin title';
        sec.Section_Type__c = 'PageBlockSection';
        sec.Layout__c  = '2';
        sec.Page__c = page.Id;
        insert sec;
        
        Section_Detail__c sd = new Section_Detail__c();
        sd.Order__c = 1;
        sd.Name = 'Save';
        sd.Navigation_Directions__c = 'Forward';
        sd.Component_Label__c   = 'Save';
        sd.Component_Type__c = 'Command Button';
        sd.Section__c = sec.Id;
        insert sd;



         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;


        NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
        SR.NSIBPM__Customer__c  = a.Id;
        SR.NSIBPM__Email__c = 'test@nsigulf.com';
        SR.NSIBPM__Send_SMS_to_Mobile__c= '12123';
        SR.COUNTRY_OF_SALE__C = 'UAE';
        insert SR;


        Amendment__c amd = new Amendment__c();
        amd.Service_Request__c = SR.Id;
        insert amd;

        Amendment__c amd1 = new Amendment__c();
        amd1.Service_Request__c = SR.Id;
        insert amd1;
        
        NSIBPM__Document_Master__c Dm = new NSIBPM__Document_Master__c();
        Dm.Name = 'Test DM';
        Dm.NSIBPM__Code__c = 'Bank Statement';
        Dm.NSIBPM__Document_Type_Code__c = 'Doc Type';
        insert Dm;

        List<NSIBPM__SR_Doc__c> SRDoc_List = createSRDocs(SR.Id, Dm);

       


     }
     

     public static List<NSIBPM__SR_Doc__c> createSRDocs(Id SRId,NSIBPM__Document_Master__c Dm)
     {
        List<NSIBPM__SR_Doc__c> SRDoc_List = new List<NSIBPM__SR_Doc__c>();
        NSIBPM__SR_Doc__c SRDoc;
        for(Integer i=0;i<10;i++)
        {
           SRDoc = new NSIBPM__SR_Doc__c();
           SRDoc.Name = 'Test' + i;
           SRDoc.NSIBPM__Document_Master__c = Dm.Id;
           SRDoc.NSIBPM__Service_Request__c = SRId;
           SRDoc_List.add(SRDoc); 
        }
        insert SRDoc_List;
        return SRDoc_List;
     }

    @isTest static void test_method_one() {
        // Implement test code
        // 
        NSIBPM__Service_Request__c  SR = [Select Id from NSIBPM__Service_Request__c];
        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];
        List<Amendment__c> amdList = [Select Id from Amendment__c];
        List<NSIBPM__SR_Doc__c> SRDoc_List = [Select Id from NSIBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);
        
        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('Type','RAKFTZ_Pre_Approval');
        Process_Flow.getParameters().put('id',SR.Id);
        Process_Flow.getParameters().put('PageId',p.Id);
        Test.startTest();
        DAMAC_UploadDocuments cls = new DAMAC_UploadDocuments();
        cls.strObjectId = SR.Id;
        cls.strDocumentName = 'test';
        cls.FileName = 'Test';
        cls.AgrDocId  = 'testId';
        cls.strSRDocId = SRDoc_List[0].Id;
        cls.objSRDocEdit = SRDoc_List[0];
        cls.strError = 'Error';
        cls.strAttachmentName = 'strAttachmentName';
        cls.setstrObjectName('test');
        String str = cls.getstrObjectName();
        SRDoc_List[0].NSIBPM__Doc_ID__c = NULL;
        cls.PreviousPage();
        cls.NextPage();
        cls.Cancel();
        cls.docBody = 'TestBody';
        cls.Upload();
        Test.stopTest();


    }
    @isTest static void test_goTopage() {
        // Implement test code
        // 
        NSIBPM__Service_Request__c  SR = [Select Id from NSIBPM__Service_Request__c];
        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];
        List<Amendment__c> amdList = [Select Id from Amendment__c];
        List<NSIBPM__SR_Doc__c> SRDoc_List = [Select Id from NSIBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);
        
        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('Type','RAKFTZ_Pre_Approval');
        Process_Flow.getParameters().put('id',p.Id);
        Process_Flow.getParameters().put('PageId',p.Id);
        Test.startTest();
        DAMAC_UploadDocuments cls = new DAMAC_UploadDocuments();
        cls.FlowId  = pf.Id;
        cls.goTopage();
        Test.stopTest();

    }
    @isTest static void test_DynamicButtonAction() {
        // Implement test code
        // 
        NSIBPM__Service_Request__c  SR = [Select Id from NSIBPM__Service_Request__c];
        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];
        List<Amendment__c> amdList = [Select Id from Amendment__c];
        List<NSIBPM__SR_Doc__c> SRDoc_List = [Select Id from NSIBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);
        
        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('Type','RAKFTZ_Pre_Approval');
        Process_Flow.getParameters().put('id',p.Id);
        Process_Flow.getParameters().put('PageId',p.Id);
        Test.startTest();
        DAMAC_UploadDocuments cls = new DAMAC_UploadDocuments();
        cls.objSRFlow = SR;
        cls.strObjectId = SR.Id;
        cls.strActionId  = sd.Id;
        SRDoc_List[0].NSIBPM__Is_Not_Required__c = false;
        SRDoc_List[0].NSIBPM__Doc_ID__c  = NULL;
        update SRDoc_List[0];
        cls.DynamicButtonAction();
        Test.stopTest();

    }
    @isTest static void test_DyncPgMainPB() {
        // Implement test code
        // 
        NSIBPM__Service_Request__c  SR = [Select Id from NSIBPM__Service_Request__c];
        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];
        List<Amendment__c> amdList = [Select Id from Amendment__c];
        List<NSIBPM__SR_Doc__c> SRDoc_List = [Select Id from NSIBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);
        
        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('Type','RAKFTZ_Pre_Approval');
        Process_Flow.getParameters().put('id',p.Id);
        Process_Flow.getParameters().put('PageId',p.Id);
        Test.startTest();
        DAMAC_UploadDocuments cls = new DAMAC_UploadDocuments();
        
        cls.getDyncPgMainPB();
        cls.getDyncPgMainPBBottom();
        cls.Back_To_SR();
        cls.AgrDocId = SRDoc_List[0].Id;
        cls.EditDoc();
        cls.SaveDoc();

        Test.stopTest();

    }
    
}