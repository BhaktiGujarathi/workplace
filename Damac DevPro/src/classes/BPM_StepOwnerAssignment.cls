global without sharing class BPM_StepOwnerAssignment implements NSIBPM.Step_Assignment_Executable {
    
    //Assigns owner for the first step that is created on SR submit
	global List<NSIBPM__Step__c> Assign_Step_Owner_SR_Submit(Map<String, NSIBPM__Service_Request__c> MapSRs, list<NSIBPM__Step__c> lstSteps, Map<String, NSIBPM__SR_Steps__c> MapSRSteps) {
    	system.debug('--Interface Execition-->Assign_Step_Owner_SR_Submit');
    	return lstSteps;
  	}
   
	//Assigns owner for the subsquent steps that are created depending on closure of previous step
	global list<NSIBPM__Step__c> Assign_Step_Owner_Step_Closure(Map<String, NSIBPM__Step__c> MapSteps, list<NSIBPM__Step__c> lstSteps, Map<String, NSIBPM__SR_Steps__c> MapSRSteps) {
    	system.debug('--Interface Execition-->Assign_Step_Owner_Step_Closure');
        list<NSIBPM__Step__c> lststepstoupdate = assignStepOwnerMethod(lstSteps);
    	return lststepstoupdate;
  	} 
  	
  	public static list<NSIBPM__Step__c> assignStepOwnerMethod(list<NSIBPM__Step__c> lstSteps){
  		system.debug('--lstSteps1---'+lstSteps);
  		/*map<string,GEMS_Queue_Config__c> customSettingsForQueue = GEMS_Queue_Config__c.getAll();
  		map<string,string> mapOfSchoolAndQueue = new map<string,string>();
  		map<string,id> mapOfQueueAndId = new map<string,id>();
  		system.debug('--customSettingsForQueue---'+customSettingsForQueue);
  		if(customSettingsForQueue!=null && customSettingsForQueue.size()>0){
  			for(GEMS_Queue_Config__c var : customSettingsForQueue.values()){
  				mapOfSchoolAndQueue.put(var.School_Name__c,var.Queue_Name__c);	
  			}	
  			for(Group grp : [Select Id,Name,DeveloperName from Group where type = 'Queue' and Name = :mapOfSchoolAndQueue.values()]){
	        	mapOfQueueAndId.put(grp.name,grp.id);
			}
			system.debug('--mapOfSchoolAndQueue---'+mapOfSchoolAndQueue);
			system.debug('--mapOfQueueAndId---'+mapOfQueueAndId);
  			
  		}
  		
  		map<id,string> serviceRequestAndLinkedSchool = new map<id,string>();
  		if(lstSteps!=null && lstSteps.size()>0 && mapOfSchoolAndQueue!=null && mapOfSchoolAndQueue.size()>0){
  			for(NSIBPM__Step__c objStep : lstSteps){
  				objStep.OwnerId = mapOfQueueAndId.get(mapOfSchoolAndQueue.get(objStep.HexaBPM__SR__r.School_Name_Dev__c));
  			}	
  			return lstSteps;
  		}*/
  		system.debug('--lstSteps2---'+lstSteps);
  		return null;
  	}
    
}