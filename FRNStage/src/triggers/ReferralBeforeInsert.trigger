trigger ReferralBeforeInsert on Referral__c (Before Insert)
{
    
    Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Referral__c']);
    
    for(Referral__c r : trigger.new){
        if(r.User__c == null ) {
            if(rt_map.get(r.recordTypeID).name.containsIgnoreCase('Outbound Referral')){
                r.User__c = UserInfo.getUserId();
            }
        }
    }
}