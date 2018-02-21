public with sharing class OfferHandler {
	
	private static final String OFFER_CHOSEN = 'Chosen'; 
	
	public void onBeforeInsert(list<Offer__c> offerList) {
		updateFunder(offerList);
	}
	
	public void onBeforeUpdate(list<Offer__c> offerList) {
		updateFunder(offerList);
	}
	
	//Stmt - on insert check if there are chosen offers for that oppo if yes do nothing
	public void onAfterInsert(list<Offer__c> offerList){
		updateOppAmount(offerList);
	}
	
	public void onAfterUpdate(list<Offer__c> offerList){
		updateOppAmount(offerList);
	}
	
	public void onAfterDelete(list<Offer__c> offerList){
		updateOpportunityAmountOnDelete(offerList);
	}
	
	
	public void updateOpportunityAmountOnDelete(list<Offer__c> offerList){
		set<Id> OpportunitySet = new set<Id>();
		map<Id,Opportunity> updatedOppMap = new map<Id,Opportunity>();
		
		for(Offer__c offer : offerList){
			if(offer.Opportunity__c != null){
				OpportunitySet.add(offer.Opportunity__c);
			}
		} 
		map<Id,Opportunity> opportunityMap = new map<Id,Opportunity>();
		
		opportunityMap.putAll(this.getOpportunityMap(null, OpportunitySet));
		
		for(Offer__c offer : offerList){
			if(updatedOppMap.isEmpty() || (!updatedOppMap.isEmpty() && !updatedOppMap.containsKey(offer.Opportunity__c))){
				
				Decimal highestOfferAmt = 0;
					
				// Iterate thr the offer for that oppo
				for(Offer__c objOffer: opportunityMap.get(offer.Opportunity__c).Offers__r ){
				
					system.debug('**objOffer**'+objOffer);
					if(objOffer.Status__c == OFFER_CHOSEN){
						
						//Overwrite the offer amount with chosen offer							
						highestOfferAmt = objOffer.Amount__c;
						break;
					}else if(objOffer.Amount__c > highestOfferAmt)
						highestOfferAmt = objOffer.Amount__c;
				}
				
				updatedOppMap.put(offer.Opportunity__c, new Opportunity(Id = offer.Opportunity__c, Amount = highestOfferAmt ));
			}
		}
		
		if(!updatedOppMap.isEmpty())
			update updatedOppMap.values();
	}
	
	public map<Id,Opportunity> getOpportunityMap(set<Id> chosenOpportunitySet, set<Id> OpportunitySet ){
		return new map<Id,Opportunity>([Select Id,Amount,
											   (Select Amount__c, 
													   Status__c,
													   Opportunity__c  
											 	from Offers__r) 
										from Opportunity where Id IN: opportunitySet or
										 						 Id IN: chosenOpportunitySet]);	
	}
	
	public void updateOppAmount(list<Offer__c> offerList){
		set<Id> chosenOpportunitySet = new set<Id>();
		set<Id> OpportunitySet = new set<Id>();
		map<Id,Id> oppChosenOfferIdMap = new map<Id,Id>(); 
		//set<Id> 
		map<Id,Opportunity> updatedOppMap = new map<Id,Opportunity>();
		
		//on insert check if its a chosen offer , if yes insert it to opp
		for(Offer__c offer : offerList){
			if(offer.Opportunity__c != null){
				if(offer.Status__c  == OFFER_CHOSEN){
					chosenOpportunitySet.add(offer.Opportunity__c);
					oppChosenOfferIdMap.put(offer.Opportunity__c, offer.Id);
					
				}else{
					OpportunitySet.add(offer.Opportunity__c);
				}
			}
		} 
		
		map<Id,Opportunity> opportunityMap =  new map<Id,Opportunity>();
		
		opportunityMap.putAll(this.getOpportunityMap(chosenOpportunitySet, OpportunitySet));

		for(Offer__c offer : offerList){
			system.debug('***offer**'+offer.ID);
			if(offer.Opportunity__c != null && !opportunityMap.isEmpty()	
											&& opportunityMap.containsKey(offer.Opportunity__c)){
				
				Boolean hasChosenOffer = false;
				Decimal highestOfferAmt = 0;
				
				Opportunity opp;
				if(!updatedOppMap.isEmpty() && updatedOppMap.containsKey(offer.Opportunity__c))
					opp = updatedOppMap.get(offer.Opportunity__c);
				else{
					opp = opportunityMap.get(offer.Opportunity__c);	
				}
					
				if(offer.Status__c == OFFER_CHOSEN ){
					
					chosenOpportunitySet.add(offer.Opportunity__c);
					
					hasChosenOffer = true;
					opp.Amount = offer.Amount__c;
					oppChosenOfferIdMap.put(opp.Id , offer.Id);
				}
				//Check if its not a chosen offer and  there is no chosen offer in trigger.new for same opportunity
				else if(offer.Status__c != OFFER_CHOSEN && (chosenOpportunitySet.isEmpty() || 
																	(!chosenOpportunitySet.isEmpty() 
														 			 && !chosenOpportunitySet.contains(offer.Opportunity__c))) )
				{
					//if offer is not chosen, check if opportunity has any chosen offers
					for(Offer__c objOffer: opportunityMap.get(offer.Opportunity__c).Offers__r ){
						
						system.debug('**objOffer**'+objOffer);
						if(objOffer.Amount__c > highestOfferAmt)
							highestOfferAmt = objOffer.Amount__c;
								
						if(objOffer.Status__c == OFFER_CHOSEN){
							
							chosenOpportunitySet.add(offer.Opportunity__c);
							
							oppChosenOfferIdMap.put(objOffer.Opportunity__c , objOffer.Id);
							hasChosenOffer = true;
							//Overwrite the offer amount with chosen offer							
							highestOfferAmt = objOffer.Amount__c;
							break;
						}
					}
					
					system.debug('**highestOfferAmt*'+highestOfferAmt);
					//Check if the Opportunity has no chosen offer					
					if(!hasChosenOffer){
						
						//Assumption - if any of the offer amount does not match opp amount then update oppo amount or
						// 			   
						//If the Opportunity Amount is less than offer amount then update the Opportunity amount
						if(opp!= null && (oppChosenOfferIdMap.isEmpty() || (!oppChosenOfferIdMap.isEmpty() 
																		   && !oppChosenOfferIdMap.containsKey(offer.Opportunity__c)
																		   )
									      )){ 
												  
							opp.Amount = offer.Amount__c > highestOfferAmt ? offer.Amount__c : highestOfferAmt;
							//opp.Amount = highestOfferAmt;
						}
							
					}else{
						opp.Amount = highestOfferAmt;
					}
					//updatedOppMap.put(opp.Id,opp);	
				}
				updatedOppMap.put(opp.Id,opp);	
			}
		}
		if(!updatedOppMap.isEmpty()){
			system.debug('**updatedOppMap***'+updatedOppMap);
			update updatedOppMap.values();
		}
	}
	
	public void updateFunder(list<Offer__c> offerList) {
		set<Id> submissionIdSet = new set<Id>();
		map<Id,Submission__c> submissionMap = new map<Id,Submission__c>();
		
		//on Insert of offer collect the Submission of all offer
		for(Offer__c offer : offerList) {
			
			//TODO - for update ccheck if the submission is changed
			if(offer.Submission__c != null)
				submissionIdSet.add(offer.Submission__c);
		}
		
		if(!submissionIdSet.isEmpty()) {
			submissionMap = new map<Id,Submission__c>([Select Id,Name,Funder__c 
													   from Submission__c 
													   where Id IN: submissionIdSet]);
		}
		for(Offer__c offer : offerList) {
			
			//TODO - for update ccheck if the submission is changed then only update
			if(offer.Submission__c != null && submissionMap != null && !submissionMap.isEmpty() 
																	&& submissionMap.containsKey(offer.Submission__c)){
				offer.Funder__c = submissionMap.get(offer.Submission__c).Funder__c;	
			}
		}			 
	}
}