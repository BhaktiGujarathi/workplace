@isTest
private class ACHTest {

	
	@isTest 
	private static void createTransactionDailyBatch() {
        string nextHitDate = string.valueOf(ACHUtils.getValidDate(date.today().addDays(1))).split(' ')[0];
        createRepayments('Daily');

        ACH_Public_Settings__c settings = new ACH_Public_Settings__c();
        settings.Email_Recipient__c = 'test@test.test';
        insert settings;
        ACHUtils.sendErrorEmail('Test', null, 'This is a test');

        Test.startTest();
        ID batchprocessid = Database.executeBatch(new ACHCreateTransactionsBatch(nextHitDate));
        Test.stopTest();

        Repayment__c repayment = [select id from Repayment__c limit 1];

        Payment__c payment = [select id, Transaction_Amount__c, Status__c, Effective_Date__c from Payment__c limit 1];
        System.assertEquals(1000, payment.Transaction_Amount__c);
        System.assertEquals('Scheduled', payment.Status__c);
        System.assertEquals(ACHUtils.skipHolidays(ACHUtils.getValidDate(date.today().addDays(1)), repayment), payment.Effective_Date__c);
	}


	@isTest 
	private static void createTransactionWeeklyBatch() {
        string nextHitDate = string.valueOf(ACHUtils.getValidDate(date.today().addDays(1))).split(' ')[0];
        createRepayments('Weekly');
		
        Test.startTest();
        ID batchprocessid = Database.executeBatch(new ACHCreateTransactionsBatch(nextHitDate));
        Test.stopTest();

        Repayment__c repayment = [select id from Repayment__c limit 1];

        Payment__c payment = [select id, Transaction_Amount__c, Status__c, Effective_Date__c from Payment__c limit 1];
        System.assertEquals(1000, payment.Transaction_Amount__c);
        System.assertEquals('Scheduled', payment.Status__c);
        System.assertEquals(ACHUtils.skipHolidays(ACHUtils.getValidDate(date.today().addDays(1)), repayment), payment.Effective_Date__c);
	}

	@isTest 
	private static void createTransactionMonthlyBatch() {
        string nextHitDate = string.valueOf(ACHUtils.getValidDate(date.today().addDays(1))).split(' ')[0];
        createRepayments('Monthly');
		
        Test.startTest();
        ID batchprocessid = Database.executeBatch(new ACHCreateTransactionsBatch(nextHitDate));
        Test.stopTest();

        Repayment__c repayment = [select id from Repayment__c limit 1];

        Payment__c payment = [select id, Transaction_Amount__c, Status__c, Effective_Date__c from Payment__c limit 1];
        System.assertEquals(1000, payment.Transaction_Amount__c);
        System.assertEquals('Scheduled', payment.Status__c);
        System.assertEquals(ACHUtils.skipHolidays(ACHUtils.getValidDate(date.today().addDays(1)), repayment), payment.Effective_Date__c);
	}
	
	@isTest 
	private static void scheduleCreateTransactionTest() {
		ID scheduleId = System.schedule('Create Transactions Batch', '0 0 * * * ?', new ACHCreateTransactionBatchSchedule());	
        system.assertNotEquals(null, scheduleId);
	}

