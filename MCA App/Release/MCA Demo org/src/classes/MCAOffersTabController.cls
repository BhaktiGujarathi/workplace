public with sharing class MCAOffersTabController {

  public Offer__c[] offers;
  public Container[] containers;
  public Opportunity opportunity{get; set;}

  public Offer__c[] newOffers {get; set;}

  public Boolean editAll {get;set;}

  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}

  private Id opportunityId;

  public Decimal fundingAmountHigh {get; set;}
  public Decimal fundingAmountLow {get; set;}

  public Decimal paybackHigh {get; set;}
  public Decimal paybackLow {get; set;}

  public Decimal rateHigh {get; set;}
  public Decimal rateLow {get; set;}
  
  public Decimal originationFeeHigh {get; set;}
  public Decimal originationFeeLow {get; set;}

  public Decimal termsHigh {get; set;}
  public Decimal termsLow {get; set;}

  public Decimal holdbackHigh {get; set;}
  public Decimal holdbackLow {get; set;}

  public Decimal paymentAmountHigh {get; set;}
  public Decimal paymentAmountLow {get; set;}
  
  public List<Submission__c> submissionlist {get; Set;}
  public Integer subSize {get; set;}
  public Integer offerSize {get; set;}


  public MCAOffersTabController() {

    opportunityId = Apexpages.currentPage().getParameters().get('id');
    opportunity = [select Id, Name, StageName, AccountId From Opportunity where Id =: opportunityId];

    refresh();
  }

  //public Offer__c[] getOffers() {
  public Container[] getContainers() {

    resetTotals();

    offers = new Offer__c[] {};
    containers = new Container[] {};

    offers.addAll(newOffers);

    for (Offer__c off :[SELECT
                               Term_Months__c,
                               Status__c,
                               Send__c,
                               Details__c,
                               Rate__c,
                               Payment_Amt__c,
                               Payback_Amt__c,
                               PMT_Schedule__c,
                               Origination_fee__c,
                               Holdback__c,
                               Funder__c,
                               Deal_Type__c,
                               Opportunity__c,
                               Submission__c,
                               Amount__c,
                               Buy_Rate__c,
                               Commi__c,
                               Commi_per__c,
                               Max_Commi__c,
                               Payback_Funded__c,
                               Expected__c,
                               Referral_Payout__c
                          FROM Offer__c
                          WHERE Opportunity__c = :opportunityId]) {

      offers.add(off);

      fundingAmountHigh = (fundingAmountHigh < off.Amount__c) ? off.Amount__c : fundingAmountHigh;
      paybackHigh = (paybackHigh < off.Payback_Amt__c) ? off.Payback_Amt__c : paybackHigh;
      termsHigh = (termsHigh < off.Term_Months__c) ? off.Term_Months__c : termsHigh;
      holdbackHigh = (holdbackHigh < off.Holdback__c) ? off.Holdback__c : holdbackHigh;
      paymentAmountHigh = (paymentAmountHigh < off.Payment_Amt__c) ? off.Payment_Amt__c : paymentAmountHigh;
      rateHigh = (rateHigh < off.Rate__c) ? off.Rate__c : rateHigh;
      originationFeeHigh = (originationFeeHigh < off.Origination_fee__c)? off.Origination_fee__c:originationFeeHigh;
      system.debug('@@@@@@ originationFeeHigh '+off.Origination_fee__c);
      
      
      fundingAmountLow = (fundingAmountLow > off.Amount__c) ? off.Amount__c : fundingAmountLow;
      paybackLow = (paybackLow > off.Payback_Amt__c) ? off.Payback_Amt__c : paybackLow;
      termsLow = (termsLow > off.Term_Months__c) ? off.Term_Months__c : termsLow;
      holdbackLow = (holdbackLow > off.Holdback__c) ? off.Holdback__c : holdbackLow;
      paymentAmountLow = (paymentAmountLow > off.Payment_Amt__c) ? off.Payment_Amt__c : paymentAmountLow;
      rateLow = (rateLow > off.Rate__c) ? off.Rate__c : rateLow;
       originationFeeLow = (originationFeeHigh > off.Origination_fee__c)? off.Origination_fee__c:originationFeeHigh;

    }
    offerSize = offers.size();
    sanitizeTotals();

    for (Integer i = 0; i < offers.size(); i++) {
      containers.add(new Container(offers[i], i));
    }

    getSubmissionNames();
    return containers;

    //return offers;
  }
    public void save(){}
    public List<SelectOption> getSubmissionNames()
    {
      List<SelectOption> options = new List<SelectOption>();
      submissionlist = new List<Submission__c>();
      submissionlist = [Select Id, Name,Funder__c,Funder__r.Name, Status__c FROM Submission__c where Opportunity__c =: opportunityId];
      subSize = submissionlist.size();
      //options.add(new SelectOption('--None--','--None--'));
      for (Integer j=0;j<submissionlist.size();j++)
      {
        String subName = submissionlist[j].Name;
          options.add(new SelectOption(submissionlist[j].Id,submissionlist[j].Funder__r.Name+'-'+submissionlist[j].Status__c+'-('+subName.substring(4,subName.length())+')'));
      }
      return options;
    }
    
  public void newOffer() {

    newOffers.add(new Offer__c(Opportunity__c = opportunityId));
  }


  public void refresh() {

    recordToDelete = null;
    editAll = false;
    newOffers = new Offer__c[] {};
    resetTotals();
  }

  public void saveAllOffers() {

    /*
    Offer__c[] recordsToUpdate = new Offer__c[] {};

    for (Offer__c record :offers) {

      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdate.add(record);
      }
    }
    */
     upsert offers;
     
    system.debug('***Enter In Exception111111'+containers[0].offer.holdback__c);
    try{   
        system.debug('***Enter In Exception222222'+offers[0].holdback__c);
        system.debug('***Enter In Exception222222'+offers[0].Payment_Amt__c);
        upsert offers;
        system.debug('***Enter In Exception00000000000****');
    }
    catch(DmlException e){
        system.debug('***Enter In Exception****'+e.getMessage());
        String msg;
        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, There is no submission for this offer')){
        	
        	system.debug('***Enter In Exception 1****');
            msg = 'An Offer cannot be created without a Submission. Please create a Submission record';
        }
        else{
        	system.debug('***Enter In Exception 2****');
            msg = e.getMessage();
        }
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msg));
    }
    refresh();
  }

  public void editAll() {
    refresh();
    editAll = true;
    newOffers = new Offer__c[] {};
    resetTotals();
  }

  public void deleteOffer() {

    if (recordToDelete != null) {
      Offer__c record = [SELECT Id FROM Offer__c WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void removeOffer() {

    if (indexToRemove != null) {

      Container c = null;

      for (Container element :containers) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }

      //containers.remove(c.index);
      newOffers.remove(c.index);
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

     
  }

  private void sanitizeTotals() {

     fundingAmountLow = fundingAmountLow == 999999999 ? 0 : fundingAmountLow;

     paybackLow = paybackLow == 999999999 ? 0 : paybackLow;

     rateLow = rateLow == 999999999 ? 0 : rateLow;

     termsLow = termsLow == 999999999 ? 0 :termsLow;

     holdbackLow = holdbackLow == 999999999 ? 0 :holdbackLow;

     paymentAmountLow = paymentAmountLow == 999999999 ? 0 : paymentAmountLow;
     
      originationFeeLow = originationFeeLow == 999999999 ? 0 : originationFeeLow ;
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