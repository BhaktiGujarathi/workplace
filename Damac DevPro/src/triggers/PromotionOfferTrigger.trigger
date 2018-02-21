trigger PromotionOfferTrigger on Promotion_Package_Offer__c (after delete, after insert, after update) {
    if(trigger.isAfter){
      if(trigger.isInsert){
        //PromotionOfferTriggerHandler.afterInsert(trigger.new);
      }
      if(trigger.isUpdate){

      }
    }
}