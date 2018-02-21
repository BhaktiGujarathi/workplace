public class AchWorksUtil{

    //ACH Settings to switch between production and sandbox environments.
    //public static ACHSettings__c setting = [select Go_Live__c from ACHSettings__c where name='Go Live'];
    //public static string credName=setting.Go_Live__c?'ACH Live':'ACH Test';  
    
    //Custom settings for ach credentials such as sss, locid, company and companykey
    public static List<ACH_Credentials__c> achCred = new List<ACH_Credentials__c>([select name, sss__c, LocID__c,company__c,companyKey__c      
                                                                    from ACH_Credentials__c where Active__c=true]);  
                                                                      
    //Method to send transactions to ach works under salesforce batch id
    @future(callout=true)
    public static void sendAchTransBatch(){
        List<ACH_Batch__c> batches = new List<ACH_Batch__c> ();
        for (ACH_Batch__c b : [select id, description__c, Status__c,External_Batch_ID__c,
                                      (select id,External_Transaction_ID__c,Transaction_Amount__c,Repayment__r.Type_of_Account__c,
                                      Repayment__r.Bank_Account_Number__c, Repayment__r.Bank_Routing_Number__c, Repayment__r.Payee_Account__c,
                                      Repayment__r.Payee_Account__r.name,Effective_Date__c, Status__c, Memo__c, Check__c 
                                      From Payments__r where Status__c='Scheduled' and RecordType.Name='Debit' and Repayment__r.Status__c='Active')  
                                      from Ach_Batch__c where status__c='Pending']) {
            if (b.Payments__r != null && !b.Payments__r.isEmpty()) {
                batches.add(b);
            }
            
        }

        /*List<ACH_Batch__c> batches = new List<ACH_Batch__c>([select id, description__c, Status__c,External_Batch_ID__c,
                                      (select id,External_Transaction_ID__c,Transaction_Amount__c,Payment_Setting__r.Type_of_Account__c,
                                      Payment_Setting__r.Bank_Account_Number__c, Payment_Setting__r.Bank_Routing_Number__c, Payment_Setting__r.Payee_Account__c,
                                      Payment_Setting__r.Payee_Account__r.name,Effective_Date__c, Status__c, Memo__c, Check__c 
                                      From Transactions__r where Status__c='Scheduled' and RecordType.Name='Debit' and Payment_Setting__r.Status__c='Active')  
                                      from Ach_Batch__c where status__c='Pending']);*/
        
        //Do nothing if there is no credentials in custom settings.
        if(achCred.size()==0)
            return;
            
        /*Query active transactions for pending batch for today.
        List<ACH_Transaction__c> lstTrans = new List<ACH_Transaction__c>([select id,External_Transaction_ID__c,Transaction_Amount__c,Payment_Setting__r.Type_of_Account__c,
                                                                           Payment_Setting__r.Bank_Account_Number__c, Payment_Setting__r.Bank_Routing_Number__c, Payment_Setting__r.Payee_Account__c,
                                                                           Payment_Setting__r.Payee_Account__r.name,Effective_Date__c, Status__c 
                                                                           From ACH_Transaction__c where Status__c='Scheduled' and RecordType.Name='Debit' and Payment_Setting__r.Status__c='Active']);*/
        
        //Simply return if there is no batch created for today.
        if(batches.size()==0)
            return;       
            
        //Create webservice object.     
        ACHWorksService.ACHWorksWSSoap achsoap = new ACHWorksService.ACHWorksWSSoap();
        
        //Switch webservice endpoints with respect to settings.
        if(achCred[0].name == 'ACH Test')
            achsoap.endpoint_x = 'http://tstsvr.achworks.com/dnet/achws.asmx';
        List<Payment__c> lstTrans = new List<Payment__c>();
        //Create Ach Batch files with adding ach transaction records.
        if(batches.size()>0 && batches.size()<=100){
            for(ACH_Batch__c batch:batches){
                if(batch.Payments__r.size()>0){
                    ACHWorksService.ACHTransRecord myACHTransRecord = new ACHWorksService.ACHTransRecord();
                    ACHWorksService.TransResult myACHTransResult = new ACHWorksService.TransResult();
                    ACHWorksService.ACHTransRecord myACHTransRecord1 = new ACHWorksService.ACHTransRecord();
                    ACHWorksService.ACHTransRecord myACHTransRecord2 = new ACHWorksService.ACHTransRecord();
                    ACHWorksService.ACHFile myACHFile = new ACHWorksService.ACHFile(); 
                    ACHWorksService.CompanyInfo comInfo = new ACHWorksService.CompanyInfo();  
                    comInfo.sss=achCred[0].sss__c;
                    comInfo.locID=achCred[0].LocID__c;
                    comInfo.company=achCred[0].company__c;
                    comInfo.companyKey=achCred[0].companyKey__c;            
                    ACHWorksService.ArrayOfACHTransRecord arrAccRec = new ACHWorksService.ArrayOfACHTransRecord();
                    arrAccRec.ACHTransRecord = new ACHWorksService.ACHTransRecord[batch.Payments__r.size()];
                    Double totalDebitAmount = 0;    
                    Integer i=0;                
                    for(Payment__c trans:batch.Payments__r){            
                        arrAccRec.ACHTransRecord[i] = prepareTransRecord(trans);
                        totalDebitAmount+=trans.Transaction_Amount__c;
                        i++;       
                    }                
                    myACHFile.SSS=achCred[0].sss__c;
                    myACHFile.LocID=achCred[0].LocID__c;
                    myACHFile.ACHFileName='';
                    myACHFile.TotalNumRecords=arrAccRec.ACHTransRecord.size();
                    myACHFile.TotalDebitRecords=arrAccRec.ACHTransRecord.size();
                    myACHFile.TotalDebitAmount=totalDebitAmount;
                    myACHFile.TotalCreditRecords=0;
                    myACHFile.TotalCreditAmount=0;
                    myACHFile.ACHRecords=arrAccRec;
                    
                    //Send transaction batch to ach works.
                    ACHWorksService.TransResult res=achsoap.SendACHTransBatch(comInfo,myACHFile);
                    
                    //Read response and change transactions statuses from Pending to Scheduled.              
                    for(Payment__c trans:batch.Payments__r){ 
                        trans.Status__c = 'Pending';        
                    }  
                    
                    //Update batch with External_Batch_ID__c(XML File name from ach)
                    batch.External_Batch_ID__c=res.Details.substring(res.Details.indexOf('=')+1,res.Details.indexOf(']'));
                    batch.Status__c = res.Status;
                    batch.description__c = res.Details;                    
                    lstTrans.addAll(batch.Payments__r);
                }
            }
            if(lstTrans.size()>0)
                update lstTrans;
            update batches;
        }
    }
    
    //Gets the returns from ach works.
    public static ACHWorksService.ACHReturns getACHReturns(){
        ACHWorksService.CompanyInfo comInfo = new ACHWorksService.CompanyInfo();  
        comInfo.sss=achCred[0].sss__c;
        comInfo.locID=achCred[0].LocID__c;
        comInfo.company=achCred[0].company__c;
        comInfo.companyKey=achCred[0].companyKey__c;
        ACHWorksService.ACHWorksWSSoap achsoap = new ACHWorksService.ACHWorksWSSoap();
        
        if(achCred[0].name == 'ACH Test')
            achsoap.endpoint_x = 'http://tstsvr.achworks.com/dnet/achws.asmx';
        ACHWorksService.ACHReturns ret = achsoap.GetACHReturns(comInfo);
        return ret;
    }
    
    //Gets ach works return history for particular date range.
    public static ACHWorksService.ACHReturns getACHReturnsHist(Datetime fromDate, Datetime toDate){
        ACHWorksService.CompanyInfo comInfo = new ACHWorksService.CompanyInfo();  
        comInfo.sss=achCred[0].sss__c;
        comInfo.locID=achCred[0].LocID__c;
        comInfo.company=achCred[0].company__c;
        comInfo.companyKey=achCred[0].companyKey__c;
        ACHWorksService.ACHWorksWSSoap achsoap = new ACHWorksService.ACHWorksWSSoap();
        if(achCred[0].name == 'ACH Test')
            achsoap.endpoint_x = 'http://tstsvr.achworks.com/dnet/achws.asmx';
        ACHWorksService.ACHReturns ret = achsoap.getACHReturnsHist(comInfo,fromDate,toDate);
        return ret;
    }
    /*public static Achworkscom.ACHReturns getACHReturnsTest(Achworkscom.CompanyInfo comInfo){
        Achworkscom.ACHReturns ret = new Achworkscom.ACHReturns();
        /*ret.SSS='TST';
        ret.LocID='9502';
        ret.Status='SUCCESS';
        ret.Details='Retrieved  14  records on  04/16/2010  04:49:27    PM  Pacific Time.   Server  Processing  Time:<0.0001    ms';
        ret.TotalNumRecords=14;
        return ret;
    }*/
    
    //For tracking returns and settlements.
    @future(callout=true)
    public static void trackTrasactions(){
        system.debug('1');
        ACH_Public_Settings__c settings = ACH_Public_Settings__c.getOrgDefaults();
        ACHWorksService.ACHReturns ret;
        if (settings == null || settings.Last_Tracking_Date__c == null) {
            ret = getACHReturns();
        }
        else {
            system.debug('\n\nhist >>>> \n');
            ret = getACHReturnsHist(settings.Last_Tracking_Date__c.addDays(-5), DateTime.now());
        }
        system.debug('returns >>> ' + ret);
        /*Achworkscom.ACHReturns ret = getACHReturns();
        trackReturns(ret);*/
        
        trackReturns(ret);
        
    }
    
    //For tracking returns and settlements for date range.
    @future(callout=true)
    public static void trackTrasactions(Datetime fromDate, Datetime toDate){
        ACHWorksService.ACHReturns ret = getACHReturnsHist(fromDate,toDate);
        trackReturns(ret);
    }
    
    //This method actually checks returns and updates related transactions with statuses and error info.
    public static void trackReturns(ACHWorksService.ACHReturns returns){  
            ACH_Public_Settings__c settings =   ACH_Public_Settings__c.getOrgDefaults();
        //Do nothing if there are not returns.      
        if(returns.TotalNumRecords == 0)
            return;
            
        //Map to store front end trace and return record.
        Map<String,ACHWorksService.ACHReturnRecord> fetReturnMap = new Map<String,ACHWorksService.ACHReturnRecord>();
        
        //Set to store action details or return codes.
        Set<string> codes = new Set<string>();
        
        Map<String,Schema.RecordTypeInfo> rtMapByName = Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('Debit');
        string recTypeIdDebit = String.valueOf(rtByName.getRecordTypeId());

        rtByName =  rtMapByName.get('Credit');
        string recTypeIdCredit = String.valueOf(rtByName.getRecordTypeId());
        
        //Get record type ids.
        //string recTypeIdDebit = [select id from RecordType where name='Debit' and SobjectType='ACHIT__Ach_Transaction__c'].id;
        //string recTypeIdCredit = [select id from RecordType where name='Credit' and SobjectType='ACHIT__Ach_Transaction__c'].id;
        for(ACHWorksService.ACHReturnRecord ret:returns.ACHReturnRecords.ACHReturnRecord){          
            fetReturnMap.put(ret.FrontEndTrace,ret);
            
            if(ret.ActionDetail!=null && ret.ActionDetail!='')
                codes.add(ret.ActionDetail.trim());
        }
        
        //Query fee settings on the basis of codes.
        List<Bounce_Fees_Settings__c> bfSettings = new List<Bounce_Fees_Settings__c>([select id,Fees__c,Response_Code__c, Description__c  
                                                     from Bounce_Fees_Settings__c where Response_Code__c in:codes]);
        Map<string,Bounce_Fees_Settings__c> resCodeFeesMap = new Map<string,Bounce_Fees_Settings__c>();
        for(Bounce_Fees_Settings__c bfSetting:bfSettings){
            resCodeFeesMap.put(bfSetting.Response_Code__c, bfSetting);
        }       
        List<Ach_Transaction_Log__c> logs = new List<Ach_Transaction_Log__c>();
        List<Payment__c> lstTrans = new List<Payment__c>([select id,Settlement_Date__c,Name,External_Transaction_ID__c,Status__c, Repayment__r.Payee_Account__r.name,Repayment__r.name,
                                                                          Repayment__r.Payee_Account__r.Owner.Email, Repayment__c, Repayment__r.Status__c, 
                                                                          Response_Code__c,Error_Description__c,Effective_Date__c,Error_Code__c,Transaction_Amount__c 
                                                                          from Payment__c where External_Transaction_ID__c!=null and Status__c !='Failed' 
                                                                          and External_Transaction_ID__c in :fetReturnMap.keySet()]);       
        List<Payment__c> lstFees = new List<Payment__c>();
        //List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<String> transactionIds = new Set<String>();
        for (Payment__c t : lstTrans) {
            transactionIds.add(t.Id);
        }
        Map<String, Ach_Transaction_Log__c[]> transactionLogs = queryTransactions(transactionIds);

        for(Payment__c trans:lstTrans){  
            string extId = trans.External_Transaction_ID__c.toUpperCase();            
            if(!fetReturnMap.containsKey(extId))
                continue;
            
            string responseCode = fetReturnMap.get(extId).ResponseCode.trim();
            string actionCode = fetReturnMap.get(extId).ActionDetail!=null?fetReturnMap.get(extId).ActionDetail.trim():null;
            string custTransType = fetReturnMap.get(extId).CustTransType;
            DateTime actionDate = fetReturnMap.get(extId).ActionDate;
            trans.Status__c = (responseCode!='2STL' && responseCode!='1SNT'?'Failed':responseCode=='2STL'?'Settled':'Pending');
            trans.Response_Code__c = responseCode;
            
            //fees calculations
            if(resCodeFeesMap.containsKey(actionCode) && responseCode!='2STL' && responseCode!='1SNT'){             
                Payment__c fee = new Payment__c();
                fee.Repayment__c = trans.Repayment__c;
                fee.Transaction_Amount__c = -Math.abs(resCodeFeesMap.get(actionCode).Fees__c);
                fee.RecordTypeId = custTransType=='D'?recTypeIdDebit:recTypeIdCredit;
                fee.Transaction_Type__c = 'Fee';
                fee.Response_Code__c = responseCode;
                fee.Error_Code__c = actionCode;
                fee.Error_Description__c = resCodeFeesMap.get(actionCode).Description__c;
                fee.Payment__c = trans.id;
                fee.Status__c = 'Fees Applied';
                trans.Error_Code__c = actionCode;
                trans.Error_Description__c = resCodeFeesMap.get(actionCode).Description__c;
                lstFees.add(fee);
                Boolean createLog = true;
                if (trans.Id != null && transactionLogs.containsKey(trans.Id)) {
                    for (Ach_Transaction_Log__c l : transactionLogs.get(trans.Id)) {
                        if (l.Response_Code__c == responseCode) {
                            createLog = false;
                        }
                    }
                }
                
                if (createLog) {
                    Ach_Transaction_Log__c log = new Ach_Transaction_Log__c();              
                    log.Response_Code__c = responseCode;
                    log.Description__c = resCodeFeesMap.get(actionCode).Description__c;
                    log.Error_Code__c = actionCode;
                    log.Log_Date__c = actionDate;
                    log.Payment__c = trans.id;
                    logs.add(log);
                }
                
                
            }
            else{
                if(responseCode=='2STL'){
                    trans.Settlement_Id__c = actionCode.replaceAll('(\\s+)', '');
                    trans.Settlement_Date__c = actionDate;
                    trans.Error_Description__c = String.valueOf(actionDate);
                }
                Boolean createLog = true;
                if (trans.Id != null && transactionLogs.containsKey(trans.Id)) {
                    for (Ach_Transaction_Log__c l : transactionLogs.get(trans.Id)) {
                        if (l.Response_Code__c == responseCode) {
                            createLog = false;
                        }
                    }
                }
                
                if (createLog) {
                    Ach_Transaction_Log__c log = new Ach_Transaction_Log__c();
                    log.Response_Code__c = responseCode;
                    log.Error_Code__c = responseCode=='2STL'?'':actionCode;
                    log.Description__c = actionCode;
                    log.Log_Date__c = actionDate;
                    log.Payment__c = trans.id;
                    logs.add(log);
                }
                
                
            }
            settings.Last_Tracking_Date__c = DateTime.now();
        }
        
        if(lstFees.size()>0) {
            insert lstFees;
            
            
        }
            
        if(lstTrans.size()>0) {
            update lstTrans;
        }
        
        if(logs.size()>0) {
            insert logs;
        }
        
        /*if(emails.size()>0)
            Messaging.sendEmail(emails);
          */  
        upsert settings;
    }

    private static Map<String, Ach_Transaction_Log__c[]> queryTransactions(Set<String> transactionId) {
        Map<String, Ach_Transaction_Log__c[]> transactionLogs = new Map<String, Ach_Transaction_Log__c[]>();
        //ACHIT__ACH_Transaction_Log__c.ACHIT__Response_Code__c
        for (Ach_Transaction_Log__c tlog : [select id, Payment__c, Response_Code__c from Ach_Transaction_Log__c where Payment__c in : transactionId]) {
            if (transactionLogs.containsKey(tlog.Payment__c)) {
                transactionLogs.get(tlog.Payment__c).add(tlog);
            }
            else {
                transactionLogs.put(tlog.Payment__c, new Ach_Transaction_Log__c[] {tlog});
            }
            
        }
        return transactionLogs;
    }
    
    //This method prepares transaction record to be sent to ach works.
    public static ACHWorksService.ACHTransRecord prepareTransRecord(Payment__c trans){
        ACHWorksService.ACHTransRecord achTransRecord = new ACHWorksService.ACHTransRecord();
        achTransRecord.SSS=achCred[0].sss__c;
        achTransRecord.LocID=achCred[0].LocID__c;
        achTransRecord.FrontEndTrace=trans.External_Transaction_ID__c;
        achTransRecord.OriginatorName=UserInfo.getOrganizationName();
        achTransRecord.TransactionCode='CCD';
        achTransRecord.CustTransType='D';
        achTransRecord.CustomerID=trans.Repayment__r.Payee_Account__c;
        achTransRecord.CustomerName=trans.Repayment__r.Payee_Account__r.name;        
        achTransRecord.CustomerRoutingNo=trans.Repayment__r.Bank_Routing_Number__c;
        achTransRecord.CustomerAcctNo=trans.Repayment__r.Bank_Account_Number__c;
        achTransRecord.CustomerAcctType=trans.Repayment__r.Type_of_Account__c=='Savings'?'S':'C';
        achTransRecord.TransAmount=trans.Transaction_Amount__c;
        //achTransRecord.CheckOrCustID=trans.Payment_Setting__r.Payee_Account__c;
        achTransRecord.CheckOrCustID=trans.Check__c;
        achTransRecord.CheckOrTransDate=datetime.now();
        achTransRecord.EffectiveDate=trans.Effective_Date__c;
        //achTransRecord.Memo='CASH ADV';
        achTransRecord.Memo = trans.Memo__c;
        achTransRecord.OpCode='S';
        achTransRecord.AccountSet='1';
        return achTransRecord;
    }
    
    //This methods confirms the validity of account and connection to ach.
    public static string connectionCheck(){
        ACHWorksService.CompanyInfo comInfo = new ACHWorksService.CompanyInfo();  
        comInfo.sss=achCred[0].sss__c;
        comInfo.locID=achCred[0].LocID__c;
        comInfo.company=achCred[0].company__c;
        comInfo.companyKey=achCred[0].companyKey__c;
        ACHWorksService.AchworksWSSoap achsoap = new ACHWorksService.ACHWorksWSSoap(); 
        if(achCred[0].name == 'ACH Test')
            achsoap.endpoint_x = 'http://tstsvr.achworks.com/dnet/achws.asmx';       
        return achsoap.ConnectionCheck(comInfo);
    }
}