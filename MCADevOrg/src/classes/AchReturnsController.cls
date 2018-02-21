public with sharing class AchReturnsController {
    public List<ACHReturnRecord> achReturns{get;set;}
    public List<List<ACHReturnRecord>> achReturnsList{get;set;}
    //public Achworkscom.ACHReturns rets{get;set;}
    public ACHWorksService.ACHReturns rets{get;set;}
    public Integer totalRecords {get;set;}
    public Payment__c trans{get;set;}
    public List<ACHCredentials__c> achCred{get;set;}
    public AchReturnsController(){
        achCred = new List<ACHCredentials__c>([select name from ACHCredentials__c where Active__c=true]);
        achReturns = new List<ACHReturnRecord>();
        achReturnsList = new List<List<ACHReturnRecord>>();          
        totalRecords = 0;   
        trans = new Payment__c();
        trans.Effective_Date__c = datetime.now().date();  
        getAchReturns();        
    }
    public PageReference getAchReturns() { 
        if(trans.Effective_date__c!=null){ 
            date effDate = Date.newInstance(trans.Effective_date__c.year(),trans.Effective_date__c.month(),trans.Effective_date__c.day());
            Datetime fromDate = effDate ;
            Datetime toDate = effDate ;
            rets = AchWorksUtil.getACHReturnsHist(fromDate,toDate);
        }else{   
            //Integer.valueOf('jo');          
            rets = AchWorksUtil.getACHReturns();  
        }      
        totalRecords = rets.TotalNumRecords;
        system.debug(totalRecords);
        if(totalRecords == 0)
            return null;
        Integer i=0;
        //for(Achworkscom.ACHReturnRecord achRet: rets.ACHReturnRecords.ACHReturnRecord){
        for(ACHWorksService.ACHReturnRecord achRet: rets.ACHReturnRecords.ACHReturnRecord){
            ACHReturnRecord rec = new ACHReturnRecord();
            rec.FrontEndTrace = achRet.FrontEndTrace;
            rec.ResponseCode = achRet.ResponseCode;
            rec.EffectiveDate = achRet.EffectiveDate;
            rec.ActionDate = achRet.ActionDate;
            rec.ActionDetail = achRet.ActionDetail;
            rec.TransAmount = achRet.TransAmount;
            rec.CustomerName = achRet.CustomerName;
            rec.SourceFile = achRet.SourceFile;
            achReturns.add(rec);            
        }        
        return null;
    }
    public PageReference syncReturns(){
        AchWorksUtil.trackReturns(rets);
        return null;
    }
    public class ACHReturnRecord {
        public String SSS{get;set;}
        public String LocID{get;set;}
        public String SourceFile{get;set;}
        public String FrontEndTrace{get;set;}
        public String ResponseCode{get;set;}
        public String CustTransType{get;set;}
        public String BackEndSN{get;set;}
        public String CustomerName{get;set;}
        public Double TransAmount{get;set;}
        public DateTime EffectiveDate{get;set;}
        public DateTime ActionDate{get;set;}
        public String ActionDetail{get;set;}
    }
}