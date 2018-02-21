/* 
 *  Description - Handler for LeadMCATrigger. 
 *   
 *  Date - 08-05-2014
 *  
 *  Created by - Sneha P.
 *  updated by - Yogesh M. onBeforeUpdate() and trackLeadStatus()
 */
public with sharing class LeadHandler {

    /* Function called on After Update of lead, whenever a lead is converted and Opportunity and Contact Role is created, 
     *  the Contact role should be the Owner 1 of the Opportunity
     */ 
    public void onAfterUpdate(map<Id,Lead> oldLeadMap ,list<Lead> newLeadList){
        map<Id,Id> mapOppFirstOwner = new map<Id,Id>();
        list<Opportunity> opportunityList = new list<Opportunity>();
        
        for(Lead objLead : newLeadList){
            if(oldLeadMap.get(objLead.Id).isConverted == false && objLead.isConverted == true &&
                objLead.ConvertedOpportunityId != null && objLead.ConvertedContactId != null) {
                mapOppFirstOwner.put(objLead.ConvertedOpportunityId, objLead.ConvertedContactId);
            }
        }
        
        for(Id OppId : mapOppFirstOwner.keySet()){
            opportunityList.add(new Opportunity(Id = OppId, Owner_1__c = mapOppFirstOwner.get(OppId)));
        }
        
        try{
            //if(opportunityList.size() > 0)
                update opportunityList;
        }catch(Exception e){
            system.debug('-----Error: '+e.getMessage());
        }
    }

    public void onBeforeInsert() {
        trackLeadStatus(trigger.new);
    }

    /*Update the stage of related Contract when Opportunity stage changes to funded.*/
    public void onBeforeUpdate(map<Id, Lead> leadOldMap, list<Lead> leadNewList){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead lead: leadNewList){
                
            if(leadOldMap.get(lead.Id).Status != lead.Status)
            {
                leadsToUpdate.add(lead);
            }
        }
        trackLeadStatus(leadsToUpdate);
    }
    
    /**
     * when Lead status changed then populate its date for respective field 
     * and boolean variable to true
     */
    public void trackLeadStatus(List<Lead> leads) {
        Map<String, String> statusToDateFieldMap = StatusFieldMapping.LEAD_STATUS_DATE_FIELD_MAP;
        Map<String, String> statusToBooleanFieldMap = StatusFieldMapping.LEAD_IS_STATUS_FIELD_MAP;
        for(Lead lead :leads) {
            if(statusToDateFieldMap.containsKey(lead.Status)) {
                lead.put(statusToDateFieldMap.get(lead.Status), system.now());
            }
            if(statusToBooleanFieldMap.containsKey(lead.Status)) {
                lead.put(statusToBooleanFieldMap.get(lead.Status), true);
            }
        }
    }
}