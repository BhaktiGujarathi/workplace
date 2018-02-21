public with sharing class MCAOffersTabController {

    public Offer__c[] offers;
    public Container[] containers;
    public Opportunity opportunity{get; set;}
    public Set<Id> setofferId;
    public Offer__c[] newOffers {get; set;}

    public Boolean editAll {get;set;}

    public Id recordToDelete {get;set;}
    public Integer indexToRemove {get;set;}

    private Id opportunityId;

    public Decimal fundingAmountHigh {get; set;}
    public Decimal fundingAmountLow {get; set;}

    public Decimal payOffAmountHigh {get; set;}
    public Decimal payOffAmountLow {get; set;}
    
    public Decimal netAmountHigh {get; set;}
    public Decimal netAmountLow {get; set;}
    public Decimal buyRateHigh {get; set;}
    public Decimal buyRateLow {get; set;}
    public Decimal expectedHigh {get; set;}
    public Decimal expectedLow {get; set;}
    public Decimal paybackHigh {get; set;}
    public Decimal paybackLow {get; set;}
    public Decimal payoutHigh {get; set;}
    public Decimal payoutLow {get; set;}

    public Decimal rateHigh {get; set;}
    public Decimal rateLow {get; set;}

    public Decimal termsHigh {get; set;}
    public Decimal termsLow {get; set;}

    public Decimal holdbackHigh {get; set;}
    public Decimal holdbackLow {get; set;}

    public Decimal paymentAmountHigh {get; set;}
    public Decimal paymentAmountLow {get; set;}

    public Decimal originationFeeHigh {get; set;}
    public Decimal originationFeeLow {get; set;}

    public List<Submission__c> submissionlist {get; Set;}
    public Integer subSize {get; set;}
    public Integer offerSize {get; set;}
    public string DestURL {get; set;}
    public Boolean isFirst;
    public Boolean isUpdated;
    public Map<Id, Offer__c> mapIDANDOffer;
    public List<Offer__c> listToUpdate;
    public Boolean isValidation;
    
    
    public MCAOffersTabController() {
        mapIDANDOffer = new Map<Id, Offer__c>();
        isFirst = true;
        isValidation = false;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        opportunity = [select Id, Name, StageName, AccountId, Owner_1__c, Owner_1__r.Email  From Opportunity where Id =: opportunityId];
        DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.Email_Offer_Template_Id+'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
        refresh();
    }

    public Container[] getContainers() {

        resetTotals();
        setofferId = new Set<Id>();
        offers = new Offer__c[] {};
        offerList();

        offers.addAll(newOffers);
        if(isFirst && !editAll && !isValidation){
            isFirst = false;
            for (Offer__c off: mapIDANDOffer.values()) {
        
                offers.add(off);
                calculateVal(off);
                
            }
        } else {
            for (Container containerVal: containers) {
                system.debug('---->'+containerVal);
                if(containerVal.offer != null && containerVal.offer.id != null 
                    && containerVal.index != indexToRemove){
                    if(!editAll)
                        offers.add(mapIDANDOffer.get(containerVal.offer.id));
                     else
                        offers.add(containerVal.offer);
                    calculateVal(mapIDANDOffer.get(containerVal.offer.id));
                }else if(containerVal.offer != null && containerVal.index != indexToRemove)
                    offers.add(containerVal.offer);
            }
        }
        indexToRemove = -1;
        offerSize = offers.size();
        sanitizeTotals();
        newOffers = new List<Offer__c>();
        containers = new Container[] {};
        system.debug('offers ---->'+offers);
        for (Integer i = 0; i < offers.size(); i++) {
            //if(!setofferId.contains(offers[i].id))
                containers.add(new Container(offers[i], i));
            //setofferId.add(offers[i].id);
        }

        getSubmissionNames();
        system.debug('containers---->'+containers);
        return containers;
    }
    
    public void calculateVal(Offer__c off) {
        if(off != null){
            fundingAmountHigh = (fundingAmountHigh < off.Amount__c) ? off.Amount__c : fundingAmountHigh;
            payOffAmountHigh = (payOffAmountHigh < off.Payoff_Amount__c) ? off.Payoff_Amount__c : payOffAmountHigh;
            netAmountHigh = (netAmountHigh < off.Net_Funded_Amount__c) ? off.Net_Funded_Amount__c : netAmountHigh;
            buyRateHigh = (buyRateHigh < off.Buy_Rate__c) ? off.Buy_Rate__c : buyRateHigh;
            expectedHigh = (expectedHigh < off.Expected__c) ? off.Expected__c : expectedHigh;
            paybackHigh = (paybackHigh < off.Payback_Amt__c) ? off.Payback_Amt__c : paybackHigh;
            payoutHigh = (payoutHigh < off.Referral_Payout__c) ? off.Referral_Payout__c : payoutHigh;
            termsHigh = (termsHigh < off.Term_Months__c) ? off.Term_Months__c : termsHigh;
            holdbackHigh = (holdbackHigh < off.Holdback__c) ? off.Holdback__c : holdbackHigh;
            paymentAmountHigh = (paymentAmountHigh < off.Payment_Amt__c) ? off.Payment_Amt__c : paymentAmountHigh;
            rateHigh = (rateHigh < off.Rate__c) ? off.Rate__c : rateHigh;
            originationFeeHigh = (originationFeeHigh < off.Origination_fee__c)? off.Origination_fee__c:originationFeeHigh;
    
    
            fundingAmountLow = (fundingAmountLow > off.Amount__c) ? off.Amount__c : fundingAmountLow;
            payOffAmountLow = (payOffAmountLow > off.Payoff_Amount__c) ? off.Payoff_Amount__c : payOffAmountLow;
            netAmountLow = (netAmountLow > off.Net_Funded_Amount__c) ? off.Net_Funded_Amount__c : netAmountLow;
            buyRateLow = (buyRateLow > off.Buy_Rate__c) ? off.Buy_Rate__c : buyRateLow;
            expectedLow = (expectedLow > off.Expected__c) ? off.Expected__c : expectedLow;
            paybackLow = (paybackLow > off.Payback_Amt__c) ? off.Payback_Amt__c : paybackLow;
            payoutLow = (payoutLow > off.Referral_Payout__c) ? off.Referral_Payout__c : payoutLow;
            termsLow = (termsLow > off.Term_Months__c) ? off.Term_Months__c : termsLow;
            holdbackLow = (holdbackLow > off.Holdback__c) ? off.Holdback__c : holdbackLow;
            paymentAmountLow = (paymentAmountLow > off.Payment_Amt__c) ? off.Payment_Amt__c : paymentAmountLow;
            rateLow = (rateLow > off.Rate__c) ? off.Rate__c : rateLow;
            originationFeeLow = (originationFeeHigh > off.Origination_fee__c)? off.Origination_fee__c:originationFeeHigh;
        }
    }
     //It is used query all the present task for the opportunity
    public void offerList() {
        mapIDANDOffer.clear();
        mapIDANDOffer = new Map<Id, Offer__c>([SELECT
                                                Term_Months__c,
                                                id,
                                                Status__c,
                                                Send__c,
                                                Details__c,
                                                Rate__c,
                                                Payment_Amt__c,
                                                Payoff_Amount__c,
                                                Net_Funded_Amount__c,
                                                Payback_Amt__c,
                                                PMT_Schedule__c,
                                                Holdback__c,
                                                Funder__c,
                                                Deal_Type__c,
                                                Opportunity__c,
                                                Submission__c,
                                                Amount__c,
                                                Origination_fee__c,
                                                Buy_Rate__c,
                                                Expected__c,
                                                Payback_Funded__c,
                                                Referral_Payout__c
                                            FROM Offer__c
                                            WHERE Opportunity__c = :opportunityId]);
    }// End 
    
    public void save(){}
    
    public List<SelectOption> getSubmissionNames(){
        List<SelectOption> options = new List<SelectOption>();
        submissionlist = new List<Submission__c>();
        submissionlist = [Select Id, Name,Funder__c,Funder__r.Name, Status__c FROM Submission__c where Opportunity__c =: opportunityId];
        subSize = submissionlist.size();
        for (Integer j=0;j<submissionlist.size();j++){
            String subName = submissionlist[j].Name;
            options.add(new SelectOption(submissionlist[j].Id,submissionlist[j].Funder__r.Name+'-'+submissionlist[j].Status__c+'-('+subName.substring(4,subName.length())+')'));
        }
        return options;
    }

    public void newOffer() {
        saveMessage();
        newOffers.add(new Offer__c(Opportunity__c = opportunityId));
    }
    
    public void updateInlineEditedValue() {
        String msgStr = '';
        try{
            //update listToUpdate;
            List<Database.saveResult> results = Database.update(listToUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                  }
              }
           }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }

    public void checkoldAndNewVal() {
        Offer__c offerValue = new Offer__c();
        listToUpdate = new List<Offer__c>();
        offerList();
        for (Container containerVal: containers) {
            if(containerVal.offer.id != null){
                offerValue = mapIDANDOffer.get(containerVal.offer.id);
                if(offerValue != null) {
                    if(containerVal.offer.Deal_Type__c != offerValue.Deal_Type__c
                    || containerVal.offer.Amount__c != offerValue.Amount__c
                    || containerVal.offer.Payback_Amt__c != offerValue.Payback_Amt__c
                    || containerVal.offer.Rate__c != offerValue.Rate__c
                    || containerVal.offer.Term_Months__c != offerValue.Term_Months__c
                    || containerVal.offer.Holdback__c != offerValue.Holdback__c
                    || containerVal.offer.Payment_Amt__c != offerValue.Payment_Amt__c
                    || containerVal.offer.PMT_Schedule__c != offerValue.PMT_Schedule__c
                    || containerVal.offer.Origination_fee__c != offerValue.Origination_fee__c
                    || containerVal.offer.Buy_Rate__c != offerValue.Buy_Rate__c
                    || containerVal.offer.Expected__c != offerValue.Expected__c
                    || containerVal.offer.Payback_Funded__c != offerValue.Payback_Funded__c
                    || containerVal.offer.Referral_Payout__c != offerValue.Referral_Payout__c
                    || containerVal.offer.Status__c != offerValue.Status__c
                    || containerVal.offer.Details__c != offerValue.Details__c
                    || containerVal.offer.Payoff_Amount__c != offerValue.Payoff_Amount__c
                    ){
                        listToUpdate.add(containerVal.offer);
                        isUpdated = true;
                    }
                }
            }
        }
    }
    
    public void refresh() {
        recordToDelete = null;
        isFirst = true;
        editAll = false; 
        newOffers = new Offer__c[] {};
        resetTotals();
    }

    public void saveAllOffers() {
        isValidation = false;
        String msgStr = '';
        try{
            //upsert offers;
            List<Database.upsertResult> results = Database.upsert(offers, false);
            for (Integer i =0; i < results.size(); i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: ' + err.getMessage()  + ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                  }
              }
           }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(DmlException e){
            isValidation = true;
            String msg;
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, There is no submission for this offer')){
                msg = 'An Offer cannot be created without a Submission. Please create a Submission record';
            }
            else{
                msg = e.getMessage();
            }
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msg));
        }
        refresh();
    }
    
    public void saveMessage(){
        isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }
    }

    public void removeOffer(){
         saveMessage();
    }
     
    public void editAll() {
        refresh();
        editAll = true;
    }

    public void deleteOffer() {
        saveMessage();
        if (recordToDelete != null) {
            Offer__c record = [SELECT Id FROM Offer__c WHERE Id = :recordToDelete];
            delete record;
            
        }
    }

    private void resetTotals() {
        fundingAmountHigh = 0;
        fundingAmountLow = 999999999;
        paybackHigh = 0;
        paybackLow = 999999999;
        rateHigh = 0;
        rateLow = 999999999;
        termsHigh = 0;
        termsLow = 999999999;
        holdbackHigh = 0;
        holdbackLow = 999999999;
        paymentAmountHigh = 0;
        paymentAmountLow = 999999999;
        originationFeeHigh = 0; 
        originationFeeLow = 0;
        payOffAmountHigh = 0;
        payOffAmountLow = 999999999;
        netAmountHigh = 0;
        netAmountLow = 999999999;
        buyRateHigh = 0;
        buyRateLow = 999999999;
        expectedHigh = 0;
        expectedLow = 999999999;
        payoutHigh = 0;
        payoutLow = 999999999;
    }

    private void sanitizeTotals() {
        fundingAmountLow = fundingAmountLow == 999999999 ? 0 : fundingAmountLow;
        paybackLow = paybackLow == 999999999 ? 0 : paybackLow;
        rateLow = rateLow == 999999999 ? 0 : rateLow;
        termsLow = termsLow == 999999999 ? 0 :termsLow;
        holdbackLow = holdbackLow == 999999999 ? 0 :holdbackLow;
        paymentAmountLow = paymentAmountLow == 999999999 ? 0 : paymentAmountLow;
        payoutLow = payoutLow == 999999999 ? 0 : payoutLow;
        expectedLow = expectedLow == 999999999 ? 0 : expectedLow;
        buyRateLow = buyRateLow == 999999999 ? 0 : buyRateLow;
        netAmountLow = netAmountLow == 999999999 ? 0 : netAmountLow;
        payOffAmountLow = payOffAmountLow == 999999999 ? 0 : payOffAmountLow;
    }

    public class Container {

        public Offer__c offer {get;set;}
        public Integer index {get;set;}

        public Container(Offer__c instance, Integer index) {
            offer = instance;
            this.index = index;
        }
    }
}