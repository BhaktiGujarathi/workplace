trigger RunningBalanceTrigger on ACH_Transaction__c (after insert, after update) {
    Opportunity[] deals = new Opportunity[]{};
    Map<String, ACH_Transaction__c[]> paymentsMap = new Map<String, ACH_Transaction__c[]>();
    Map<String, Double> paymentsAmountMap = new Map<String, Double>();
    Map<String, String[]> dealIds = new Map<String, String[]>();
    
    for (ACH_Transaction__c p : Trigger.new) {
        if (paymentsMap.containsKey(p.Payment_Setting__c)) {
            paymentsMap.get(p.Payment_Setting__c).add(p);
            paymentsAmountMap.put(p.Payment_Setting__c, paymentsAmountMap.get(p.Payment_Setting__c) + p.Transaction_Amount__c);
        }
        else {
            paymentsMap.put(p.Payment_Setting__c, new ACH_Transaction__c[] {p});
            paymentsAmountMap.put(p.Payment_Setting__c, p.Transaction_Amount__c);
            
        }
    }
    
    for (Payment_Setting__c ps : [SELECT Id, Opportunity__c FROM Payment_Setting__c WHERE Id IN : paymentsMap.keySet()]) {
        if (dealIds.containsKey(ps.Opportunity__c)) {
            dealIds.get(ps.Opportunity__c).add(ps.Id);
        }
        else {
            dealIds.put(ps.Opportunity__c, new String[] { ps.Id });
        }
    }
    
    if (Trigger.isInsert) {      
        for (Opportunity deal : [SELECT Id, Average_Daily_Balance__c FROM Opportunity WHERE Id IN : dealIds.keySet()]) {
            for (String paymentSettingId : dealIds.get(deal.Id)) {
                if (deal.Average_Daily_Balance__c == null) {
                    deal.Average_Daily_Balance__c = 0;
                }
                deal.Average_Daily_Balance__c = deal.Average_Daily_Balance__c - paymentsAmountMap.get(paymentSettingId);
            }
            deals.add(deal);
        }
        update deals;
    }
    
    /*if (Trigger.isUpdate) {
        Map<String, Double> oldPaymentsAmountMap = new Map<String, Double>();
        for (ACH_Transaction__c p : Trigger.old) {
            if (paymentsMap.containsKey(p.Payment_Setting__c)) {
                oldPaymentsAmountMap.put(p.Payment_Setting__c, oldPaymentsAmountMap.get(p.Payment_Setting__c) + p.Transaction_Amount__c);
            }
            else {
                oldPaymentsAmountMap.put(p.Payment_Setting__c, p.Transaction_Amount__c);
                
            }
        }
        
        for (Opportunity deal : [SELECT Id, Average_Daily_Balance__c FROM Opportunity WHERE Id IN : dealIds.keySet()]) {
            for (String paymentSettingId : dealIds.get(deal.Id)) {
                if (deal.Average_Daily_Balance__c == null) {
                    deal.Average_Daily_Balance__c = 0;
                }
                deal.Average_Daily_Balance__c = deal.Average_Daily_Balance__c - (oldPaymentsAmountMap.get(paymentSettingId) - paymentsAmountMap.get(paymentSettingId));
            }
            deals.add(deal);
        }
        update deals;
    }
    
    if (Trigger.isDelete) {
        for (Opportunity deal : [SELECT Id, Average_Daily_Balance__c FROM Opportunity WHERE Id IN : dealIds.keySet()]) {
            for (String paymentSettingId : dealIds.get(deal.Id)) {
                if (deal.Average_Daily_Balance__c == null) {
                    deal.Average_Daily_Balance__c = 0;
                }
                deal.Average_Daily_Balance__c = deal.Average_Daily_Balance__c + paymentsAmountMap.get(paymentSettingId);
            }
            deals.add(deal);
        }
        update deals;
    }*/
    
}