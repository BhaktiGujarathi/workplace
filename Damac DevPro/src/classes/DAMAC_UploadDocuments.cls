global without sharing class DAMAC_UploadDocuments{

    /* Start of Properties for Dynamic Flow */
        public boolean isProcessFlow{get;set;}
        public string strPageId{get;set;}
        public string strActionId{get;set;}
        public map<string,string> mapParameters;
        public NSIBPM__Service_Request__c objSRFlow{get;set;}
        public string strHiddenPageIds{get;set;}
        public boolean isGuestUser {get;set;}
    	public boolean isCommunity{get;set;}
        public string FlowId;
        public string SerReqId;
        public string ActionId;
        public string PageTitle{get;set;}
    /* End of Properties for Dynamic Flow */
    
    /*Global Declaration*/            
        public Attachment document{get;set;}
        public boolean isPortalUser{get;set;}
        public list<NSIBPM__SR_Doc__c> ltGeneratedDocs{get;set;}
        public string DocIDs='';
        string FrameDisplay='None';
        string ImgDisplay='None';
        string displayTable='block';
        string DocumentID='';
        string Imagesrc;
        string dvDocsVisibility='';
        boolean blnDisableControls=false;
        list<Attachment> lstDoc; 
        list<SelectOption> lstFolderList = new list<SelectOption>(); 
        public string strObjectId {get; set;}
        string strObjectName='';
        public NSIBPM__SR_Doc__c objSRDoc{get;set;}
        public string strLastDocId{get;set;}
        public string strLastDocName{get;set;}
        public NSIBPM__SR_Doc__c objRelatedAttach{get;set;}
        public string strDocumentName{get;set;}
        public string FileName{get;set;}
        public string AgrDocId{get;set;}
        public string strSRDocId{get;set;}
        public string userType{get;set;}
        public NSIBPM__SR_Doc__c objSRDocEdit{get;set;}
        public string strError{get;set;}
        public string strComments{get;set;}
        public string strExternalComments{get;set;}
        public string strAttachmentName{get;set;}
        public set<id> setsrids{get;set;}
        public string thumbBase64 {get;set;}
        public void setstrObjectName(string value){
            strObjectName=value;
        }
        public string getstrObjectName(){
            return strObjectName;
        }
        
        public list<NSIBPM__SR_Doc__c> lstDocPreviewSlide{get;set;}
        public Boolean firstOff{set;get;}    // previous part
        public Boolean lastOff{set;get;}     // next part

        public boolean showHeaderAndSidebar{set;get;} //DAMAC Change

        public boolean isEditable{set;get;} //DAMAC Change
    	public boolean isDocEditable{set;get;}
    /* End of Global Declarations*/
       
       /*
            Construtor Definition:- DocumentViewer()
            This constructor is used to gets the Id of the Object from the current page reference and assigns it to the local variable        
       */
       public DAMAC_UploadDocuments(){
           firstOff = false;
           lastOff = false;
           isCommunity = false;
           isGuestUser = false;
           lstDocPreviewSlide = new list<NSIBPM__SR_Doc__c>();
           offsetVal = 0;
           /* Start of Properties Initialization for Dynamic Flow */
           setsrids = new set<id>();
           objSRDoc = new NSIBPM__SR_Doc__c();
           document = new Attachment();
           ltGeneratedDocs = new list<NSIBPM__SR_Doc__c>();
           isPortalUser = true;
           strComments = '';
           strExternalComments = '';
           userType = 'salesforce';
           MapParameters = apexpages.currentpage().getParameters();
           
           userType = 'Community';
           isPortalUser = true;
           for(User objUsr:[select id,Profile.UserLicense.name,ContactId,Contact.Email,Contact.AccountId,Contact.FirstName,Contact.LastName,Contact.Account.Website from User where Id=:userinfo.getUserId()]){
               if(objUsr.Profile.UserLicense.name == 'Guest User License'){
                   isGuestUser = true;
               }
               else{
                   if(objUsr.ContactId!=null)
                       isCommunity = true;
               }
           }
           
           if(apexpages.currentpage().getParameters().get('Id')!=null){
                strObjectId = string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id'));
                if(MapParameters.get('FlowId')!=null && MapParameters.get('FlowId')!=''){
                    for(Page_Flow__c pf:[Select Id,Name from Page_Flow__c where Id=:MapParameters.get('FlowId')]){
                        PageTitle = pf.Name;
                    }
                    
                }
                set<string> SetstrFields = Cls_Evaluate_Conditions.FetchObjectFields(MapParameters.get('FlowId'),'NSIBPM__Service_Request__c');
                string strQuery = 'select Id';
                if(SetstrFields==null || (SetstrFields!=null && SetstrFields.size()==0))
                    SetstrFields = new set<string>();
                    SetstrFields.add('nsibpm__customer__c');
                    SetstrFields.add('is_flow_request__c');
                    SetstrFields.add('filled_page_ids__c');
                    SetstrFields.add('recordtypeid');
                    SetstrFields.add('nsibpm__record_type_name__c');
                    SetstrFields.add('name');
                    SetstrFields.add('nsibpm__internal_status_name__c');
               		SetstrFields.add('Document_Generated__c');
                    
                //building the query
                for(String strFld:SetstrFields){
                    if(strFld.toLowerCase()!='id')
                        strQuery += ','+strFld.toLowerCase();
                }
                strQuery = strQuery+' from NSIBPM__Service_Request__c where Id=:strObjectId';
                for(NSIBPM__Service_Request__c SR:database.query(strQuery)){
                    objSRFlow = SR;
                }  
               strHiddenPageIds = PreparePageBlockUtil.getHiddenPageIds(mapParameters.get('FlowId'), objSRFlow);
               
           }
           if(strObjectId!=null)
                setsrids.add(strObjectId);
           PrepareGenDocs();
           retriveDocument();//calling the Retrieve document method to retrieve the documents of the object if exist on page load
           objRelatedAttach = new NSIBPM__SR_Doc__c();
           Prepare_Preview_Documents();

           //DAMAC Change
         if(MapParameters.get('FlowId') != NULL && MapParameters.get('FlowId') != ''){
            showHeaderAndSidebar = (MapParameters.get('FlowId') == UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Page_Flow_Name))?false:true;
         if(!showHeaderAndSidebar){
                if(!isGuestUser && !isCommunity){
                    showHeaderAndSidebar = true;
                }
            }
         }
          	isEditable = true;
             isDocEditable = true;
             //Draft,RI,Doc Rejected --> SR editable but if during Registration doc generated checkbox is selected when its in RI or Rejected
             //Fields should be locked and upload doc unlock
             if(NULL != objSRFlow && null != objSRFlow.nsibpm__internal_status_name__c &&
                (objSRFlow.nsibpm__internal_status_name__c != 'Draft' && objSRFlow.nsibpm__internal_status_name__c != 'Requested for Info' && 
                objSRFlow.nsibpm__internal_status_name__c != 'Document Rejected' && (objSRFlow.nsibpm__record_type_name__c == 'Agent_Update' && 
                  objSRFlow.nsibpm__internal_status_name__c != 'Awaiting FFA/AA'))){
                isEditable = false;
                isDocEditable = false;
             }
             else if((NULL != objSRFlow && null != objSRFlow.nsibpm__internal_status_name__c 
                  && (objSRFlow.nsibpm__record_type_name__c == 'Agent_Registration' || 
                      objSRFlow.nsibpm__record_type_name__c == 'Agent_Update')  &&
                (objSRFlow.nsibpm__internal_status_name__c == 'Requested for Info' || 
                 objSRFlow.nsibpm__internal_status_name__c == 'Document Rejected' || 
                 (objSRFlow.nsibpm__record_type_name__c == 'Agent_Update' && 
                  objSRFlow.nsibpm__internal_status_name__c == 'Awaiting FFA/AA'))
                      && objSRFlow.Document_Generated__c)){
                 isEditable = false;
                 isDocEditable = true;    
             }
           if(!isEditable){
                 isEditable = SRUtility.isUserwithEditPermissions();
             }

         System.debug('***isEditable'+isEditable);
         System.debug('***isDocEditable'+isDocEditable);
        }
        
        public integer offsetVal{get;set;}
        public integer TotalListSize{get;set;}
        public pagereference Prepare_Preview_Documents(){
            TotalListSize = 0;
            lstDocPreviewSlide = new list<NSIBPM__SR_Doc__c>();
            if(strObjectId!=null && strObjectId!=''){
                for(NSIBPM__SR_Doc__c doc:[select Id,Name,NSIBPM__Doc_ID__c,NSIBPM__Doc_Type__c from NSIBPM__SR_Doc__c where NSIBPM__Doc_ID__c!=null and NSIBPM__Service_Request__c=:strObjectId and isDeleted=false order by LastModifiedDate desc limit 1 offset:offsetVal]){
                    lstDocPreviewSlide.add(doc);
                }
                for(NSIBPM__SR_Doc__c doc:[select Id,Name,NSIBPM__Doc_ID__c,NSIBPM__Doc_Type__c from NSIBPM__SR_Doc__c where NSIBPM__Doc_ID__c!=null and NSIBPM__Service_Request__c=:strObjectId and isDeleted=false order by CreatedDate asc]){
                    TotalListSize = TotalListSize + 1;
                }
                if(TotalListSize!=null && TotalListSize>1) 
                    lastOff = true;
                else 
                    lastOff = false;
            }
            return null;
        }
        public void PreviousPage(){
            lstDocPreviewSlide = new list<NSIBPM__SR_Doc__c>();
            if(offsetVal-1 <= 0){
                offsetVal = 0;
                firstOff = false;
            }else{
                offsetVal -= 1;
            }
            lastOff = true;
            Prepare_Preview_Documents();
        }
        public void NextPage(){
            lstDocPreviewSlide = new list<NSIBPM__SR_Doc__c>();
            offsetVal += 1;
            if(offsetVal>2000){
                offsetVal=2000;
            }
            firstOff = true;
            Prepare_Preview_Documents();
            if(TotalListSize!=null && TotalListSize>0){
                if(offsetVal+1>=TotalListSize) 
                    lastOff = false;
                firstOff = true;
            }else{
                firstOff = false;
                lastOff = false;
            }
        }
    
        public void PrepareGenDocs(){
            ltGeneratedDocs = new list<NSIBPM__SR_Doc__c>();
            if(setsrids!=null && setsrids.size()>0){
                ltGeneratedDocs = [select id,createddate,lastmodifieddate,NSIBPM__Doc_Type__c,NSIBPM__Is_Not_Required__c,NSIBPM__Requirement__c,NSIBPM__Document_Description_External__c,NSIBPM__Preview_Download_Document__c,NSIBPM__Service_Request__c,NSIBPM__Service_Request__r.NSIBPM__Internal_Status_Name__c,name,NSIBPM__Doc_ID__c,NSIBPM__Received_Physically__c,NSIBPM__Customer_Comments__c,NSIBPM__Comments__c,NSIBPM__Document_Type__c,NSIBPM__Original_Verified__c,NSIBPM__Rejection_Reason__c,NSIBPM__Status__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c IN:setsrids and NSIBPM__Sys_IsGenerated_Doc__c=true and IsDeleted=false order by CreatedDate asc];
            } 
        }
        
       /*
         Method Definition:- cancel()
         This is used to cancel the operation          
       */ 
       public void Cancel() {
            document = new Attachment();
       }
       /*
         * Method Definition:- upload()
         * This is used to Upload the document into the document object and related documents custom object.
         *      
       */ 
       
        public transient String docBody{get; set;}
       
        public void Upload() {
            if(docBody != null && docBody != '')
                document.body = EncodingUtil.base64Decode(docBody);
            system.debug('---strAttachmentName >'+strAttachmentName);
            if(strAttachmentName != null){
              if(FileName!=null && FileName.indexof('.')>-1 && FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){
                string contyp = FileName.SubString(FileName.indexof('.')+1,FileName.length());
                FileName = strAttachmentName+'.'+contyp.toLowerCase();
                  system.debug('---FileName >'+FileName);
              }
              else
                FileName = strAttachmentName; 
            }
            system.debug('---FileName >'+FileName);
            if(strObjectId!=null && strObjectId!=''){
                NSIBPM__SR_Doc__c objRA = new NSIBPM__SR_Doc__c();    
                try{
                    document.Name = FileName;
                    if(FileName!=null && FileName.indexof('.')>-1 && FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){
                        string contyp = FileName.SubString(FileName.indexof('.')+1,FileName.length());
                        if(contyp!=null && contyp.toLowerCase()=='pdf'){
                            document.ContentType = 'application/pdf';
                        }
                    }
                    if(document!=null && document.body!=null){
                        
                        document.parentId = strSRDocId;
                        if(Attachment.sObjectType.getDescribe().isCreateable() && Attachment.sObjectType.getDescribe().isUpdateable())
                            upsert document;//Inserting the document
                       
                        objRA.Id = strSRDocId;
                        list<NSIBPM__SR_Doc__c> lstDoc = getlstDoc();
                        
                         
                        /*Creating the related document attachment record */
                        if(document.Id!=null){
                            objRA.NSIBPM__Doc_ID__c = string.valueOf(document.Id);
                            objRA.NSIBPM__Status__c = 'Uploaded';
                            objRA.NSIBPM__Doc_Type__c = document.ContentType;
                        }
                        if(strComments!=null && strComments!='' && strComments.trim()!='')
                            objRA.NSIBPM__Comments__c = strComments;
                        if(strExternalComments!=null && strExternalComments!='' && strExternalComments.trim()!='')
                            objRA.NSIBPM__Customer_Comments__c = strExternalComments;
                        if(strObjectId!=null && strObjectId!=''){
                            objRA.NSIBPM__Service_Request__c = strObjectId;
                            objRA.NSIBPM__Document_Type__c = document.ContentType;
                            //try{
                        if(NSIBPM__SR_Doc__c.sObjectType.getDescribe().isUpdateable())
                            update objRA;
                            //}catch(DMLException e){
                                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getdmlMessage(0)));
                            //}
                        }
                        if(FileName!=null && FileName!=''){
                            /*Checking the file format whether it is valid or no */
                            if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pdf'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='rtf'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='txt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='jpg'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='gif'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='bmp'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='png'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='tif' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='TIF' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='doc'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='docx'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='ppt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pptx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xls'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xlsx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xml')
                            {
                                blnDisableControls=true;//once it is uploaded then assigning the flag value to true for displaying the block with document information                          
                            }else{//If the file format is not supported then throwing the exception
                               //ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Uploaded file format is not supported');
                               //ApexPages.addmessage(errorMsg); 
                            } 
                        }
                        if(document != null){ 
                           if(DocIDs != null)                        
                                DocIDs =DocIDs+';'+document.Id;//Appending all the document Id's to a String to display all the documents into the Datatable
                           else
                                DocIDs = document.id;                            
                           /*The below If block checks for whether the file format is valid format or not*/
                           if(FileName!=null && FileName!=''){
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='jpg'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='gif'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='bmp'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='png'){
                               }
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='rtf' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='tif' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='TIF' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='doc'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='docx'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='ppt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pptx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xls'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xlsx'){
                               }                                                                                  
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pdf' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='txt' ){
                               }
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){
                               }
                           }
                        }
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Please specify a file to upload.'));
                    }
                 
                }catch(DMLException e) {//To catch the DML exception while uploading the file
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getdmlMessage(0)));
                        document = new Attachment();
                }finally {
                   document = new Attachment();
                   Prepare_Preview_Documents();
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no Object Id'));   
            }
        }
    
    /*
         * Method Definition:- retriveDocument()
         * This is used to Retrieve the document related to the object and displays it on page load as well as on insertion of the document.
         *      
    */      
    public void retriveDocument(){
        try{
            strObjectId = system.currentPageReference().getParameters().get('id');
            if(setsrids!=null && setsrids.size()>0){//Checking for whether the objectId is mentioned or not
                /*Querying on Related Attachement based on object Id to display the document in the data table on Vf page Loading*/
                list<NSIBPM__SR_Doc__c> lstRA=[select NSIBPM__Doc_ID__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c IN:setsrids and IsDeleted=false];
                if(lstRA.size()>0){
                    for(integer i=0;i<lstRA.size();i++)
                        DocIDs =DocIDs+';'+lstRA[i].NSIBPM__Doc_ID__c;//Appending all the document Id's to the String
                    blnDisableControls=true;
                }
                getlstDoc();
            }   
        }catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no records to display');
            ApexPages.addmessage(errorMsg);         
        }   
    }
        
     /*
         * Method Definition:- getlstDoc()
         * This is used to return the document list to be displayed in the datatable on page load as well as on insertion and deletion
         *      
    */
    public list<NSIBPM__SR_Doc__c> getlstDoc(){
        try{
            strObjectId = system.currentPageReference().getParameters().get('id');
            list<NSIBPM__SR_Doc__c> lstDoc = new list<NSIBPM__SR_Doc__c>();
            list<string> lstDocid = new list<string>();        
            if(setsrids != null && setsrids.size()>0){
                if(DocIDs!=null && DocIDs!='')
                    lstDocid = DocIDs.split(';'); 
                /*Querying the Document based on the document Id's which has been received from Related Attachment Object*/            
                lstDoc = [select id,createddate,NSIBPM__Doc_Type__c,lastmodifieddate,NSIBPM__Is_Not_Required__c,NSIBPM__Requirement__c,NSIBPM__Document_Description_External__c,NSIBPM__Document_Master__r.Name,NSIBPM__Service_Request__c,NSIBPM__Service_Request__r.NSIBPM__Internal_Status_Name__c,NSIBPM__Service_Request__r.NSIBPM__External_Status_Name__c,name,NSIBPM__Doc_ID__c,NSIBPM__Received_Physically__c,NSIBPM__Customer_Comments__c,NSIBPM__Comments__c,NSIBPM__Document_Type__c,NSIBPM__Original_Verified__c,NSIBPM__Rejection_Reason__c,NSIBPM__Status__c,Amendment__c  from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c IN:setsrids and NSIBPM__Sys_IsGenerated_Doc__c=false and IsDeleted=false order by Amendment__c NULLS LAST];
                if(lstDoc.size()>0){
                    strLastDocId = lstDoc[lstDoc.size()-1].NSIBPM__Doc_ID__c;
                    strLastDocName = lstDoc[lstDoc.size()-1].name;
                    return lstDoc;
                }else{
                    strLastDocId = '';
                    strLastDocName = '';
                }    
              }
         }catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage());
            ApexPages.addmessage(errorMsg);         
          }
       return null;
    }   
    public void EditDoc(){
        objSRDocEdit = new NSIBPM__SR_Doc__c();
        strError='';
        if(AgrDocId!=null && AgrDocId!=''){
            list<NSIBPM__SR_Doc__c> lstSRDoc = [select id,Name,NSIBPM__Customer_Comments__c,NSIBPM__Comments__c,NSIBPM__Doc_ID__c,NSIBPM__Document_Type__c,NSIBPM__Original_Verified__c,NSIBPM__Rejection_Reason__c,NSIBPM__Status__c from NSIBPM__SR_Doc__c where Id=:AgrDocId and IsDeleted=false];
            if(lstSRDoc!=null && lstSRDoc.size()>0)
                objSRDocEdit = lstSRDoc[0];
        }
    }
    public void SaveDoc(){
        try{
            if(objSRDocEdit!=null && objSRDocEdit.id!=null){
                if((objSRDocEdit.NSIBPM__Status__c=='Rejected' || objSRDocEdit.NSIBPM__Status__c=='Re-upload') && (objSRDocEdit.NSIBPM__Rejection_Reason__c==null || (objSRDocEdit.NSIBPM__Rejection_Reason__c!=null && objSRDocEdit.NSIBPM__Rejection_Reason__c.trim()=='') || objSRDocEdit.NSIBPM__Rejection_Reason__c=='')){
                    strError = 'Reason for Rejection is Required';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Comments for customer should be provided before changing status to '+objSRDocEdit.NSIBPM__Status__c));
                }else{
                    strError = '';
                    if(NSIBPM__SR_Doc__c.sObjectType.getDescribe().isUpdateable())
                        update objSRDocEdit;
                }
            }
        }catch(DMLException e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0));
            ApexPages.addmessage(errorMsg);     
        }
    }
    public pagereference Back_To_SR(){
        NSIBPM__Step__c Reuplodstp = new NSIBPM__Step__c();
        NSIBPM__Status__c objstatus = new NSIBPM__Status__c();
        boolean hasReuploadDocs = false;
        pagereference pg = new pagereference('/'+strObjectId);
        pg.setRedirect(true);
        return pg;
    }
    //methods for the wizard
    public Component.Apex.PageBlock getDyncPgMainPB(){
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objSRFlow; 
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        return objPB.getDyncPgMainPB();
    }
    public Component.Apex.PageBlock getDyncPgMainPBBottom(){
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objSRFlow; 
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        return objPB.getBottomButtonsPB();
        //return objPB.getDyncPgMainPB();
    }
    public pagereference DynamicButtonAction(){
        system.debug('Inside method ==>DynamicButtonAction');
        system.debug('strActionId==>'+strActionId);
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId'); 
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objSRFlow;
        PreparePageBlockUtil.ActionId = strActionId;
        
        boolean isReqDocsUploaded = true;
        boolean isNext = false;
        
		//Ravi - Check for reupload status for any Docs and return error.
		for(NSIBPM__SR_Doc__c srdoc:[select Id,NSIBPM__Status__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c=:strObjectId and  NSIBPM__Status__c =: Label.SR_DOC_Status limit 1]){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.SR_DOC_Reupload_ErrMsg));
            return null;
        }
        
        for(NSIBPM__SR_Doc__c srdoc:[select Id from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c=:strObjectId and NSIBPM__Is_Not_Required__c=false and NSIBPM__Doc_ID__c=null limit 1]){
            isReqDocsUploaded = false;
        }
        for(Section_Detail__c btn:[select id,Navigation_Directions__c from Section_Detail__c where Id=:strActionId]){
            if(btn.Navigation_Directions__c=='Forward')
                isNext = true;
        }
        //To allow navigation even if doc is not uploaded but SR is marked with NSIBPM__Required_Docs_not_Uploaded__c 
        if(isNext==true){
            for(NSIBPM__Service_Request__c objSR:[select Id,NSIBPM__Required_Docs_not_Uploaded__c from NSIBPM__Service_Request__c where Id=:objSRFlow.Id]){
                if(isReqDocsUploaded && objSR.NSIBPM__Required_Docs_not_Uploaded__c==true){
                    objSR.NSIBPM__Required_Docs_not_Uploaded__c = false;
                    upsert objSR;
                }
            }

        }else{
            isReqDocsUploaded = true;
        }
        
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        system.debug('-->'+isReqDocsUploaded+'--->'+isNext);
        if(isReqDocsUploaded==true || (!isReqDocsUploaded && !isNext)){
            pagereference pg = objPB.getButtonAction();
            system.debug('pg==>'+pg);
            return pg;
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please upload all required documents in order to proceed with your application.'));
            return null;
        }
        return Null;
    }
    public string strNavigatePageId{get;set;}
    public pagereference goTopage(){
       
        Pagereference pg;
        system.debug('strNavigatePageId==>'+strNavigatePageId);
        if(strNavigatePageId!=null && strNavigatePageId!=''){
            try{
                //update objSRFlow;
                PreparePageBlockUtil objSidebarRef = new PreparePageBlockUtil();
                PreparePageBlockUtil.strSideBarPageId = strNavigatePageId;
                PreparePageBlockUtil.objSR = objSRFlow;
                return objSidebarRef.getSideBarReference();
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,string.valueOf(e.getMessage())));
                return null;
            }
        }
        return null;
    }
}