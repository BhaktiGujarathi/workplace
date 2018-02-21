public with sharing class caseTriggerHandlerOTPVerification {
    public static void afterUpdate(map<Id,Case> newMap, map<Id,Case> oldMap){
	    set<Id> setBuyerIds = new set<Id>();
	    for(Case objC : newMap.values()){
	        if(objC.Buyer__c != null
	        && objC.Status.equalsIgnoreCase('Buyer OTP Verification')
	        && oldMap.get(objC.Id).Status != objC.Status){
	            setBuyerIds.add(objC.Buyer__c);
	        }
	    }
	    if(!setBuyerIds.isEmpty()){
	        map<Id,Buyer__c> mapId_Buyer = new map<Id,Buyer__c>([Select b.Phone__c
	                                                                  , b.Phone_Country_Code__c
	                                                                  , b.OTP__c
	                                                                  , b.Buyer_ID__c
	                                                                  , b.Id
	                                                                  From Buyer__c b
	                                                                  where b.Id IN : setBuyerIds]);
            if(!mapId_Buyer.isEmpty()){
                Integer intCount = 1;
                list<String> setPhoneNos = new list<String>();
                for(Case objC : newMap.values()){
		            if(objC.Buyer__c != null
		            && mapId_Buyer.containsKey(objC.Buyer__c)
		            && mapId_Buyer.get(objC.Buyer__c) != null
		            && mapId_Buyer.get(objC.Buyer__c).Phone__c != null
		            && !String.isBlank(mapId_Buyer.get(objC.Buyer__c).Phone__c)){
		                if(intCount <= 100){
		                    setPhoneNos.add(mapId_Buyer.get(objC.Buyer__c).Phone__c);
		                }else{
		                    OTPService.Sendtextmessage(setPhoneNos);
		                    intCount = 1;
		                    setPhoneNos = new list<String>();
		                }
		                intCount++;
		            }
		        }
		        if(!setPhoneNos.isEmpty()){
		            OTPService.Sendtextmessage(setPhoneNos);
		        }
            }
	    }
    } // end of afterUpdate
} // end of class