public with sharing class SchedulerQueryGenenrator {

    public static String queryFetch(integer dayspastdue) {
        String schedulerQuery;
        if  (dayspastdue == 30){ 
             schedulerQuery= 'Select Id, '
                                    +'Total_30_Days_Past_Due__c, '
                                    +'(Select Total_Amount_Due__c, '
                                    +  'Days_Past_Due__c '
                                    +  'From Invoices__r '  
                                    +  'where Days_Past_Due__c>=30 and Days_Past_Due__c<60) '
                            +'From Account';
        }else if(dayspastdue == 90){
           schedulerQuery= 'Select Id, '
                                    +'Total_90_Days_Past_Due__c, '
                                    +'(Select Total_Amount_Due__c, '
                                    + 'Days_Past_Due__c '
                                    + 'From Invoices__r '  
                                    + 'where Days_Past_Due__c>=90) '
                            +'From Account';
        }else if(dayspastdue == 0){
           schedulerQuery= 'Select Id, '
                                    +'Total_Past_Due_Invoices__c, '
                                    +'(Select Total_Amount_Due__c, '
                                    + 'Days_Past_Due__c '
                                    + 'From Invoices__r '  
                                    + 'where Days_Past_Due__c>0) '
                            +'From Account';
        } else if(dayspastdue == 60) {
            schedulerQuery= 'Select Id, '
                                    +'Total_60_Days_Past_Due__c, '
                                    +'(Select Total_Amount_Due__c, '
                                    + 'Days_Past_Due__c '
                                    + 'From Invoices__r '  
                                    + 'where Days_Past_Due__c>=60 and Days_Past_Due__c<90) '
                            +'From Account';
        }
        return schedulerQuery;
    }
}