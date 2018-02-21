global without sharing class ManageSRStatusConditionBased implements NSIBPM.CustomCodeExecutable {
    /*if country of sale is null, set status to Under Review
if country of sale is not null, set status to Awaiting FFA/AA*/
    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        String retStr = 'Success';
        try{
            NSIBPM__Service_Request__c objSR = SRUtility.getSRDetails(step.NSIBPM__SR__c);
            return updateSR(objSR);
        }
        catch(exception ex){
            return ex.getMessage();
        }
        
    }
    
    public static string updateSR(NSIBPM__Service_Request__c objSR){
        try{
            set<string> stStatusCodes = new set<string>{'UNDER_REVIEW','AWAITING_FFA_AA'};
                Map<string,id> mpstatus = new Map<string,id>();
            for(NSIBPM__SR_Status__c srStatus : [select id,name,NSIBPM__Code__c from NSIBPM__SR_Status__c where NSIBPM__Code__c in : stStatusCodes]){
                mpstatus.put(srStatus.NSIBPM__Code__c,srStatus.id);
            }
            if(mpstatus != null && !mpstatus.isempty()){
                if(objSR.New_Country_of_Sale__c != null){
                    objSR.NSIBPM__External_SR_Status__c = mpstatus.get('AWAITING_FFA_AA');
                    objSR.NSIBPM__Internal_SR_Status__c = mpstatus.get('AWAITING_FFA_AA');
                }else{
                    objSR.NSIBPM__External_SR_Status__c = mpstatus.get('UNDER_REVIEW');
                    objSR.NSIBPM__Internal_SR_Status__c = mpstatus.get('UNDER_REVIEW');
                }
            }
            update objSR;
            return 'Success';
        }
        catch(exception ex){
            return 'Error - '+ex.getmessage();
        }
    }
}