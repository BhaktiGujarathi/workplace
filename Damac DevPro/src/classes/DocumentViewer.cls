/**********************************************************
    Author      :   Durga Prasad
    Company     :   NSI Middle East
    Description :   -This Class is used to insert the documents based on the type of document.
                    -It will display the documents inserted related to the current object and provided option for viewing, editing and deleting the document.
                    -The selected document can be viewed in a frame. 
                    -Defaulted Folder in which documents has to be uploaded based on the object name     
    Date        :   08-Mar-2015
*************************************************************/
global with sharing class DocumentViewer extends Describe_Sobject_Access{
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
        public string DomainName{get;set;}
        public NSIBPM__SR_Doc__c objSRDocEdit{get;set;}
        public string strError{get;set;}
        public string strComments{get;set;}
        public string strExternalComments{get;set;}
        public string strAttachmentName{get;set;}
        public set<id> setsrids{get;set;}
        public void setstrObjectName(string value){
            strObjectName=value;
        }
        public string getstrObjectName(){
            return strObjectName;
        }
    /* End of Global Declarations*/
    
       /*
            Construtor Definition:- DocumentViewer()
            This constructor is used to gets the Id of the Object from the current page reference and assigns it to the local variable        
       */
       public DocumentViewer(){
           /* Start of Properties Initialization for Dynamic Flow */
           setsrids = new set<id>();
           objSRDoc = new NSIBPM__SR_Doc__c();
           document = new Attachment();
           ltGeneratedDocs = new list<NSIBPM__SR_Doc__c>();
           isPortalUser = true;
           strComments = '';
           strExternalComments = '';
           userType = 'salesforce';
           DomainName = '';
           sObjectName = 'nsibpm__srdoc__c';
           getAccess();
           for(User curUser:[select id,ContactId,ProfileId,Profile.UserLicenseId,Profile.UserLicense.Name,Profile.UserLicense.LicenseDefinitionKey from User where Id=:userInfo.getUserId() and IsActive=true]){
                if(curUser.Profile.UserLicense.Name=='Salesforce'){
                    userType = 'salesforce';
                }else if(curUser.Profile.UserLicense.Name=='Company Communities'){
                    userType = 'salesforce';
                }else{
                    userType = 'Community';
                }
                if(curUser.ContactId!=null){
                    isPortalUser = true;
                }else{
                    isPortalUser = false;
                }
           }
           if(userType!='salesforce' && Label.Community_Domain !=null && Label.Community_Domain != '')
                DomainName = Label.Community_Domain;
           if(apexpages.currentpage().getParameters().get('Id')!=null)
                strObjectId = string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id'));
           //strObjectId = apexpages.currentpage().getParameters().get('Id');//;system.currentPageReference().getParameters().get('id');//getting the Id of the object from the current page reference
           if(strObjectId!=null)
                setsrids.add(strObjectId);
           PrepareGenDocs();
           retriveDocument();//calling the Retrieve document method to retrieve the documents of the object if exist on page load
           //setdvDocsVisibility('block');//Setting the visibility of the documents
           objRelatedAttach = new NSIBPM__SR_Doc__c();
        }
        public void PrepareGenDocs(){
            ltGeneratedDocs = new list<NSIBPM__SR_Doc__c>();
            if(setsrids!=null && setsrids.size()>0){
                ltGeneratedDocs = [select id,createddate,lastmodifieddate,NSIBPM__Doc_Type__c,NSIBPM__Requirement__c,NSIBPM__Is_Not_Required__c,NSIBPM__Document_Description_External__c,Preview_Download_Document__c,NSIBPM__Service_Request__c,NSIBPM__Service_Request__r.NSIBPM__External_Status_Name__c,NSIBPM__Service_Request__r.NSIBPM__Internal_Status_Name__c,name,NSIBPM__Doc_ID__c,NSIBPM__Received_Physically__c,NSIBPM__Customer_Comments__c,NSIBPM__Comments__c,NSIBPM__Document_Type__c,NSIBPM__Original_Verified__c,NSIBPM__Rejection_Reason__c,NSIBPM__Status__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c IN:setsrids and NSIBPM__Sys_IsGenerated_Doc__c=true and IsDeleted=false order by CreatedDate asc];
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
        public void Upload() {
            if(strObjectId!=null && strObjectId!=''){
                NSIBPM__SR_Doc__c exitingSr =  new NSIBPM__SR_Doc__c();
                exitingSr = [select id,File_Name_Prefix__c,name,Push_to_IPMS__c from NSIBPM__SR_Doc__c  where id=:strSRDocId LIMIT 1];
                NSIBPM__SR_Doc__c objRA = new NSIBPM__SR_Doc__c();    
                try{
                    if(Schema.sObjectType.Attachment.fields.Name.isUpdateable())
                        document.Name = FileName;
                    if(FileName!=null && FileName.indexof('.')>-1 && FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){
                        string contyp = FileName.SubString(FileName.indexof('.')+1,FileName.length());
                        if(contyp!=null && contyp.toLowerCase()=='pdf'){
                            if(Schema.sObjectType.Attachment.fields.ContentType.isUpdateable())
                                document.ContentType = 'application/pdf';
                        }
                    }
                    if(document!=null){
                        if(document.body!=null){
                           if(Schema.sObjectType.Attachment.fields.parentId.isCreateable())
                                document.parentId = strSRDocId;
                        if(Attachment.sObjectType.getDescribe().isCreateable() && Attachment.sObjectType.getDescribe().isUpdateable()){
                            if(exitingSr.Push_to_IPMS__c){
                                document.Name = string.valueof(exitingSr.File_Name_Prefix__c+'-'+exitingSr.Name+'.'+FileName.SubString(FileName.indexof('.')+1,FileName.length())).deleteWhitespace();                                
                            }
                            upsert document;//Inserting the document 
                        }
                        /*Creating the related document attachment record */
                        objRA.Id = strSRDocId;
                        if(document.Id!=null){
                          if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Doc_ID__c.isUpdateable())
                            objRA.NSIBPM__Doc_ID__c = string.valueOf(document.Id);
                          if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Status__c.isUpdateable())  
                            objRA.NSIBPM__Status__c = 'Uploaded';
                          if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Doc_Type__c.isUpdateable())
                            objRA.NSIBPM__Doc_Type__c = document.ContentType;
                        }
                        if(strComments!=null && strComments!='' && strComments.trim()!='')
                            if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Comments__c.isUpdateable())
                             objRA.NSIBPM__Comments__c = strComments;
                        if(strExternalComments!=null && strExternalComments!='' && strExternalComments.trim()!='')
                            if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Customer_Comments__c.isUpdateable())
                                objRA.NSIBPM__Customer_Comments__c = strExternalComments;
                        if(strObjectId!=null && strObjectId!=''){
                            if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Service_Request__c.isUpdateable())
                                objRA.NSIBPM__Service_Request__c = strObjectId;
                            if(Schema.sObjectType.NSIBPM__SR_Doc__c.fields.NSIBPM__Document_Type__c.isUpdateable())    
                                objRA.NSIBPM__Document_Type__c = document.ContentType;
                            try{
                                if(NSIBPM__SR_Doc__c.sObjectType.getDescribe().isUpdateable())
                                    update objRA;
                            }catch(Exception e){
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                            }
                        }
                        if(FileName!=null && FileName!=''){
                            if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pdf'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='rtf'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='txt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='jpg'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='gif'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='bmp'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='png'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='tif' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='TIF' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='doc'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='docx'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='ppt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pptx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xls'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xlsx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xml'){
                                blnDisableControls=true;                          
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
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='jpg'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='gif'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='bmp'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='png'){}
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='rtf' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='tif' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='TIF' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='doc'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='docx'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='ppt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pptx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xls'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xlsx'){}                                                                                  
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pdf' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='txt'){}
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){}
                           }
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Please specify a file to upload.'));
                    }
                 }
            }catch (DMLException e){//To catch the DML exception while uploading the file
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                document = new Attachment();
            }finally{
                document = new Attachment();
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
                        DocIDs = DocIDs+';'+lstRA[i].NSIBPM__Doc_ID__c;//Appending all the document Id's to the String
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
                lstDoc = [select id, Doc_URL__c, createddate,lastmodifieddate,NSIBPM__Doc_Type__c,NSIBPM__Requirement__c,NSIBPM__Is_Not_Required__c,NSIBPM__Document_Description_External__c,Preview_Download_Document__c,NSIBPM__Service_Request__c,NSIBPM__Service_Request__r.NSIBPM__External_Status_Name__c,NSIBPM__Service_Request__r.NSIBPM__Internal_Status_Name__c,name,NSIBPM__Doc_ID__c,NSIBPM__Received_Physically__c,NSIBPM__Customer_Comments__c,NSIBPM__Comments__c,NSIBPM__Document_Type__c,NSIBPM__Original_Verified__c,NSIBPM__Rejection_Reason__c,NSIBPM__Status__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c IN:setsrids and NSIBPM__Sys_IsGenerated_Doc__c=false and IsDeleted=false order by CreatedDate asc];
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
        }catch(Exception e){
            e.getMessage();
        }
    }
    public pagereference Back_To_SR(){
        NSIBPM__Step__c Reuplodstp = new NSIBPM__Step__c();
        NSIBPM__Status__c objstatus = new NSIBPM__Status__c();
        boolean hasReuploadDocs = false;
        pagereference pg = new pagereference('/'+strObjectId);
        pg.setRedirect(true);
        /*
        for(Step__c stp:[select id,SR_Step__c,Status__c from Step__c where Status__r.Code__c='AWAITING_RE_UPLOAD' and (SR__c=:strObjectId or SR__r.Parent_SR__c=:strObjectId) and IsDeleted=false]){
            Reuplodstp = stp;
        }
        for(Status__c status:[select id,Name from Status__c where Code__c='DOCUMENT_RE_UPLOADED' and IsDeleted=false]){
            objstatus = status;
        }
        for(SR_Doc__c srDoc:[select id from SR_Doc__c where Service_Request__c=:strObjectId and Status__c='Re-upload' and IsDeleted=false]){
            hasReuploadDocs = true;
            break;
        }
        if(Reuplodstp!=null && Reuplodstp.Id!=null && objstatus!=null && objstatus.Id!=null){
            if(hasReuploadDocs==false){
                //string strResult = Cls_DocumentReupload_StatusChange.UpdateStatus(Reuplodstp.Id, objstatus.Id);
                //system.debug('strResult==>'+strResult);
            }
        }
        */
        return pg;
    }
}