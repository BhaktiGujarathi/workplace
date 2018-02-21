public without sharing class CreditCardHandlerServiceBefore {
    public static final String frmInsert = 'Insert';
    public static final String frmUpdate = 'Update';
    public static final String frmDelete = 'Delete';

    public void updateAccount(map<Id,Credit_Card__c > oldCreditCardMap, list<Credit_Card__c> creditCardList, String frmOperation ){
        set<Id> setOpportunity = new set<Id>();
        
        for(Credit_Card__c objCC: creditCardList){
            if(objCC.Opportunity__c != null && (frmOperation == frmInsert || 
                                                    (frmOperation == frmUpdate && 
                                                        (objCC.Opportunity__c != oldCreditCardMap.get(objCC.Id).Opportunity__c ||
                                                       objCC.Account__c == null)
                                                    )
                                                )){
                setOpportunity.add(objCC.Opportunity__c);
            }
        }
        
        map<Id,Opportunity> oppMap;
        if(!setOpportunity.isEmpty())
            oppMap = new map<Id, Opportunity>([Select AccountId from Opportunity where Id IN: setOpportunity]);
            
        for(Credit_Card__c objCC: creditCardList){
            if(objCC.Opportunity__c != null && (frmOperation == frmInsert || 
                                                    (frmOperation == frmUpdate && 
                                                      (objCC.Opportunity__c != oldCreditCardMap.get(objCC.Id).Opportunity__c) ||
                                                       objCC.Account__c == null)
                                                ) 
                                            && oppMap!= null && !oppMap.isEmpty() 
                                            && oppMap.containsKey(objCC.Opportunity__c) 
                                            && objCC.Account__c == null){
                objCC.Account__c = oppMap.get(objCC.Opportunity__c).AccountId;
            }
        }   
    }
}