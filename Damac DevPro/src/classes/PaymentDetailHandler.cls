public with sharing class PaymentDetailHandler {
    public void handleInsert(list<Payment_Detail__c> listPaymentDetails) {
        set<Id> setRelatedCase = new set<Id>();
        for(Payment_Detail__c payDetailsInst: listPaymentDetails) {
            if(payDetailsInst.Case__c != null) {
                if(payDetailsInst.Pending_Amount__c != null) {
                    setRelatedCase.add(payDetailsInst.Case__c);
                }
            }
        }
        if(!setRelatedCase.isEmpty()) {
            rollupAmountOnCase(setRelatedCase);
        }
        system.debug('setRelatedCase==='+setRelatedCase);
    }

    public void rollupAmountOnCase(set<Id> setRelatedCase) {
        list<Case> listCaseUpdate = new list<Case>();
        map<Id, Decimal> mapAmountRollUp = new map<Id, Decimal>();
        for(Payment_Detail__c caseRollupInst : [select Case__c, Pending_Amount__c from Payment_Detail__c where Case__c IN: setRelatedCase]) {
            if(mapAmountRollUp.containsKey(caseRollupInst.Case__c)) {
                mapAmountRollUp.put(caseRollupInst.Case__c, mapAmountRollUp.get(caseRollupInst.Case__c) + caseRollupInst.Pending_Amount__c);
            }
            else {
                mapAmountRollUp.put(caseRollupInst.Case__c, caseRollupInst.Pending_Amount__c);
            }
        }
        system.debug('mapAmountRollUp==='+mapAmountRollUp);
        for(Id idInst: mapAmountRollUp.keySet()) {
            Case caseObj = new Case();
            caseObj.Id = idInst;
            caseObj.Pending_Amount__c = mapAmountRollUp.get(idInst);
            listCaseUpdate.add(caseObj);
        }
        //system.debug('listCaseUpdate==='+listCaseUpdate);
        if(!listCaseUpdate.isEmpty()) {
            update listCaseUpdate;
            system.debug('listCaseUpdate==='+listCaseUpdate);
        }

    }
}