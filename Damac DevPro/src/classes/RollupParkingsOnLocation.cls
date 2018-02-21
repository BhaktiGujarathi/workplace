public without sharing class RollupParkingsOnLocation {
    @invocableMethod
    public static void findParkings(list<Id> ids){
    	list<Location__c> lstLocationToUpdate = new list<Location__c>(); 
    	for(Location__c objLoc : [Select l.Submit_Parkings_for_Review__c
    								   , l.Id
    								   , Total_Parkings__c
    								   , (Select Id 
    								   	  From Parkings__r) 
							   	  From Location__c l 
							   	  where l.Id IN : ids]){
    		if(objLoc.Parkings__r != null
    		&& !objLoc.Parkings__r.isEmpty()){
    			objLoc.Total_Parkings__c = objLoc.Parkings__r.size();
    			lstLocationToUpdate.add(objLoc); 
    		}
    	}
    	if(!lstLocationToUpdate.isEmpty()){
    		update lstLocationToUpdate;
    	}
    }
}