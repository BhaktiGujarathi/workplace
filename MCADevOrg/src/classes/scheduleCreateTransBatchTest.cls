@isTest
class scheduleCreateTransBatchTest
    {   
        
        public static testmethod void validateScheduleCreateTransBatch()
            {   
                Bank_Holiday__c holiday = new Bank_Holiday__c();
                holiday.Holiday_Date__c = Date.today().addDays(1);
                insert holiday;
                
                Map<String,Schema.RecordTypeInfo> rtMapByName = Repayment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
		        Schema.RecordTypeInfo rtByName =  rtMapByName.get('Recurring');
		        Id recTypeId = rtByName.getRecordTypeId();
		        system.debug(recTypeId);
                //Id recTypeId = [select Id from RecordType where SobjectType = 'ACHIT__Payment_Setting__c' and name = 'Recurring' limit 1].Id;                
                Account objAccount = new Account();
                objAccount.Name = 'Test Account';
                insert objAccount;
                Date currentDate = Date.Today();
                
                Test.starttest();
                Repayment__c objPayment = new Repayment__c();
                objPayment.Payment_Amount__c = 1000;
                objPayment.RecordTypeID=recTypeId;
                objPayment.Payment_Frequency__c = 'Daily';
                objPayment.Next_Hit_Date__c = currentDate.addDays(1);
                objPayment.Intial_Repayment_Amount__c = 10000;
                objPayment.Status__c = 'Active';
                objPayment.Payee_Account__c = objAccount.id;
                insert objPayment;
                String CRON_EXP = '0 0 0 1 1 ? 2025';  
                String jobId = System.schedule('testScheduledApex', CRON_EXP, new scheduleCreateTransBatch() );

                CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                System.assertEquals(CRON_EXP, ct.CronExpression); 
                System.assertEquals(0, ct.TimesTriggered);
                System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
                Test.stopTest();
            }
    }