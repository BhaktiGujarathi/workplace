/**
 * Class ReferralHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class ReferralHandler implements TriggerInterface {
    
    public Map<Id,String> RAMLookupMap ;
    public Map<Id,Opportunity> OppList ;
    public Map<Id,Opportunity> oppMap;
    
    // Constructor
    public ReferralHandler(){
        RAMLookupMap = new Map<Id,String>();
        OppList = new  Map<Id,Opportunity>();
        oppMap = new Map<Id,Opportunity>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){ 
       
        
    }
 
    public void bulkAfter(){
        Set<Id> accIdset = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for(Referral__c re: (List<Referral__c>)trigger.new){
            if(re.Account__c != null){
                accIdset.add(re.Account__c);
            }
            if(re.Opportunity__c != null){
                oppIds.add(re.Opportunity__c);
            }
        }
      
        for(Account acc:[select id,RAM_Lookup__c from Account where Id IN: accIdset]){
            RAMLookupMap.put(acc.Id,acc.RAM_Lookup__c);
        }
        if(oppIds.size()>0){
            oppMap = new Map<Id,Opportunity>([Select Id,
                                                     RAM_Assigned__c,
                                                     RecordTypeId 
                                                from Opportunity 
                                               where Id IN:oppIds]);
        }
    }
    
        
    
 
    public void beforeInsert(SObject so){
       /*  Referral__c ref = (Referral__c)so;
        if(ref.RecordTypeId == Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId() && ref.User__c == null){
             ref.User__c = UserInfo.getUserId();
        } */
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){ 
        
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
 
    public void afterInsert(SObject so){  
        Referral__c ref = (Referral__c)so;
        Opportunity opp = new Opportunity();
        opp = oppMap.get(ref.Opportunity__c);
        Id iopOpportunityRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
        if( ref.Opportunity__c != null
         && opp.RecordTypeId != iopOpportunityRecordtypeId
         && ref.RecordTypeId == Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId() 
         && (ref.Referral_Rank__c == 'Primary') 
         && RAMLookupMap.containsKey(ref.Account__c)){            
            if(opp.RAM_Assigned__c == null) {
                opp.RAM_Assigned__c = RAMLookupMap.get(ref.Account__c);
                system.debug('>>> is null');
            }
            OppList.put(opp.Id, opp);
        }
    }
 
    public void afterUpdate(SObject oldSo, SObject so){  
          Referral__c ref = (Referral__c)so;
          Referral__c Oldref = (Referral__c)oldSo;
          Opportunity opp = new Opportunity();
          opp = oppMap.get(ref.Opportunity__c);
          Id iopOpportunityRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
        if(oppMap.containsKey(ref.Opportunity__c) 
        && opp.RecordTypeId != iopOpportunityRecordtypeId
        && (ref.Referral_Rank__c == 'Primary') 
        && oppMap.get(ref.Opportunity__c).RAM_Assigned__c!= RAMLookupMap.get(ref.Account__c) 
        && ref.Opportunity__c != null && ref.RecordTypeId ==  Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId()){
            
            if(opp.RAM_Assigned__c == null) {
                opp.RAM_Assigned__c = RAMLookupMap.get(ref.Account__c);
                system.debug('>>> is null');
            }
            OppList.put(opp.Id, opp);
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
        System.debug('OppList.Size_________________________ '+OppList.size());
        if(OppList.size()>0){
            Util.flag = false; // To isolate this handler from OpportunityHandler
            Update OppList.values();
        }
    }
}