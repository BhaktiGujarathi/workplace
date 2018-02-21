/*
Description : 
Created By   : Pratiksha Narvekar
Created Date :24-07-2017
Test Class : 
Change History : 
*/

public class SRStausBar {
    public string ClosedactiveString{get;set;}
    public string CreatedactiveString{get;set;}
    public string Task1activeString{get;set;}
    public string Task2activeString{get;set;}
    public string Task3activeString{get;set;}
    
    String SRID{get;set;}
    public SRStausBar(ApexPages.StandardController controller) {
        SRID = ApexPages.currentPage().getParameters().get('id');
    	System.debug('...SRID...'+SRID);
    	SRStausBar();
    }
    public void SRStausBar(){
        System.debug('...SRID2...'+SRID);
    	if(SRID !=''){
    		List<Service_Request__c> objSR = new List<Service_Request__c>();
    		List<Task> objTask = new List<Task>();
    		objTask =[Select ID,
    		                 WhatId,
    		                 Subject,
    		                 Status
    		         From Task
    		         WHERE WhatId =: SRID];
    		objSR =[Select Status__c,
    		               IsTask1_Completed__c,
    		               IsTask2_Completed__c,
    		               IsTask3_Completed__c,
    		               SR_Type__c,
    		               ID 
    		        From Service_Request__c
    		        WHERE ID =: SRID];
    		System.debug('...objTask...'+objTask);        
    		if(!objSR.isEmpty()){
    			if(objSR[0].Status__c =='Closed'){
    				ClosedactiveString='active';
    			}
    			else if(objSR[0].Status__c =='New' && objSR[0].IsTask1_Completed__c == false){
    				CreatedactiveString = 'active';
    			}
    			if(!objTask.isEmpty()){
    		    for(Task objT : objTask){
    			if(objSR[0].SR_Type__c =='Change of Contact Details'
    			   && objT.Subject=='Verify Details And Documnets' 
    			   && objT.Status !='Completed'){
    				Task1activeString='active';
    			}
    			else if(objSR[0].SR_Type__c =='Change of Contact Details'
    			        && objT.Subject=='Verify Payment Received' 
    			        && objT.Status !='Completed'){
    				Task2activeString='active';
    			}
    			else if(objSR[0].SR_Type__c =='Change of Contact Details'
    			        && objT.Subject=='Inform Customer on Approval' 
    			        && objT.Status !='Completed' ){
    				Task3activeString='active';
    			}
    			}   
    			} 			    			    			
    		}        
    	}
    }
}