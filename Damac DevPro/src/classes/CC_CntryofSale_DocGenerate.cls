global without sharing class CC_CntryofSale_DocGenerate implements NSIBPM.CustomCodeExecutable {

    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        String retStr = '';
        List<id> accids = new List<id>();
        try {        
            NSIBPM__Service_Request__c currSR = getSRDetails(step.NSIBPM__SR__c);
            List<Agent_Site__c> lstAgentSites = [select id,name,Start_Date__c,Active__c,Agency__c,End_Date__c,Reinstated_Date__c from Agent_Site__c where Agency__c =: currSR.NSIBPM__Customer__c];
            Map<string,Agent_Site__c> mpAgentSites = new Map<String,Agent_Site__c>();
            if(lstAgentSites != null && !lstAgentSites.isempty() && currSR.Country_of_Sale__c != null){
                for(Agent_Site__c objas : lstAgentSites){
                    mpAgentSites.put(objas.name,objas);
                }
                for(string strSite : currSR.Country_of_Sale__c.split(';')){
                    if(!mpAgentSites.containskey(strSite)){
                        retStr = retStr+strSite+',';
                    }
                }
            }
            if(retStr == ''){
                retStr = 'NULL';
            }
        } catch (Exception e) {
            system.debug('-->CC_CntryofSale_DocGenerate -->'+ e.getmessage());
            retStr = 'NULL';
        }
        return retStr;
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

}