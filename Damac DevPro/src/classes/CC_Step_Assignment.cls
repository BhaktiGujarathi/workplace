global without sharing class CC_Step_Assignment Implements NSIBPM.Step_Assignment_Executable{
         
    global List<NSIBPM__Step__c> Assign_Step_Owner_SR_Submit(Map<String,NSIBPM__Service_Request__c> MapSRs,list<NSIBPM__Step__c> lstSteps, Map<String,NSIBPM__SR_Steps__c> MapSRSteps){
        return lstSteps;       
    }
    global list<NSIBPM__Step__c> Assign_Step_Owner_Step_Closure(Map<String,NSIBPM__Step__c> MapSteps,list<NSIBPM__Step__c> lstSteps,Map<String,NSIBPM__SR_Steps__c> MapSRSteps){
       system.debug('--Interface Execition-->Assign_Step_Owner_Step_Closure');
        list<NSIBPM__Step__c> lststepstoupdate = assignStepOwnerMethod(lstSteps,MapSRSteps);
        return lststepstoupdate;
    }
    
    public static list<NSIBPM__Step__c> assignStepOwnerMethod(list<NSIBPM__Step__c> lstSteps,Map<String, NSIBPM__SR_Steps__c> MapSRSteps){
        try{
            List<RTSA__c> csRTNameStepsConsidered = RTSA__c.getAll().values();
            map<String,Map<string,Integer>> mpRTmpSteps = new map<String,Map<String,Integer>>();
            for(RTSA__c objrtsa : csRTNameStepsConsidered){
                Map<string,integer> mptemp = new Map<string,integer>();
                if(objrtsa.Comma_Seperated_Step_No__c != null)
                    for(string str : objrtsa.Comma_Seperated_Step_No__c.split(',')){
                        mptemp.put(str,1);
                    }
                mpRTmpSteps.put(objrtsa.name,mptemp);
            }
            system.debug('--->mapofcs-->'+mpRTmpSteps);
            NSIBPM__Service_Request__c objSR = [select id,name,Override_Step_Owner__c,NSIBPM__Record_Type_Name__c,createdbyid from NSIBPM__Service_Request__c where id =: lstSteps[0].NSIBPM__SR__c];
            if(objSR.Override_Step_Owner__c){
                system.debug('--->isOverrideOwner-->');
                for(NSIBPM__Step__c objStep : lstSteps){
                    system.debug('--->'+MapSRSteps.get(objStep.NSIBPM__SR_Step__c).id);
                    string srStpID = string.valueof(MapSRSteps.get(objStep.NSIBPM__SR_Step__c).id);
                    if(mpRTmpSteps.containskey(objSR.NSIBPM__Record_Type_Name__c) && (mpRTmpSteps.get(objSR.NSIBPM__Record_Type_Name__c).containskey(srStpID) || mpRTmpSteps.get(objSR.NSIBPM__Record_Type_Name__c).containskey(srStpID.substring(0,15))))  
                    {
                        system.debug('--->isOverrideOwnerstep found-->');
                        objStep.ownerid = objSr.createdbyid;
                    }
                }
            }
            return lstSteps;
        }
        Catch(exception ex){
            return lstSteps;
        }
    }
}