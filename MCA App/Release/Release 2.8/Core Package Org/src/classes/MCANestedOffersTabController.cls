public with sharing class MCANestedOffersTabController {

  public Id submissionId {get; set;}

  private Offer__c[] sOffers;

  public Offer__c[] offers;
  
  public Offer__c[] newOffers {get; set;}
  
  public Boolean editAll {get;set;}
  
  public Id recordToDelete {get;set;}
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
  
  public MCANestedOffersTabController() {
  
    opportunityId = Apexpages.currentPage().getParameters().get('id');

    refresh();
  }  

  public Offer__c[] getOffers() {
  
    offers = new Offer__c[] {};
    
    offers.addAll(newOffers);
  
    system.debug('COLUMN_ID ' + submissionId);
                
    for (Offer__c off :[SELECT 
					                     Term_Months__c,
					                     Status__c,
					                     Send__c,
					                     Rate__c,
					                     Payment_Amt__c,
					                     Payback_Amt__c,
					                     PMT_Schedule__c,
					                     Holdback__c,
					                     Funder__c,
					                     Deal_Type__c,
					                     Submission__c,
					                     Amount__c       
					                FROM Offer__c
					                WHERE Opportunity__c = :opportunityId
					                AND Submission__c = :submissionId]) {
					                	
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
                
    return offers;
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
  
    upsert offers;

    refresh();
  }
  
  public void editAll() {
    editAll = true;
  }  
  
  public void deleteOffer() {
  
    if (recordToDelete != null) {
      Offer__c record = [SELECT Id FROM Offer__c WHERE Id = :recordToDelete];
      delete record;
    }
  }    
  
  private void resetTotals() {
  
	   fundingAmountHigh = 0;
	   fundingAmountLow = 0;
	  
	   paybackHigh = 0;
	   paybackLow = 0;
	  
	   rateHigh = 0;
	   rateLow = 0;
	  
	   termsHigh = 0;
	   termsLow = 0;
	  
	   holdbackHigh = 0;
	   holdbackLow = 0;
	  
	   paymentAmountHigh = 0;
	   paymentAmountLow = 0;    
  }

}