public without sharing class SRUtility {
        public static void CreateChatterGroup(Map<id,sobject> mpAccount){
        system.debug('---mpAccount>'+mpAccount);
        Map<Id,account> mpacc = new Map<Id,account>();
        //set<id> accids = new set<id>();
        for(account acc : [select id,name,Agency_Short_Name__c,(SELECT createdbyid,createdby.profile.name,createdby.contactid,createdby.contact.accountid,
                                                                createdby.Profile.UserLicense.Name,NSIBPM__Customer__c,Id,name 
                                                                FROM NSIBPM__Service_Requests__r
                                                                WHERE nsibpm__internal_status_name__c = 'Approved' 
                                                                AND NSIBPM__Customer__c in : mpAccount.keyset() and NSIBPM__Customer__c != null
                                                                AND RecordType.DeveloperName = 'Agent_Registration'
                                                                LIMIT 1),UniqueNo__c from account where id in : mpAccount.keyset()]){
                                                                    if(acc.NSIBPM__Service_Requests__r != null && !acc.NSIBPM__Service_Requests__r.isempty()){
                                                                        for(NSIBPM__Service_Request__c sr : acc.NSIBPM__Service_Requests__r){
                                                                            //portal user or guest user
                                                                            if(sr.createdby.contactid != null || sr.createdby.Profile.UserLicense.Name == 'Guest User License'){
                                                                                //accids.add(acc.id);
                                                                                mpacc.put(acc.id,acc);
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                }  
        system.debug('--->'+mpacc);
        if(mpacc != null && !mpacc.isempty()){
            List<CollaborationGroup> lstCG = new List<CollaborationGroup>();
            for(id accid : mpacc.keyset()){
                account acc = ((account)mpacc.get(accid));
                string str = (acc.Agency_Short_Name__c != null ? acc.Agency_Short_Name__c : '' );
                if(str.length() >27)
                    str = str.substring(0,27);
                
                lstCG.add(new CollaborationGroup(name = str+acc.UniqueNo__c+'-Sales', CollaborationType='Private', NetworkId= System.Label.Community_ID));
                
            }
            system.debug('--->'+lstCG);
            if(lstCG != null && !lstCG.isempty()){
                insert lstCG;
            }
        }
        
    }
        
    public static List<Amendment__c> getAllAmendments(Id SrId) {
        
        List<Amendment__c> amd_List = new List<Amendment__c>();
        String amdQuery = UtilityQueryManager.getAllFields(Amendment__c.getsObjectType().getDescribe());
        amdQuery += ' WHERE Service_Request__c =: SrId ';
        for (Amendment__c amd : Database.query(amdQuery)) {
            amd_List.add(amd);
            
        } 
        return amd_List;
    }
    
    public static boolean isUserwithEditPermissions(){
        Profile p = [select id,name from profile where id =: userinfo.getProfileId() limit 1];
        Map<string,boolean> mpProfilesNames = new Map<string,boolean>{'Agent Admin Team' => true,'Agent Admin Manager' => true};
            if(mpProfilesNames.containskey(p.name)){
                return true;
            }    
        return false;
    }

    
    
    
    /*
    * Enqueue the async receipt webservice once the Docs Ok step on Deal SR is decisioned.
    */ 
    public static void callAsyncReceiptWebservice(ID srID){
        List<Id> bIds = new List<Id>();
        for(Booking__c b : [select id from Booking__c where Deal_SR__c =: srID])
        {bIds.add(b.id);}
        if(bIds != null && !bIds.isEmpty())
            system.enqueueJob(new AsyncReceiptWebservice (bIds,'Doc Ok'));
    }
    
    public static string validateSRSubmit(Id SRId){
        //Validate new Registration
        string companyPerErrSuffix = ' .Please proceed to Company Personnel to make the changes';
        String retStr  = 'Success';
        String SrQuery;
        DescribeSObjectResult describeResult = NSIBPM__Service_Request__c.getsObjectType().getDescribe();
        
        List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
        SrQuery = ' SELECT ' + String.join( fieldNames, ',' ) + ', RecordType.DeveloperName ' + ' FROM ' + describeResult.getName();
        SrQuery += ' WHERE Id=: SRId LIMIT 1';
        
        NSIBPM__Service_Request__c currSR = Database.query(SrQuery);
        List<Amendment__c> amd_List = getAllAmendments(SRId);
        system.debug('--->amd_List'+amd_List.size());
        if(amd_List == null || amd_List.isempty() || amd_List.size() == 0){
            getAllAmendmentsForContacts(currSR);
            amd_List = getAllAmendments(SRId);
             system.debug('--->amd_List'+amd_List.size());
        }
        String recordTypeName = currSR.RecordType.DeveloperName;   
        if(recordTypeName == 'Agent_Registration' || recordTypeName == 'Agent_Update'){
            
            //Check if all roles are selected -START
            Boolean isOwner = false;
            Boolean isAuth = false;
            Boolean isAgent = false;
            Boolean isAdmin = false;
            integer CntofAuthSig = 0;
            for(Amendment__c amd : amd_List){
                
                isOwner =(amd.Owner__c) ? amd.Owner__c : isOwner; 
                isAgent =(amd.Agent_Representative__c) ? amd.Agent_Representative__c : isAgent; 
                isAdmin =(amd.Portal_Administrator__c) ? amd.Portal_Administrator__c : isAdmin;
                isAuth  =(amd.Authorised_Signatory__c) ? amd.Authorised_Signatory__c : isAuth;
                if(amd.Authorised_Signatory__c){
                    CntofAuthSig++;
                }  
                
            }
            
            if(CntofAuthSig > 1 && currSR.Agency_Type__c == 'Corporate'){
                retStr = 'Only one authorized signatory per agency is allowed.'+companyPerErrSuffix;
                return retStr;
            }
            
            System.debug('=====>'+isOwner +'-'+ isAdmin +'-'+ isAuth +'-'+ isAgent);
            if(!(isOwner && isAdmin && isAuth && isAgent) && currSR.Agency_Type__c == 'Corporate'){
                retStr = 'Every Agency should have at least one User per Role.'+companyPerErrSuffix;
                return retStr;
            }
            
            //Check if sum of all owners ShareHolding = 100 -START
            Decimal shareSum = 0;
            for(Amendment__c amd : amd_List){
                if(amd.Owner__c){
                    shareSum += (amd.Shareholding__c != NULL) ? amd.Shareholding__c : 0;
                }
                
            }
            System.debug('shareSum===>'+shareSum);
            if(shareSum != 100 && currSR.Agency_Type__c == 'Corporate'){
                
                retStr = 'Share Holding sum should be 100'+companyPerErrSuffix;
                return retStr;
            }
            System.debug('===>'+retStr);
            //Check If docs are uploaded - START
            Boolean isReqDocsUploaded = true;
            for(NSIBPM__SR_Doc__c srdoc:[select Id from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c=:SRId and NSIBPM__Is_Not_Required__c=false and ( NSIBPM__Doc_ID__c=null OR NSIBPM__Status__c = 'Re-upload' ) limit 1]){
                isReqDocsUploaded = false;
            }
            if(!isReqDocsUploaded){
                retStr = 'Please Upload/Re-upload all required documents in order to proceed with your application.';
                return retStr;
                
            }
            //Check for reupload status for any Docs and return error.
            for(NSIBPM__SR_Doc__c srdoc:[select Id,NSIBPM__Status__c from NSIBPM__SR_Doc__c where NSIBPM__Service_Request__c=:SRId and  NSIBPM__Status__c =: Label.SR_DOC_Status limit 1]){
                retStr = Label.SR_DOC_Reupload_ErrMsg;
                return retStr;
            } 
            
            //TL mandatory
            if(currSR.Trade_License_Number__c == ''){
                retStr = 'Trade Licence Number is mandatory.';
                return retStr;
            }
            
            
            //Check if duplicate TL
            IF(currSR.Trade_License_Number__c != NULL){
                List<Account> dupAccList = checkDupTLNumber(currSR.Trade_License_Number__c,currSR.RecordType.DeveloperName,currSR.Agency_Type__c,currSR.ID_Type__c,currSR.ID_Number__c);
                if(dupAccList.size() > 0 && recordTypeName != 'Agent_Update' ){

                    if(currSR.Agency_Type__c == 'Corporate'){
                        retStr = 'Matching account found with the same Trade Licence Number.';
                    }else if(currSR.Agency_Type__c == 'Individual'){
                        retStr = 'Matching account found with the same ID Type and ID Number.';
                    }
                    retStr += (dupAccList[0].Blacklisted__c) ? ' This account is BlackListed.' : '';
                    retStr += (dupAccList[0].Terminated__c) ? ' This account is Terminated.'  : '';
                    return retStr;
                }
            }
            
            
        } 
        System.debug('***retStr:'+retStr);
        return retStr;
    }
    
    public static List<Account> checkDupTLNumber(String TLNum,String RT,string AgencyType,string IdType, string Idnumber){
        Set<String> RTNames = new Set<String> {'Agent_Registration'};
            List<Account> accList = new List<Account>();
        if(RTNames.contains(RT)){
            if(AgencyType == 'Corporate' && TLNum != null){
                accList = [Select Trade_License_Number__c,Blacklisted__c,Terminated__c from Account where Trade_License_Number__c=: TLNum and Inactive__c = false];
            }
            if(AgencyType == 'Individual' && IdType != null && Idnumber != null){
                accList = [Select Trade_License_Number__c,Blacklisted__c,Terminated__c from Account where ID_Type__pc=: IdType and ID_Number__pc =: Idnumber];
            }
        }
        return accList;
    }
    
    public static List<Account> checkDupTLNumber(String TLNum,String RT){
        Set<String> RTNames = new Set<String> {'Agent_Registration'};
            List<Account> accList = new List<Account>();
        if(RTNames.contains(RT)){
            accList = [Select Trade_License_Number__c,Blacklisted__c,Terminated__c from Account where Trade_License_Number__c=: TLNum];
        }
        return accList;
    }
    
    public static Id getSRStatusFromTransition(Id SrStepId, String fromStatusCode, String toStatusCode){
        Id SRStaus;
        NSIBPM__Step_Transition__c  transition = [SELECT NSIBPM__SR_Status_External__c 
                                                  FROM NSIBPM__Step_Transition__c
                                                  WHERE NSIBPM__SR_Step__c =:SrStepId
                                                  AND NSIBPM__Transition__r.NSIBPM__From__r.NSIBPM__Code__c =:fromStatusCode
                                                  AND NSIBPM__Transition__r.NSIBPM__To__r.NSIBPM__Code__c =:toStatusCode
                                                  LIMIT 1 ];
        SRStaus =  (transition != NULL) ? transition.NSIBPM__SR_Status_External__c : NULL;                                        
        System.debug('Transition==>'+transition);
        return SRStaus;
    }
    
    public static void updateStepStatus(String statusCodeNew,String statusCodeOld,ID SrId){
        
        NSIBPM__Status__c newStatus = [Select Id from NSIBPM__Status__c Where NSIBPM__Code__c =:statusCodeNew LIMIT 1];
        
        
        System.debug('newStatus==>'+newStatus);
        NSIBPM__Step__c openStep;
        //If new Status Exists
        if(newStatus != NULL){
            //Get Current Open Step
            openStep = [Select Id,NSIBPM__Status__c,NSIBPM__SR_Step__c,NSIBPM__Status__r.NSIBPM__Code__c,NSIBPM__Status__r.NSIBPM__Type__c from NSIBPM__Step__c Where NSIBPM__SR__c =:SRId AND NSIBPM__Status__r.NSIBPM__Type__c != 'End' LIMIT 1 ];
            System.debug('openStep==>'+openStep.NSIBPM__Status__r.NSIBPM__Code__c);
            //If status of open step matches
            if(openStep != NULL && openStep.NSIBPM__Status__r.NSIBPM__Code__c == statusCodeOld){
                openStep.NSIBPM__Status__c = newStatus.Id;
                NSIBPM__Service_Request__c SR =  new NSIBPM__Service_Request__c(id=SRId);
                SR.NSIBPM__External_SR_Status__c = getSRStatusFromTransition(openStep.NSIBPM__SR_Step__c,statusCodeOld,statusCodeNew);
                SR.NSIBPM__Internal_SR_Status__c = getSRStatusFromTransition(openStep.NSIBPM__SR_Step__c,statusCodeOld,statusCodeNew);
                
                update SR;
            }
        }
        System.debug('openStep===>'+openStep);
        update openStep;
        
    }
    
    public static void  getAllAmendmentsForContacts(NSIBPM__Service_Request__c SR){
        String cancelledStatus = 'Cancelled';
        List<Amendment__c> amdList = new list<Amendment__c>();
        Set<Id>conIdSet = new Set<Id>();
        Id AccId = SR.NSIBPM__Customer__c;
        Id SrId =SR.id;
        Map<Id, Amendment__c> amendment_Map = new Map<Id,Amendment__c>();
        
        //get all existing amendments for current SR and contact to avoid re creation of amendments
        for(Amendment__c amd :  [Select id,Contact__c from Amendment__c where Service_Request__c =: srid]){
            conIdSet.add(amd.Contact__c);
        }
        String conQuery = 'Select Title,FirstName,Country_Of_Origin__c,LastName,ID_Issue_date__c,ID_Number__c,Mobile_Country_Code__c,Designation__c,Nationality__c,MobilePhone,Id_Expiry_Date__c,Broker_Card_Expiry_Date__c,Broker_Card_Number__c,AccountId,ID_Type__c ,Email,Id,Passport_Number__c,Shareholding__c,Is_Eligible_To_Sell__c,Agent_Representative__c,Owner__c,Authorised_Signatory__c,Portal_Administrator__c FROM Contact ';
        conQuery += ' WHERE AccountId =: AccId AND Id NOT IN :conIdSet AND Status__c != :cancelledStatus  ';
        
        
        for (Contact con  : Database.query(conQuery)) {
            Amendment__c amd =  new Amendment__c();
            amd.Title__c  = con.Title;
            amd.First_Name__c  = con.FirstName;
            amd.Last_Name__c = con.LastName;
            amd.Account__c = con.AccountId  ;
            amd.Service_Request__c = SrId;
            amd.Email__c = con.Email;
            amd.Contact__c =con.Id;
            amd.Mobile__c = con.MobilePhone;
            amd.ID_Number__c = con.ID_Number__c;
            amd.ID_Issue_date__c = con.ID_Issue_date__c;
            amd.Id_Expiry_Date__c = con.Id_Expiry_Date__c;
            amd.ID_Type__c =con.ID_Type__c;
            amd.Mobile__c = con.MobilePhone;
            amd.Shareholding__c = con.Shareholding__c;
            amd.Designation__c = con.Designation__c;
            //amd.Nationality__c = con.Nationality__c;
            amd.Nationality__c = con.Country_Of_Origin__c;
            amd.ID_Type__c = con.ID_Type__c;
            amd.Broker_Card_Expiry_Date__c = con.Broker_Card_Expiry_Date__c;
            amd.Broker_Card_Number__c = con.Broker_Card_Number__c;
            amd.Is_Eligible_To_Sell__c = con.Is_Eligible_To_Sell__c;
            amd.Mobile_Country_Code__c = con.Mobile_Country_Code__c;
            amd.Agent_Representative__c = con.Agent_Representative__c ;
            amd.Owner__c = con.Owner__c;
            amd.Authorised_Signatory__c = con.Authorised_Signatory__c ;
            amd.Portal_Administrator__c = con.Portal_Administrator__c ;
            amdList.add(amd);
            
        }
        insert  amdList;
        
    } 
    
    /*********************************************************************************************
* @Description : Get Current Page URL                                    *
* @Params      :                                                                  *
* @Return      :  URL String                                                                   *
*********************************************************************************************/    
    public static string  getReferer() {
        String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
        string pageURL = ApexPages.currentPage().getHeaders().get('Referer');
        System.debug('==>'+pageURL);
        URL currentPageURL = new URL(pageURL);
        // String URLL = 'https:/' + hostVal+ '/agents/Process_Flow?' + currentPageURL.getQuery();
        String URLL = 'https:/' + hostVal+ pageURL + currentPageURL.getQuery();
        System.debug('URLL==>'+URLL);
        //return URLL;
        return pageURL;
    }
    
    public static NSIBPM__Service_Request__c getSRDetails(Id SRId) {
        NSIBPM__Service_Request__c currSR = new NSIBPM__Service_Request__c();
        DescribeSObjectResult describeResult = NSIBPM__Service_Request__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
        query += ' WHERE Id =: SRId LIMIT 1';
        System.debug('==>' + query);
        currSR = Database.query(query);
        return currSR;
    }
    
    public static List<sobject> getRecords(string sobjecttype,string condition){
        try{
            System.debug('sobjecttype = +condition ='+sobjecttype+condition);
            List<sobject> lstSobjects = new List<Sobject>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sobjecttype).getDescribe().fields.getMap();
            string queryString = '';
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.getname().endsWith('__c')){
                    queryString += dfield.getname()+',';
                }
            }
            queryString = 'SELECT Id,'+queryString+'Name FROM '+sobjecttype +condition;
            System.debug('queryString = '+queryString);
            for(SObject sobj : Database.query(queryString)){
                lstSobjects.add(sobj);
            }
            System.debug('lstSobjects-->'+lstSobjects.size());
            return lstSobjects;
        }
        Catch(exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
   
    
}