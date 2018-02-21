/*
    Author      :   Durga Prasad
    Description :   This class belongs to the Dynamic wizard which will constructs the Page elements from controller and defines 
                    the page flow.
    Modification
    History     :
*/
public without sharing class Process_FlowCls{
    
    public NSIBPM__Service_Request__c objSR{get;set;}
    public list<Page__c> lstPages{get;set;}
   
    public Process_FlowCls thisClass {get;set;}//not using
    
    public string strPageId{get;set;}
    public string stringActionId{get;set;}
    public string PageFlowId;
        
    public string pageTitle{get;set;}
    public string pageDescription{get;set;}
    public string strHiddenPageIds{get;set;} 
    public string strSRID{get;set;}
    public string strReqFieldIds{get;set;}
    public map<string,string> mapParameters;
    public boolean isCommunity{get;set;}
    public string strRecordType{get;set;}
    public Decimal CurrentPageOrder {get;set;}
    public boolean showHeaderAndSidebar{set;get;} //DAMAC Change
    public boolean isEditable{set;get;} //DAMAC Change
    public boolean isDocEditable{set;get;}
    public string pgParamAccid {get;set;}
    public boolean isGuestUser {get;set;}
   // public string strGeneralInstructions{get;set;}
    /*
        Constructor codes when the Page loads
    */
    public Process_FlowCls(){
       strPageId = '';
         strSRID = '';
         strHiddenPageIds = '';
         objSR = new NSIBPM__Service_Request__c();
         lstPages = new list<Page__c>();
         stringActionId = '';
         strReqFieldIds = '';
         strRecordType = '';
         pgParamAccid = '';
         isCommunity = false;
         isGuestUser = false;
         User objUser = new User();
         try{
         //if there is a contact for this logged in user, then it is a community user
         for(User objUsr:[select id,Profile.UserLicense.name,ContactId,Contact.Email,Contact.AccountId,Contact.FirstName,Contact.LastName,Contact.Account.Website from User where Id=:userinfo.getUserId()]){
            objUser = objUsr;
            if(objUsr.Profile.UserLicense.name == 'Guest User License'){
                isGuestUser = true;
            }
             else{
                 if(objUsr.ContactId!=null)
                    isCommunity = true;
             }
         }
         mapParameters = new map<string,string>();
         // all the parameters in the url are stored in this map
         if(apexpages.currentPage().getParameters()!=null && apexpages.currentPage().getParameters().size()>0)
            mapParameters = apexpages.currentPage().getParameters();
            
         pageflowId = apexpages.currentPage().getparameters().get('FlowId');
         
         if(apexpages.currentPage().getParameters().get('Id')!=null){
            strSRID = apexpages.currentPage().getParameters().get('Id');
         }
         if(apexpages.currentPage().getParameters().get('AccId')!=null){
             pgParamAccid =  apexpages.currentPage().getParameters().get('AccId');   
         }    
         strPageId = mapParameters.get('PageId');
         // to highlight the current page passed in url or highlight the page which is marked as defualt in the setup
         if(mapParameters.get('PageId')!=null){
            lstPages = [select id,Name,Is_Custom_Component__c,Page_Order__c,Page_Description__c,Page_Flow__r.Name,Page_Flow__c,Page_Flow__r.Record_Type_API_Name__c,Render_By_Default__c,VF_Page_API_Name__c from Page__c where Page_Flow__c=:pageflowId and Id=:mapParameters.get('PageId') order by Page_Order__c];
         }else{
            lstPages = [select id,Name,Is_Custom_Component__c,Page_Order__c,Page_Description__c,Page_Flow__r.Name,Page_Flow__c,Page_Flow__r.Record_Type_API_Name__c,Render_By_Default__c,VF_Page_API_Name__c from Page__c where Page_Flow__c=:pageflowId order by Page_Order__c];
         }
         // get the SR template id for the given rec type api name 
         if(lstPages!=null && lstPages.size()>0){
            pageTitle = lstPages[0].Page_Flow__r.Name;
            CurrentPageOrder = lstPages[0].Page_Order__c;
            System.debug('Page'+pageTitle);
            if(lstPages[0].Page_Flow__r.Record_Type_API_Name__c!=null){
                strRecordType = lstPages[0].Page_Flow__r.Record_Type_API_Name__c;
                for(NSIBPM__SR_Template__c srtemp:[select id from NSIBPM__SR_Template__c where NSIBPM__SR_RecordType_API_Name__c=:lstPages[0].Page_Flow__r.Record_Type_API_Name__c]){
                    objSR.NSIBPM__SR_Template__c = srtemp.Id;
                }
            }
            // page title and description are shown here
            if(strPageId == null || (strPageId!=null && strPageId == '')){
                if(lstPages[0].Render_By_Default__c==true){
                    apexpages.currentPage().getParameters().put('PageId',lstPages[0].id);
                    strPageId = lstPages[0].id;
                    pageDescription = lstPages[0].Page_Description__c;
                }
            }
            //for the given customer if there any Request of same type
            if((objUser!=null && objUser.ContactId!=null && objUser.Contact.AccountId!=null) || (pgParamAccid != null && pgParamAccid != '')){
                /*for(NSIBPM__Service_Request__c SR:[select id from NSIBPM__Service_Request__c where NSIBPM__Customer__c=:objUser.Contact.AccountId and nsibpm__internal_status_name__c='Draft' and NSIBPM__isClosedStatus__c=false and NSIBPM__IsCancelled__c=false and NSIBPM__Is_Rejected__c=false and RecordType.DeveloperName=:strRecordType]){
                    strSRID = SR.Id;
                    mapParameters.put('Id',strSRID);
                }*/
                string accid = '';
                if(objUser.Contact.AccountId!=null)
                	accid = objUser.Contact.AccountId;
                else if(pgParamAccid != null && pgParamAccid != '')
					accid = pgParamAccid;                    
                NSIBPM__Service_Request__c objSRPending = UtilityQueryManager.checkPendingSR(accid);
                if(null != objSRPending){
                    strSRID = objSRPending.Id;
                    mapParameters.put('Id',strSRID);
                }   
            }
        }
        if(strSRID!=null && strSRID!=''){
            if(pageflowId!=null && pageflowId!=''){
                //query all the fields configured in the page are query here.
                String strQuery = '';
                strQuery += UtilityQueryManager.getAllFields(NSIBPM__Service_Request__c.getsObjecttype().getDescribe()) ;
                strQuery += '  where Id =:strSRID ';
                for(NSIBPM__Service_Request__c SR:database.query(strQuery)){
                    objSR = SR;
                    
                }
            }
         }else{
            if(strRecordType!=null && strRecordType!=''){
                for(RecordType rec:[Select Id,Name from RecordType where developerName=:strRecordType and sObjectType='NSIBPM__Service_Request__c']){
                    objSR.RecordTypeId = rec.Id;
                }
            }
         }
         
         if(objUser!=null && objUser.ContactId!=null && objUser.Contact.AccountId!=null){
            objSR.NSIBPM__Customer__c = objUser.Contact.AccountId;
            if(objUser.Contact.FirstName!=null)
                objSR.First_Name__c = objUser.Contact.FirstName;
            if(objUser.Contact.LastName!=null)
                objSR.Last_Name__c = objUser.Contact.LastName;
         
         }
         objSR.Is_Flow_Request__c = true;
         IF(pageflowId!=NULL && pageflowId!='')
            objSR.flow_id__c = pageflowId;
         thisClass = this;
         System.debug('SR RT Name==>'+objSR.NSIBPM__Customer__c);
             System.debug('SR RT Name==>'+strRecordType);
         if(objSR.NSIBPM__Customer__c!=null){
             objSR = prePopulateServiceRequest(objSR,objSR.NSIBPM__Customer__c,strRecordType);
         }
         else if(pgParamAccid != null && pgParamAccid != ''){
             objSR.NSIBPM__Customer__c = pgParamAccid;
             objSR = prePopulateServiceRequest(objSR,pgParamAccid,strRecordType);    
         }
         
          //DAMAC Change
         if(pageflowId != NULL && pageflowId != ''){
            showHeaderAndSidebar = (pageflowId == UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Page_Flow_Name))?false:true;
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
         if(NULL != objSR && null != objSR.nsibpm__internal_status_name__c &&
            (objSR.nsibpm__internal_status_name__c != 'Draft' && objSR.nsibpm__internal_status_name__c != 'Requested for Info' && 
            objSR.nsibpm__internal_status_name__c != 'Document Rejected')){
            isEditable = false;
            isDocEditable = false;
         }
         else if((NULL != objSR && null != objSR.nsibpm__internal_status_name__c 
              && (objSR.nsibpm__record_type_name__c == 'Agent_Registration' || objSR.nsibpm__record_type_name__c == 'Agent_Update')  &&
            (objSR.nsibpm__internal_status_name__c == 'Requested for Info' || 
             objSR.nsibpm__internal_status_name__c == 'Document Rejected') && objSR.Document_Generated__c)){
             isEditable = false;
             isDocEditable = true;    
         }
         
             if(!isEditable){
                 isEditable = SRUtility.isUserwithEditPermissions();
             }
     }
     catch(Exception e){
       System.debug('Error==>'+e.getMessage());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please contact DAMAC support. Error - '+ e.getMessage())); 
         return;
     }
         

    }
    public pagereference Redirect_DefaultCustomPage(){
        pagereference pg;
        
        return null;
    }
    
    
    /*
        Method Name :   prepare_Page_Description
        Description :   This will Re-prepares the Page title & Description for the Current Page.
    */
    public void prepare_Page_Description(){
        if(strPageId!=null && strPageId!=''){
            for(Page__c objPG:[select id,Name,Page_Description__c,Page_Flow__r.Name from Page__c where id=:strPageId]){
                pageTitle = objPG.Page_Flow__r.Name;
                pageDescription = objPG.Page_Description__c;
            }
        }else{
            pageTitle = '';
            pageDescription = '';
        }
    }
    
    /*
        Method Name :   getClass
        Description :   This will returns the current Class Instance for the Sidebar Component.
    */
    public Process_FlowCls getClass(){
        return this;
    }
    
    /*
        Method Name :   getDyncPgMainPB
        Description :   Method which will creates the Dynamic VF Components based on the Configuration defined
    */
    public Component.Apex.PageBlock getDyncPgMainPB(){
        strHiddenPageIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        strPageId = mapParameters.get('PageId');
        if(strPageId!=null && strPageId!=''){
            prepare_Page_Description();
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            for(Section__c objSec:[select id,Name,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Cancel_Request__c,Object_Name__c,Order__c,Section__c,Field_Description__c,Default_Value__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c from Section_Details__r order by Order__c), 
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Page__c=:strPageId order by Order__c,Section_Type__c]){
                lstSec.add(objSec);
                if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                    for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                        if(objSecDet.Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Navigation_Rule__c SDRenRule:[select id,Rule_Text_Condition__c,Section_Detail__c from Page_Navigation_Rule__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Navigation_Rule__c> lstSDRenRules = new list<Page_Navigation_Rule__c>();
                    if(mapSecDetailRenderRules.get(SDRenRule.Section_Detail__c)!=null && mapSecDetailRenderRules.get(SDRenRule.Section_Detail__c).size()>0){
                        lstSDRenRules = mapSecDetailRenderRules.get(SDRenRule.Section_Detail__c);
                        lstSDRenRules.add(SDRenRule);
                    }else{
                        lstSDRenRules.add(SDRenRule);
                    }
                    mapSecDetailRenderRules.put(SDRenRule.Section_Detail__c,lstSDRenRules);
                }
            }
            //looping all section of the current page 
            for(Section__c objSec:lstSec){
                boolean bBuildSection = false;
                if(objSec.Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        //looping navig rule and evaluate the condit.
                        for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                            boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }
                }
                if(bBuildSection==true && objSec.Section_Type__c=='PageBlockSection'){
                    Component.Apex.PageBlockSection dycPB = new Component.Apex.PageBlockSection();
                    dycPB.Id = 'PBS_'+objSec.Id;
                    //no of columns in the layout 
                    dycPB.columns = Integer.valueOf(objSec.layout__c);
                    dycPB.Title = objSec.Name;
                    
                    Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                    pageBlockSectionWrapper.layout = 'block';
                    pageBlockSectionWrapper.styleClass = 'colLayout' + objSec.layout__c+' pageBlockSectionWrapper';
                    pageBlockSectionWrapper.childComponents.add(dycPB);
                    
                    if (objSec.Section_Description__c != '' && objSec.Section_Description__c != null){
                        Component.Apex.OutPutPanel sectDesc = new Component.Apex.OutPutPanel();
                        sectDesc.layout = 'block';
                        sectDesc.styleClass = 'sectionDescription';
                        Component.Apex.outputtext sectDescLabel = new Component.Apex.outputtext(escape=false);
                        sectDescLabel.value = objSec.Section_Description__c;
                        sectDesc.childComponents.add(sectDescLabel);
                        dycPB.childComponents.add(sectDesc);
                    }
                    // input or output field
                    if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        dycPB.Title = objSec.Name;
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = Cls_Evaluate_Conditions.executeNavigationRules(SDRendRule.Rule_Text_Condition__c,objSR);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;                         
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Input Field'){
                                pb.mode = 'Edit';
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                
                                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                Schema.SObjectType ObjSchema;
                                
                                if(objSecDet.Default_Value__c!=null && objSR.get(objSecDet.Field_API_Name__c)==null)
                                    objSR.put(objSecDet.Field_API_Name__c,objSecDet.Default_Value__c);
                                    
                                Component.Apex.inputfield inpFld = new Component.Apex.inputfield();
                                inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                PBSItem.Id = 'PBSItem'+'_'+inpFld.Id;
                                if(objSecDet.Object_Name__c=='NSIBPM__Service_Request__c'){
                                    inpFld.expressions.value = '{!objSR.'+objSecDet.Field_API_Name__c+'}';
                                    ObjSchema = schemaMap.get('NSIBPM__Service_Request__c');
                                }
                                //on change event is invoking the javascript method
                                if(objSecDet.hasOnChange__c==true)
                                    inpFld.onChange='InvokeChangeEvent();return false;';
                                // if label is not defined for a field then get it from definition
                                Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();

                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.Component_Label__c;
                                if (objSecDet.Component_Label__c == '' || objSecDet.Component_Label__c == null)
                                    Fldlabel.value = fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.Component_Label__c;
                                //help text after the field
                                Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel(escape=false);
                                FldDescription.value = objSecDet.Field_Description__c;
                                // three panels to display label field description
                                Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                labelPanel.layout = 'block';
                                labelPanel.styleClass = 'labelWrapper';
                                
                                Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                fieldPanel.layout = 'block';
                                fieldPanel.styleClass = 'fieldWrapper';
                                
                                Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                fDescPanel.layout = 'block';
                                fDescPanel.styleClass = 'descWrapper';

                                labelPanel.childComponents.add(Fldlabel);
                                // to bring the red bar for required field
                                if(objSecDet.Mark_it_as_Required__c){
                                    Component.Apex.OutPutPanel ReqBlockMainPnl = new Component.Apex.OutPutPanel();
                                    ReqBlockMainPnl.styleClass = 'requiredInput';
                                    ReqBlockMainPnl.layout = 'block';
                                    
                                    Component.Apex.OutPutPanel ReqBlockFldPnl = new Component.Apex.OutPutPanel();
                                    ReqBlockFldPnl.id=inpFld.Id+'_ReqBlock';
                                    ReqBlockFldPnl.styleClass = 'requiredBlock';
                                    ReqBlockFldPnl.layout = 'block';
                                    
                                    ReqBlockMainPnl.childComponents.add(ReqBlockFldPnl);
                                    ReqBlockMainPnl.childComponents.add(inpFld);
                                    
                                    fieldPanel.childComponents.add(ReqBlockMainPnl);
                                    if(strReqFieldIds==''){
                                        strReqFieldIds = inpFld.Id;
                                    }else{
                                        strReqFieldIds = strReqFieldIds+','+inpFld.Id;
                                    }
                                }else{
                                    fieldPanel.childComponents.add(inpFld);
                                }

                                /*if(objSecDet.Field_API_Name__c=='Agency_Name__c'){
                                    inpFld.onBlur = 'AutoFillAgentArabic();return false;';
                                    inpFld.onkeyUp = 'AutoFillAgentArabic();return false;';
                                }*/

                                 if(objSecDet.Field_API_Name__c=='Fax__c' || 
                                    objSecDet.Field_API_Name__c == 'Phone_Number__c' ||
                                    objSecDet.Field_API_Name__c == 'Telephone__c' ||
                                    objSecDet.Field_API_Name__c == 'Agency_Mobile__c'
                                    ){
                                    inpFld.onkeypress='return isNumber(event)';
                                }
                                
                                fDescPanel.childComponents.add(FldDescription);
                                
                                PBSItemPnl.childComponents.add(labelPanel);
                                
                                PBSItemPnl.childComponents.add(fieldPanel);
                                
                                if(objSec.layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);
                                
                                PBSItem.childComponents.add(PBSItemPnl);
                                
                                dycPB.childComponents.add(PBSItem);
                                
                            }else if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Blank Space'){// && objSec.layout__c == '2'
                                
                                pb.mode = 'edit';
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                PBSItem.childComponents.add(PBSItemPnl);
                                dycPB.childComponents.add(PBSItem);
                                
                            }else if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Output Field'){
                                pb.mode = 'Detail';
                                dycPB.collapsible = false;
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                
                                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                Schema.SObjectType ObjSchema;
                                
                                Component.Apex.Outputfield inpFld = new Component.Apex.Outputfield();
                                inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                if(objSecDet.Object_Name__c=='NSIBPM__Service_Request__c'){
                                    inpFld.expressions.value = '{!objSR.'+objSecDet.Field_API_Name__c+'}';
                                    ObjSchema = schemaMap.get('NSIBPM__Service_Request__c');
                                }
                                
                                Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();

                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.Component_Label__c;
                                if (objSecDet.Component_Label__c == '' || objSecDet.Component_Label__c == null)
                                    Fldlabel.value = fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.Component_Label__c;
                                
                                Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel();
                                FldDescription.value = objSecDet.Field_Description__c;
                                
                                Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                labelPanel.layout = 'block';
                                labelPanel.styleClass = 'labelWrapper';
                                
                                Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                fieldPanel.layout = 'block';
                                fieldPanel.styleClass = 'fieldWrapper';
                                
                                Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                fDescPanel.layout = 'block';
                                fDescPanel.styleClass = 'descWrapper';

                                labelPanel.childComponents.add(Fldlabel);
                                fieldPanel.childComponents.add(inpFld);
                                
                                fDescPanel.childComponents.add(FldDescription);
                                
                                PBSItemPnl.childComponents.add(labelPanel);
                                PBSItemPnl.childComponents.add(fieldPanel);
                                
                                if (objSec.layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);
                                
                                PBSItem.childComponents.add(PBSItemPnl);
                                
                                dycPB.childComponents.add(PBSItem);
                            }
                        }
                    }
                    pb.childComponents.add(pageBlockSectionWrapper);
                }else if(bBuildSection==true && objSec.Section_Type__c=='CommandButtonSection'){
                    if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = Cls_Evaluate_Conditions.executeNavigationRules(SDRendRule.Rule_Text_Condition__c,objSR);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;                         
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width:70px;min-height:20px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                // on click of commit record = true  it is a save button
                                if(objSecDet.Commit_the_Record__c==false && objSecDet.Cancel_Request__c==false){
                                    //for prev button Ignore_Required_Fields__c is marked as true 
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }else if(objSecDet.Cancel_Request__c==true){
                                    dycBtn.onClick = 'CancelRequest();return false;';
                                }
                                //button locations                             
                                if(objSecDet.Button_Location__c!=null)
                                    PBtns.location = objSecDet.Button_Location__c;
                                if (objSecDet.Button_Position__c == 'left')
                                    dycBtn.styleClass = 'left';
                                else if (objSecDet.Button_Position__c == 'right')
                                    dycBtn.styleClass = 'right';
                                PBtns.childComponents.add(dycBtn);
                            }
                        }
                    }
                }
            }
        }
        if(pageflowId==null || pageflowId==''){
            pageflowId = apexpages.currentPage().getparameters().get('FlowId');
        }
        if(pageflowId!=null && pageflowId!=''){
            strHiddenPageIds = PreparePageBlockUtil.getHiddenPageIds(pageflowId,objSR);
        }
        return pb;
    }
    /*
        Method Name :   RePrepareSection
        Description :   Dummy method which is used to refresh the Dynamic PB to re-prepare the Fields based on new Values
    */
    public void RePrepareSection(){
        
    }
    
    public void createdocuments(){
        //create documents for individual sr type.
        list<NSIBPM__SR_Doc__c> lstSRDocs_throughCode = new list<NSIBPM__SR_Doc__c>();
        list<NSIBPM__SR_Doc__c> lstSRDocs_todelete = new list<NSIBPM__SR_Doc__c>();
        Map<string,NSIBPM__SR_Doc__c> mpdocCodeSRDoc = new Map<string,NSIBPM__SR_Doc__c>();
        Map<String, String> mpGCC = new Map<String, String>{'Bahrain' => '1', 'Kuwait' => '2', 'Oman' => '3', 'Qatar' => '4','Saudi Arabia' => '5','United Arab Emirates' => '6'};
            
        for(NSIBPM__SR_Doc__c srdoc : [Select id, NSIBPM__Doc_ID__c,NSIBPM__Document_Master__r.NSIBPM__Code__c from NSIBPM__SR_Doc__c Where Amendment__c = null AND NSIBPM__Service_Request__c =: objSR.id and NSIBPM__SR_Template_Doc__r.NSIBPM__Added_through_Code__c = true]){
            mpdocCodeSRDoc.put(srdoc.NSIBPM__Document_Master__r.NSIBPM__Code__c,srdoc);
        }
        
        String SRQuery = UtilityQueryManager.getAllFields(NSIBPM__Service_Request__c.getsObjectType().getDescribe());
        SRQuery += ' WHERE id =\''+ objSR.id +'\'';
        for (NSIBPM__Service_Request__c sr : Database.query(SRQuery)) {
            objSR = sr;
        } 
        
        if(objSR.Agency_Type__c != null && objSR.Agency_Type__c == 'Individual' && objSR.id != null){
            for (NSIBPM__SR_Template_Docs__c SRTemplateDoc : [Select Id, Name, NSIBPM__Group_No__c, NSIBPM__Document_Master__r.NSIBPM__Code__c, NSIBPM__Requirement__c, NSIBPM__Generate_Document__c, NSIBPM__DMS_Document_Index__c, NSIBPM__Added_through_Code__c, NSIBPM__Document_Description_External__c, NSIBPM__SR_Template__c, NSIBPM__Document_Master__c, NSIBPM__Optional__c, NSIBPM__Document_Description__c, NSIBPM__Document_Name_for_SR__c, NSIBPM__Document_Master__r.Name from NSIBPM__SR_Template_Docs__c where NSIBPM__SR_Template__r.NSIBPM__SR_RecordType_API_Name__c = :objSR.nsibpm__record_type_name__c and NSIBPM__Added_through_Code__c = true and NSIBPM__On_Submit__c = true]) {
                String docCode = SRTemplateDoc.NSIBPM__Document_Master__r.NSIBPM__Code__c;
                String docName = SRTemplateDoc.NSIBPM__Document_Master__r.Name;
                //For agent registration
                if(objSR.NSIBPM__Record_Type_Name__c == 'Agent_Registration')
                {
                    if (docCode == 'PASSPORT_COPY') {
                        lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                    }
                    else if(docCode == 'VISA_COPY'){
                        //if((objSR.ID_Type__c != null && objSR.ID_Type__c == 'Visa') || (objSR.Nationality__c != null && objSR.Country__c != null && mpGCC.containskey(objSR.Country__c) && !mpGCC.containskey(objSR.Nationality__c))){
                        if((objSR.ID_Type__c != null && objSR.ID_Type__c == 'Visa') || (objSR.Nationality__c != null && objSR.Country__c != null && objSR.Nationality__c != objSR.Country__c && ((mpGCC.containskey(objSR.Country__c) && !mpGCC.containskey(objSR.Nationality__c)) || (!mpGCC.containskey(objSR.Country__c) && mpGCC.containskey(objSR.Nationality__c)) || (!mpGCC.containskey(objSR.Country__c) && !mpGCC.containskey(objSR.Nationality__c))))){
                        	lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                    else if(docCode == 'BROKER_CARD'){
                        if(objSR.Eligible_to_Sell_in_Dubai__c){
                            lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                    else if(docCode == 'NATIONAL_ID_COPY'){
                        if(objSR.ID_Type__c != null && objSR.ID_Type__c == 'National ID'){
                            lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                }
                //for agent update
                else if(objSR.NSIBPM__Record_Type_Name__c == 'Agent_Update'){
                    if(docCode == 'VISA_COPY'){
                        //if((objSR.ID_Type_Change__c && objSR.ID_Type__c == 'Visa') || objSR.IsVisaChge__c || (objSR.Nationality__c != null && objSR.Country__c != null && mpGCC.containskey(objSR.Country__c) && !mpGCC.containskey(objSR.Nationality__c))){
                        if((objSR.ID_Type_Change__c && objSR.ID_Type__c == 'Visa') || objSR.IsVisaChge__c || (objSR.IsChgeNationality_Country__c && objSR.Nationality__c != null && objSR.Country__c != null && objSR.Nationality__c != objSR.Country__c && ((mpGCC.containskey(objSR.Country__c) && !mpGCC.containskey(objSR.Nationality__c)) || (!mpGCC.containskey(objSR.Country__c) && mpGCC.containskey(objSR.Nationality__c)) || (!mpGCC.containskey(objSR.Country__c) && !mpGCC.containskey(objSR.Nationality__c))))){
							lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                    else if(docCode == 'BROKER_CARD'){
                        if(objSR.Broker_Card_Change__c){
                            lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                    else if(docCode == 'NATIONAL_ID_COPY'){
                        if((objSR.ID_Type_Change__c && objSR.ID_Type__c == 'National ID') || (objSR.IsNationalIDChge__c)){
                            lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                    else if(docCode == 'PASSPORT_COPY'){
                        if((objSR.ID_Type_Change__c && objSR.ID_Type__c == 'Passport') || (objSR.IsPassportChge__c) || (objSR.Address_Change__c) || (objSR.Name_Change_Individual_Accnt__c)){
                            lstSRDocs_throughCode.add(createSRDoc(docName , SRTemplateDoc,mpdocCodeSRDoc));
                        }
                        else{
                            if(mpdocCodeSRDoc.containskey(docCode))
                                lstSRDocs_todelete.add(mpdocCodeSRDoc.get(docCode));
                        }
                    }
                }
                
            }
        }
        else if(objSR.Agency_Type__c != null && objSR.Agency_Type__c == 'Corporate' && objSR.id != null){
            delete ([Select id, NSIBPM__Doc_ID__c from NSIBPM__SR_Doc__c Where Amendment__c = null AND NSIBPM__Service_Request__c =: objSR.id and NSIBPM__SR_Template_Doc__r.NSIBPM__Added_through_Code__c = true]);
        }
        
        if (!lstSRDocs_todelete.isEmpty()) {
            System.debug('lstSRDocs_todelete==>' + lstSRDocs_todelete);
            delete lstSRDocs_todelete;
        }
        
        if (!lstSRDocs_throughCode.isEmpty()) {
            System.debug('lstSRDocs_throughCode==>' + lstSRDocs_throughCode);
            upsert lstSRDocs_throughCode Unique_SR_Doc_Name__c;
        }
    }
    
		public NSIBPM__SR_Doc__c createSRDoc(String docName, NSIBPM__SR_Template_Docs__c SRTmpDoc,Map<string,NSIBPM__SR_Doc__c> mpSRDoc) {
            NSIBPM__SR_Doc__c objSRDoc = new NSIBPM__SR_Doc__c();
            if(mpSRDoc.containskey(SRTmpDoc.NSIBPM__Document_Master__r.NSIBPM__Code__c)){
                objSRDoc.id = mpSRDoc.get(SRTmpDoc.NSIBPM__Document_Master__r.NSIBPM__Code__c).id;
            }
            if (docName.length() > 80)
                docName = docName.subString(0, 79);
            objSRDoc.Name = docName;
            objSRDoc.NSIBPM__Service_Request__c = objSR.Id;
            objSRDoc.NSIBPM__SR_Template_Doc__c = SRTmpDoc.Id;
            objSRDoc.NSIBPM__Status__c = 'Pending Upload';
            objSRDoc.NSIBPM__Document_Master__c = SRTmpDoc.NSIBPM__Document_Master__c;
            objSRDoc.NSIBPM__Group_No__c = SRTmpDoc.NSIBPM__Group_No__c;
            objSRDoc.NSIBPM__Is_Not_Required__c = SRTmpDoc.NSIBPM__Optional__c;
            objSRDoc.NSIBPM__Generate_Document__c = SRTmpDoc.NSIBPM__Generate_Document__c;
            objSRDoc.NSIBPM__Document_Description_External__c = SRTmpDoc.NSIBPM__Document_Description_External__c;
            objSRDoc.NSIBPM__Sys_IsGenerated_Doc__c = SRTmpDoc.NSIBPM__Generate_Document__c;
            objSRDoc.NSIBPM__Unique_SR_Doc__c = SRTmpDoc.NSIBPM__Document_Master__r.Name + '_' + objSR.name;
            objsrdoc.Unique_SR_Doc_Name__c = objSRDoc.NSIBPM__Unique_SR_Doc__c;
            objSRDoc.NSIBPM__From_Finalize__c = true;
            // System.debug('DocID ==>'+SRTmpDoc.NSIBPM__Document_Master__r.Name + '_' +amdId);
            return objSRDoc;
    	}

    
    /*
        Method Name :   DynamicButtonAction
        Description :   Action Method which Dynamically Changes the layout & Actions based on the Configuration
    */
    public PageReference DynamicButtonAction(){
        string whatId = ''; 
        try{
            if(stringActionId!=null && stringActionId!=''){
                boolean hasPGNavRule = false;
                boolean isNext = false;
                for(Section_Detail__c objSecDtl:[select id,Name,Navigation_Direction__c,(select id from Page_Navigation_Rule__r) from Section_Detail__c where Id=:stringActionId]){
                    if(objSecDtl.Navigation_Direction__c=='Forward')
                        isNext = true;
                        
                    if(objSecDtl.Page_Navigation_Rule__r!=null && objSecDtl.Page_Navigation_Rule__r.size()>0){
                        hasPGNavRule = true;
                    }
                } 
                if(isNext==true){
                    try{
                        if(objSR.filled_page_ids__c==null)
                            objSR.filled_page_ids__c = '';
                        if(objSR.filled_page_ids__c=='' || (objSR.filled_page_ids__c!=null && objSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                            if(objSR.filled_page_ids__c=='')
                                objSR.filled_page_ids__c = strPageId;
                            else
                                objSR.filled_page_ids__c = objSR.filled_page_ids__c+';'+strPageId;
                        }
                        /*//Validate if Agency Type is Corporate
                        if(validateAgencyType()){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Agency type cannot be Individual.'));
                            return null;
                        }*/
                        //Validate Duplicate Trade Licence Number
                        if(objSR.Trade_License_Number__c != null || (objSR.ID_Type__c != null && objSR.ID_Number__c != null)){
                            List<Account> dupAccList = SRUtility.checkDupTLNumber(objSR.Trade_License_Number__c,strRecordType,objSR.Agency_Type__c,objSR.ID_Type__c,objSR.ID_Number__c);
                            if(dupAccList.size() > 0  ){
                               String errStr;
                                if(dupAccList[0].Blacklisted__c && dupAccList[0].Terminated__c){
                                    errStr = 'Matching Account found. Account is Blacklisted and Terminated.';
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errStr));
                               		 return null;
                                }
                                else if(dupAccList[0].Terminated__c){
                                    errStr = 'Matching Account found and is Terminated.';
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errStr));
                               		 return null;
                                }
                                else if(dupAccList[0].Blacklisted__c){
                                    errStr = 'Matching Account found and is Blacklisted.';
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errStr));
                               		 return null;
                                }
                                if(objSR.Agency_Type__c == 'Corporate'){
                                    errStr = 'This account already exits. Trade Licence Number is duplicate.';
                                }else if(objSR.Agency_Type__c == 'Individual'){
                                    errStr = 'This account already exits. ID Type and ID Number match found.';
                                }
                               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errStr));
                                return null;
                           }
                        }
                        String  ref = SRUtility.getReferer();
                        upsert objSR;
                        createdocuments();
                       objSr.SR_URL__c = (objSr.SR_URL__c == NULL) ?  ref + '&Id=' +string.valueOf(objSR.Id) : objSr.SR_URL__c;//Populate URL to be used in EmailNotification, Populate only once
                        update objSR;
                        apexpages.currentPage().getParameters().put('Id',string.valueOf(objSR.Id));
                    }catch(DMLException e){
                        string DMLError = e.getdmlMessage(0)+'';
                        if(DMLError==null){
                            DMLError = e.getMessage()+'';
                        }
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
                        return null;
                    }
                }
                PreparePageBlockUtil.FlowId = mapParameters.get('FlowId'); 
                PreparePageBlockUtil.PageId = mapParameters.get('PageId');
                PreparePageBlockUtil.objSR = objSR;
                PreparePageBlockUtil.ActionId = stringActionId;
                
                PreparePageBlockUtil objPB = new PreparePageBlockUtil();
                pagereference pg = objPB.getButtonAction();
                return pg;
                
            }
        }catch(Exception e){
            
        }
        return null;
    }
    
    /*
        Method Name :   CommitRecord
        Description :   This will saves the record i.e. Insert or Update.
    */
    public void CommitRecord(){
        try{
            if(objSR.filled_page_ids__c==null)
                objSR.filled_page_ids__c = '';
            if(objSR.filled_page_ids__c=='' || (objSR.filled_page_ids__c!=null && objSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                if(objSR.filled_page_ids__c=='')
                    objSR.filled_page_ids__c = strPageId;
                else
                    objSR.filled_page_ids__c = objSR.filled_page_ids__c+';'+strPageId;
            }
            
            upsert objSR;
            createDocuments();
            SRUtility.updateStepStatus('REQUESTED_FOR_INFO','MORE_INFO_UPDATED',objSR.Id);
        }catch(DMLException e){
            string DMLError = e.getdmlMessage(0)+'';
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
        }
    }
    
    /*
        Method Name :   CancelSR
        Decription  :   This will cancel the Open SR and the PriceItems of the SR also get cancelled.
    */
    public pagereference CancelSR(){
        Pagereference pg = new PageReference('');
        pg.setRedirect(true); 
        return pg;
    }
    public string strNavigatePageId{get;set;}
    public pagereference goTopage(){
        //when user clicks on any of the side bar page, id will be assinged to this variable
        if(strNavigatePageId!=null && strNavigatePageId!=''){
            try{
                if(objSR.filled_page_ids__c==null)
                    objSR.filled_page_ids__c = '';
                if(objSR.filled_page_ids__c=='' || (objSR.filled_page_ids__c!=null && objSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                    if(objSR.filled_page_ids__c=='')
                        objSR.filled_page_ids__c = strPageId;
                    else
                        objSR.filled_page_ids__c = objSR.filled_page_ids__c+';'+strPageId;
                }
                upsert objSR;
                createdocuments();
                PreparePageBlockUtil objSidebarRef = new PreparePageBlockUtil();
                PreparePageBlockUtil.strSideBarPageId = strNavigatePageId;
                PreparePageBlockUtil.objSR = objSR;
                return objSidebarRef.getSideBarReference(); // page reference is return dynamically
                
            }catch(dmlexception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getdmlMessage(0)+''));
                return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()+''));
                return null;
            }
        }
         return null;
    }
  
/**
 * [prePopulateServiceRequest - Prepopulate SR fields  with Account details previously saved]
 * @param  SR        [Service Request]
 * @param  AccountId [Id of Account - Customer__c]
 * @param  RTName    [RecordType Name - to copy RT specific fields]
 * @return           [description]
 */
public NSIBPM__Service_Request__c prePopulateServiceRequest(NSIBPM__Service_Request__c SR, Id AccountId,String RTName)
    {
        System.debug('NSI Process_FlowCls prePopulateServiceRequest');
        System.debug('AccountId '+AccountId + 'RecordTypeId :'+RTName +'SR==>'+SR);
        List<Account_SR_Field_Mapping__c> CS = Account_SR_Field_Mapping__c.getAll().values();
        
        List<Account> accList = new List<Account>();
        accList  = getAccInfo(AccountId,RTName);
        If(accList.size() >0 ){
            string agencyType = SR.Agency_type__c != null ? SR.Agency_type__c : (accList[0].Agency_Type__c != null ? accList[0].Agency_Type__c : '');
            if(agencyType != null && agencyType != ''){
                for(Account_SR_Field_Mapping__c mapping : CS){
                    if(mapping.RecordType_Name__c.equals(RTName) ){
                        if(agencyType == 'Corporate'){
                            if(!mapping.Is_Person_Account__c)
                            SR.put(mapping.SR_Field__c,((SR.get(mapping.SR_Field__c) != NULL && SR.get(mapping.SR_Field__c) !='')  || SR.Id != NULL ) ? SR.get(mapping.SR_Field__c) :  accList[0].get(mapping.Account_Field__c));
                        }
                        else{
                            if(mapping.Is_Person_Account__c || mapping.Is_Common_to_All_RT__c)
                            	SR.put(mapping.SR_Field__c,((SR.get(mapping.SR_Field__c) != NULL && SR.get(mapping.SR_Field__c) !='')  || SR.Id != NULL ) ? SR.get(mapping.SR_Field__c) :  accList[0].get(mapping.Account_Field__c));
                        }
                    }
                }
                
            }
            /*for(Account_SR_Field_Mapping__c mapping : CS){
                if(mapping.RecordType_Name__c.equals(RTName) ){
                    System.debug('RTName==>'+mapping.RecordType_Name__c + 'AccField==>'+mapping.Account_Field__c + 'SRField==>' + mapping.SR_Field__c);
                    System.debug('SR Val:'+SR.get(mapping.SR_Field__c));
                    System.debug('Acc Val:'+accList[0].get(mapping.Account_Field__c));
                    //SR.put(mapping.SR_Field__c,accList[0].get(mapping.Account_Field__c));
                    SR.put(mapping.SR_Field__c,((SR.get(mapping.SR_Field__c) != NULL && SR.get(mapping.SR_Field__c) !='')  || SR.Id != NULL ) ? SR.get(mapping.SR_Field__c) :  accList[0].get(mapping.Account_Field__c));
                    System.debug('SR==>'+SR);
                }
            }*/
        }
        return SR;
    }
    public List<Account> getAccInfo(ID AccountId,String RTName){
        List<Account_SR_Field_Mapping__c> CS = Account_SR_Field_Mapping__c.getAll().values();
        List<Account> accList = new List<Account>();
        Map<string,integer> mpuniquesfields = new Map<string,integer>();
        String accQuery = 'SELECT Id,';
        for(Account_SR_Field_Mapping__c mapping : CS)
        {
            if(mapping.RecordType_Name__c.equals(RTName) && mapping.Account_Field__c.tolowercase()!='id'){
                mpuniquesfields.put(mapping.Account_Field__c,1);
            }
        }
        List<string> uniqFields = new List<string>();
        uniqFields.addall(mpuniquesfields.keyset());
        //if(!mpuniquesfields.containskey(mapping.Account_Field__c))accQuery += mapping.Account_Field__c + ',';elsempuniquesfields.put(mapping.Account_Field__c,1);
        accQuery += string.join(uniqFields, ',');
        accQuery += ' FROM Account';
        accQuery += ' WHERE  Id = :AccountId LIMIT 1';
        System.debug('**'+accQuery);
        accList = database.query(accQuery);
        return accList;


    }

 public boolean validateAgencyType(){
    System.debug('Process_Flow-DynamicButtonAction-validateAgencyType');
        System.debug('strRecordType =>'+strRecordType);
        Boolean invalid = false;
        if(strRecordType == 'Agent_Registration' && objSR.Agency_Type__c != 'Corporate'){
            invalid = true;
        }
        return invalid;
    }

}