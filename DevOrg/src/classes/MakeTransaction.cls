public class MakeTransaction{
    
    public string responseofJSON{get;set;}
    public string frontEndTrace{get;set;} 
    public Boolean showResponse{get;set;}
    public string sSS{get;set;}
    public string locID{get;set;}
    public string status{get;set;}
    public string details{get;set;}
    public Integer totalNumErrors{get;set;}
    public datetime callDateTime{get;set;}
    public double amount{get;set;}
    public string selectedFrequency {get;set;}
    
    public string ConnectionCheckResult;    
    public string CheckCompanyStatusResult;
    
    public void MakeTransaction(){
        showResponse = false;
        this.init();
    }//End MakeTransaction constructor.
    
    
    public void init(){
        system.debug('****Inside Init*****');
        
        AchworksCom.CompanyInfo InpCompanyInfo = new AchworksCom.CompanyInfo();
        InpCompanyInfo.SSS='TST';
        InpCompanyInfo.LocID='9505';
        InpCompanyInfo.Company='THAT COMPANY'; 
        InpCompanyInfo.CompanyKey='RICO';
        //InpCompanyInfo.CompanyKey='SASD%!%$DGLJGWYRRDGDDUDFDESDHDD';
         
        AchworksCom achWorkRecord = new AchworksCom();
        AchworksCom.ACHWorksWSSoap newRec =  new AchworksCom.ACHWorksWSSoap();
        ConnectionCheckResult = newRec.ConnectionCheck(InpCompanyInfo);
        system.debug('****ConnectionCheckResult***' + ConnectionCheckResult);
        
        CheckCompanyStatusResult = newRec.CheckCompanyStatus(InpCompanyInfo);
        system.debug('****CheckCompanyStatusResult***' + CheckCompanyStatusResult);
        
        
        AchworksCom.ACHTransRecord InpACHTransRecord = new AchworksCom.ACHTransRecord();
        
        InpACHTransRecord.SSS = 'TST';
        InpACHTransRecord.LocID = '9505';
        InpACHTransRecord.FrontEndTrace = frontEndTrace; //'J-­-00089'; frontEndTrace
        InpACHTransRecord.OriginatorName = 'MYCOMPANY';
        InpACHTransRecord.TransactionCode = 'PPD';
        InpACHTransRecord.CustTransType = 'C';
        InpACHTransRecord.CustomerID = 'CUSTID123-­-3';
        InpACHTransRecord.CustomerName = 'YOUNG,JOE';
        InpACHTransRecord.CustomerRoutingNo = '987654320';
        InpACHTransRecord.CustomerAcctNo = '00332358882';
        InpACHTransRecord.CustomerAcctType = 'C';
        InpACHTransRecord.TransAmount = amount;
        InpACHTransRecord.CheckOrCustID = '9166388811';
        InpACHTransRecord.CheckOrTransDate = dateTime.newInstanceGmt(2014, 05, 29);//'03/24/2010';
        InpACHTransRecord.EffectiveDate = dateTime.newInstanceGmt(2014, 05, 30);//'03/24/2010';
        //InpACHTransRecord.Memo = selectedFrequency;
        InpACHTransRecord.Memo = 'FirstPay';
        InpACHTransRecord.OpCode = 'R';
        InpACHTransRecord.AccountSet = '1';
        
        AchworksCom.TransResult SendACHTransResult = newRec.SendACHTrans(InpCompanyInfo, InpACHTransRecord);
        system.debug('****SendACHTransResult***' + SendACHTransResult);
        system.debug('****SendACHTransResult Status***' + SendACHTransResult.Status);
        responseofJSON = JSON.serializePretty(SendACHTransResult);
        system.debug('***responseofJSON***' + responseofJSON);
        
        sSS = SendACHTransResult.SSS;
        locID = SendACHTransResult.LocID;
        status = SendACHTransResult.Status;
        details = SendACHTransResult.Details;
        totalNumErrors = SendACHTransResult.TotalNumErrors; 
        callDateTime = SendACHTransResult.CallDateTime;
        String achfileName = SendACHTransResult.FileName;
        
        system.debug('****status ***' + status );
        system.debug('****achfileName***' + achfileName);
        system.debug('****TotalNumErrors***' + SendACHTransResult.TotalNumErrors);
        system.debug('****SendACHTransResult.Errors***' + SendACHTransResult.Errors);
        system.debug('****CallMethod***' + SendACHTransResult.CallMethod);
        if(status == 'SUCCESS'){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Confirm,
                                                      SendACHTransResult.Status + ' One Time payment with ACH performed sucessfully.');
            apexpages.addmessage(msg);  
        }
        else{
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,
                                                      SendACHTransResult.Status + ' One Time payment with ACH Failed.');
            apexpages.addmessage(msg);
        }
        AchworksCom.ACHReturns GetACHReturnsResult = newRec.GetACHReturns(InpCompanyInfo);
        system.debug('****GetACHReturnsResult***' + GetACHReturnsResult);
        showResponse = true;
    }//End init method. GetACHReturns
        
     public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Daily','Daily'));
        options.add(new SelectOption('Weekly','Weekly'));
        options.add(new SelectOption('Monthly','Monthly'));

        return options;
    }     
        
}//End MakeTransaction class.