public with sharing class ACHUtils {

	public static Date getValidDate(Date nextHitDate){
        Set<Date> holidaySet = new Set<Date>();
         
        for (Bank_Holiday__c holiday : [select id
                                             , name
                                             , Holiday_Date__c 
                                          from Bank_Holiday__c 
                                         where Holiday_Date__c = THIS_YEAR 
                                           and Holiday_Date__c >= Today]) {
            holidaySet.add(holiday.Holiday_Date__c);
        }

        Datetime dt = DateTime.newInstance(nextHitDate, Time.newInstance(0, 0, 0, 0));    
        String dayOfWeek = dt.format('EEEE');
       
        if (dayOfWeek.equals('Saturday') || dayOfWeek.equals('Sunday') || holidaySet.contains(nextHitDate)) {
            return getValidDate(nextHitDate.addDays(1));
        }
        else {
            return nextHitDate;
        }
    }


    public static Date getNextHitDate(Repayment__c paymentSetting) {
        if (paymentSetting.Payment_Frequency__c == 'Daily') {
            return skipHolidays(paymentSetting.Next_Hit_Date__c.addDays(1), paymentSetting);

        } else if (paymentSetting.Payment_Frequency__c == 'Weekly') {
            return skipHolidays(paymentSetting.Next_Hit_Date__c.addDays(7), paymentSetting);

        } else if (paymentSetting.Payment_Frequency__c == 'Monthly') {
            return skipHolidays(paymentSetting.Next_Hit_Date__c.addMonths(1), paymentSetting);
        }
        return null;
    }


    public static Date skipHolidays(Date nextHitDate, Repayment__c paymentSetting) {
        if (!paymentSetting.Payments__r.isEmpty()) {
            Payment__c auxTransaction = null;
            for (Payment__c t : paymentSetting.Payments__r) {
                if (t.Status__c == 'Scheduled' && t.Effective_Date__c == nextHitDate) {
                    auxTransaction = t;
                }
            }
            if (auxTransaction != null) {
                nextHitDate = nextHitDate.addDays(1);
            }
        }

        nextHitDate = getValidDate(nextHitDate);
        return nextHitDate;
        
    }


    public static void sendErrorEmail(String batchName, Exception e, String message) {
        ACH_Public_Settings__c settings = ACH_Public_Settings__c.getOrgDefaults();
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (settings.Email_Recipient__c != null) {
            email.setToAddresses(new String[] { settings.Email_Recipient__c });
        }
        else {
            email.setToAddresses(new String[] { 'support@cloudmybiz.com' });
        }
        email.setSubject('Batch execution Failed in salesforce organisation: ' + batchName);

        string html = 'Error encountered while Creating Transactions:';

        if (e != null) {
            html += '<p>' + e.getMessage() + '</p>';
            html += '<p>' + e.getStackTraceString() + '</p>';
        }

        if (message != '') {
            html += '<p>Details: ' + message + '</p>';
        }
        email.setHtmlBody(html);
        emails.add(email);
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }


    public static ACH_Credentials__c getActiveCredentials() {
        for (ACH_Credentials__c c : [SELECT Active__c
                                          , Company__c
                                          , CompanyKey__c
                                          , LocID__c
                                          , SSS__c
                                          , Is_Test__c
                                          , Name
                                      FROM ACH_Credentials__c
                                     WHERE Active__c =: true]) {
            return c;
        }
        return null;
    }


    public static ACHWorksService.ACHTransRecord createTransactionRecord(Payment__c trans, ACH_Credentials__c credential){

        ACHWorksService.ACHTransRecord achTransRecord = new ACHWorksService.ACHTransRecord();
        achTransRecord.SSS                  = credential.SSS__c;
        achTransRecord.LocID                = credential.LocID__c;
        achTransRecord.FrontEndTrace        = trans.External_Transaction_ID__c;
        achTransRecord.OriginatorName       = UserInfo.getOrganizationName();
        achTransRecord.TransactionCode      = 'CCD';
        achTransRecord.CustTransType        = 'D';
        achTransRecord.CustomerID           = trans.Repayment__r.Payee_Account__c;
        achTransRecord.CustomerName         = trans.Repayment__r.Payee_Account__r.name;        
        achTransRecord.CustomerRoutingNo    = trans.Repayment__r.Bank_Routing_Number__c;
        achTransRecord.CustomerAcctNo       = trans.Repayment__r.Bank_Account_Number__c;
        achTransRecord.CustomerAcctType     = trans.Repayment__r.Type_of_Account__c=='Savings'?'S':'C';
        achTransRecord.TransAmount          = trans.Transaction_Amount__c;
        achTransRecord.CheckOrCustID        = trans.Check__c;
        achTransRecord.CheckOrTransDate     = datetime.now();
        achTransRecord.EffectiveDate        = trans.Effective_Date__c;
        achTransRecord.Memo                 = trans.Memo__c;
        achTransRecord.OpCode               ='S';
        achTransRecord.AccountSet           ='1';

        return achTransRecord;
    }


    public static ACHWorksService.CompanyInfo getCompanyInformation(ACH_Credentials__c credentials) {
        ACHWorksService.CompanyInfo comInfo = new ACHWorksService.CompanyInfo();  
        comInfo.sss         = credentials.sss__c;
        comInfo.locID       = credentials.LocID__c;
        comInfo.company     = credentials.company__c;
        comInfo.companyKey  = credentials.companyKey__c;
        
        return comInfo;
    }


    //Gets the returns from ach works.
    public static ACHWorksService.ACHReturns getACHReturns(){
        ACH_Credentials__c credentials = getActiveCredentials();
        ACHWorksService.CompanyInfo comInfo = getCompanyInformation(credentials);
        ACHWorksService.ACHWorksWSSoap achsoap = new ACHWorksService.ACHWorksWSSoap();
        
        if(credentials.Name == 'ACH Test') {
            achsoap.endpoint_x = 'http://tstsvr.achworks.com/dnet/achws.asmx';
        }

        ACHWorksService.ACHReturns ret = null;
        if (!Test.isRunningTest()) {
            ret = achsoap.GetACHReturns(comInfo);
        }
        return ret;
    }
    
    //Gets ach works return history for particular date range.
    public static ACHWorksService.ACHReturns getACHReturnsHist(Datetime fromDate, Datetime toDate){
        ACH_Credentials__c credentials = getActiveCredentials();
        ACHWorksService.CompanyInfo comInfo = getCompanyInformation(credentials);
        ACHWorksService.ACHWorksWSSoap achsoap = new ACHWorksService.ACHWorksWSSoap();
        if(credentials.name == 'ACH Test') {
            achsoap.endpoint_x = 'http://tstsvr.achworks.com/dnet/achws.asmx';
        }
        ACHWorksService.ACHReturns ret = null;
        if (!Test.isRunningTest()) {
            ret = achsoap.getACHReturnsHist(comInfo,fromDate,toDate);
        } 
        return ret;
    }


}