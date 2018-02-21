public class PaymentTermsTriggerHandler implements TriggerFactoryInterface{
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
        
        
        
    }    
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after update.                        *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    
        
    }
    
    
    // TOBE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        
        
        set<String> TermIds = new set<String>();
        for(sobject sobj: newRecordsList){
            Payment_Terms__c pt = (Payment_Terms__c) sobj;
            if(pt.TERM_ID__c != null){
                TermIds.add(pt.TERM_ID__c);
            }
            System.debug('>>>>>>>>>>>>>>'+pt.Milestone_event_arabic__c);
        }
        
        if(!TermIds.isEmpty()){
            Map<String,Payment_Plan__c> mpPlans = new Map<string,Payment_Plan__c>();
            for(Payment_Plan__c pp: [Select id,TERM_ID__c from Payment_Plan__c where TERM_ID__c in: termIds]){
                mpPlans.put(pp.TERM_ID__c, pp);
            }
            
            for(sobject sobj: newRecordsList){
                Payment_Terms__c pt = (Payment_Terms__c) sobj;
                if(pt.TERM_ID__c != null && mpPlans.containsKey(pt.TERM_ID__c)){
                    pt.Payment_Plan__c = mpPlans.get(pt.TERM_ID__c).Id;
                }
            }
        }
        
    }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        
        set<String> TermIds = new set<String>();
        for(sobject sobj: newRecordsMap.values()){
            Payment_Terms__c pt = (Payment_Terms__c) sobj;
            if(pt.TERM_ID__c != null){
                TermIds.add(pt.TERM_ID__c);
            }
            System.debug('>>>>>>>>>>>>>>'+pt.Milestone_event_arabic__c);
        }
        
        if(!TermIds.isEmpty()){
            Map<String,Payment_Plan__c> mpPlans = new Map<string,Payment_Plan__c>();
            for(Payment_Plan__c pp: [Select id,TERM_ID__c from Payment_Plan__c where TERM_ID__c in: termIds]){
                mpPlans.put(pp.TERM_ID__c, pp);
            }
            
            for(sobject sobj: newRecordsMap.values()){
                Payment_Terms__c pt = (Payment_Terms__c) sobj;
                if(pt.TERM_ID__c != null && mpPlans.containsKey(pt.TERM_ID__c)){
                    pt.Payment_Plan__c = mpPlans.get(pt.TERM_ID__c).Id;
                }
            }
        }
    
    }
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}

}