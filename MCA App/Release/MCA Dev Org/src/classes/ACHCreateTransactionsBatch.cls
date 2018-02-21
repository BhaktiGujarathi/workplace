global with sharing class ACHCreateTransactionsBatch  implements Database.Batchable < sObject >  {
	
    global final String query;
    global Payment__c[] transactions;
    global static Set < Date > holidaySet;


	global ACHCreateTransactionsBatch(String nextHitDate) {
		query = 'select id' +
                     ', Payment_Amount__c' +
                     ', Last_Batch_Date__c' +
                     ', Payment_Frequency__c' +
                     ', Next_Hit_Date__c' +
                     ', Intial_Repayment_Amount__c' +
                     ', (select id, Effective_Date__c, Status__c from Payments__r order by Effective_Date__c desc)' +
                     ', Pending_Amount__c' +
                     ', Payment_Method__c' +
                     ', Total_Outstanding_Amount__c' +
                 ' from Repayment__c' +
                ' where Next_Hit_Date__c = ' + nextHitDate +
                  ' and Total_Outstanding_Amount__c > 0 ' +
                  ' and Status__c = \'Active\' order by Createddate desc';

        transactions = new Payment__c[] {};
	}


    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, Repayment__c [] scope) {
        try {

            Map < String, Schema.RecordTypeInfo > rtMapByName = Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName = rtMapByName.get('Debit');
            String recTypeId = String.valueOf(rtByName.getRecordTypeId());

            
            Ach_Batch__c batch = null;
            for (Ach_Batch__c b: [select id
                                       , createddate
                                       , isScheduled__c
                                       , (select id, Repayment__c from Payments__r where Effective_Date__c = tomorrow)
                                    from Ach_Batch__c
                                   where createddate = today]) {
                batch = b;
            }

            Map < String, Payment__c > transactionsMap = new Map < String, Payment__c > ();

            if (batch != null) {
                for (Payment__c t: batch.Payments__r) {
                    transactionsMap.put(t.Repayment__c, t);
                }
            } else {
                batch = new Ach_Batch__c();
                batch.Status__c = 'Pending';
                batch.isScheduled__c = True;
                insert batch;
            }

            for (Repayment__c paymentSetting: scope) {
                Payment__c trans = new Payment__c();
                trans.ACH_Batch__c = batch.id;
                trans.Status__c = 'Scheduled';
                trans.Repayment__c = paymentSetting.id;
                trans.Transaction_Amount__c = (paymentSetting.Total_Outstanding_Amount__c - paymentSetting.Pending_Amount__c 
                                                    > paymentSetting.Payment_Amount__c 
                                                    ? paymentSetting.Payment_Amount__c 
                                                    : paymentSetting.Total_Outstanding_Amount__c - paymentSetting.Pending_Amount__c);
                trans.Transaction_Type__c = 'Payment';
                trans.RecordTypeId = recTypeId;
                trans.Payment_Method__c = paymentSetting.Payment_Method__c;
                trans.Effective_Date__c = ACHUtils.skipHolidays(paymentSetting.Next_Hit_Date__c, paymentSetting);
                
                if (paymentSetting.Payment_Frequency__c != null) {
                    paymentSetting.Next_Hit_Date__c = ACHUtils.getNextHitDate(paymentSetting);
                }
                
                if (trans.Transaction_Amount__c > 0 && !transactionsMap.containsKey(trans.Repayment__c)) {
                    transactions.add(trans);
                }

                paymentSetting.Last_Batch_Date__c = system.now();
            }

            if (transactions.size() > 0) {
                insert transactions;

                for (Payment__c trans: transactions) {
                    String id = string.valueOf(trans.id);
                    String idDate = String.valueOf(Date.today().month()) 
                                  + String.valueOf(Date.today().day()) 
                                  + String.valueOf(Date.today().year()).substring(2, 4);
                    trans.External_Transaction_ID__c = 'T' + idDate + id.substring((18 - (11 - (idDate.length()))), 18);
                }

                update transactions;
            }

            update scope;
        } catch (Exception e) {
            ACHUtils.sendErrorEmail('ACHCreateTransactionsBatch', e, '');
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}