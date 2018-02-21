public with sharing class DAMAC_CompanyPersonnelCntlr {



    ApexPages.StandardController controller {get; set;}
    public boolean editMode {get; set;}
    public Amendment__c currAmnd {get; set;}
    public List<Amendment__c> amendment_List {get; set;}
    public String instructionMsg {get;set;}
    public Map<Id, Amendment__c> amendment_Map {get; set;}
    public boolean showHeaderAndSidebar{set;get;} //DAMAC Change
    public Id currAmdId {get; set;}
    /* Start of Properties for Dynamic Flow */
    public Decimal CurrentPageOrder {get;set;}
    public string strNavigatePageId {get; set;}
    public string strPageId {get; set;}
    public string strActionId {get; set;}
    public map<string, string> mapParameters;
    public NSIBPM__Service_Request__c objFinSR {get; set;}
    public string pageTitle {get; set;}
    public string pageDescription {get; set;}
    public boolean isSubmitted {get; set;}
    public string strHiddenPageIds {get; set;}
    public string strAppId {get; set;}
    public NSIBPM__Service_Request__c objSR {get; set;}
    public boolean isEditable {set; get;} //DAMAC Change
    public boolean isDocEditable{set;get;}
    public boolean isGuestUser {get;set;}
    public boolean isCommunity {get;set;}
    
    /* End of Properties for Dynamic Flow */
    public DAMAC_CompanyPersonnelCntlr(ApexPages.StandardController controller) {
        isGuestUser = false;
        iscommunity = false;
        this.controller = controller;
        objSR = (NSIBPM__Service_Request__c)controller.getRecord();
        instructionMsg = '1. Please make sure that you have added the right City of Corporation before adding Company Personnel. <br/> 2. Shareholding value is mandatory only for Owners. <br/> 3. Only one authorized signatory is allowed.';
        editMode = false;
        amendment_List = new List<Amendment__c>();
        amendment_Map = new Map<Id, Amendment__c>();
        mapParameters = new map<string, string>();
        
        //if there is a contact for this logged in user, then it is a community user
         for(User objUsr:[select id,Profile.UserLicense.name,ContactId,Contact.Email,Contact.AccountId,Contact.FirstName,Contact.LastName,Contact.Account.Website from User where Id=:userinfo.getUserId()]){
            if(objUsr.Profile.UserLicense.name == 'Guest User License'){
                isGuestUser = true;
            }
             else{
                 if(objUsr.ContactId!=null)
                    isCommunity = true;
             }
         }
        
        if (apexpages.currentPage().getParameters() != null)
            mapParameters = apexpages.currentPage().getParameters();
        strAppId = mapParameters.get('Id');
        objFinSR = new NSIBPM__Service_Request__c();
        if (mapParameters.get('Type') != null && mapParameters.get('Type') != '') {
            for (Page_Flow__c pf : [select Id, Record_Type_API_Name__c from Page_Flow__c where Record_Type_API_Name__c = :mapParameters.get('Type')]) {
                apexpages.currentPage().getParameters().put('FlowId', pf.Id);
                mapParameters.put('FlowId', pf.Id);
            }
        }
        if (mapParameters.get('FlowId') != null && strAppId != null) {
            strPageId = mapParameters.get('PageId');
            for (Page__c pg : [select id, Name, Page_Description__c,Page_Order__c, Page_Flow__r.Name from Page__c where Id = :strPageId]) {
                pageTitle = pg.Page_Flow__r.Name;
                CurrentPageOrder = pg.Page_Order__c;//Controll backward navigation validation
                pageDescription = pg.Page_Description__c;
            }
            if (mapParameters != null && mapParameters.get('FlowId') != null) {

                //query all the fields configured in the page are query here.
                String strQuery = '';
                strQuery += UtilityQueryManager.getAllFields(NSIBPM__Service_Request__c.getsObjecttype().getDescribe()) ;
                strQuery += '  WHERE Id =:strAppId ';
                for (NSIBPM__Service_Request__c SR : database.query(strQuery)) {
                    objFinSR = SR;

                }
                strHiddenPageIds = PreparePageBlockUtil.getHiddenPageIds(mapParameters.get('FlowId'), objFinSR);
            }
        }

        if (apexpages.currentPage().getParameters() != null && apexpages.currentPage().getParameters().size() > 0)
            mapParameters = apexpages.currentPage().getParameters();



        amendment_List =  getAllAmendments();
        editMode = ( amendment_List.size()  == 0 )  ? true : editMode; //If no amendments are available ask users create by enabling edit mode
        currAmnd = ( amendment_List.size()  == 0 ) ? new Amendment__c() : currAmnd; //Instantiate currAmd

         isEditable = true;
         isDocEditable = true;
         //Draft,RI,Doc Rejected --> SR editable but if during Registration doc generated checkbox is selected when its in RI or Rejected
         //Fields should be locked and upload doc unlock
         if(NULL != objFinSR && null != objFinSR.nsibpm__internal_status_name__c &&
            (objFinSR.nsibpm__internal_status_name__c != 'Draft' && objFinSR.nsibpm__internal_status_name__c != 'Requested for Info' && 
            objFinSR.nsibpm__internal_status_name__c != 'Document Rejected')){
            isEditable = false;
            isDocEditable = false;
         }
         else if((NULL != objFinSR && null != objFinSR.nsibpm__internal_status_name__c 
              && objFinSR.nsibpm__record_type_name__c == 'Agent_Registration' &&
            (objFinSR.nsibpm__internal_status_name__c == 'Requested for Info' || 
             objFinSR.nsibpm__internal_status_name__c == 'Document Rejected') && objFinSR.Document_Generated__c)){
             isEditable = false;
             isDocEditable = true;    
         }
        if(!isEditable){
                 isEditable = SRUtility.isUserwithEditPermissions();
             }
        //DAMAC Change
         if(mapParameters.get('FlowId') != NULL && mapParameters.get('FlowId') != ''){
            showHeaderAndSidebar = (mapParameters.get('FlowId') == UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Page_Flow_Name))?false:true;
            if(!showHeaderAndSidebar){
                if(!isGuestUser && !isCommunity){
                    showHeaderAndSidebar = true;
                }
            }
         }
        System.debug('***isEditable' + isEditable);
    }

    public String validateAmendment(Amendment__c amd) {

        String errorStr = 'Success';
        if (!(amd.Owner__c  || amd.Portal_Administrator__c  || amd.Agent_Representative__c  || amd.Authorised_Signatory__c)) {

            errorStr = 'Please select at least one role';
        }
        if(amd.Authorised_Signatory__c && (amd.Designation__c == NULL || amd.Designation__c == '')){
            errorStr = 'Designation is required for Authorised Signatory';
        }
        if (amd.Owner__c && amd.Shareholding__c == NULL) {

            errorStr = 'Please enter Share Holding %';
        }
        if (amd.Agent_Representative__c && objFinSR.City_Of_Incorporation_New__c == 'Dubai' &&  (amd.Broker_Card_Number__c == NULL || amd.Broker_Card_Expiry_Date__c == NULL)) {
            errorStr = 'Broker Card No and Broker Card Expiry Date is required for Agents.';
        }
        return errorStr;
    }
    public List<Amendment__c> getAllAmendments() {

        amendment_Map.clear();
        String srId = objFinSR.Id;
        String amdQuery = UtilityQueryManager.getAllFields(Amendment__c.getsObjectType().getDescribe());
        amdQuery += ' WHERE Service_Request__c =: srId ';
        for (Amendment__c amd : Database.query(amdQuery)) {
            amendment_Map.put(amd.Id, amd);

        }
        System.debug('getAllAmendments==>' + amendment_Map.keySet().size());
        return amendment_Map.Values();

    }

    public PageReference editAmd() {
        currAmnd = amendment_Map.get(currAmdId);
        editMode = true;
        return NULL;
    }

    public void deleteAmd() {
        Amendment__c delAmd = new Amendment__c(id = currAmdId);
        try {
            deleteSRDocs(delAmd, 'Delete'); //Delete all the associated docs before deleting amendment
            delete delAmd;
            amendment_List =  getAllAmendments();
            System.debug('==>' + amendment_List.size());
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }

    }
    public PageReference createAmd() {
        currAmnd = new Amendment__c();
        editMode = true;
        return Null;
    }

    public PageReference cancel() {
        currAmnd = new Amendment__c();
        editMode = false;
        return Null;
    }
    public PageReference save() {

        try {
            String validate = validateAmendment(currAmnd);
            if (validate == 'Success') {
                currAmnd.Service_Request__c = objFinSR.Id;
                upsert currAmnd;
                createDocuments(currAmnd);
                editMode = false;
                amendment_List = getAllAmendments();
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, validate));
            }

        } catch (DMLException  e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, e.getdmlMessage(0)));
        }
        return Null;
    }
    public NSIBPM__SR_Doc__c createSRDoc(String docName, NSIBPM__SR_Template_Docs__c SRTmpDoc , Id amdId) {


        NSIBPM__SR_Doc__c objSRDoc = new NSIBPM__SR_Doc__c();

        if (docName.length() > 80)
            docName = docName.subString(0, 79);
        objSRDoc.Name = docName;
        objSRDoc.NSIBPM__Service_Request__c = objFinSR.Id;
        objSRDoc.Amendment__c = amdId;
        objSRDoc.NSIBPM__SR_Template_Doc__c = SRTmpDoc.Id;
        objSRDoc.NSIBPM__Status__c = 'Pending Upload';
        objSRDoc.NSIBPM__Document_Master__c = SRTmpDoc.NSIBPM__Document_Master__c;
        objSRDoc.NSIBPM__Group_No__c = SRTmpDoc.NSIBPM__Group_No__c;
        objSRDoc.NSIBPM__Is_Not_Required__c = SRTmpDoc.NSIBPM__Optional__c;
        objSRDoc.NSIBPM__Generate_Document__c = SRTmpDoc.NSIBPM__Generate_Document__c;
        objSRDoc.NSIBPM__Document_Description_External__c = SRTmpDoc.NSIBPM__Document_Description_External__c;
        objSRDoc.NSIBPM__Sys_IsGenerated_Doc__c = SRTmpDoc.NSIBPM__Generate_Document__c;
        objSRDoc.NSIBPM__Unique_SR_Doc__c = SRTmpDoc.NSIBPM__Document_Master__r.Name + '_' + amdId;
        objSRDoc.NSIBPM__From_Finalize__c = true;
        // System.debug('DocID ==>'+SRTmpDoc.NSIBPM__Document_Master__r.Name + '_' +amdId);
        return objSRDoc;

    }
    public void createDocuments(Amendment__c amd) {

        deleteSRDocs(amd, 'Upsert');
        Map<String, String> existingSRDocsMap = new Map<String, String>();
        String amendmentQuery = UtilityQueryManager.getAllFields(Amendment__c.getsObjectType().getDescribe());
        Id amdId = amd.Id;
        amendmentQuery += ' WHERE Id =: amdId Limit 1 ';

        Amendment__c currAmd = Database.query(amendmentQuery);
        System.debug('DAMAC_CompanyPersonnelCntlr.createDocuments.currAmd ==>' + currAmd);
		Map<String, String> mpGCC = new Map<String, String>{'Bahrain' => '1', 'Kuwait' => '2', 'Oman' => '3', 'Qatar' => '4','Saudi Arabia' => '5','United Arab Emirates' => '6'};
        
        //Amendment<---SRDoc--->SRTemplateDoc
        for (NSIBPM__SR_Doc__c srdoc : [select Id, Amendment__c, NSIBPM__SR_Template_Doc__c from NSIBPM__SR_Doc__c where Amendment__c = :currAmd.Id]) {
            existingSRDocsMap.put(srdoc.Amendment__c + '-' + srdoc.NSIBPM__SR_Template_Doc__c, srdoc.Id);
        }
        list<NSIBPM__SR_Doc__c> lstSRDocs_throughCode = new list<NSIBPM__SR_Doc__c>();
        for (NSIBPM__SR_Template_Docs__c SRTemplateDoc : [Select Id, Name, NSIBPM__Group_No__c, NSIBPM__Document_Master__r.NSIBPM__Code__c, NSIBPM__Requirement__c, NSIBPM__Generate_Document__c, NSIBPM__DMS_Document_Index__c, NSIBPM__Added_through_Code__c, NSIBPM__Document_Description_External__c, NSIBPM__SR_Template__c, NSIBPM__Document_Master__c, NSIBPM__Optional__c, NSIBPM__Document_Description__c, NSIBPM__Document_Name_for_SR__c, NSIBPM__Document_Master__r.Name from NSIBPM__SR_Template_Docs__c where NSIBPM__SR_Template__r.NSIBPM__SR_RecordType_API_Name__c = :objFinSR.nsibpm__record_type_name__c and NSIBPM__Added_through_Code__c = true and NSIBPM__On_Submit__c = true]) {
            String docCode = SRTemplateDoc.NSIBPM__Document_Master__r.NSIBPM__Code__c;
            String docName = SRTemplateDoc.NSIBPM__Document_Master__r.Name;
            if (existingSRDocsMap.get(currAmd.Id + '-' + SRTemplateDoc.Id) == NULL) {

                if (docCode == 'POWER_OF_ATTORNEY') {
                        if (!currAmd.Owner__c && currAmd.Authorised_Signatory__c) {
                            lstSRDocs_throughCode.add(createSRDoc(currAmd.first_name__c + '-' + docName , SRTemplateDoc, currAmd.Id));
                        }
                    } else if (docCode == 'BROKER_CARD') {
                        if (currAmd.Agent_Representative__c && objFinSR.City_Of_Incorporation_New__c == 'Dubai') {
                            lstSRDocs_throughCode.add(createSRDoc(currAmd.first_name__c + '-' + docName , SRTemplateDoc, currAmd.Id));
                        }

                    } else if (docCode == 'VISA_COPY') {
                        //if ((currAmd.Nationality__c != objFinSR.Country_of_Incorporation_New__c) || currAmd.ID_type__c == 'Visa') {
                        if ((currAmd.Nationality__c != objFinSR.Country_of_Incorporation_New__c && ((mpGCC.containskey(objFinSR.Country_of_Incorporation_New__c) && !mpGCC.containskey(currAmd.Nationality__c)) || (!mpGCC.containskey(objFinSR.Country_of_Incorporation_New__c) && mpGCC.containskey(currAmd.Nationality__c)) || (!mpGCC.containskey(objFinSR.Country_of_Incorporation_New__c) && !mpGCC.containskey(currAmd.Nationality__c)))) || currAmd.ID_type__c == 'Visa') {
                            lstSRDocs_throughCode.add(createSRDoc(currAmd.first_name__c + '-' + docName , SRTemplateDoc, currAmd.Id));
                        }
                    } 
                    else if (docCode == 'NATIONAL_ID_COPY') {
                        if (currAmd.ID_type__c == 'National ID') {
                            lstSRDocs_throughCode.add(createSRDoc(currAmd.first_name__c + '-' + docName , SRTemplateDoc, currAmd.Id));
                        }
                    }else {

                        lstSRDocs_throughCode.add(createSRDoc(currAmd.first_name__c + '-' + docName , SRTemplateDoc, currAmd.Id));
                    }

            }
        }
        if (!lstSRDocs_throughCode.isEmpty()) {
            System.debug('lstSRDocs_throughCode==>' + lstSRDocs_throughCode);
            insert lstSRDocs_throughCode;
        }

    }
    public void deleteSRDocs(Amendment__c amd, String type) {
        if (Type.equals('Upsert')) {
            delete ([Select id, Amendment__c, NSIBPM__Doc_ID__c from NSIBPM__SR_Doc__c Where Amendment__c = : amd.Id AND NSIBPM__Doc_ID__c = NULL]);
        } else {
            // When amendment is deleted delete all docs
            delete ([Select id, Amendment__c, NSIBPM__Doc_ID__c from NSIBPM__SR_Doc__c Where Amendment__c = : amd.Id ]);
        }

    }


    /* BPM Code  */
    public pagereference goTopage() {
        if (strNavigatePageId != null && strNavigatePageId != '') {
            try {
                PreparePageBlockUtil objSidebarRef = new PreparePageBlockUtil();
                PreparePageBlockUtil.strSideBarPageId = strNavigatePageId;
                PreparePageBlockUtil.objSR = objFinSR;
                return objSidebarRef.getSideBarReference();
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, string.valueOf(e.getMessage())));
                return null;
            }
        }
        return null;
    }
    public string EditSecPageId {get; set;}
    public pagereference EditSectionDetails() {
        Pagereference pg = new Pagereference('/apex/Process_Flow?FlowId=' + mapParameters.get('FlowId') + '&Id=' + objFinSR.Id + '&PageId=' + EditSecPageId);
        pg.setredirect(true);
        return pg;
    }
    public Component.Apex.PageBlock getDyncPgMainPB() { //content of the page which is configured
        PreparePageBlockUtil obj = new PreparePageBlockUtil();
        obj.objFinSR = objFinSR;
        PreparePageBlockUtil.objSR = objFinSR;
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        //PreparePageBlockUtil.objFinSR = objFinSR;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        PreparePageBlockUtil.PageName = 'Primary Information';
        PreparePageBlockUtil.PageBlockTitle = 'Primary Information Details';


        Component.Apex.PageBlock ConfirmPB = objPB.getConfirmationPB();
        return ConfirmPB;
    }

    public Component.Apex.PageBlock getDyncPgMainPBSection() { //content of the page which is configured
        PreparePageBlockUtil obj = new PreparePageBlockUtil();
        obj.objFinSR = objFinSR;
        PreparePageBlockUtil.objSR = objFinSR;
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        //PreparePageBlockUtil.objFinSR = objFinSR;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        PreparePageBlockUtil.PageName = 'Primary Information';
        PreparePageBlockUtil.PageBlockTitle = 'Primary Information Details';


        Component.Apex.PageBlock ConfirmPB = objPB.getDyncPgMainPB();
        return ConfirmPB;
    }

    public Component.Apex.PageBlock getDyncPgMainPBBottom() { //to display the buttons which are configured
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objFinSR;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        return objPB.getBottomButtonsPB();
    }
    
    public list<String> validateAllAmendments(){
        list<String> lstErr = new List<string>();
        amendment_List = getAllAmendments();
        integer CntofAuthSig = 0;
          for(Amendment__c amd : amendment_List){
              if(amd.Authorised_Signatory__c){
                  CntofAuthSig++;
              }  
          }
         if(CntofAuthSig > 1){
             lstErr.add('Only one authorized signatory per agency is allowed.');
         }
        return lstErr;
    }
    
    public pagereference DynamicButtonAction() { // on click of buttons the actions to perform
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objFinSR;
        PreparePageBlockUtil.ActionId = strActionId;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        pagereference pg;
        System.debug('strActionId=>' + strActionId);
        boolean AllowedToSubmit = true;
        
        List<string> lstErrorMsgs = validateAllAmendments();
        if(lstErrorMsgs != null && !lstErrorMsgs.isempty()){
            for(string str : lstErrorMsgs){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, str));
            }
            return null;
        }
        
        if (strActionId != null && strActionId != '') {
            boolean isNext = false;
            for (Section_Detail__c btn : [select id, Navigation_Directions__c from Section_Detail__c where Id = :strActionId]) {
                if (btn.Navigation_Directions__c == 'Forward')
                    isNext = true;
            }
            if (isNext == true) { // no validation is required for cliking on prev button. only next/fwd button needs validation
                if (editMode) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please Save/Cancel before navigating.'));
                    return null;
                }

                string strResult = '';
                try {
                    Boolean updateSR = true;
                    System.debug('==>Next');
                    update objFinSr;
                    strResult = 'Success';
                } catch (Exception e) {
                    strResult = e.getMessage();
                    return null;
                }

                if (strResult != 'Success') {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, strResult));
                    return null;
                }
            } else {
                AllowedToSubmit = true;
            }
        }
        if (AllowedToSubmit == true) {
            pg = objPB.getButtonAction();//if all validation pass thro and no error, then proceed to the next page , which is configured in the flow
        }
        return pg;
    }
    /* BPM Code  */
}