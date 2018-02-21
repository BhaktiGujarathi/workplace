public class TestPlanForTransactionController {
     
    public Date currentDate{get;set;}
    public Integer noOFDays{get;set;}
    public Repayment__c pay{get;set;}
    public List<ACHCredentials__c> achCred{get;set;}
    public Set<Date> holidaySet{get;set;}
    public TestPlanForTransactionController(){
        pay = new Repayment__c();
        achCred = new List<ACHCredentials__c>([select name from ACHCredentials__c where Active__c=true]);
    }
    public void CallBatch()
    {              
        date currentdate = pay.Next_Hit_Date__c;
        holidaySet = new Set<Date>();
        List<Bank_Holiday__c> holidays = new List<Bank_Holiday__c>([select id,name,Holiday_Date__c from Bank_Holiday__c where Holiday_Date__c=THIS_YEAR and Holiday_Date__c>=Today]);
        for(Bank_Holiday__c holiday:holidays){
          holidaySet.add(holiday.Holiday_Date__c);
        }
        string nextHitDate = string.valueOf(getValidDate(currentdate)).split(' ')[0];
        system.debug('**'+nextHitDate);
        string query = 'select id,Payment_Amount__c,Last_Batch_Date__c,Payment_Frequency__c,Next_Hit_Date__c,Intial_Repayment_Amount__c,'+
                        '(select id,Effective_Date__c,Status__c from Payments__r order by Effective_Date__c desc),'+
                        ' Pending_Amount__c,Payment_Method__c,Total_Outstanding_Amount__c '+
                        ' from Repayment__c'+
                        ' where Next_Hit_Date__c = '+nextHitDate+
                        ' and Total_Outstanding_Amount__c > 0 and Status__c = \'Active\' order by Createddate desc limit 1';
        system.debug('query' +query);
        CreateTransBatch transBatch = new CreateTransBatch(query);
        ID batchprocessid = Database.executeBatch(transBatch);
    }
    public Date getValidDate(Date nextHitDate){
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