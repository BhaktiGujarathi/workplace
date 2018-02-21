trigger trg_Campaign on Campaign__c (before insert, before update) {
    
    try{
    	Trg_Ctrl_Var__c ctrlVariable = Trg_Ctrl_Var__c.getValues('trg_Campaign');
        if(!ctrlVariable.Activate__c){
            return;
        }
    }
    catch(exception ex){
        system.debug(ex.getMessage());
    }
    
    if((trigger.isinsert || trigger.isUpdate) && trigger.isbefore){
        //Generate Campaign Name
        List<Campaign__c> lstCampaigns = new List<Campaign__c>();
        for(Campaign__c c : trigger.new){
            if(!c.Old_Campaign__c)
                lstCampaigns.add(c);
            c.MED_Changed_Date__c = ( ( trigger.isUpdate && c.Marketing_End_Date__c != null && c.Marketing_End_Date__c != trigger.oldMap.get(c.id).Marketing_End_Date__c && c.Marketing_End_Date__c < trigger.oldMap.get(c.id).Marketing_End_Date__c) ? Date.today() : c.MED_Changed_Date__c);
		}
        if(lstCampaigns != null && !lstCampaigns.isempty()){
        	Campaignhandler.getCode(lstCampaigns);
        }
    }
}