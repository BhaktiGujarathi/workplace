/*
* Controller - SRNavigationOverrideCtrl
* VF Page -  SRNavigationOverride
* V1 - 14/03/2017 - Standard EDIT/NEW button override logic. 
*/ 

public class SRNavigationOverrideCtrl extends Describe_Sobject_Access {
    public boolean isEdit {get;set;}
    public string srID {get;set;}
    public NSIBPM__Service_Request__c objSR {get;set;}
    public boolean isinternalUser {get;set;}
    public string pageflowID {get;set;}
    public boolean isThruPGFlows {get;set;}
    public string DetectedMode {get;set;}
    public static Map<string,string> PageParameters = new Map<string,string>();
    public string RecordtypeName {get;set;}
    /*
    * Constructor: Logic to find out
    * RecordType of SR
    * SR is either in EDIT/NEW Mode
    * Logged in user is Salesforce/Guest/Community Licensed user
    * PageflowID - Which should be associated to SR.
    */ 
    public SRNavigationOverrideCtrl(ApexPages.StandardController controller){
        try{
            PageParameters = ApexPages.currentPage().getParameters();
            if (PageParameters.get('id') == null)
            { DetectedMode = 'New';  } else if (PageParameters.get('id') != null & PageParameters.get('retURL') != null)
            { DetectedMode = 'Edit'; } else if (PageParameters.get('id') != null & PageParameters.get('retURL') == null)
            { DetectedMode = 'View'; }
            system.debug('---DetectedMode->'+DetectedMode);
            system.debug('---Contructor->'+PageParameters);
            isEdit = false;
            srID = '';
            pageflowID ='';
            isThruPGFlows = false;
            isinternalUser = false;
            //Find out logged in user is either Salesforce(Internal)/Community user.
            User u = [select id,name,contactid,contact.accountid from user where id =: userinfo.getUserId()];
            if(u != null && u.id != null){
                if(u.ContactId == null){
                    isinternalUser = true;
                }
                if(u.contactid != null && u.contact.accountid != null || test.isRunningTest()){
                    isinternalUser = false;
                }
            }
            //SR Edit Mode
            if(controller.getId() != null)
                srID = controller.getId();
            
            objSR = (NSIBPM__Service_Request__c)controller.getRecord();
            
            if(PageParameters.get('RecordType') != null && PageParameters.get('RecordType') != ''){
                objSR.RecordTypeId = PageParameters.get('RecordType');
                system.debug('---objSR-> '+objSR.recordtypeid);
            }            
            //Get all existing pageflows in systems.
            Map<string,string> mpPageflows = new Map<string,string>();
            for(Page_Flow__c pg : [select id,name,Record_Type_API_Name__c from Page_Flow__c]){
                mpPageflows.put(pg.Record_Type_API_Name__c,pg.id);
            }
            
            if(objSR.recordtypeid == null){
                List<Schema.RecordTypeInfo> infos = Schema.SObjectType.NSIBPM__Service_Request__c.RecordTypeInfos;         
                //check each one
                for (Schema.RecordTypeInfo info : infos) {
                    if (info.DefaultRecordTypeMapping) {
                        objSR.recordtypeid = info.RecordTypeId;
                        system.debug('---objSR12 -> '+objSR.recordtypeid);
                        break;
                    }
                }
            }
            //Check for if SR Recordtype associated with any process flow.
            if(objSR.recordtypeid != null){
                for(recordtype rt : [select id,name,developername from recordtype where id=: objSR.recordtypeid]){
                    system.debug('---recordtype -> '+rt.name);
                    if(mpPageflows.containskey(rt.developername)){
                        isThruPGFlows = true;
                    }
                }
            }
            
            system.debug('---mpPageflows-> '+mpPageflows+ ' --isinternalUser-> '+isinternalUser+' ---srID-> '+srID); 
            //In case of EDIT, get SR with all field values.
            If(srID != null && srID != ''){
                //isEdit = true;
                String strQuery = '';
                strQuery += UtilityQueryManager.getAllFields(NSIBPM__Service_Request__c.getsObjecttype().getDescribe()) ;
                strQuery += '  where Id =:srID ';
                for(NSIBPM__Service_Request__c SR:database.query(strQuery)){
                    objSR = SR;
                }
                pageflowID = mpPageflows.get(objSR.NSIBPM__Record_Type_Name__c);
            }
            else{
                pageflowID = mpPageflows.get(Label.ManageAgencySiteInsert);
            }
            if(PageParameters.get('RecordType') != null && PageParameters.get('RecordType') != ''){
                objSR.RecordTypeId = PageParameters.get('RecordType');
                system.debug('---objSR-> '+objSR.recordtypeid);
            }
            system.debug('---pageflowID-> '+pageflowID);
        }
        catch(exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact system administrator.'));
            return;
        }
        
        
    }
    
    
    /*
    * On Page Load Action:
    * Find out if the EDIT/NEW buttons needs to be overridden based on configuration from custom settings.
    * Form the redirect URL based on EDIT/NEW
    */ 
    public pagereference init(){
        try{
            system.debug('---insideinit->');
            system.debug('---objSR-> '+objSR.recordtypeid);
            //update objSR;
            sObjectName = 'srq';
    		getAccess();
    		if(DetectedMode == 'Edit' && !canEditRecord){
    			return null;
    		}
    		
            for(recordtype rt : [select id,name,developername from recordtype where id =: objSR.recordtypeid]){
                RecordtypeName = rt.name;
                system.debug('---RecordtypeName-> '+RecordtypeName);
            }
            Pagereference pg = null;
            PSRLT__c mhc = PSRLT__c.getInstance(userinfo.getProfileId());
            string prefix = '';
            string sobjectkeyprefix = NSIBPM__Service_Request__c.sobjecttype.getDescribe().getKeyPrefix();
            //for future use incase if any prefix needs to be appended
            if(isinternalUser){
                prefix = '/apex';
            }
            
            //If recordtype is Booking Unit:
            if(RecordtypeName != null && RecordtypeName == 'Change Joint Buyer'){
                //check for custom settings - if NEW/EDIT needs to be overridden
                string parentid ='';
                Map<string,integer> mpPP = new Map<string,integer>();
                for(string str : PageParameters.keyset()){
                    String idval = String.escapeSingleQuotes(str);
                    if(idval.tolowercase().contains('_lkid')) {
                        parentid = PageParameters.get(str);
                        break;
                    }
                }
                
                if(mhc != null && mhc.id != null){
                    //If it has to be overridden
                    if(mhc.Override__c){
                        //In case of EDIT navigate to the manage buyers page
                        if(DetectedMode == 'Edit'){
                            pg= new Pagereference(prefix+'/apex/ManageBuyersVf?id='+parentid);
                        }
                        else if(DetectedMode == 'View'){
                            pg= new Pagereference('/'+srID+'?nooverride=1');
                        }
                        //In case of NEW change joint buyer, navigate to ManageBuyersVf.
                        else{
                            pg= new Pagereference(prefix+'/apex/ManageBuyersVf?id='+parentid);
                        }
                    }
                    //If not overridden
                    else{
                        //In case of new navigate to the manage buyers page
                        if(DetectedMode == 'New'){
                            pg= new Pagereference(prefix+'/apex/ManageBuyersVf?id='+parentid);
                        }
                        //If EDIT standard layout.
                        else if(DetectedMode == 'Edit'){
                            pg= new Pagereference('/'+srID+'/e?nooverride=1&retURL=%2F'+srID); 
                        }
                        else{
                            pg= new Pagereference('/'+srID+'?nooverride=1'); 
                        }
                    }
                }else{
                    //In case of new navigate to the manage buyers page
                    if(DetectedMode == 'New'){
                        pg= new Pagereference(prefix+'/apex/ManageBuyersVf?id='+parentid);
                    }
                    //If EDIT standard layout.
                    else if(DetectedMode == 'Edit'){
                        pg= new Pagereference('/'+srID+'/e?nooverride=1&retURL=%2F'+srID); 
                    }
                    else{
                        pg= new Pagereference('/'+srID+'?nooverride=1'); 
                    }
                }
                return pg;
            }
            //If there is no process flow associated with SR recordtype. Flow should be the same.
            if(!isThruPGFlows){
                system.debug('---isThruPGFlows-> '+isThruPGFlows);
                if(DetectedMode == 'Edit'){
                    pg= new Pagereference('/'+srID+'/e?nooverride=1&retURL=%2F'+srID);
                }
                else if(DetectedMode == 'View'){
                    pg= new Pagereference('/'+srID+'?nooverride=1');
                }
                else{
                    String navURL = '/'+sobjectkeyprefix+'/e?&RecordType='+objSR.recordtypeid+'&nooverride=1';
                    Map<string,integer> mpPP = new Map<string,integer>();
                    for(string str : PageParameters.keyset()){
                        String idval = String.escapeSingleQuotes(str);
                        if(idval.tolowercase().contains('_lkid')) {
                            navURL += '&'+str+'='+PageParameters.get(str);
                            mpPP.put(idval.replace('_lkid', ''),1);
                        }
                    }
                    for(string str : PageParameters.keyset()){
                        String idval = String.escapeSingleQuotes(str);
                        if(mpPP.containskey(idval)) {
                            navURL += '&'+str+'='+PageParameters.get(str);
                        }
                    }
                    navURl += '&retURL=%2F'+sobjectkeyprefix+'%2Fo';
                    system.debug('---navURL->'+navURL);
                    pg= new Pagereference(navURL);
                }
                return pg;
            }
            //If there is a associated process flow with SR recordtype
            else{
                //check for custom settings - if NEW/EDIT needs to be overridden
                if(mhc != null && mhc.id != null){
                    //If it has to be overridden
                    if(mhc.Override__c){
                        //In case of EDIT navigate to the process flow page with SR id
                        if(DetectedMode == 'Edit'){
                            pg= new Pagereference(prefix+'/Process_Flow?FlowId='+pageflowID+'&Id='+srID);
                        }
                        else if(DetectedMode == 'View'){
                            pg= new Pagereference(prefix+'/Process_Flow?FlowId='+pageflowID+'&Id='+srID);
                        }
                        //In case of NEW SR, navigate to Agent Registration process flow.
                        else{
                            pg= new Pagereference(prefix+'/Process_Flow?FlowId='+pageflowID);
                        }
                    }
                    //If not overridden
                    else{
                        //In case of NEW SR, navigate to agent registration process flow.
                        if(DetectedMode == 'New'){
                            //pg= new Pagereference(prefix+'/Process_Flow?FlowId='+pageflowID);
                            //pg= new Pagereference('/'+sobjectkeyprefix+'/e?&RecordType='+objSR.recordtypeid+'&nooverride=1');
                            
                            String navURL = '/'+sobjectkeyprefix+'/e?&RecordType='+objSR.recordtypeid+'&nooverride=1';
                            Map<string,integer> mpPP = new Map<string,integer>();
                            for(string str : PageParameters.keyset()){
                                String idval = String.escapeSingleQuotes(str);
                                if(idval.tolowercase().contains('_lkid')) {
                                    navURL += '&'+str+'='+PageParameters.get(str);
                                    mpPP.put(idval.replace('_lkid', ''),1);
                                }
                            }
                            for(string str : PageParameters.keyset()){
                                String idval = String.escapeSingleQuotes(str);
                                if(mpPP.containskey(idval)) {
                                    navURL += '&'+str+'='+PageParameters.get(str);
                                }
                            }
                            system.debug('---navURL->'+navURL);
                            navURL +='&retURL=%2F'+sobjectkeyprefix+'%2Fo';
                            pg= new Pagereference(navURL);
                        }
                        //If EDIT standard layout.
                        else if(DetectedMode == 'Edit'){
                            pg= new Pagereference('/'+srID+'/e?nooverride=1&retURL=%2F'+srID); 
                        }
                        else{
                            pg= new Pagereference('/'+srID+'?nooverride=1'); 
                        }
                    }
                }
                //if not mentioned in custom settings for overridden navigation and NEW, navigate to agent registration process flow.
                else if(DetectedMode == 'New'){
                    pg= new Pagereference(prefix+'/Process_Flow?FlowId='+pageflowID);
                }
                //if not mentioned in custom settings for overridden navigation and EDIT, navigate to agent registration process flow.
                else if(DetectedMode == 'Edit'){
                    //pg= new Pagereference(prefix+'/Process_Flow?FlowId='+pageflowID+'&Id='+srID);
                    pg= new Pagereference('/'+srID+'/e?nooverride=1&retURL=%2F'+srID);
                }
                else{
                    pg= new Pagereference('/'+srID+'?nooverride=1');
                }
            }
            return pg;
        }catch(exception ex){
        	system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact system administrator - '+ex.getMessage()));
            return null;
        }
    }
}// End of class.