public class CommissionTriggerHandler implements TriggerFactoryInterface {
    
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        mapRegistrations(newRecordsList);
    }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        mapRegistrations(newRecordsMap.values());
    }
    
    private void mapRegistrations(List<sObject> records){
        set<String> regIds = new set<String>();
        for(sObject sObj: records){
            Agent_commission__c acom = (Agent_commission__c)sObj;
            if(aCom.Registration_ID__c != null){
                regIds.add(aCom.Registration_ID__c);
            }
        }
        Map<string,Booking_Unit__c> registrationMap = new Map<string,Booking_Unit__c>();
        if(!regIds.isEmpty()){
            for(Booking_Unit__c bu: [Select id, Registration_ID__c, Booking__c from Booking_Unit__c where Registration_ID__c in: regIds]){
                registrationMap.put(bu.Registration_ID__c, bu);
            }
        }
        for(sObject sObj: records){
            Agent_commission__c acom = (Agent_commission__c)sObj;
            if(aCom.Registration_ID__c != null){
                if(registrationMap.containsKey(aCom.Registration_ID__c)){
                    acom.Booking_Unit__c = registrationMap.get(aCom.Registration_ID__c).Id;
                    acom.Booking__c = registrationMap.get(aCom.Registration_ID__c).Booking__c;
                }
            }
        }
    }
    // TOBE Implemented
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){} 
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
}// End of class.