public without sharing class NSI_Ctrl_StepTransitions{
    public NSIBPM__Step__c step{get;set;}
    public NSIBPM__Service_Request__c objSR{get;set;}
    public String CancelLink {get;set;}
    public String StepLink {get;set;}
    public string SRID{get;set;}
    public string StepID{get;set;}
    public boolean hasAccess{get;set;}
    public boolean showDPPercentage {get;set;}
    User objCurrentUser;
    public map<string,string> MapDelegatedUsers;
    public string userType{get;set;}
    public list<TransitionWrapper> lstTrnsWrap{get;set;}
    public Integer iListSize{get;set;}
    map<id,NSIBPM__Step_Transition__c> mapStepTransition;
    public NSI_Ctrl_StepTransitions(ApexPages.StandardController controller){
        lstTrnsWrap = new list<TransitionWrapper>();
        showDPPercentage = false;
        iListSize = 0;
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            SRID = apexpages.currentpage().getParameters().get('Id');
        }
        step = new NSIBPM__Step__c();
        if(apexpages.currentpage().getParameters().get('StepId')!=null){
            StepID = apexpages.currentpage().getParameters().get('StepId');
            for(NSIBPM__Step__c stp:[SELECT Id, Name, NSIBPM__Summary__c, RecordTypeId, NSIBPM__Step_Status__c,  
                                     RecordType.DeveloperName, OwnerId, Owner.Name, RecordType.Name, NSIBPM__Parent_Step__c, 
                                     NSIBPM__SR__c, NSIBPM__SR__r.NSIBPM__SR_Template__c, NSIBPM__Status__c, NSIBPM__SR_Step__c, 
                                     NSIBPM__Rejection_Reason__c, NSIBPM__Status__r.Name ,NSIBPM__SR_Step__r.NSIBPM__Step_Template_Code__c
                                     FROM NSIBPM__Step__c 
                                     WHERE id!=null and Id=:StepID and NSIBPM__SR__c!=null and NSIBPM__SR__r.NSIBPM__SR_Template__c!=null and IsDeleted=false]){
                                         step = stp;
                                     }
            objSR = SRUtility.getSRDetails(step.NSIBPM__SR__c);
            if(step.NSIBPM__SR_Step__r != null && step.NSIBPM__SR_Step__r.NSIBPM__Step_Template_Code__c != null && step.NSIBPM__SR_Step__r.NSIBPM__Step_Template_Code__c == 'UPLOAD_POP'){
                showDPPercentage = true;
            }
        }
        hasAccess = false;
        objCurrentUser = new User();
        for(User curUser:[select Id,ContactId,ProfileId,Profile.UserLicenseId,Profile.UserLicense.Name,Profile.UserLicense.LicenseDefinitionKey,Profile.Name from User where id!=null and Id=:userInfo.getUserId() and IsActive=true]){
            objCurrentUser = curUser;
            if(curUser.ContactId==null){
                userType = 'salesforce';
                CancelLink = '/'+SRID;
                StepLink =  '/'+StepId;
            }else{
                userType = 'Community';
                CancelLink = '/agents/'+SRID;
                StepLink =  '/agents/'+StepId;
            }
        }
    }
    public void Check_Permissions(){
        MapDelegatedUsers = new map<string,string>();
        MapDelegatedUsers = GetDelegatedUsers(objCurrentUser.Id);
        if(step.OwnerId==userinfo.getUserId() || MapDelegatedUsers.get(step.OwnerId)!=null || (objCurrentUser!=null && objCurrentUser.Profile.Name=='System Administrator')){
            hasAccess = true;
        }else if(userType!=null && userType=='Community'){
            hasAccess = true;
        }else{
            if(string.valueOf(step.OwnerId).substring(0,3)=='00G'){
                getGroupData(step.OwnerId);
                system.debug('#### lstGroupsData = '+lstGroupsData);
                for(GroupDetails GD:lstGroupsData){
                    if(GD.GroupOrUserId==userinfo.getUserId()){
                        hasAccess = true;
                        break;
                    }
                }
            }
        }
        //hasAccess = false;
        Prepare_Transitions();
    }
    public void Prepare_Transitions(){
        set<id> setValidSteps = new set<id>();
        mapStepTransition = new map<id,NSIBPM__Step_Transition__c>();
        if(userType=='salesforce'){
            for(NSIBPM__Step_Transition__c trans:[select NSIBPM__From__c,NSIBPM__To__c,NSIBPM__Transition__c,NSIBPM__Transition__r.NSIBPM__To__c,NSIBPM__SR_Step__c,NSIBPM__SR_Status_External__c,NSIBPM__SR_Status_Internal__c from NSIBPM__Step_Transition__c where NSIBPM__Transition__c!=null and NSIBPM__From__c=:step.NSIBPM__Status__r.Name and NSIBPM__SR_Step__c=:step.NSIBPM__SR_Step__c and IsDeleted=false]){
                setValidSteps.add(trans.NSIBPM__Transition__r.NSIBPM__To__c);
                mapStepTransition.put(trans.NSIBPM__Transition__r.NSIBPM__To__c,trans);
            }
        }else{
            for(NSIBPM__Step_Transition__c trans:[select NSIBPM__From__c,NSIBPM__To__c,NSIBPM__Transition__c,NSIBPM__Transition__r.NSIBPM__To__c,NSIBPM__SR_Step__c,NSIBPM__SR_Status_External__c,NSIBPM__SR_Status_Internal__c from NSIBPM__Step_Transition__c where NSIBPM__Transition__c!=null and NSIBPM__From__c=:step.NSIBPM__Status__r.Name and NSIBPM__SR_Step__c=:step.NSIBPM__SR_Step__c and NSIBPM__Display_on_Portal__c=true and IsDeleted=false]){
                setValidSteps.add(trans.NSIBPM__Transition__r.NSIBPM__To__c);
                mapStepTransition.put(trans.NSIBPM__Transition__r.NSIBPM__To__c,trans);
            }
        }
        if(setValidSteps!=null && setValidSteps.size()>0){
            TransitionWrapper objWrap;
            for(NSIBPM__Status__c objstat:[Select Id,Name,NSIBPM__Type__c,NSIBPM__Rejection__c,NSIBPM__SR_Closed_Status__c,NSIBPM__Code__c from NSIBPM__Status__c where ID!=null and ID IN:setValidSteps and IsDeleted=false]){
                objWrap = new TransitionWrapper();
                objWrap.objStatus = objstat;
                objWrap.objSRStepTrans = new NSIBPM__Step_Transition__c();
                if(mapStepTransition.get(objstat.id)!=null)
                    objWrap.objSRStepTrans = mapStepTransition.get(objstat.id);
                lstTrnsWrap.add(objWrap);
            }
            iListSize = lstTrnsWrap.size();
        }
    }
    public string selTransition{get;set;}
    public string RejReason{get;set;}
    public string StepNotes{get;set;}
    public pagereference SaveChanges(){
        pagereference pg;
        if(selTransition!=null && mapStepTransition.get(selTransition)!=null){
            /* Savepoint can only be set after making the callout*/
            Savepoint Stat_svpoint = Database.setSavepoint();
            try{
                pg = new PageReference('/'+SRID);
                pg.setRedirect(true);
                if(mapStepTransition.get(selTransition).NSIBPM__SR_Status_Internal__c!=null && mapStepTransition.get(selTransition).NSIBPM__SR_Status_External__c!=null){
                    NSIBPM__Service_Request__c objSRloc = new NSIBPM__Service_Request__c(Id=SRID);
                    if(objSRloc.Recordtype.Name == 'Deal'){// Added on May 15 2017 - For jacob
                        objSRloc.NSIBPM__Required_Docs_not_Uploaded__c = false; // Added on April 25 2017 - For jacob
                        makeSrDocsOptional(SRID); // Added on May 9 2017 - For Jacob
                    }
                    objSRloc.DP_Payment__c = objSR.DP_Payment__c;
                    system.debug('--->objSRloc.DP_Payment__c '+objSRloc.DP_Payment__c);
                    if(mapStepTransition.get(selTransition).NSIBPM__SR_Status_Internal__c!=null)
                        objSRloc.NSIBPM__Internal_SR_Status__c = mapStepTransition.get(selTransition).NSIBPM__SR_Status_Internal__c;
                    if(mapStepTransition.get(selTransition).NSIBPM__SR_Status_External__c!=null)
                        objSRloc.NSIBPM__External_SR_Status__c = mapStepTransition.get(selTransition).NSIBPM__SR_Status_External__c;
                    
                    update objSRloc;
                }else if(showDPPercentage){
                    NSIBPM__Service_Request__c objSRloc = new NSIBPM__Service_Request__c(Id=SRID);
                    objSRloc.DP_Payment__c = objSR.DP_Payment__c;
                    system.debug('--->objSRloc.DP_Payment__c '+objSRloc.DP_Payment__c);
                     update objSRloc;
                }
                step.NSIBPM__Status__c = mapStepTransition.get(selTransition).NSIBPM__Transition__r.NSIBPM__To__c;
                step.NSIBPM__Step_Notes__c = StepNotes;
                step.NSIBPM__Rejection_Reason__c = RejReason;                
                NSIBPM__Status__c stpStatus = [Select Id,Name,NSIBPM__Type__c,NSIBPM__Rejection__c,NSIBPM__SR_Closed_Status__c,NSIBPM__Code__c from NSIBPM__Status__c where id!=null and id=:(mapStepTransition.get(selTransition).NSIBPM__Transition__r.NSIBPM__To__c) and IsDeleted=false];                
                if(stpStatus!=null && (stpStatus.NSIBPM__Code__c=='MORE_INFO_UPDATED' || stpStatus.NSIBPM__Code__c == 'DOCS_SENT' || stpStatus.NSIBPM__Code__c == 'POP_UPLOADED') && step.NSIBPM__SR__c!=null){     
                    boolean isReuploadRequired = false; 
                    if(stpStatus.NSIBPM__Code__c == 'DOCS_SENT'){
                        NSIBPM__Service_Request__c objSRlocal = SRUtility.getSRDetails(step.NSIBPM__SR__c);
                        if(objSRlocal.Delivery_Mode__c != null && objSRlocal.Delivery_Mode__c == 'Dispatch')
                        for(Booking__c bk : [select id,name from Booking__c where Deal_SR__c =:step.NSIBPM__SR__c and AWB_Number__c = null and Dispatch_Date__c = null]){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'AWB Number and Dispatch Date cannot be null for the bookings under this deal.'));
                            return null;
                        }
                    }
                    if(stpStatus.NSIBPM__Code__c == 'POP_UPLOADED'){
                        NSIBPM__Service_Request__c objSRlocal = SRUtility.getSRDetails(step.NSIBPM__SR__c);
                        if(objSRlocal.DP_Payment__c == null){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'DP Payment % on deal is mandatory.'));
                            return null;
                        }
                    }
                    for(NSIBPM__SR_Doc__c srDoc:[select id from NSIBPM__SR_Doc__c where id!=null and NSIBPM__Service_Request__c =:step.NSIBPM__SR__c and NSIBPM__Status__c = 'Re-upload' limit 1]){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Re-upload the required document and click “Save” button in SR Documents screen.'));
                        return null;
                    }
                }
                update step;
                
            }catch(DMLException e){
                string DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage() +' ';
                    
                }
                selTransition = null;
                Database.rollback(Stat_svpoint);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select the status to proceed.'));
            return null;
        }
        return pg;
    }
    
      // Making all SR Docs Optional on Deal rejection
    public void makeSrDocsOptional(id srid){
        list<NSIBPM__SR_Doc__c> srdocs = new list<NSIBPM__SR_Doc__c>();
        srdocs = [select id,NSIBPM__Is_Not_Required__c  from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c=:srid and NSIBPM__Is_Not_Required__c=false LIMIT:LIMITS.getLimitQueryRows()];
        if(srdocs.size() > 0){
            for(NSIBPM__SR_Doc__c doc:srdocs){
                doc.NSIBPM__Is_Not_Required__c = true;
            }   
            update  srdocs;
        }
    }
    
    public static map<string,string> GetDelegatedUsers(string CurrentUserId){
        map<string,string> MapDelegatedUsers = new map<string,string>();
        for(User usr:[select Id,DelegatedApproverId from User where id!=null AND DelegatedApproverId=:CurrentUserId]){
            MapDelegatedUsers.put(usr.Id,usr.DelegatedApproverId);
        }
        return MapDelegatedUsers;
    }
    public static list<GroupDetails> lstGroupsData = new list<GroupDetails>();
    public static list<GroupDetails> getGroupData(string strGroupId){
        if(lstGroupsData.size()==0){
            set<string> setInnerGrps = new set<string>();
            for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where id!=null AND GroupId=:strGroupId]){
                GroupDetails objGrp = new GroupDetails();
                objGrp.GroupOrUserId = GrpMem.UserOrGroupId;
                if(string.valueOf(GrpMem.UserOrGroupId).substring(0,3)=='00G')
                    setInnerGrps.add(GrpMem.UserOrGroupId);
                lstGroupsData.add(objGrp);
            }
            if(setInnerGrps!=null && setInnerGrps.size()>0){
                for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where id!=null AND GroupId IN:setInnerGrps]){
                    GroupDetails objGrp = new GroupDetails();
                    objGrp.GroupOrUserId = GrpMem.UserOrGroupId;
                    lstGroupsData.add(objGrp);
                }
            }
        }
        return lstGroupsData;
    }
    public class TransitionWrapper{
        public NSIBPM__Status__c objStatus{get;set;}
        public NSIBPM__Step_Transition__c objSRStepTrans{get;set;}
    }
    public class GroupDetails{
        public string GroupOrUserId;
    }
}