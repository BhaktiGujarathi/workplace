trigger OpportunityTrigger on Opportunity (before insert, after insert, after update,before update) {
    OpportunityAuditOnUpdate handler = new OpportunityAuditOnUpdate();
    if(trigger.isAfter)
    {
        
        if(trigger.isUpdate)
        {
            if(checkRecursiveOppToAudTrail.runOnceForAfterOppToAudTrail())
            {   //Added by Merul For Audit Trail.
                handler.onOpportunityOwnerStatusUpdate(trigger.oldMap, trigger.new);
            }
            
            if(BFIUtility.checkRecursive==false){
                BFIUtility.checkRecursive =true;
                Opportunity_CMB_Utility.createPayables(trigger.newMap,trigger.oldmap);
            }
            
        }
        
        if(trigger.isInsert)
        {
            //Added by Merul For Audit Trail.
            OpportunityAuditOnInsert oppAuditInsert = new OpportunityAuditOnInsert();
            oppAuditInsert.onOpportunityInsertAuditTrailRecord();
            
        }
        
    }
    
    
    
    //Added code for Before Insert by Charan Vuyyuru
    if(trigger.isBefore){
        RecordType recOpportunity = [Select id from RecordType where sobjectType='Opportunity' and developerName='Read_Only'];
        Set<String> keys2check = new Set<String>();
        for(Opportunity opp: trigger.new){
            if(trigger.isInsert && opp.Funded_Date_Key__c != null ){
                keys2check.add(opp.Funded_Date_Key__c);
            }
            if(trigger.isUpdate && opp.Funded_Date_Key__c != null && trigger.oldmap.get(opp.Id).Funded_Date_Key__c  != opp.Funded_Date_Key__c){
               keys2check.add(opp.Funded_Date_Key__c);
            }
        }
        
        if(!keys2check.isEmpty()){
            Set<string> keysLocked = new Set<String>();
            for(Accounting_Calendar_Month__c acm: [Select id,locked__c,Key__c from Accounting_Calendar_Month__c where Key__c in: keys2check]){
                if(acm.Locked__c){
                    keysLocked.add(acm.Key__c);
                }
            }
            
            for(Opportunity opp: trigger.new){
                if(opp.Funded_Date_Key__c != null && keysLocked.contains(opp.Funded_Date_Key__c) ){
                    opp.addError(System.Label.OppReadOnlyError);
                }
            }
        }
    }
    
    
    
}