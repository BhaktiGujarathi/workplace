/** 
* Class LeadHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class LeadHandler implements TriggerInterface 
{ 
    
/** Constructor  */
    public Map<Id,Opportunity> convertedOppMap;
    public Map<Id,Contact> convertedConMap;
    public List<Opportunity> oppList;
    public Map<String,List<String>> maplead;
    public Map<String,List<Treatment_History__c>> mapTreatmentHistorylead;
    public Map<String,CampaignMember> leadCmpMembrMap;
    private List<Referral__c> Reflist;
    private List<Treatment_History__c> TreatmentHistorylist;
    
    
    public LeadHandler(){ 
        convertedOppMap = new Map<Id,Opportunity>();
        convertedConMap = new Map<Id,Contact>();
        oppList = new List<Opportunity>();
        maplead = new Map<String,List<String>>();
        mapTreatmentHistorylead = new Map<String,List<Treatment_History__c>>();
        Reflist = new List<Referral__c>();
        TreatmentHistorylist = new List<Treatment_History__c>();
        leadCmpMembrMap = new Map<String,CampaignMember>();
    }
 
    public void bulkBefore(){
        
    }   

    public void bulkAfter(){
        Set<Id> convertedOppId = new Set<Id>();
        Set<Id> convertedConId = new Set<Id>();
        Set<Id> convertedLeadIds = new Set<Id>();  
        for(Lead ld:(List<Lead>)trigger.new){
            if(ld.isconverted){ 
                convertedOppId.add(ld.ConvertedOpportunityId);
                convertedConId.add(ld.ConvertedContactId);
                convertedLeadIds.add(ld.id);
            }
             
        }
        if(convertedOppId.size()>0){
            convertedOppMap = new Map<Id,Opportunity>([Select Id,RecordTypeId,Original_Lead_Owner__c , CloseDate,CreatedDate  from Opportunity where Id IN:convertedOppId]);
        }
        if(convertedConId.size()>0){
            convertedConMap = new Map<Id,Contact>([Select Id,Name,Birthdate from Contact where Id IN:convertedConId]);
        }
        
        //// Update Referral__c after convert Lead        
        for(Referral__c ref : [Select Id,Lead__c,Opportunity__c  from Referral__c where  Lead__c In:convertedLeadIds]){
			if(!maplead.containsKey(ref.Lead__c)){
					maplead.put(ref.Lead__c, new List<String>{ref.id}); 
			}else{
				maplead.get(ref.Lead__c).add(ref.id); 
			}
             
        }
        List<Treatment_History__c> thList;
        //// Update Treatment_History__c after convert Lead        
        for(Treatment_History__c TreatHis : [Select Id,Lead__c,Opportunity__c  from Treatment_History__c where  Lead__c In:convertedLeadIds]){
            
                if(mapTreatmentHistorylead.containsKey(TreatHis.Lead__c)){
                            mapTreatmentHistorylead.get(TreatHis.Lead__c).add(TreatHis);
                } else {
                    thList = new List<Treatment_History__c>();
                    thList.add(TreatHis);
                    mapTreatmentHistorylead.put(TreatHis.Lead__c,thList);
                } 
                
        }
        
        for(CampaignMember cmpMbr: [SELECT Id,LeadId,Referral_Order__c,RAM_Assigned_to_Referral_Source__c FROM CampaignMember WHERE LeadId IN : convertedLeadIds AND Referral_Order__c =:'Primary']) {
            leadCmpMembrMap.put(cmpMbr.LeadId,cmpMbr);
        }
    }
     
    public void beforeInsert(SObject so){       
        Lead le = (Lead)so;
        system.debug('>>> le : '+le);
        String companyname = '';
        if(le.FirstName!=null){
            companyname = le.FirstName +' ';
        }
        if(le.MiddleName!=null){
            companyname += le.MiddleName +' ';
        }

        companyname += (le.LastName != null ? le.LastName : '');
        le.company = companyname;
    } 
    
    public void beforeUpdate(SObject oldSo, SObject so){ 
        Lead le = (Lead)so;
        String companyname = '';
        if(le.FirstName!=null){
            companyname = le.FirstName +' ';
        }
        if(le.MiddleName!=null){
            companyname += le.MiddleName +' ';
        }
        companyname += le.LastName;
        le.company = companyname;
    } 
    
    public void beforeDelete(SObject so){ 

    } 
    /** 
    * afterInsert 
    * 
    * This method is called iteratively for each record inserted during an AFTER 
    * trigger. Always put field validation in the 'After' methods in case another trigger 
    * has modified any values. The record is 'read only' by this point. 
    */ 
    public void afterInsert(SObject so) { 
        
    } 

    public void afterUpdate(SObject oldSo, SObject so){ 
        String localtimeinString = System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
        System.debug('localtimeinString__________________________________'+localtimeinString);          
        Lead ld = (Lead)so;
        System.debug('New Lead __________________________________'+ld);
        Lead ldOld = (Lead)oldSo;
        System.debug('New Lead __________________________________'+ldOld);
        if(ld.isconverted && convertedOppMap.containsKey(ld.ConvertedOpportunityId) ){
            
            Opportunity opp = convertedOppMap.get(ld.ConvertedOpportunityId); 
            opp.Original_Lead_Owner__c = ld.OwnerId;
            OpportunityEstimatedCloseDays__c opcd = OpportunityEstimatedCloseDays__c.getInstance('EstimatedCloseDays');
            opp.CloseDate = (System.Today()).addDays(Integer.valueOf(opcd.Number__c));
            if(ld.Opportunity_RecordType__c != null)
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ld.Opportunity_RecordType__c).getRecordTypeId(); 
            opp.Ready_to_Make_Commitment__c = ld.Ready_to_Make_Commitment__c;
            opp.Contact__c = ld.ConvertedContactId;   
			
            System.debug('ld ::>'+ld);
            System.debug('leadCmpMembrMap ::>'+leadCmpMembrMap);
            if(leadCmpMembrMap.containsKey(ld.Id) && leadCmpMembrMap.get(ld.Id).RAM_Assigned_to_Referral_Source__c!=null)
                opp.OwnerId = leadCmpMembrMap.get(ld.Id).RAM_Assigned_to_Referral_Source__c;
            
            if(convertedConMap.containsKey(ld.ConvertedContactId)){
                String OpprecName ='IOP';
                if(ld.Opportunity_RecordType__c =='Residential Treatment'){ 
                    OpprecName = 'RTC';
                }else if(ld.Opportunity_RecordType__c =='Outpatient Treatment'){
                    OpprecName = 'IOP';
                }else if(ld.Opportunity_RecordType__c =='Refer Out Only'){
                    OpprecName = 'ROO';
                }
                System.debug('opp ::>'+opp);
                opp.Scratchpad__c = ld.Scratchpad__c;
                opp.Name = convertedConMap.get(ld.ConvertedContactId).Name  +' '+ OpprecName + ' ' + opp.CreatedDate.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
                
            }
            convertedConMap.get(ld.ConvertedContactId).Birthdate = ld.Birthdate__c;
			Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
			if(pricebookName!=null)
				opp.Pricebook2Id = [Select id, name, isActive from Pricebook2 where Name=:pricebookName.Default_Pricebook_Name__c limit 1].Id;   
            System.debug('opp ::.'+opp);
            oppList.add(opp); 
        }
        if(ld.isconverted && maplead.containsKey(ld.id)){
			for(String refId: maplead.get(ld.id)){
				 Referral__c ref = new Referral__c();
				 ref.id = refId;
				 ref.Opportunity__c = ld.ConvertedOpportunityId;
				 Reflist.add(ref);
			}
            
        }
        
        if(ld.isconverted && mapTreatmentHistorylead.containsKey(ld.id)){
            for(Treatment_History__c th : mapTreatmentHistorylead.get(ld.id)){
                Treatment_History__c TreatHis = new Treatment_History__c();
                TreatHis.id = th.id;
                TreatHis.Opportunity__c = ld.ConvertedOpportunityId;
                TreatmentHistorylist.add(TreatHis);
            }
             
        } 
                
        
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
        if(oppList.size()>0){
            update oppList;
            System.debug('oppList ::>'+oppList);
        }
        System.debug('Reflist ::>'+Reflist);
         if(Reflist.size()>0){
            update Reflist; 
        }
        
        System.debug('TreatmentHistorylist ::>'+TreatmentHistorylist);
        if(TreatmentHistorylist.size()>0){
            update TreatmentHistorylist; 
        }
        if(convertedConMap.size() >0){
            update convertedConMap.values();
        }
        
    } 
}