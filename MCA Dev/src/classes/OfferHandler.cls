public with sharing class OfferHandler {

    private static final String OFFER_CHOSEN = 'Chosen';
    private Set<Id> opportunityIds = new Set<Id>();
    private static final string errorMessage = 'Only 1 Offer can have the Status Chosen:';
    // Used in SubmissionTrigger to fire delete event handler for Offer on delete of Submission
    public static List<Offer__c> offersToDelete;

    public void onBeforeInsert(map<Id,Offer__c> pOldOfferMap,
                                                             list<Offer__c> pNewOfferList) {
        validateOfferDetailsOnBeforeInsert(pOldOfferMap, pNewOfferList);
        updateFunder(pNewOfferList);
    }

    public void onBeforeUpdate(list<Offer__c> offerList) {
        validateOfferDetailsOnBeforeUpdate((Map<Id, Offer__c>)Trigger.newMap);
        updateFunder(offerList);
    }

    //Stmt - on insert check if there are chosen offers for that oppo if yes do nothing
    public void onAfterInsert(list<Offer__c> offerList){
        updateOppAmount(offerList);
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'OfferRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_noOfOffers =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT', 'Id',
                    'Number_of_offers__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_noOfOffers , offerList,
                'Offer__c', 'Opportunity__c', 'Opportunity', '');
         }
    }

    public void onAfterUpdate(list<Offer__c> offerList){
        updateOppAmount(offerList);
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'OfferRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_noOfOffers =
                    new list<RollupService.fieldDefinition> {
                new RollupService.fieldDefinition('COUNT', 'Id',
                'Number_of_offers__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_noOfOffers , offerList,
                'Offer__c', 'Opportunity__c', 'Opportunity', '');
        }
    }

    public void onAfterDelete(list<Offer__c> offerList){
        updateOpportunityAmountOnDelete(offerList);
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'OfferRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_noOfOffers =
                    new list<RollupService.fieldDefinition> {
                new RollupService.fieldDefinition('COUNT', 'Id',
                'Number_of_offers__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_noOfOffers , offerList,
                'Offer__c', 'Opportunity__c', 'Opportunity', '');
        }
    }
    public void onAfterUndelete(list<Offer__c> offerList){
        if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'OfferRollUpTrigger'].IsActivate__c){
            list<RollupService.fieldDefinition> fieldDefinitions_noOfOffers =
                new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT', 'Id',
            'Number_of_offers__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions_noOfOffers , offerList,
            'Offer__c', 'Opportunity__c', 'Opportunity', '');
        }
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
        System.debug('>>>>chosenOpportunitySet>>>>'+chosenOpportunitySet);

        map<Id,Opportunity> opportunityMap =  new map<Id,Opportunity>();

        opportunityMap.putAll(this.getOpportunityMap(chosenOpportunitySet, OpportunitySet));
        System.debug('>>>>opportunityMap>>>>'+opportunityMap);

        for(Offer__c offer : offerList){
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
                    //opp = assignValue(opp, offer);
                    //opp.Amount = offer.Amount__c;
                    oppChosenOfferIdMap.put(opp.Id , offer.Id);
                    //if(oppChosenOfferIdMap.containsKey()) {
                        opp.Chosen_Offer__c = offer.Id;
                    //}
                }
                //Check if its not a chosen offer and  there is no chosen offer in trigger.new for same opportunity
                else if(offer.Status__c != OFFER_CHOSEN && (chosenOpportunitySet.isEmpty() ||
                                                                    (!chosenOpportunitySet.isEmpty()
                                                                     && !chosenOpportunitySet.contains(offer.Opportunity__c))) )
                {

                    //if offer is not chosen, check if opportunity has any chosen offers
                    for(Offer__c objOffer: opportunityMap.get(offer.Opportunity__c).Offers__r ){
                        if(objOffer.Amount__c > highestOfferAmt)
                            highestOfferAmt = objOffer.Amount__c;

                        if(objOffer.Status__c == OFFER_CHOSEN){

                            chosenOpportunitySet.add(offer.Opportunity__c);
                            //opp = assignValue(opp, offer);
                            oppChosenOfferIdMap.put(objOffer.Opportunity__c , objOffer.Id);
                            hasChosenOffer = true;
                            //Overwrite the offer amount with chosen offer
                            highestOfferAmt = objOffer.Amount__c;
                            break;
                        }
                    }
                    //Check if the Opportunity has no chosen offer
                    if(!hasChosenOffer){

                        //Assumption - if any of the offer amount does not match opp amount then update oppo amount or
                        //
                        //If the Opportunity Amount is less than offer amount then update the Opportunity amount
                        if(opp!= null &&
                            (oppChosenOfferIdMap.isEmpty() || (!oppChosenOfferIdMap.isEmpty()
                                && !oppChosenOfferIdMap.containsKey(offer.Opportunity__c))) ){
                            opp.Amount = offer.Amount__c > highestOfferAmt ? offer.Amount__c : highestOfferAmt;
                            opp = assignNullValue(opp);
                            //opp.Amount = highestOfferAmt;
                        }

                    } else{
                        opp.Amount = highestOfferAmt;
                    }

                    //updatedOppMap.put(opp.Id,opp);
                } else {
                    //opp = assignNullValue(opp);
                }
                system.debug('>>>>>opp>>>>>'+opp);
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
            system.debug('**offer.Submission__c**'+offer.Submission__c);
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

    public Opportunity assignNullValue(Opportunity pObjOpportunity) {
        pObjOpportunity.Chosen_Offer__c = null;
        //pObjOpportunity.Deal_Type__c = null;
        //pObjOpportunity.Term_Months__c = 0;
        //pObjOpportunity.Schedule__c = '';
        return pObjOpportunity;
    }

    // Assign value
    public Opportunity assignValue(Opportunity pObjOpportunity, Offer__c pOffer ) {
        pObjOpportunity.Chosen_Offer__c = pOffer.Id;
        //pObjOpportunity.Deal_Type__c = pOffer.Deal_Type__c;
        //pObjOpportunity.Term_Months__c = pOffer.Term_Months__c;
        //pObjOpportunity.Amount = pOffer.Amount__c;

        return pObjOpportunity;
    }// end assignValue()

    /*Method to validate Offer Details on Before Insert if there is already offer present with Status Chosen*/
    public void validateOfferDetailsOnBeforeInsert (map<Id,Offer__c> pOldOfferMap,
                                                    list<Offer__c> pNewOfferList){

        for(Offer__c offer1: pNewOfferList){
            if(offer1.Opportunity__c <> null){
                opportunityIds.add(offer1.Opportunity__c);
            }
        }//End For
        opportunityIds.remove(null);

        // Get the existing Offer with status Chosen
        Map<string, Offer__c> offerStatusMap = new Map<string, Offer__c>();
        for (Offer__c offer : [select id,
                                              Status__c,
                                              Opportunity__c
                                       from Offer__c
                                       where Opportunity__c in :opportunityIds
                                       AND Status__c =: OFFER_CHOSEN]) {
            offerStatusMap.put(offer.Status__c,offer);
        }//end for

        Set<Id> setOppId = new Set<Id>();
        for(Offer__c offer2 : pNewOfferList){

            Offer__c existingOffer = offerStatusMap.get(offer2.Status__c);
            if((existingOffer != null && existingOffer.Status__c == offer2.Status__c ) || setOppId.contains(offer2.Opportunity__c )) {
                if(existingOffer != null)
                    offer2.addError(errorMessage + existingOffer.Id);
                else
                    offer2.addError(errorMessage);
            }//End If
            if(offer2.Status__c == OFFER_CHOSEN)
                setOppId.add(offer2.Opportunity__c );
        }//End For
    }//End validateOfferDetailsOnBeforeInsert

    /*Method to validate Offer Details on Before Update if there is already offer present with Status Chosen*/
    public void validateOfferDetailsOnBeforeUpdate(Map<Id, Offer__c> newOfferMap) {
        Set<Id> setOppID = new Set<Id>();
        Map<Id, List<Offer__c>> mapOfOppWithOffers = new Map<Id, List<Offer__c>>();
        Integer noOfStatus;
        for(Offer__c objOffer :newOfferMap.values()) {
            setOppID.add(objOffer.Opportunity__c);
            if(mapOfOppWithOffers.get(objOffer.Opportunity__c) != null)
                mapOfOppWithOffers.get(objOffer.Opportunity__c).add(objOffer);
            else
                mapOfOppWithOffers.put(objOffer.Opportunity__c, new List<Offer__c>{objOffer});
        }
        setOppID.remove(null);

        for(Opportunity objOpp :[SELECT Id,
                                        (SELECT Id,
                                                Status__c,
                                                Opportunity__c
                                        FROM Offers__r
                                        WHERE Status__c =: OFFER_CHOSEN)
                                 FROM Opportunity
                                 WHERE id IN :setOppID]) {
            noOfStatus = 0;

            // Iterate offers
            for(Offer__c objOffer :objOpp.Offers__r) {
                if(newOfferMap.get(objOffer.Id) == null)
                    noOfStatus++;
            }//End For

            // Iterate offers
            for(Offer__c objOffer :mapOfOppWithOffers.get(objOpp.Id)) {
                if(objOffer.Status__c == OFFER_CHOSEN) {
                    noOfStatus++;
                    if(noOfStatus > 1)
                        objOffer.addError(errorMessage + objOffer.Id);
                }
            }//End For
        }//End For
    }//End validateOfferDetailsOnBeforeUpdate
}