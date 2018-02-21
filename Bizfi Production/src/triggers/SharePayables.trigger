trigger SharePayables on McaApp__Payable__c (before insert, before update, after insert) {
    

    if (trigger.isAfter) {
        
        PayableUtility obj = new PayableUtility();
        obj.shareRecords(trigger.new);
    }
    else {
        
        Map<Integer,String> mpMonths = BFIUtility.mpMonths;
        Set<String> Keys2Check = new Set<String>();
        RecordType recPayable = [Select id 
                                   from RecordType 
                                  where sobjectType = 'McaApp__Payable__c' 
                                    and developerName = 'Read_Only'];
        

        for (McaApp__Payable__c pay : trigger.new) {
            
            if (pay.recordtypeId != recPayable.Id) {
                
                if (pay.McaApp__Payable_Date__c != null) {
                   
                   Keys2Check.add(mpMonths.get(pay.McaApp__Payable_Date__c.month())+'###'+pay.McaApp__Payable_Date__c.Year());
                }
                
                if (pay.McaApp__Due_Date__c != null) {
                   
                   Keys2Check.add(mpMonths.get(pay.McaApp__Due_Date__c.month())+'###'+pay.McaApp__Due_Date__c.Year());   
                }
                
                if (pay.McaApp__Date_Paid__c != null) {
                   
                   Keys2Check.add(mpMonths.get(pay.McaApp__Date_Paid__c .month())+'###'+pay.McaApp__Date_Paid__c.Year());      
                }
            }
            else {
               
               if (pay.McaApp__Payable_Date__c != null && trigger.oldmap.get(pay.id).McaApp__Payable_Date__c != pay.McaApp__Payable_Date__c) {
                   
                   pay.addError(System.Label.PayableReadOnlyError);
               }
               
               if (pay.McaApp__Due_Date__c  != null && trigger.oldmap.get(pay.id).McaApp__Due_Date__c != pay.McaApp__Due_Date__c ) {
               
                   //pay.addError(System.Label.PayableReadOnlyError);
                   Keys2Check.add(mpMonths.get(pay.McaApp__Due_Date__c.month())+'###'+pay.McaApp__Due_Date__c.Year());   
               } 
               
               if (pay.McaApp__Date_Paid__c != null && trigger.oldmap.get(pay.id).McaApp__Date_Paid__c != pay.McaApp__Date_Paid__c) {
               
                   //pay.addError(System.Label.PayableReadOnlyError);
                   Keys2Check.add(mpMonths.get(pay.McaApp__Date_Paid__c .month())+'###'+pay.McaApp__Date_Paid__c.Year());      
               }  
            }    
        }
        
        if (!Keys2Check.isEmpty()) {

            Set<String> existingkeys = new set<String>();
            
            for(Accounting_Calendar_Month__c acm: [Select Id,   
                                                          Key__c 
                                                     from Accounting_Calendar_Month__c 
                                                    where Key__c in:keys2check 
                                                      and Locked__c = true]) {
                existingkeys.add(acm.key__c);    
            }
            
            for (McaApp__Payable__c pay : trigger.new) {
            
                if (pay.McaApp__Payable_Date__c != null) {
                   
                   if (existingkeys.contains(mpMonths.get(pay.McaApp__Payable_Date__c.month())+'###'+pay.McaApp__Payable_Date__c.Year())) {
                       
                       pay.addError(System.Label.PayableReadOnlyError);
                   }
                }
                
                if (pay.McaApp__Due_Date__c != null) {
                
                   if (existingkeys.contains(mpMonths.get(pay.McaApp__Due_Date__c.month())+'###'+pay.McaApp__Due_Date__c.Year())) {
                       
                       pay.addError(System.Label.PayableReadOnlyError);
                   }
                }
                
                if (pay.McaApp__Date_Paid__c != null) {
                    
                    if (existingkeys.contains(mpMonths.get(pay.McaApp__Date_Paid__c.month())+'###'+pay.McaApp__Date_Paid__c.Year())) {
                        
                        pay.addError(System.Label.PayableReadOnlyError);
                    }
                        
                }    
            }
        }
    }
}