/*
Author: Charan Vuyyuru
Created Date: 07/24/2105
Description: Populates the Original Campaign Info to Custom field on Lead.
*/
trigger CloneCampaignInfo on CampaignMember (before insert) {
    
    //Preparing a Map of Lead Id with Campaign Id
    Map<Id,Id> mpLeads = new map<Id,Id>();
    for(CampaignMember cm : trigger.new){
        mpLeads.put(cm.LeadId,cm.CampaignId);
    }
    
    //Querying the new leads that don't have Original Campaign Info populated.
    List<Lead> lstLeads = new List<Lead>();
    for(Lead ld : [Select id from lead where Id in: mpLeads.keyset() and Original_Campaign__c = null]){
        //Checking whether Lead exists in the map keyset.
        if(mpLeads.containsKey(ld.Id)){
            ld.Original_Campaign__c = mpLeads.get(ld.Id);
            lstLeads.add(ld);
        }
    }
    
    //Updating the valid Leads
    if(!lstleads.isEmpty())
    update lstleads;
    
}