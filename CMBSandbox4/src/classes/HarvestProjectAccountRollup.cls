/*
* Version 		Date             Author         Description
* 	1.0			24/09/2015       Ashwini S      For Roll up on Account for Actual_Minus_Estimate__c and for total no.of project 
*/


public with sharing class HarvestProjectAccountRollup {
	
    public HarvestProjectAccountRollup(){}
//this roll up will update account
    public void accountRollup(map<Id, HarvestProject__c> mapNewHarvestProjectList, map<Id, HarvestProject__c> mapOldHarvestProjectList){ 
        set<Id> setAccount = new set<Id>();// to  fetch  related account
        decimal totalUnusedEstimatedHours = 0;// to count unused estimated hours
        decimal openProjects=0;// no. of project that are not archived
        list<Account> accountListResult = new list<Account>(); // list of account that will be updated
        if (mapNewHarvestProjectList!= null){
            for(HarvestProject__c project: mapNewHarvestProjectList.Values()){
                if(project.Account__c != null){
                    setAccount.add(project.Account__c); 
                }
            }
    	}// in case of account change on update
    	if (mapOldHarvestProjectList!= null){
    		for(HarvestProject__c project: mapOldHarvestProjectList.Values()){
   				if(project.Account__c != null){
     				setAccount.add(project.Account__c); 
    			}
    		}
    	}
    	list<Account> lstAcc = [Select Id,
	    							Total_unused_estimated_hours__c,
	    							Total_of_projects__c,
	    							Total_Open_Projects__c,
	    							(Select Account__c,
	    								Actual_Minus_Estimate__c, 
	    								Archived__c
	    							From HarvestProjects__r )
    							From Account 
    							Where Id IN : setAccount];
    	
   	if(lstAcc != null && !lstAcc.isEmpty()){ 	
    	for(Account objAcc: lstAcc){ 
   			totalUnusedEstimatedHours=0;
   			openProjects=0;
   			for(HarvestProject__c objProject : objAcc.HarvestProjects__r){
   			    system.debug(objProject.Archived__c);
    			if(objProject.Archived__c==false){
    			 totalUnusedEstimatedHours = totalUnusedEstimatedHours + decimalValue(objProject.Actual_Minus_Estimate__c);
    			 openProjects=openProjects+1;
    			 system.debug(totalUnusedEstimatedHours);
    			}
   			}
   			objAcc.Total_unused_estimated_hours__c = totalUnusedEstimatedHours;
   			objAcc.Total_of_projects__c=objAcc.HarvestProjects__r.size();
   			objAcc.Total_Open_Projects__c=openProjects;
   			accountListResult.add(objAcc);
    	}
    	if(!accountListResult.isEmpty()){
   			update accountListResult;
    	}
  	}
  }
  
  //to convert null value into decimal
  public decimal decimalValue(decimal decValue){
   		return((decValue!=null && decvalue>0)?decValue:0);
  }	
}