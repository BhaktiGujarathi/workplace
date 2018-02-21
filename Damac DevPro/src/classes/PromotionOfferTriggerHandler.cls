public without sharing class PromotionOfferTriggerHandler {
    /*public static void afterInsert (list<Promotion_Offer__c> lstNew){
        set<Id> setPromotionIds = new set<Id>(); 
        for(Promotion_Offer__c objFA : lstNew){
            if(objFA.Promotion_Package__c != null
            && objFA.Booking_Unit__c != null){
                setPromotionIds.add(objFA.Promotion_Package__c);
            }
        }
        
        if(!setPromotionIds.isEmpty()){
            list<Promotion_Package__c> lstPromotionToUpdate = new list<Promotion_Package__c>();
            for(Promotion_Package__c objF : [Select f.Id
                                          , f.Blocked_Units__c
                                          , (Select Id
                                                  , Promotion_Package__c
                                                  , Booking_Unit__c 
                                             From Promotion_Offers__r
                                             where Booking_Unit__c != null) 
                                    From Promotion_Package__c f
                                    where Id IN : setPromotionIds]){
                if(objF.Promotion_Offers__r != null
                && !objF.Promotion_Offers__r.isEmpty()){
                    objF.Blocked_Units__c = objF.Promotion_Offers__r.size();
                    lstPromotionToUpdate.add(objF);
                }
            }
            if(!lstPromotionToUpdate.isEmpty()){
                update lstPromotionToUpdate;
            }
        }
    }*/
}