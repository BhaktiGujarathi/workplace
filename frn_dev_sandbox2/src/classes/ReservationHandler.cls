/**
 * Class  ReservationHandler
 *
 * Trigger Handler for the Entity SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class ReservationHandler implements TriggerInterface{  
	
	
	Map<String,String> tripOppIdMap;
	Map<Id,RecordType> resRTMap;
	Map<String,List<QuoteLineItem>> oppQLIMap;
	Map<String,List<String>> oppRelatedQuotesMap;	
	Map<Id,Product2> productMap;
	Map<String,String> productRelatedPBE;
	
	public ReservationHandler(){		
		tripOppIdMap = new Map<String,String>(); 
		oppQLIMap = new Map<String,List<QuoteLineItem>>();
		oppRelatedQuotesMap = new Map<String,List<String>>();
		productMap = new Map<Id,Product2>();
		productRelatedPBE = new Map<String,String>();
		resRTMap = new Map<Id,RecordType>([SELECT Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'Reservation__c']); 		
	}
	 
	public void bulkBefore(){
		
	}
	
	public void bulkAfter(){  
		
		Set<String> tripIds = new Set<String>();
		Set<String> resIds = new Set<String>();
		for(Reservation__c res :(List<Reservation__c>) ((trigger.isDelete) ? trigger.old :trigger.new)){
			tripIds.add(res.Trip__c);//Set of reservation related trip Id
			resIds.add(res.Id);	 //Set of reservation Id		
		}
		
		if(tripIds.size()>0){
			//Map of trip and related opportunity Id
			for(Trip__c trp:[Select Id,Opportunity__c from Trip__c where Id IN:tripIds AND Opportunity__c!=null]){	
				if(trp.Opportunity__c!=null) tripOppIdMap.put(trp.Id,trp.Opportunity__c);
			}
			
			if(tripOppIdMap.size()>0){
				//Map of product whose Name = 'Car Service' OR Name = 'Airfare' 
				productMap = new Map<Id,Product2>([SELECT Auto_Add_to_Quote_Line_Items__c,Family,Id,IsActive,Name,Payment_Application_Order__c,Sort_Order__c FROM Product2 WHERE Auto_Add_to_Quote_Line_Items__c = true AND (Name = 'Car Service' OR Name = 'Airfare')]);
				
				//Default price book id
				Id FRN_PriceBookId ;
				Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
				if(pricebookName!=null)
					FRN_PriceBookId = [SELECT Id FROM Pricebook2 WHERE Name =:pricebookName.Default_Pricebook_Name__c].Id;
				
				if(productMap.size() > 0){
					for(PricebookEntry pbe : [Select id,Pricebook2Id,Product2Id,UnitPrice FROM PricebookEntry WHERE Product2Id IN: productMap.keySet() AND Pricebook2Id =: FRN_PriceBookId]){
						productRelatedPBE.put(pbe.Product2Id,pbe.Id);
					}
				}
		
				//Map of Opportunity related quotes
				List<String> quotetIds;
				for(Quote qot:[Select Id,OpportunityId FROM Quote WHERE OpportunityId IN:tripOppIdMap.values()]){
					if(oppRelatedQuotesMap.containsKey(qot.OpportunityId)){
						oppRelatedQuotesMap.get(qot.OpportunityId).add(qot.Id);
					} else {
						quotetIds = new List<String>();
						quotetIds.add(qot.Id);
						oppRelatedQuotesMap.put(qot.OpportunityId,quotetIds);
					}
				}
				System.debug('oppRelatedQuotesMap ::>'+oppRelatedQuotesMap);
				
				//Map of rest of the (same opportunity related reservation) reservations with opportunity id as key
				Map<String,List<Reservation__c>> oppResMap = new Map<String,List<Reservation__c>>();
				List<Reservation__c> resLsit;	
				for(Reservation__c res: [SELECT Id, RecordType.Name, Trip__r.Opportunity__r.Name, Rate__c, Name, Total_Amount_Charged__c FROM Reservation__c WHERE Trip__r.Opportunity__c IN : tripOppIdMap.values() AND Id NOT IN: resIds AND (RecordType.Name = 'Car Service' OR RecordType.Name = 'Airfare')]){
					if(oppResMap.containsKey(res.Trip__r.Opportunity__c)){
						(oppResMap.get(res.Trip__r.Opportunity__c)).add(res);
					} else {
						resLsit = new List<Reservation__c>();
						resLsit.add(res);
						oppResMap.put(res.Trip__r.Opportunity__c,resLsit);
					}
				}			
			
				//Map of Opportunity and list of QLIs with product name Product2.Name = 'Car Service' OR Product2.Name = 'Airfare'			
				for(QuoteLineItem qli:[Select Id,Product2Id,QuoteId,Product2.Name,Quote.OpportunityId,Auto_Added__c,UnitPrice from QuoteLineItem WHERE Quote.OpportunityId IN: tripOppIdMap.values() AND (Product2.Name = 'Car Service' OR Product2.Name = 'Airfare')]){
					if(oppQLIMap.containsKey(qli.QuoteId)){
						oppQLIMap.get(qli.QuoteId).add(qli);
					} else {
						oppQLIMap.put(qli.QuoteId,new List<QuoteLineItem>{qli});
					}
				}				
				System.debug('oppQLIMap ::>'+oppQLIMap);
			
				//Recalculate sales price of QLIs (processing reservation which are not being edited in this session)
				for(String quoteId:oppQLIMap.keySet()){
					for(QuoteLineItem qli:oppQLIMap.get(quoteId)){
						qli.UnitPrice = 0;
						if(oppResMap.containsKey(qli.Quote.OpportunityId)){
							for(Reservation__c res:oppResMap.get(qli.Quote.OpportunityId)){
								if(qli.Product2.Name == 'Car Service' && res.RecordType.Name == 'Car Service'){
									qli.UnitPrice += ((res.Rate__c!=null) ? res.Rate__c : 0.00);
								} else if(qli.Product2.Name == 'Airfare' && res.RecordType.Name == 'Airfare'){
									qli.UnitPrice += ((res.Total_Amount_Charged__c!=null) ? res.Total_Amount_Charged__c : 0.00);
								}
							}
						}
					}
				}
				System.debug('oppQLIMap ::>'+oppQLIMap);
			}			
		}
	}	
  
	public void beforeInsert(SObject so){
		
	}
	
	public void beforeUpdate(SObject oldSo, SObject so){ 
		       
	}
	
	public void beforeDelete(SObject so){
	
	}
	
	public void afterInsert(SObject so){ 
		Reservation__c res = (Reservation__c)so;
		processQLI(res);	 
		System.debug('oppQLIMap ::>'+oppQLIMap);		
	}
		 
	public void afterUpdate(SObject oldSo, SObject so){ 
		Reservation__c res = (Reservation__c)so;
		Reservation__c oldRes = (Reservation__c)oldSo;
		processQLI(res);		
		System.debug('oppQLIMap ::>'+oppQLIMap);
	}
	
	public void afterDelete(SObject so){
		
	}
	
	public void afterUndelete(SObject so){
		Reservation__c res = (Reservation__c)so;
		processQLI(res);
		System.debug('oppQLIMap ::>'+oppQLIMap);	
	}
	
	public void andFinally(){ 
		if(oppQLIMap.size()>0){
			List<QuoteLineItem> qliList = new List<QuoteLineItem>();
			for(String quoteKey:oppQLIMap.keySet()){
				System.debug('oppQLIMap.get(quoteKey) ::>'+oppQLIMap.get(quoteKey));	
				qliList.addAll(oppQLIMap.get(quoteKey));
			}
			System.debug('qliList ::>'+qliList);	
			upsert qliList;
		}
	}  
	
	public void processQLI(Reservation__c res){
		boolean isCarServiceExisted = false;
		boolean isAirfareExisted = false;		
		if((resRTMap.get(res.RecordTypeId).Name == 'Car Service') || (resRTMap.get(res.RecordTypeId).Name == 'Airfare' )){			
			if(tripOppIdMap.containsKey(res.Trip__c) && oppRelatedQuotesMap.containsKey(tripOppIdMap.get(res.Trip__c))){
				for(String quoteId:oppRelatedQuotesMap.get(tripOppIdMap.get(res.Trip__c))){	
					isCarServiceExisted = false;
					isAirfareExisted = false;
					if(oppQLIMap.containsKey(quoteId)){
						for(QuoteLineItem qli:oppQLIMap.get(quoteId)){
							if(qli.Product2.Name == 'Car Service' && resRTMap.get(res.RecordTypeId).Name == 'Car Service'){
								isCarServiceExisted = true;
								qli.UnitPrice += ((res.Rate__c!=null) ? res.Rate__c : 0.00);
							} else if(qli.Product2.Name == 'Airfare' && resRTMap.get(res.RecordTypeId).Name == 'Airfare'){
								isAirfareExisted = true;
								qli.UnitPrice += ((res.Total_Amount_Charged__c!=null) ? res.Total_Amount_Charged__c : 0.00);
							}
						}
					}		
					// if QLI of type Car Service not exist in this quote
					if(!isCarServiceExisted){
						createQLI('Car Service',quoteId,res);
					}
					// if QLI of type Airfare not exist in this quote
					if(!isAirfareExisted){
						createQLI('Airfare',quoteId,res);						
					}
				}
			}
		} 
	}
	
	public void createQLI(String type,String quoteId,Reservation__c res){
		for(Product2 prdt:productMap.values()){
			System.debug('prdt.Name ::>'+prdt.Name);
			//for each product 
			if(prdt.Name==type && productRelatedPBE.containsKey(prdt.id)){
				System.debug('prdt.Name ::>'+prdt.Name);
				QuoteLineItem qli = new QuoteLineItem();
				qli.QuoteId = quoteId;
				qli.PriceBookentryId = productRelatedPBE.get(prdt.id);
				qli.Product2Id = prdt.id;
				qli.Quantity = 1;
				qli.Auto_Added__c = true;
				if(prdt.Name == 'Car Service' && resRTMap.get(res.RecordTypeId).Name == 'Car Service'){
					qli.UnitPrice = ((res.Rate__c!=null) ? res.Rate__c : 0.00);
				} else if (prdt.Name == 'Airfare' && resRTMap.get(res.RecordTypeId).Name == 'Airfare'){
					qli.UnitPrice = ((res.Total_Amount_Charged__c!=null) ? res.Total_Amount_Charged__c : 0.00);
				}
				System.debug('qli.UnitPrice ::>'+qli.UnitPrice);
				if(qli.UnitPrice!=null && qli.UnitPrice>0){
					if(oppQLIMap.containsKey(quoteId)){
						oppQLIMap.get(quoteId).add(qli);
					} else {
						oppQLIMap.put(quoteId,new List<QuoteLineItem>{qli});  
					}								
				}
			}
		}
	}
}