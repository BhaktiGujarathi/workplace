trigger ValidateReceivables on McaApp__Receivable__c (before insert, before update) {
    
    
    Map<Integer,String> mpMonths = BFIUtility.mpMonths;
    Set<String> Keys2Check = new Set<String>();
    RecordType recReceivable = [Select id from RecordType where sobjectType='McaApp__Receivable__c' and developerName='Read_Only'];
    

    for (McaApp__Receivable__c rec : trigger.new) {
        
        if (rec.recordtypeId != recReceivable.id) {
            
            if (rec.McaApp__Date_Sent__c != null) {
               
               Keys2Check.add(mpMonths.get(rec.McaApp__Date_Sent__c.month())+'###'+rec.McaApp__Date_Sent__c.Year());
            }
            
            if (rec.McaApp__Due_Date__c != null) {
            
               Keys2Check.add(mpMonths.get(rec.McaApp__Due_Date__c.month())+'###'+rec.McaApp__Due_Date__c.Year());   
            }
            
            if (rec.McaApp__Date_Paid__c != null) {
            
               Keys2Check.add(mpMonths.get(rec.McaApp__Date_Paid__c .month())+'###'+rec.McaApp__Date_Paid__c.Year());      
            }
        } 
        else{
            if (rec.McaApp__Date_Sent__c != null && rec.McaApp__Date_Sent__c != trigger.oldMap.get(rec.id).McaApp__Date_Sent__c) {
                
                rec.addError(System.Label.ReceivableReadOnly);
            }
            
            if (rec.McaApp__Due_Date__c!= null && rec.McaApp__Due_Date__c!= trigger.oldMap.get(rec.id).McaApp__Due_Date__c) {
                
                //rec.addError(System.Label.ReceivableReadOnly);
                Keys2Check.add(mpMonths.get(rec.McaApp__Due_Date__c.month())+'###'+rec.McaApp__Due_Date__c.Year());   
            }
            
            if (rec.McaApp__Date_Paid__c != null && rec.McaApp__Date_Paid__c != trigger.oldMap.get(rec.id).McaApp__Date_Paid__c) {
                
                //rec.addError(System.Label.ReceivableReadOnly);
                Keys2Check.add(mpMonths.get(rec.McaApp__Date_Paid__c .month())+'###'+rec.McaApp__Date_Paid__c.Year());      
            }
            
        }   
    }
    
    if (!keys2check.isEmpty()) {
    
        Set<String> existingkeys = new set<String>();
        
        for (Accounting_Calendar_Month__c acm: [Select id, 
                                                       Key__c 
                                                  from Accounting_Calendar_Month__c 
                                                 where Key__c in:keys2check 
                                                   and Locked__c = true]){
            existingkeys.add(acm.key__c);    
        }
        
        for (McaApp__Receivable__c rec: trigger.new) {
            
            if (rec.McaApp__Date_Sent__c != null) {
               
               if (existingkeys.contains(mpMonths.get(rec.McaApp__Date_Sent__c.month())+'###'+rec.McaApp__Date_Sent__c.Year())) {
                   
                   rec.addError(System.Label.ReceivableReadOnly);
               }
            }
            
            if (rec.McaApp__Due_Date__c != null) {
               
               if (existingkeys.contains(mpMonths.get(rec.McaApp__Due_Date__c.month())+'###'+rec.McaApp__Due_Date__c.Year())) {
                   
                   rec.addError(System.Label.ReceivableReadOnly);
               }
            }

            if (rec.McaApp__Date_Paid__c != null) {
                
                if (existingkeys.contains(mpMonths.get(rec.McaApp__Date_Paid__c.month())+'###'+rec.McaApp__Date_Paid__c.Year())) {
                    
                    rec.addError(System.Label.ReceivableReadOnly);
                }
            }    
        }
    }
}