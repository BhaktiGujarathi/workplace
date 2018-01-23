/**
 * Class CampaignMemberHandler
 *
 * Trigger Handler for the Campaign MemberHandler SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class CampaignMemberHandler implements TriggerInterface {
    
    
    public Map<String,Campaign> mapCampaign; 
    public Map<String,Lead> mapLead; 
    public List<Referral__c> ReflistSource;
    
	// Constructor
    public CampaignMemberHandler(){
		mapCampaign = new Map<String,Campaign>();
		mapLead = new Map<String,Lead>(); 
		ReflistSource = new List<Referral__c>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){
        Set<Id> cmId = new Set<Id>();
        for(CampaignMember cm:(List<CampaignMember>)trigger.new){
            cmId.add(cm.CampaignId);
        }
        if(cmId.size() > 0){
            for(Campaign cam: [Select id,Referral_Source__c,Referral_Source__r.RAM_Lookup__c from Campaign where id IN : cmId AND Referral_Source__c != null]){
                mapCampaign.put(cam.Id, cam);
            }            
        }
    }
 
    public void bulkAfter(){
        Set<Id> cmId = new Set<Id>();
        for(CampaignMember cm:(List<CampaignMember>)trigger.new){
            cmId.add(cm.LeadId);
        }
        if(cmId.size() > 0){
            for(Lead ld: [Select id,Name,City,State from Lead where id IN : cmId]){
                mapLead.put(ld.Id, ld);
            }            
        }
    }
 
    public void beforeInsert(SObject so){        
        CampaignMember cm = (CampaignMember)so;
        if(mapCampaign.containsKey(cm.CampaignId)){
            cm.Referral_Source__c = mapCampaign.get(cm.CampaignId).Referral_Source__c;      
			if(mapCampaign.get(cm.CampaignId).Referral_Source__r.RAM_Lookup__c!=null)
				cm.RAM_Assigned_to_Referral_Source__c = mapCampaign.get(cm.CampaignId).Referral_Source__r.RAM_Lookup__c;
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        CampaignMember cm = (CampaignMember)so;
        if(mapCampaign.containsKey(cm.CampaignId) && cm.CampaignId != null){
            cm.Referral_Source__c = mapCampaign.get(cm.CampaignId).Referral_Source__c;
            if(mapCampaign.get(cm.CampaignId).Referral_Source__r.RAM_Lookup__c!=null)
				cm.RAM_Assigned_to_Referral_Source__c = mapCampaign.get(cm.CampaignId).Referral_Source__r.RAM_Lookup__c;
        }
    }
    
    public void afterInsert(SObject so){
        CampaignMember cm = (CampaignMember)so;
        if(cm.Referral_Source__c != null ){
            Referral__c refl = new Referral__c();
            if(cm.LeadId  != null){
                refl.Lead__c = cm.LeadId ;
            }
            if(cm.Referral_Source__c  != null){
                refl.Account__c = cm.Referral_Source__c;
            }
            if(cm.CampaignId != null){
                refl.Campaign__c = cm.CampaignId;
            }
            if(cm.Referral_Source_Contact__c != null){
                refl.Consentor__c = cm.Referral_Source_Contact__c;
            }
            if(cm.LeadId != null && mapLead.containsKey(cm.LeadId)){
                refl.Patient_Name__c = mapLead.get(cm.LeadId).Name;
                refl.City__c = mapLead.get(cm.LeadId).City;
                refl.State__c = mapLead.get(cm.LeadId).State;
            }
            refl.RecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
            ReflistSource.add(refl);            
        }        
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        CampaignMember cm = (CampaignMember)so;
        if(cm.Referral_Source__c != null ){
            Referral__c refl = new Referral__c();
            if(cm.LeadId  != null){
                refl.Lead__c = cm.LeadId ;
            }
            if(cm.Referral_Source__c  != null){
                refl.Account__c = cm.Referral_Source__c;
            }
            if(cm.CampaignId != null){
                refl.Campaign__c = cm.CampaignId;
            }
            if(cm.Referral_Source_Contact__c != null){
                refl.Consentor__c = cm.Referral_Source_Contact__c;
            }
            if(cm.LeadId != null && mapLead.containsKey(cm.LeadId)){
                refl.Patient_Name__c = mapLead.get(cm.LeadId).Name;
                refl.City__c = mapLead.get(cm.LeadId).City;
                refl.State__c = mapLead.get(cm.LeadId).State;
            }            
            refl.RecordTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
            ReflistSource.add(refl);            
        }
    }
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
       if(ReflistSource.size() >0){
           insert ReflistSource;
       }
       System.debug('ReflistSource..>> '+ReflistSource);
    }
}