trigger AccountingCalendarMonthTrigger on Accounting_Calendar_Month__c (before insert, before update, after insert, after update, after delete) {
    
    if(trigger.isBefore){
        
        set<String> stKeys = new set<String>();
        for(Accounting_Calendar_Month__c acm: trigger.new){
            if(trigger.isInsert && acm.locked__c)
                acm.Lock_Date_Time__c=System.Now();
            
            if(trigger.isUpdate && acm.Locked__c && acm.Locked__c != trigger.oldMap.get(acm.Id).Locked__c)
                acm.Lock_Date_Time__c=System.Now();
            
            if(trigger.isUpdate && acm.Locked__c == false && acm.Locked__c != trigger.oldMap.get(acm.Id).Locked__c)
                acm.addError('You cannot modify a locked month. Please contact your system administrator');
            
            if(trigger.isUpdate && acm.Locked__c && trigger.oldMap.get(acm.Id).Locked__c && (acm.Month__c != trigger.oldMap.get(acm.Id).Month__c || (acm.Year__c != trigger.oldMap.get(acm.Id).Year__c)))
                acm.addError('You cannot modify a locked month. Please contact your system administrator');
            
            if(trigger.isUpdate && acm.Lock_Date_Time__c == null && trigger.oldmap.get(acm.id).Lock_Date_Time__c  != null)
                acm.addError('You cannot modify a locked month. Please contact your system administrator');    
                    
            stKeys.add(acm.Month__c+'###'+acm.Year__c);    
        }
        
        Set<String> existingKeys = new Set<String>();
        for(Accounting_Calendar_Month__c acm: [Select id,Key__c from Accounting_Calendar_Month__c where Key__c in:stKeys and Id not in: trigger.new]){
            existingKeys.add(acm.Key__c);
        }
        
        for(Accounting_Calendar_Month__c acm: trigger.new){
            if(existingKeys.contains(acm.Month__c+'###'+acm.Year__c)){
                acm.addError(System.Label.UniqueRecord_ACM);
            }   
        }    
    }
    
    
    if(trigger.isAfter){
        Set<String> lockMonths = new Set<String>();
        for(Accounting_Calendar_Month__c acm: trigger.isDelete ? trigger.old :trigger.new){
            if(acm.locked__c){
                lockMonths.add(acm.Month__c+'###'+acm.Year__c);
            }
        }
        
        
        if(!lockMonths.isEmpty()){

            if (!System.isBatch() && !System.isFuture()) {
                
                // Update Opportunities
                AccountCalendarOpportunityLockBatch.start(lockMonths, Trigger.isDelete);

                // Update Payables
                // AccountCalendarPayableLockBatch.start(lockMonths, Trigger.isDelete);

                // Update Receivables
                // AccountCalendarReceivableLockBatch.start(lockMonths, Trigger.isDelete);
            }            
            
            //Update Opportunities
            //RecordType recOpportunity = [Select id from RecordType where sobjectType='Opportunity' and developerName='Read_Only'];
            //RecordType LegacyOpportunity = [Select id from RecordType where sobjectType='Opportunity' and developerName='Legacy_Funding_Opportunity'];
            //List<Opportunity> lstOpps = new List<Opportunity>();
            //for(Opportunity opp: [Select id,recordtypeId from Opportunity where stagename = 'Funded' and Funded_Date_Key__c in:lockMonths]){
            //    if(trigger.isdelete){
            //        if(opp.recordTypeId != LegacyOpportunity.Id){
            //            opp.recordtypeId = LegacyOpportunity.Id;
            //            lstOpps.add(opp);
            //        }
            //    }
            //    else{
            //        if(opp.recordTypeId != recOpportunity.Id){
            //            opp.recordtypeId = recOpportunity.Id;
            //            lstOpps.add(opp);
            //        }
            //    }
            //}            
            
            //Update Payables
            //RecordType recPayable = [Select id from RecordType where sobjectType='McaApp__Payable__c' and developerName='Read_Only'];
            //RecordType defPayable = [Select id from RecordType where sobjectType='McaApp__Payable__c' and developerName='Default'];
            //List<McaApp__Payable__c> lstPays = new List<McaApp__Payable__c>();
            //for(McaApp__Payable__c pay: [Select id,recordtypeId from McaApp__Payable__c where Payable_Date_Key__c in:lockMonths]){
                
            //    if(trigger.isdelete){
            //        if(pay.recordTypeId != defPayable.Id){
            //            pay.recordtypeId = defPayable.Id;
            //            lstPays.add(pay);
            //        }
            //    }
            //    else{
            //        if(pay.recordTypeId != recPayable.Id){
            //            pay.recordtypeId = recPayable.Id;
            //            lstPays.add(pay);
            //        }
            //    }
            //}
            
            //Update Payables
            //RecordType recReceivable = [Select id from RecordType where sobjectType='McaApp__Receivable__c' and developerName='Read_Only'];
            //RecordType defReceivable = [Select id from RecordType where sobjectType='McaApp__Receivable__c' and developerName='Default'];
            //List<McaApp__Receivable__c> lstReceivables = new List<McaApp__Receivable__c>();
            //for(McaApp__Receivable__c rec: [Select id, recordtypeId from McaApp__Receivable__c where Receivable_Invoice_Key__c in:lockMonths]){
            //    if(trigger.isdelete){
            //        if(rec.recordTypeId != defReceivable.Id){
            //            rec.recordtypeId = defReceivable.Id;
            //            lstReceivables.add(rec);
            //        }
            //    }
            //    else{
            //        if(rec.recordtypeid != recReceivable.Id){
            //            rec.RecordTypeId = recReceivable.Id;
            //            lstReceivables.add(rec);
            //        }
            //    }
            //}
            
            //if (!lstOpps.isEmpty()) {
            //    update lstOpps;
            //}
                
            //if(!lstPays.isEmpty())
            //    update lstPays;
                
            //if(!lstReceivables.isEmpty())
            //    update lstReceivables;
        }
    }

}