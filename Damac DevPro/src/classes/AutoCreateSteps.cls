global class AutoCreateSteps implements Database.Batchable <sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'select id,name,IPMS_Registration_Status__c from NSIBPM__Service_Request__c where IPMS_Registration_Status__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List <NSIBPM__Service_Request__c> scope) {
        Map<Id,string> mpSRIMPSRegCode = new Map<Id,string>();
        for(NSIBPM__Service_Request__c sr : scope){
            mpSRIMPSRegCode.put(sr.id,sr.IPMS_Registration_Status__c);
        }
        system.debug('--->'+mpSRIMPSRegCode);
        Map<string,NSIBPM__Status__c> mpstepstatuses = new Map<string,NSIBPM__Status__c>();
        List<NSIBPM__Status__c> lststepstatuses = (List<NSIBPM__Status__c>)SRUtility.getRecords('NSIBPM__Status__c', '');
        for(NSIBPM__Status__c stpstatus : lststepstatuses){
            mpstepstatuses.put(stpstatus.name,stpstatus);
            mpstepstatuses.put(stpstatus.NSIBPM__Code__c,stpstatus);
        }
        
        Map<string,NSIBPM__SR_Status__c> mpsrstatuses = new Map<string,NSIBPM__SR_Status__c>();
        List<NSIBPM__SR_Status__c> lstSRstatuses = (List<NSIBPM__SR_Status__c>)SRUtility.getRecords('NSIBPM__SR_Status__c', '');
        for(NSIBPM__SR_Status__c srstatus : lstSRstatuses){
            mpsrstatuses.put(srstatus.NSIBPM__Code__c,srstatus);
        }
        
        List<NSIBPM__SR_Steps__c> lstSRSteps = (List<NSIBPM__SR_Steps__c>)SRUtility.getRecords('NSIBPM__SR_Steps__c', ' where NSIBPM__SR_Template__r.NSIBPM__SR_RecordType_API_Name__c =\'Deal\' order by NSIBPM__Step_No__c asc');
        system.debug('--lstSRSteps->'+lstSRSteps.size()+'-->');
        
        string str = '(';
        for(NSIBPM__SR_Steps__c srStep : lstSRSteps){
            str += '\''+srStep.NSIBPM__Step_Template__c+'\',';
        }
        str = str.substring(0,str.length()-1);
        str += ')';
        List<NSIBPM__Step_Template__c> lstStpTemplate = (List<NSIBPM__Step_Template__c>)SRUtility.getRecords('NSIBPM__Step_Template__c', ' where id in '+str );
        system.debug('---lstStpTemplate>'+lstStpTemplate.size()+'-->');
        
        Map<id,NSIBPM__Step_Template__c> mpstptemplate = new Map<id,NSIBPM__Step_Template__c>();
        for(NSIBPM__Step_Template__c sttemp : lstStpTemplate){
            mpstptemplate.put(sttemp.id,sttemp);
        }
        system.debug('---mpstptemplate>'+mpstptemplate);
        
        if(mpSRIMPSRegCode != null && !mpSRIMPSRegCode.isempty())
        createsteps(mpSRIMPSRegCode,lstSRSteps,mpstptemplate,mpstepstatuses,mpsrstatuses);        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    public static void createsteps(Map<Id,string> mpsridnoofstepstocreated,List<NSIBPM__SR_Steps__c> lstSRSteps,Map<id,NSIBPM__Step_Template__c> mpstptemplate, Map<string,NSIBPM__Status__c> mpstepstatuses,Map<string,NSIBPM__SR_Status__c> mpsrstatuses){
        try{           
            delete [select id from NSIBPM__Step__c where NSIBPM__SR__c in : mpsridnoofstepstocreated.keyset()];
            
            //Get from custom settings
            Map<string,SRAC__c> mpSRAC = SRAC__c.getall();
            system.debug('--mpSRAC---> '+mpSRAC);

            Map<string,boolean> mpexcludesteps = new Map<string,boolean>();
            
            Map<string,string> mpsteptemplateanditsstatus = new Map<string,string>();
            Map<string,SRStpMD__c> mpStpStatuses = SRStpMD__c.getall();
            for(SRStpMD__c srstp : mpStpStatuses.values()){
                if(!srstp.Is_Excluded__c)
                    mpsteptemplateanditsstatus.put(srstp.SR_Step_Master_Code__c,srstp.Final_Status_Name_Code__c);
                else{
                    mpexcludesteps.put(srstp.SR_Step_Master_Code__c,false);
                }
            }
            

            Map<Id,List<NSIBPM__Step__c>> mptoinsert = new Map<Id,List<NSIBPM__Step__c>>();
            Map<Id,String> mpSRIDSrStatus = new Map<Id,String>();
            for(id srid : mpsridnoofstepstocreated.keyset()){
                List<NSIBPM__Step__c> lststeps = new List<NSIBPM__Step__c>();
                
                for(NSIBPM__SR_Steps__c srStep : lstSRSteps){
                    system.debug('---mpstptemplate>'+mpsridnoofstepstocreated.get(srid) +' -- '+srStep.NSIBPM__Step_No__c);
                    
                    //if sr step -> template code to be exluded.
                    if(mpexcludesteps.containskey(mpstptemplate.get(srStep.NSIBPM__Step_Template__c).NSIBPM__Code__c)){
                        continue;
                    }
                    if(!mpSRAC.containskey(mpsridnoofstepstocreated.get(srid)) ||  mpSRAC.get(mpsridnoofstepstocreated.get(srid)).Step_No__c < srStep.NSIBPM__Step_No__c){
                        break;
                    }
                    system.debug('---mpstptemplate>'+mpSRAC.get(mpsridnoofstepstocreated.get(srid)).Step_No__c +' -- '+srStep.NSIBPM__Step_No__c);
                    NSIBPM__Step__c insStp = new NSIBPM__Step__c();
                    insStp.NSIBPM__SR__c = srid;
                    insStp.NSIBPM__Step_Template__c = srStep.NSIBPM__Step_Template__c;
                    insStp.NSIBPM__SR_Step__c = srStep.id;
                    insStp.NSIBPM__Summary__c = srStep.NSIBPM__Summary__c;
                    insStp.NSIBPM__Step_No__c = srStep.NSIBPM__Step_No__c;
                    insStp.NSIBPM__Sys_Step_Loop_No__c = string.valueOf(insStp.NSIBPM__Step_No__c)+'_'+'1';
                    if(mpSRAC.get(mpsridnoofstepstocreated.get(srid)).Step_No__c == srStep.NSIBPM__Step_No__c){
                        insStp.NSIBPM__Status__c = mpstepstatuses.get(mpSRAC.get(mpsridnoofstepstocreated.get(srid)).Step_Status_Code__c).id;
                        mpSRIDSrStatus.put(srid,mpSRAC.get(mpsridnoofstepstocreated.get(srid)).SR_Status_Code__c);
                    }else{
                        insStp.NSIBPM__Status__c = mpstepstatuses.get(mpsteptemplateanditsstatus.get(mpstptemplate.get(srStep.NSIBPM__Step_Template__c).NSIBPM__Code__c)).id;
                    } 
                    lststeps.add(insStp);
                }
                mptoinsert.put(srid,lststeps);
            }
            List<NSIBPM__Step__c> stepstoinsert = new List<NSIBPM__Step__c>();
            
            for(id srid : mptoinsert.keyset()){
                stepstoinsert.addall(mptoinsert.get(srid));
            }
            
            List<NSIBPM__Service_Request__c> srstoUpdate = new List<NSIBPM__Service_Request__c>();
            for(id srid : mpSRIDSrStatus.keyset()){
                NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
                sr.NSIBPM__External_SR_Status__c = mpsrstatuses.get(mpSRIDSrStatus.get(srid)).id;
                sr.NSIBPM__Internal_SR_Status__c = sr.NSIBPM__External_SR_Status__c;
                sr.id = srid;
                sr.IPMS_Registration_Status__c = null;
                srstoUpdate.add(sr);
            }
            
            if(stepstoinsert != null && !stepstoinsert.isempty())
                insert stepstoinsert;
            if(srstoUpdate != null && !srstoUpdate.isempty())
                update srstoUpdate;
        }
        catch(exception ex){
            system.debug('--->'+ ex.getMessage());
        }
    }
    
}