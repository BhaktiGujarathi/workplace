public with sharing class CommissionUpdateService {
    
    public void updateCommissions(map<Id, Invoice__c> invoiceNewMap, map<Id, Invoice__c> invoiceOldMap) {
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Set<Id> opportunityIds = new set<Id>();
        List<Commission__c> commissionList = new List<Commission__c>();
        
        if(invoiceNewMap != null) {
            for(Invoice__c invoiceObj : invoiceNewMap.values()) {
                if(invoiceOldMap != null && invoiceOldMap.containsKey(invoiceObj.Id)) {
                    Invoice__c invoiceInstance = invoiceOldMap.get(invoiceObj.Id);
                    if(invoiceInstance.isPaid__c <> invoiceObj.isPaid__c && invoiceObj.isPaid__c == true) {
                        opportunityIds.add(invoiceObj.Opportunity__c);
                    }
                } else {
                    opportunityIds.add(invoiceObj.Opportunity__c);
                }
            }
        }
        /*
        if(invoiceOldMap!= null) {
            for(Invoice__c invoiceObj : invoiceOldMap.Values) {
                opportunityIds.add(invoiceObj.Opportunity__c);
            }
        }*/
        
        if(opportunityIds !=  null && !opportunityIds.isEmpty()) {
            opportunityList = [Select id, 
                                      name, 
                                      (Select id, 
                                              Invoice_Paid__c, 
                                              Invoice__c 
                                      From Commissions__r 
                                      )
                               From Opportunity
                               Where Id in :opportunityIds];
        }
        
        if(opportunityList != null && !opportunityList.isEmpty()) {
            for(Opportunity oppObj : opportunityList) {
                for(Commission__c commissionObj : oppObj.Commissions__r) {
                    commissionObj.Invoice_Paid__c = true;
                    commissionList.add(commissionObj);
                }
            }
        }
        
        if(commissionList != null && !commissionList.isEmpty()) {
            try {
                update commissionList;
            } catch(Exception ex) {
                system.debug('>>> Error exception: ' +ex.getMessage());
            }
        }
                           
    }
}