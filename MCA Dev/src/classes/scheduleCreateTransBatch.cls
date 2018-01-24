global class scheduleCreateTransBatch implements Schedulable {
   global static Set<Date> holidaySet;
   global void execute(SchedulableContext SC) {
      holidaySet = new Set<Date>();
      List<Bank_Holiday__c> holidays = new List<Bank_Holiday__c>([select id,name,Holiday_Date__c from Bank_Holiday__c where Holiday_Date__c=THIS_YEAR and Holiday_Date__c>=Today]);
      for(Bank_Holiday__c holiday:holidays){
          holidaySet.add(holiday.Holiday_Date__c);
      }
      string nextHitDate = string.valueOf(getValidDate(date.today().addDays(1))).split(' ')[0];
      string query = 'select id,Payment_Amount__c,Last_Batch_Date__c,Payment_Frequency__c,Next_Hit_Date__c,Intial_Repayment_Amount__c,'+
            '(select id,Effective_Date__c,Status__c from Payments__r order by Effective_Date__c desc),'+
            ' Pending_Amount__c,Payment_Method__c,Total_Outstanding_Amount__c'+
            ' from Repayment__c'+
            ' where Next_Hit_Date__c = '+nextHitDate+
            ' and Total_Outstanding_Amount__c > 0 and Status__c = \'Active\' order by Createddate desc';
       CreateTransBatch transBatch = new CreateTransBatch(query);
       ID batchprocessid = Database.executeBatch(transBatch);
   }
   private Date getValidDate(Date nextHitDate){
       Datetime dt = DateTime.newInstance(nextHitDate, Time.newInstance(0, 0, 0, 0));       
       String dayOfWeek=dt.format('EEEE');
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