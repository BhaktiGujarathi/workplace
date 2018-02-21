public with sharing class MCAOffersTabController {

  public Offer__c[] offers;
  public Container[] containers;
  
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
  
  public Decimal termsHigh {get; set;}
  public Decimal termsLow {get; set;}
  
  public Decimal holdbackHigh {get; set;}
  public Decimal holdbackLow {get; set;}
  
  public Decimal paymentAmountHigh {get; set;}
  public Decimal paymentAmountLow {get; set;}  
  
  
  public MCAOffersTabController() {
  
    opportunityId = Apexpages.currentPage().getParameters().get('id');
	
    refresh();
  }  
  
  //public Offer__c[] getOffers() {
  public Container[] getContainers() {
  
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
                               Holdback__c,
                               Funder__c,
                               Deal_Type__c,
                               Opportunity__c,
                               Submission__c,
                               Amount__c       
                          FROM Offer__c
                          WHERE Opportunity__c = :opportunityId]) {
                            
      offers.add(off);
      
      fundingAmountHigh = (fundingAmountHigh < off.Amount__c) ? off.Amount__c : fundingAmountHigh;
      paybackHigh = (paybackHigh < off.Payback_Amt__c) ? off.Payback_Amt__c : paybackHigh;
      termsHigh = (termsHigh < off.Term_Months__c) ? off.Term_Months__c : termsHigh;
      holdbackHigh = (holdbackHigh < off.Holdback__c) ? off.Holdback__c : holdbackHigh;
      paymentAmountHigh = (paymentAmountHigh < off.Payment_Amt__c) ? off.Payment_Amt__c : paymentAmountHigh;
      rateHigh = (rateHigh < off.Rate__c) ? off.Rate__c : rateHigh;
      
      fundingAmountLow = (fundingAmountLow > off.Amount__c) ? off.Amount__c : fundingAmountLow;
      paybackLow = (paybackLow > off.Payback_Amt__c) ? off.Payback_Amt__c : paybackLow;
      termsLow = (termsLow > off.Term_Months__c) ? off.Term_Months__c : termsLow;
      holdbackLow = (holdbackLow > off.Holdback__c) ? off.Holdback__c : holdbackLow;
      paymentAmountLow = (paymentAmountLow > off.Payment_Amt__c) ? off.Payment_Amt__c : paymentAmountLow;
      rateLow = (rateLow > off.Rate__c) ? off.Rate__c : rateLow;          
    }                
                
    sanitizeTotals();
    
    for (Integer i = 0; i < offers.size(); i++) {
      containers.add(new Container(offers[i], i));
    }
                
    
    return containers;    
    
    //return offers;
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

  public void saveAll() {
  
    /*
    Offer__c[] recordsToUpdate = new Offer__c[] {};
    
    for (Offer__c record :offers) {
      
      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdate.add(record);
      }  
    }
    */
    upsert offers; 

    refresh();
  }
  
  public void editAll() {
  	refresh();
    editAll = true;
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
  }  

  private void sanitizeTotals() {
  
     fundingAmountLow = fundingAmountLow == 999999999 ? 0 : fundingAmountLow;
  
     paybackLow = paybackLow == 999999999 ? 0 : paybackLow;
 
     rateLow = rateLow == 999999999 ? 0 : rateLow;
    
     termsLow = termsLow == 999999999 ? 0 :termsLow;
    
     holdbackLow = holdbackLow == 999999999 ? 0 :holdbackLow;
    
     paymentAmountLow = paymentAmountLow == 999999999 ? 0 : paymentAmountLow;    
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