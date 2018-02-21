public without sharing class DAMAC_ConfirmRequestController {

    public List<Amendment__c> amdList {get;set;}
    /* Start of Properties for Dynamic Flow */
    public string strPageId {get; set;}
    public string strActionId {get; set;}
    public map<string, string> mapParameters;
    public NSIBPM__Service_Request__c objFinSR {get; set;}
    public string pageTitle {get; set;}
    public string pageDescription {get; set;}
    public boolean isSubmitted {get; set;}
    public string strHiddenPageIds {get; set;}
    public double Fees {get; set;}
    public double Deposit {get; set;}
    public boolean isGuestUser {get;set;}
    public boolean isCommunity{get;set;}
    /* End of Properties for Dynamic Flow */
    public string strAppId;
    public boolean showHeaderAndSidebar{set;get;} //DAMAC Change

    public DAMAC_ConfirmRequestController() {
        amdList =  new List<Amendment__c>();
        isSubmitted = false;
		isCommunity = false;
        isGuestUser = false;
        
        for(User objUsr:[select id,Profile.UserLicense.name,ContactId,Contact.Email,Contact.AccountId,Contact.FirstName,Contact.LastName,Contact.Account.Website from User where Id=:userinfo.getUserId()]){
               if(objUsr.Profile.UserLicense.name == 'Guest User License'){
                   isGuestUser = true;
               }
               else{
                   if(objUsr.ContactId!=null)
                       isCommunity = true;
               }
           }
        /* Start of Properties Initialization for Dynamic Flow */
        mapParameters = new map<string, string>();
        if (apexpages.currentPage().getParameters() != null)
            mapParameters = apexpages.currentPage().getParameters();
        strAppId = mapParameters.get('Id');
        
        objFinSR = new NSIBPM__Service_Request__c();
        if(mapParameters.get('Type') != null && mapParameters.get('Type') != '') {
            for(Page_Flow__c pf : [select Id, Record_Type_API_Name__c from Page_Flow__c where Record_Type_API_Name__c = :mapParameters.get('Type')]) {
                apexpages.currentPage().getParameters().put('FlowId', pf.Id);
                mapParameters.put('FlowId', pf.Id);
            }
        }
        if(mapParameters.get('FlowId') != null && strAppId != null) {
            strPageId = mapParameters.get('PageId');
            for (Page__c pg : [select id, Name, Page_Description__c, Page_Flow__r.Name from Page__c where Id = :strPageId]) {
                pageTitle = pg.Page_Flow__r.Name;
                pageDescription = pg.Page_Description__c;
            }
            if (mapParameters != null && mapParameters.get('FlowId') != null) {
                /*get all the fields used in the flow to prepare the query to be used in sr object*/
                set<string> setstrFields = Cls_Evaluate_Conditions.FetchObjectFields(mapParameters.get('FlowId'), 'NSIBPM__Service_Request__c');
                string strQuery = 'select Id';
                if (setstrFields == null || (setstrFields != null && SetstrFields.size() == 0))
                    setstrFields = new set<string>();
                setstrFields.add('filled_page_ids__c');
                setstrFields.add('id');
                setstrFields.add('name');
                setstrFields.add('nsibpm__finalizeamendmentflg__c');
                setstrFields.add('recordtype.developername');
                setstrFields.add('nsibpm__sr_template__c');
                setstrFields.add('recordtype.name');
                setstrFields.add('nsibpm__customer__c');

                for (String strFld : SetstrFields) {
                    if (strFld.toLowerCase() != 'id')
                        strQuery += ',' + strFld.toLowerCase();
                }
                strQuery = strQuery + ' from NSIBPM__Service_Request__c where Id=:strAppId';
                for (NSIBPM__Service_Request__c app : database.query(strQuery)) {
                    objFinSR = app;
                    
                }
                strHiddenPageIds = PreparePageBlockUtil.getHiddenPageIds(mapParameters.get('FlowId'), objFinSR);
            }
        }
      amdList = SRUtility.getAllAmendments(objFinSR.Id);

      //DAMAC Change
     if(mapParameters.get('FlowId') != NULL && mapParameters.get('FlowId') != ''){
        showHeaderAndSidebar = (mapParameters.get('FlowId') == UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Page_Flow_Name))?false:true;
        if(!showHeaderAndSidebar){
                if(!isGuestUser && !isCommunity){
                    showHeaderAndSidebar = true;
                }
            }
     } 
    }
    public string strNavigatePageId {get; set;}
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
    
   public List<string> CheckforMandatoryFields(){
       List<string> errString = new List<string>();
        try{
            
            set<string> strFieldAPIName = new set<string>();
            Map<string,string> mpColumnNames = new Map<string,string>();
            system.debug('-->inside CheckforMandatoryFields '+MapParameters.get('FlowId'));
            NSIBPM__Service_Request__c validatecheckSR = new NSIBPM__Service_Request__c();
            list<Section_Detail__c>  lstfieldstocheck = [select id,Field_API_Name__c,Section__r.Section_Title__c,Section__r.Page__r.Page_Title__c,Section__r.Page__c,Mark_it_as_Required__c,Section__r.Page__r.Name
                                                         from Section_Detail__c where 
                                                         Component_Type__c = 'Input Field' and 
                                                         (Mark_it_as_Required__c = true) and Field_API_Name__c != null and
                                                         Section__r.Page__r.Page_Flow__c =: MapParameters.get('FlowId') order by Section__r.Page__r.Page_Title__c,Section__r.Section_Title__c limit 500];
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType srschema = schemaMap.get('NSIBPM__Service_Request__c');
            Map<String, Schema.SObjectField> fieldMap = srschema.getDescribe().fields.getMap(); 
            Map<String, String> fieldAPIName = new Map<String, String>();
            
            if(lstfieldstocheck != null && !lstfieldstocheck.isempty()){
                for(Section_Detail__c scDet : lstfieldstocheck){ 
                    strFieldAPIName.add((scDet.Field_API_Name__c).toLowerCase());
                    mpColumnNames.put((scDet.Field_API_Name__c).toLowerCase(),(scDet.Section__r.Page__r.name +' - '+ scDet.section__r.Section_Title__c));
                }
                
                for(String fieldName : fieldMap.keySet()){
                    if(mpColumnNames.containskey(fieldName))
                        fieldAPIName.put(fieldName.toLowerCase(), fieldMap.get(fieldName).getDescribe().getLabel());
                }
                
                string strQuery = 'select id';
                for(String strFld : fieldMap.keySet()){
                    if(strFld !='id')
                        strQuery += ','+strFld;
                }
                String SRID = mapParameters.get('Id');
                strQuery = strQuery+' from NSIBPM__Service_Request__c where Id=:SRID';
                for(NSIBPM__Service_Request__c SR : database.query(strQuery)){
                    validatecheckSR = SR;
                }
  
                Map<string,boolean> mpFieldstoSkip = new Map<string,boolean>{'agency_short_name__c' => true,'date_of_incorporation__c' => true,'country_of_incorporation_new__c' => true,'city_of_incorporation_new__c' => true,'trade_license_expiry_date__c' => true,'trade_license_number__c' => true,'agency_type__c' => true,'orn_number__c'=>true,'rera_expiry_date__c'=>true,'p_o_box_no__c'=>true,'zip_postal_code__c'=>true,'iban_number__c'=>true,'ifsc_code__c'=>true,'swift_code__c'=>true,'sort_code__c'=>true};
				mpFieldstoSkip.put('first_name__c',true);
                mpFieldstoSkip.put('last_name__c',true);
                mpFieldstoSkip.put('id_type__c',true);
                mpFieldstoSkip.put('id_expiry_date__c',true);
                mpFieldstoSkip.put('id_number__c',true);
                mpFieldstoSkip.put('nationality__c',true);
                mpFieldstoSkip.put('broker_card_number__c',true);
                mpFieldstoSkip.put('broker_card_expiry_date__c',true);
                mpFieldstoSkip.put('agency_name__c',true);
                mpFieldstoSkip.put('id_issue_date__c',true);
                
                system.debug('field value --> '+ mpFieldstoSkip.keyset());
                
                if(validatecheckSR != null && validatecheckSR.id != null){
                    for(String strFld : strFieldAPIName){
                        system.debug('fields --> '+ strFld);
                        if(!mpFieldstoSkip.containskey(strFld)){
                            system.debug('field value --> '+ validatecheckSR.get(strFld));
                            if(validatecheckSR.get(strFld) == null){
                                errString.add(mpColumnNames.get(strFld) +'::'+fieldAPIName.get(strFld)+ ' cannot be empty/null');
                                system.debug('-->errString ' +errString);    
                            }
                        }
                    }

                    errString.addall(checkfordependecies(mpColumnNames,validatecheckSR,fieldAPIName));
                }
                
            }
            system.debug('-->errString ' +errString);
            return errString;
            
        }
        catch(exception ex){
			errString.add(ex.getmessage());
            return errString;
        }
        
    }
    
    public list<string> checkfordependecies(Map<string,string> mpColumnNames,NSIBPM__Service_Request__c validatecheckSR,Map<String, String> fieldAPIName){
        try{
			List<string> errString = new List<string>();
			if(mpColumnNames.containskey('agency_type__c')){
                if(string.isBlank((string)validatecheckSR.get('agency_type__c'))){
                    errString.add(mpColumnNames.get('agency_type__c') +'::'+fieldAPIName.get('agency_type__c') + ' cannot be empty/null');
                }
                else if((string)validatecheckSR.get('agency_type__c') == 'Corporate'){
					if(mpColumnNames.containskey('agency_name__c')){
                        if(string.isBlank((string)validatecheckSR.get('agency_name__c'))){
                            errString.add(mpColumnNames.get('agency_name__c') +'::'+fieldAPIName.get('agency_name__c') + ' cannot be empty/null');
                        }
                    }                    
                    if(mpColumnNames.containskey('trade_license_number__c')){
                        if(string.isBlank((string)validatecheckSR.get('trade_license_number__c'))){
                            errString.add(mpColumnNames.get('trade_license_number__c') +'::'+fieldAPIName.get('trade_license_number__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('trade_license_expiry_date__c')){
                        if(string.isBlank((string)validatecheckSR.get('trade_license_expiry_date__c'))){
                            errString.add(mpColumnNames.get('trade_license_expiry_date__c') +'::'+fieldAPIName.get('trade_license_expiry_date__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('country_of_incorporation_new__c')){
                        if(string.isBlank((string)validatecheckSR.get('country_of_incorporation_new__c'))){
                            errString.add(mpColumnNames.get('country_of_incorporation_new__c') +'::'+fieldAPIName.get('country_of_incorporation_new__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('city_Of_incorporation_new__c')){
                        if(string.isBlank((string)validatecheckSR.get('city_Of_incorporation_new__c'))){
                            errString.add(mpColumnNames.get('city_Of_incorporation_new__c') +'::'+fieldAPIName.get('city_Of_incorporation_new__c') + ' cannot be empty/null');
                        }
                        else if((string)validatecheckSR.get('city_Of_incorporation_new__c') == 'Dubai'){
                            if(string.isBlank((string)validatecheckSR.get('orn_number__c'))){
                                errString.add(mpColumnNames.get('orn_number__c') +'::'+fieldAPIName.get('orn_number__c') + ' cannot be empty/null');
                            }
                            if(string.isBlank((string)validatecheckSR.get('rera_expiry_date__c'))){
                                errString.add(mpColumnNames.get('rera_expiry_date__c') +'::'+fieldAPIName.get('rera_expiry_date__c') + ' cannot be empty/null');
                            }
                        }
                    }
                    if(mpColumnNames.containskey('agency_short_name__c')){
                        if(string.isBlank((string)validatecheckSR.get('agency_short_name__c'))){
                            errString.add(mpColumnNames.get('agency_short_name__c') +'::'+fieldAPIName.get('agency_short_name__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('date_of_incorporation__c')){
                        if(string.isBlank((string)validatecheckSR.get('date_of_incorporation__c'))){
                            errString.add(mpColumnNames.get('date_of_incorporation__c') +'::'+fieldAPIName.get('date_of_incorporation__c') + ' cannot be empty/null');
                        }
                    }
                }
                else if((string)validatecheckSR.get('agency_type__c') == 'Individual'){
                    
                    if(mpColumnNames.containskey('id_issue_date__c')){
                        if(string.isBlank((string)validatecheckSR.get('id_issue_date__c'))){
                            errString.add(mpColumnNames.get('id_issue_date__c') +'::'+fieldAPIName.get('id_issue_date__c') + ' cannot be empty/null');
                        }
                    } 
                    if(mpColumnNames.containskey('first_name__c')){
                        if(string.isBlank((string)validatecheckSR.get('first_name__c'))){
                            errString.add(mpColumnNames.get('first_name__c') +'::'+fieldAPIName.get('first_name__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('last_name__c')){
                        if(string.isBlank((string)validatecheckSR.get('last_name__c'))){
                            errString.add(mpColumnNames.get('last_name__c') +'::'+fieldAPIName.get('last_name__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('id_type__c')){
                        if(string.isBlank((string)validatecheckSR.get('id_type__c'))){
                            errString.add(mpColumnNames.get('id_type__c') +'::'+fieldAPIName.get('id_type__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('id_expiry_date__c')){
                        if(string.isBlank((string)validatecheckSR.get('id_expiry_date__c'))){
                            errString.add(mpColumnNames.get('id_expiry_date__c') +'::'+fieldAPIName.get('id_expiry_date__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('id_number__c')){
                        if(string.isBlank((string)validatecheckSR.get('id_number__c'))){
                            errString.add(mpColumnNames.get('id_number__c') +'::'+fieldAPIName.get('id_number__c') + ' cannot be empty/null');
                        }
                    }
                    if(mpColumnNames.containskey('nationality__c')){
                        if(string.isBlank((string)validatecheckSR.get('nationality__c'))){
                            errString.add(mpColumnNames.get('nationality__c') +'::'+fieldAPIName.get('nationality__c') + ' cannot be empty/null');
                        }
                    }
                    if(boolean.valueof(validatecheckSR.get('eligible_to_sell_in_dubai__c'))){
                        if(mpColumnNames.containskey('broker_card_number__c')){
                            if(string.isBlank((string)validatecheckSR.get('broker_card_number__c'))){
                                errString.add(mpColumnNames.get('broker_card_number__c') +'::'+fieldAPIName.get('broker_card_number__c') + ' cannot be empty/null');
                            }
                        }
                        if(mpColumnNames.containskey('broker_card_expiry_date__c')){
                            if(string.isBlank((string)validatecheckSR.get('broker_card_expiry_date__c'))){
                                errString.add(mpColumnNames.get('broker_card_expiry_date__c') +'::'+fieldAPIName.get('broker_card_expiry_date__c') + ' cannot be empty/null');
                            }
                        }
                    }
                }
            }

            if(mpColumnNames.containskey('p_o_box_zip_postal_code__c')){
                if(string.isBlank((string)validatecheckSR.get('p_o_box_zip_postal_code__c'))){
                    errString.add(mpColumnNames.get('p_o_box_zip_postal_code__c') +'::'+fieldAPIName.get('p_o_box_zip_postal_code__c') + ' cannot be empty/null');

                }
                else if((string)validatecheckSR.get('p_o_box_zip_postal_code__c') == 'P.O. Box No.'){
                    if(string.isBlank((string)validatecheckSR.get('p_o_box_no__c'))){
                    	errString.add(mpColumnNames.get('p_o_box_no__c') +'::'+fieldAPIName.get('p_o_box_no__c') + ' cannot be empty/null');
                	}
                }
                else if((string)validatecheckSR.get('p_o_box_zip_postal_code__c') == 'Zip/Postal Code'){
                    if(string.isBlank((string)validatecheckSR.get('zip_postal_code__c'))){
                    	errString.add(mpColumnNames.get('zip_postal_code__c') +'::'+fieldAPIName.get('zip_postal_code__c') + ' cannot be empty/null');
                	}
                }
            }
            //'iban_number__c' && strFld != 'ifsc_code__c' && strFld != 'swift_code__c' && strFld != 'sort_code__c'
            if(mpColumnNames.containskey('iban_ifsc_swift_sort__c')){
                if(string.isBlank((string)validatecheckSR.get('iban_ifsc_swift_sort__c'))){
                    errString.add(mpColumnNames.get('iban_ifsc_swift_sort__c') +'::'+fieldAPIName.get('iban_ifsc_swift_sort__c') + ' cannot be empty/null');

                }
                else if((string)validatecheckSR.get('iban_ifsc_swift_sort__c') == 'IBAN Number'){
                    if(string.isBlank((string)validatecheckSR.get('iban_number__c'))){
                    	errString.add(mpColumnNames.get('iban_number__c') +'::'+fieldAPIName.get('iban_number__c') + ' cannot be empty/null');
                	}
                }
                else if((string)validatecheckSR.get('iban_ifsc_swift_sort__c') == 'IFSC Code'){
                    if(string.isBlank((string)validatecheckSR.get('ifsc_code__c'))){
                    	errString.add(mpColumnNames.get('ifsc_code__c') +'::'+fieldAPIName.get('ifsc_code__c') + ' cannot be empty/null');
                	}
                }
                else if((string)validatecheckSR.get('iban_ifsc_swift_sort__c') == 'Swift Code'){
                    if(string.isBlank((string)validatecheckSR.get('swift_code__c'))){
                    	errString.add(mpColumnNames.get('swift_code__c') +'::'+fieldAPIName.get('swift_code__c') + ' cannot be empty/null');
                	}
                }
                else if((string)validatecheckSR.get('iban_ifsc_swift_sort__c') == 'SORT Code'){
                    if(string.isBlank((string)validatecheckSR.get('sort_code__c'))){
                    	errString.add(mpColumnNames.get('sort_code__c') +'::'+fieldAPIName.get('sort_code__c') + ' cannot be empty/null');
                	}
                }
            }
            return errString;
        }
        Catch(exception ex){
            return new List<string>();
        }
    }
    
    public pagereference DynamicButtonAction() { // on click of buttons the actions to perform
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objFinSR;
        PreparePageBlockUtil.ActionId = strActionId;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        pagereference pg;
        boolean AllowedToSubmit = true;
        
        List<string> lstErrorMsgs = CheckforMandatoryFields();
        if(lstErrorMsgs != null && !lstErrorMsgs.isempty()){
            for(string str : lstErrorMsgs){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, str));
            }
            return null;
        }
       
        if(strActionId != null && strActionId != '') {
            boolean isNext = false;
            for (Section_Detail__c btn : [select id, Navigation_Directions__c from Section_Detail__c where Id = :strActionId]) {
                if (btn.Navigation_Directions__c == 'Forward')
                    isNext = true;
            }
            if (isNext == true) { // no validation is required for cliking on prev button. only next/fwd button needs validation
                System.debug('isNext-Confirmation==>'+isNext);
                string strResult = '';
                try{
                    Boolean updateSR = true;
                    for (NSIBPM__SR_Status__c srStatus : [select Id from NSIBPM__SR_Status__c where Name = 'Submitted']) {
                        objFinSR.NSIBPM__Internal_SR_Status__c = srStatus.Id;
                        objFinSR.NSIBPM__External_SR_Status__c = srStatus.Id;
                        objFinSR.NSIBPM__Submitted_Date__c = system.today();
                        objFinSR.NSIBPM__Submitted_DateTime__c = system.now();
                    }
                    objFinSR.nsibpm__finalizeamendmentflg__c = true;
                    objFinSR.NSIBPM__Required_Docs_not_Uploaded__c = false;
                    
                    strResult = SRUtility.validateSRSubmit(objFinSR.id); 
                    System.debug('strResult==>'+strResult);
                    if(strResult == 'Success'){
                        
                        upsert objFinSR;
                        objFinSR.SR_URL__c = SRUtility.getReferer();//Populate URL to be used in EmailNotification
                        update objFinSR;
                    }
                   
                    
                }catch (Exception e) {
                    System.debug('Error==>'+e.getMessage() +'==>'+e.getLineNumber());
                    strResult = e.getMessage();
                    return null;
                }

                if(strResult != 'Success') {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, strResult));
                    return null;
                }else{
                    if(objFinSR.recordtype.developername == 'Agent_Registration'){
                       pagereference pgf = new pagereference('/apex/DAMAC_Thank_You?Id='+objFinSR.Id + '&FlowId=' +mapParameters.get('FlowId') );
                       pgf.setredirect(true);
                       return pgf;
                    }else if(objFinSR.recordtype.developername == 'Agent_Update'){
                         pagereference pgf = new pagereference('/apex/Damac_Company_Profile?Accid='+objFinSR.NSIBPM__Customer__c);
                         pgf.setredirect(true);
                         return pgf;
                    }
                    
                }
            }else{
                AllowedToSubmit = true;
            }
        }
        if (AllowedToSubmit == true) {
            pg = objPB.getButtonAction();//if all validation pass thro and no error, then proceed to the next page , which is configured in the flow
        }
        return pg;
    }

    /*
        Method Name :   CommitRecord
        Description :   This will saves the record i.e. Insert or Update.
    */
    public void CommitRecord(){
        String strResult;
        try{
            if(objFinSR.filled_page_ids__c==null)
                objFinSR.filled_page_ids__c = '';
            if(objFinSR.filled_page_ids__c=='' || (objFinSR.filled_page_ids__c!=null && objFinSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                if(objFinSR.filled_page_ids__c=='')
                    objFinSR.filled_page_ids__c = strPageId;
                else
                    objFinSR.filled_page_ids__c = objFinSR.filled_page_ids__c+';'+strPageId;
            }
                    strResult = SRUtility.validateSRSubmit(objFinSR.id); 
                    System.debug('CommitRecord strResult ==>'+strResult);
                    if(strResult == 'Success'){
                        upsert objFinSR;
                        SRUtility.updateStepStatus('MORE_INFO_UPDATED','AWAITING_ADDITIONAL_INFO',objFinSR.Id);
                        SRUtility.updateStepStatus('FFA_AA_UPLOADED','AWAITING_FFA_AA',objFinSR.Id);
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Resubmission was successfull.'));  
                    }else{
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,strResult));  
                    }
            
            
            
        
        }catch(DMLException e){
            string DMLError = e.getdmlMessage(0)+'';
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
        }
    }
 
 
}