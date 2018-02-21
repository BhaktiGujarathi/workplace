trigger PaymentPlanTrg on Payment_Plan__c (before insert, before update) {
    //Commenting the logic done by Informatica
    /*
    Map<String,Location__c> mpLocs = new Map<String,Location__c>();
    set<string> buildingIds = new set<string>();
    for(Payment_Plan__c pp: trigger.new){
        buildingIds.add(pp.Building_ID__c);
    }
    
    if(!buildingIds.isEmpty()){
        for(Location__c loc: [Select id,Location_Id__c from Location__c where Location_Id__c in: buildingIds]){
            mpLocs.put(loc.Location_Id__c, loc);
        }
        for(Payment_Plan__c pp: trigger.new){
            if(mpLocs.containsKey(pp.Building_Id__c))
                pp.Building_Location__c = mpLocs.get(pp.Building_Id__c).Id;
        }
    }
    */
    
}