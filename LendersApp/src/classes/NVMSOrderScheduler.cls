global with sharing class NVMSOrderScheduler implements Database.Batchable<Opportunity>,
														Database.AllowsCallouts,
														Database.Stateful,
														Schedulable{
															
    global List<Opportunity> start(Database.BatchableContext BC){
    	Map<String,NVMS_Configuration__c> configMap = NVMS_Configuration__c.getAll();
		Set<String> jobIds = new Set<String>();
		List<NVMS_Configuration__c> deleteableConfigs = new List<NVMS_Configuration__c>();
		for(String key : configMap.keyset()){
			NVMS_Configuration__c configObj = configMap.get(key);
			if(key != null && configObj.value__c == 'Opportunity'){
			    jobIds.add(key);
			    deleteableConfigs.add(configObj);
			}
		}
		
		if(jobIds != null && !jobIds.isEmpty()){
			List<Opportunity> oppList = [SELECT ID,Site_Inspection_Status__c,StageName,OrderNumber__c from Opportunity where ordernumber__c in :jobIds];
			for(Opportunity oppObj : oppList){
				oppObj.Site_Inspection_Status__c = 'Completed';
			}
			//if(oppList != null && !oppList.isEmpty())
				//update oppList;
			
				
			delete deleteableConfigs;
			return oppList;			
		}
      	return null;
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
       // UpdateExchangeRates((List<c2g__codaCompany__c>)scope);
       for(Opportunity oppObj:scope){
       		ApexPages.StandardController con = new ApexPages.StandardController(oppObj);
       		NVMSOrderFormExtension ext = new NVMSOrderFormExtension(con);
       		ext.AttachOrderPDFDocument();
       }
       if(scope != null && !scope.isEmpty())
       	update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
      
	public void execute(SchedulableContext sc){
		NVMSOrderScheduler b = new NVMSOrderScheduler(); //ur batch class
      	database.executebatch(b,5);
	}
}