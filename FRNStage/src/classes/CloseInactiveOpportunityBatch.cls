global class CloseInactiveOpportunityBatch implements Schedulable, Database.Batchable<sObject>,Database.Stateful {
    string query;
    global Map<String, double> dateCompare;  
    
    global Database.querylocator start(Database.BatchableContext BC){ 
        Set<string> oppRTids = new Set<string>();
        dateCompare = new Map<String, double>();

        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
        oppRTids.add(rtId);
            OpportunityCloseDays__c OutReferral = OpportunityCloseDays__c.getInstance('Refer Out Only'); 
            dateCompare.put(rtId,OutReferral.LastModifiedDays__c);
            
        rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
        oppRTids.add(rtId);         
            OpportunityCloseDays__c OutTreatment = OpportunityCloseDays__c.getInstance('Outpatient Treatment');
            dateCompare.put(rtId,OutTreatment.LastModifiedDays__c);
        
        rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        oppRTids.add(rtId);         
            OpportunityCloseDays__c ResTreatment = OpportunityCloseDays__c.getInstance('Residential Treatment');
            dateCompare.put(rtId,ResTreatment.LastModifiedDays__c);

            Query = 'Select id, Name, LastModifiedDate,Createddate, StageName, RecordTypeId From Opportunity Where RecordTypeID IN :oppRTids';
            system.debug('Query________________________________'+Query);
        
                return Database.getQueryLocator(query);
                
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){ 
        integer mDay = 0;
        integer XDay = 0;
        integer counterDay = 0;
        System.debug('scope__________________________'+scope);		
		
		Map<Id,Opportunity> scopeMap = new Map<Id,Opportunity>(scope);
		Map<Id,List<OpportunityHistory>> oppHistoryMap = new Map<Id,List<OpportunityHistory>>();
		List<OpportunityHistory> oppHistList;
		for(OpportunityHistory oppHist:[SELECT CloseDate,CreatedById,CreatedDate,ExpectedRevenue,Id,OpportunityId,Probability,StageName,SystemModstamp FROM OpportunityHistory WHERE OpportunityId IN:scopeMap.keySet() Order By CreatedDate DESC]){
			if(oppHistoryMap.containsKey(oppHist.OpportunityId)){
				oppHistoryMap.get(oppHist.OpportunityId).add(oppHist);
			} else {
				oppHistList = new List<OpportunityHistory>();
				oppHistList.add(oppHist);
				oppHistoryMap.put(oppHist.OpportunityId,oppHistList);
			}
		}
		
		OpportunityCloseDays__c refOutDays = OpportunityCloseDays__c.getInstance('Referred Out Days'); 
		if(refOutDays != null && refOutDays.LastModifiedDays__c!=null){
			XDay = Integer.valueOf(refOutDays.LastModifiedDays__c);
			System.debug('XDay ::>>>>>'+XDay);
		}
		Datetime refOutDaysBefore = System.now().addDays(-XDay);
		
		OpportunityCloseDays__c counterOfferDay = OpportunityCloseDays__c.getInstance('Counter Offer Days'); 
		if(counterOfferDay != null && counterOfferDay.LastModifiedDays__c!=null){
			counterDay = Integer.valueOf(counterOfferDay.LastModifiedDays__c);
			System.debug('counterDay ::>>>>>'+counterDay);
		}	
		Datetime counterOfferDaysBefore = System.now().addDays(-counterDay);
			
		List<Opportunity> toUpdate = new List<Opportunity>();
		for(Opportunity opp : scope){
			system.debug('LastModifiedDate_____________________________'+opp.LastModifiedDate);    
			system.debug('StageName____________________________'+opp.StageName);
			
			
			if(dateCompare.get(opp.RecordTypeId) != null){
				mDay = Integer.valueOf(dateCompare.get(opp.RecordTypeId));
			}
			system.debug('mDay____________________________ '+mDay);             
			
			Datetime LastDays = System.now().addDays(-mDay);
			system.debug('LastDays____________________________ '+LastDays);
			
			
			if(opp.LastModifiedDate <= LastDays){
				opp.StageName = 'No Activity within 10 Days';  
				toUpdate.add(opp);          
			}else if(opp.LastModifiedDate <= refOutDaysBefore){
				opp.StageName = 'Referred Out';  
				toUpdate.add(opp);          
			}else if(opp.StageName == 'Counter Offer Requested'){
				for(OpportunityHistory oppHist:oppHistoryMap.get(opp.Id)){
					System.debug('oppHist ::>'+oppHist);
					if(oppHist.StageName!='Counter Offer Requested'){
						System.debug('counterOfferDaysBefore ::>'+counterOfferDaysBefore);
						if(oppHist.CreatedDate <= counterOfferDaysBefore){
							opp.StageName = 'Referred Out';  
							toUpdate.add(opp); 
							System.debug('opp ::>'+opp);
						}
						break;
					}
				}				
			}			
		}
		if(toUpdate.size()>0){
			update toUpdate; 
		}                        
    }

    global void finish(Database.BatchableContext BC){

    }
     /*
		Schedulable_Batch_Context
     */ 

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new closeInactiveOpportunityBatch());        
    }    
}