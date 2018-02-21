global class CreateTransBatch implements Database.Batchable<sObject>{

   global final String Query;
   global List<Payment__c> transactions;
   global static Set<Date> holidaySet;
   global CreateTransBatch(String q){
      Query=q;
      transactions = new List<Payment__c>();
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);      
   }

   global void execute(Database.BatchableContext BC, List<Repayment__c> scope){
     try{     
         holidaySet = new Set<Date>();
         List<Bank_Holiday__c> holidays = new List<Bank_Holiday__c>([select id,name,Holiday_Date__c from Bank_Holiday__c where Holiday_Date__c=THIS_YEAR and Holiday_Date__c>=Today]);
         for(Bank_Holiday__c holiday:holidays){
             holidaySet.add(holiday.Holiday_Date__c);
         }
         List<Ach_batch__c> batches = new List<Ach_Batch__c>([select id,createddate, isScheduled__c,(select id, Repayment__c from Payments__r where Effective_Date__c=tomorrow) from Ach_Batch__c 
                                                             where createddate=today order by createddate desc limit 1]);
         Ach_Batch__c batch;  
         Map<string,Payment__c> payIdTransaction = new Map<string, Payment__c>();   
         if(batches.size()>0){
             batch = batches[0];
             for(Payment__c t:batches[0].Payments__r)
                payIdTransaction.put(t.Repayment__c,t);
         }
         else{
             batch = new Ach_Batch__c();
             batch.Status__c= 'Pending';
             batch.isScheduled__c = True;
             insert batch;             
         }
         transactions = new List<Payment__c>();
         
         Map<String,Schema.RecordTypeInfo> rtMapByName = Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
         Schema.RecordTypeInfo rtByName =  rtMapByName.get('Debit');
         string recTypeId = String.valueOf(rtByName.getRecordTypeId());
         system.debug(recTypeId);
         
         //Id recTypeId = [select Id from RecordType where SobjectType = 'ACHIT__Payment__c' and name = 'Debit' limit 1].Id;     
         for(Repayment__c pay : scope){
              Payment__c trans = new Payment__c();
              trans.ACH_Batch__c = batch.id;
              trans.Status__c = 'Scheduled';
              trans.Repayment__c = pay.id;
              trans.Transaction_Amount__c = (pay.Total_Outstanding_Amount__c - pay.Pending_Amount__c > pay.Payment_Amount__c ? pay.Payment_Amount__c :pay.Total_Outstanding_Amount__c - pay.Pending_Amount__c);
              trans.Transaction_Type__c = 'Payment';
              trans.RecordTypeId = recTypeId;   
              trans.Payment_Method__c = pay.Payment_Method__c;
              trans.Effective_Date__c = skipHolidays(pay.Next_Hit_Date__c,pay);
              trans.Running_Balance__c = pay.Total_Outstanding_Amount__c;         
              if(pay.Payment_Frequency__c!=null){
                  Date dt = getNextHitDate(pay);
                  pay.Next_Hit_Date__c = dt;
              }
              if(trans.Transaction_Amount__c > 0  && !payIdTransaction.containsKey(trans.Repayment__c))
                  transactions.add(trans);
              pay.Last_Batch_Date__c = system.now();//batch.createddate;
         }
         if(transactions.size()>0)
             insert transactions;
         for(Payment__c trans:transactions){
             string id = string.valueOf(trans.id);
             String idDate = String.valueOf(Date.today().month()) + String.valueOf(Date.today().day()) + String.valueOf(Date.today().year()).substring(2,4);
//             String idDate = String.valueOf(Date.today().month()) + String.valueOf(Date.today().day()) + String.valueOf(Date.today().year()).substring(3,5);
             trans.External_Transaction_ID__c='T' + idDate + id.substring((18 - (11 - (idDate.length()))),18);
                
         }
         if(transactions.size()>0)
             update transactions;
         update scope;
     }
     catch(Exception e){
      
      ACH_Payments_Settings__c settings = ACH_Payments_Settings__c.getOrgDefaults();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {settings.Email_Recipient__c});
        email.setSubject('Batch execution Failed in salesforce organisation: CreateTransBatch');
        string html = 'Error encountered while Creating Transactions:';
        html+='<p>'+e.getMessage()+'</p>';
        html+='<p>'+e.getStackTraceString()+'</p>';
        email.setHtmlBody(html);
        emails.add(email);
        if(emails.size()>0)
            Messaging.sendEmail(emails);
     }
    }

   global void finish(Database.BatchableContext BC){       
       
   }   
   private Date getNextHitDate(Repayment__c pay){       
       if(pay.Payment_Frequency__c == 'Daily'){
           return skipHolidays(pay.Next_Hit_Date__c.addDays(1),pay);
       }
       else if (pay.Payment_Frequency__c == 'Weekly'){
           return skipHolidays(pay.Next_Hit_Date__c.addDays(7),pay);
       }
       else if (pay.Payment_Frequency__c == 'Monthly'){
           return skipHolidays(pay.Next_Hit_Date__c.addMonths(1),pay);
       }
       else
           return null;
   }
   private Date skipHolidays(Date nextHitDate,Repayment__c pay){       
       if(pay.Payments__r.size()>0 
          && pay.Payments__r[0].Status__c=='Scheduled' 
          && pay.Payments__r[0].Effective_Date__c==nextHitDate){
           nextHitDate = nextHitDate.addDays(1);
       }
       nextHitDate = getValidDate(nextHitDate);
       system.debug('%%'+nextHitDate);
       return nextHitDate;
   }
   private Date getValidDate(Date nextHitDate){
       system.debug('**'+nextHitDate+','+holidaySet.contains(nextHitDate));
       Datetime dt = DateTime.newInstance(nextHitDate, Time.newInstance(0, 0, 0, 0));       
       String dayOfWeek=dt.format('EEEE');
       system.debug('**'+dayOfWeek);
       if(dayOfWeek=='Saturday')
          return getValidDate(nextHitDate.addDays(1));
       else if(dayOfWeek=='Sunday')
          return getValidDate(nextHitDate.addDays(1));
       else if(holidaySet.contains(nextHitDate))
          return getValidDate(nextHitDate.addDays(1));
       else
           return nextHitDate;
   }
}