    @isTest
	private static void validateScheduleCreateTransBatch()
    {   
        Bank_Holiday__c holiday = new Bank_Holiday__c();
        holiday.Holiday_Date__c = Date.today().addDays(1);
        insert holiday;
        
        Map<String,Schema.RecordTypeInfo> rtMapByName = Repayment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('ACH Recurring');
        Id recTypeId = rtByName.getRecordTypeId();
        
                  
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
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ACHCreateTransactionBatchSchedule() );

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }


    @isTest
    private static void runningBalanceTriggerTest() {
        createPayments(1000, 'Settled', '', '');
        Payment__c payment = [select Running_Balance__c from Payment__c limit 1];
        System.assertEquals(9000, payment.Running_Balance__c);
    }


    @isTest
    private static void sendAchTransBatchTest() {
        createCredentials();
        createPayments(1000, 'Scheduled', '', '');
        
        Test.startTest();  
        //ACHSendTransactionBatch.sendAchTransBatch();
        Test.stopTest();
        Payment__c payment = [select Status__c from Payment__c limit 1];
        
        //System.assertEquals('Pending', payment.Status__c);

    }


    @isTest 
    private static void scheduleSendTransactionTest() {
        ID scheduleId = System.schedule('Send Transactions Batch', '0 0 * * * ?', new ACHSendTransactionBatchSchedule());   
        system.assertNotEquals(null, scheduleId);
    }


    @isTest
    private static void trackAchTransBatchTest() {
        ACH_Public_Settings__c settings = new ACH_Public_Settings__c();
        settings.Last_Tracking_Date__c = Date.today();
        insert settings;

        createCredentials();

        createPayments(1000, 'Scheduled', '', 'TEST1');
        createPayments(1000, 'Scheduled', '', 'TEST2');
        createFeesSettings();

        Test.startTest();
        //ACHTrackTransactionBatch.trackTrasactions();
        Test.stopTest();

        Payment__c payment = [select Status__c from Payment__c limit 1];
        //System.assertEquals('Settled', payment.Status__c);

    }


    @isTest 
    private static void scheduleTrackTransactionTest() {

        ID scheduleId = System.schedule('Track Transactions Batch', '0 0 * * * ?', new ACHTrackTransactionBatchSchedule());   
        system.assertNotEquals(null, scheduleId);
    }


    @isTest 
    private static void getACHReturnsTest() {
        createCredentials();
        system.assertEquals(null, ACHUtils.getACHReturns());
    }


    @isTest 
    private static void getACHReturnsHistTest() {
        createCredentials();
        system.assertEquals(null, ACHUtils.getACHReturnsHist(DateTime.now().addDays(-3), Datetime.now()));
    }


    @isTest
    private static void achWorksServiceCoverage() {
        createServiceCallOutCoverage();
    }


    private static void createCredentials() {
        ACH_Credentials__c auxCredential = new ACH_Credentials__c();
        auxCredential.Name = 'ACH Test';
        auxCredential.Active__c = true;
        auxCredential.Is_Test__c = true;
        auxCredential.LocID__c = '123';
        auxCredential.companyKey__c = 'company Key Test';
        auxCredential.company__c = 'Test';
        auxCredential.sss__c = 'aaa';
        insert auxCredential;
    }


    private static String createRepayments(String frequency) {
        Map<String,Schema.RecordTypeInfo> rtMapByName   = Repayment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName                  = rtMapByName.get('ACH Recurring');
        Id recTypeId                                    = rtByName.getRecordTypeId();

        Account account = new Account();
        account.Name    = 'Test';
        insert account;

        Repayment__c repayment                  = new Repayment__c();
        repayment.Status__c                     = 'Active';
        repayment.Payment_Method__c             = 'ACH';
        repayment.Intial_Repayment_Amount__c    = 10000;
        repayment.Payment_Amount__c             = 1000;
        repayment.Payee_Account__c              = account.Id;
        repayment.Payment_Frequency__c          = frequency;
        repayment.Next_Hit_Date__c              = Date.Today().addDays(1);
        repayment.RecordTypeID                  = recTypeId;
        insert repayment;

        return repayment.Id;
    }


    private static void createPayments(Double transactionAmount, String status, String frequency, String externalId) {
        Map<String,Schema.RecordTypeInfo> rtMapByName   = Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName                  = rtMapByName.get('Debit');
        Id recTypeId                                    = rtByName.getRecordTypeId();

        ACH_Batch__c batch          = new ACH_Batch__c();
        batch.Status__c             = 'Pending';
        batch.Batch_Date_Time__c    = DateTime.now();
        insert batch;

        Payment__c payment                  = new Payment__c();
        payment.Repayment__c                = createRepayments(frequency);
        payment.Transaction_Amount__c       = transactionAmount;
        payment.Effective_Date__c           = ACHUtils.getValidDate(date.today().addDays(1));
        payment.Status__c                   = status;
        payment.RecordTypeID                = recTypeId;
        payment.ACH_Batch__c                = batch.Id;
        payment.External_Transaction_ID__c  = externalId;
        insert payment;
    }


    private static void createFeesSettings() {
        Bounce_Fees_Settings__c feesSetting = new Bounce_Fees_Settings__c();
        feesSetting.Response_Code__c = 'TST';
        feesSetting.Fees__c = 12;
        insert feesSetting;
    }


    private static void createServiceCallOutCoverage() {

    }


}