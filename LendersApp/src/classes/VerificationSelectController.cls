public class VerificationSelectController {

    public List<VerificationMasterWrap> lstVeriMaster {get;set;}
    public String dealId {get;set;}
    public String dealType {get;set;}
    public Boolean displayPopup {get; set;}  
    public VerificationMaster__c objNewVer {get;set;}      
    public Opportunity objDeal {get;set;}     

    public VerificationSelectController (ApexPages.StandardsetController controller) {   

        lstVeriMaster = new List<VerificationMasterWrap>();
        Map<String,String> urlParameters = ApexPages.currentPage().getParameters();
        dealId = '';
        dealType = '';
        objDeal = new Opportunity();
        objNewVer = new VerificationMaster__c ();
        Set<Id> setCurrentVerId = new Set<Id>();                
        
        //Get deal id
        
        for (String key : urlParameters.keyset()) {
        
            if (key.contains('id')) {

                dealId = urlParameters.get(key);
            }        
        }

        //Get all verification master ids FROM which the existing verifications were created
        for (UWVerification__c uw : [SELECT Id,verificationMaster__c FROM UWVerification__c WHERE Opportunity__c = :dealId]) {

            setCurrentVerId.add(uw.verificationMaster__c);
        }
        
        //get all verification list FROM verification master
        for (VerificationMaster__c objVeri : [SELECT Id, Name, Notes__c, Type__c, Stage__c, RecordType.Name, Renewal__c                                                                                        
                                            FROM VerificationMaster__c WHERE Id NOT IN :setCurrentVerId LIMIT 1000]) {

            lstVeriMaster.add(new VerificationMasterWrap(objVeri));
        }                
        
        List<Opportunity> lstDeal = [SELECT Id, ProgramType__c, Underwriting_Stage__c FROM Opportunity WHERE Id = :dealId];

        if (lstDeal != null && lstDeal.size() > 0 && lstDeal[0].ProgramType__c != null) {

            dealType = lstDeal[0].ProgramType__c;
            objDeal = lstDeal[0];
        }
    }
    
    public void SaveAndClose() {     

        objNewVer.OwnerId = UserInfo.getUserId();
        insert objNewVer;         
        VerificationMasterWrap ver = new VerificationMasterWrap(objNewVer);
        ver.selected = true;
        lstVeriMaster.add(ver);
        displayPopup = false;    
        //return null;
    }  
    
    public void CancelNew() {

        displayPopup = false;    
    }       
    
    public Pagereference done() {

        //Get Verification record type by name    
        Schema.DescribeSObjectResult sd = Schema.SObjectType.UWVerification__c;
        Map<String,Schema.RecordTypeInfo>  rtVerMapByName = sd.getRecordTypeInfosByName(); 
        
        List<UWVerification__c> lstVerificationToInsert = new List<UWVerification__c>();
        
        for (VerificationMasterWrap wrap : lstVeriMaster) {

            if (wrap.selected) {

                UWVerification__c objNewVer = new UWVerification__c(Name = wrap.objVer.Name,Status__c = 'Pending', Opportunity__c = dealId,
                                                VerificationMaster__c = wrap.objVer.Id, Notes__c = wrap.objVer.Notes__c);                

                objNewVer.stage__c = objDeal.Underwriting_Stage__c;                
                
                //set record type id

                if (wrap.objVer.recordtype.Name != null && rtVerMapByName.keyset().contains(wrap.objVer.recordtype.Name)) {

                    objNewVer.RecordTypeId = rtVerMapByName.get(wrap.objVer.recordtype.Name).getRecordTypeId();
                }
                
                lstVerificationToInsert.add(objNewVer);
            }
        }

        if (lstVerificationToInsert != null && lstVerificationToInsert.size() > 0) {
            
            insert lstVerificationToInsert;
        }
        else {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Please SELECT atleast one record'));
            return null;            
        }
                
        return new pagereference('/' + dealId);
    }
    
    public void newVerification() {

        //get key prefix
        //string key = Schema.getGlobalDescribe().get('VerificationMaster__c').getDescribe().getKeyPrefix();
        objNewVer = new VerificationMaster__c ();
        objNewVer.Type__c = dealType;
        displayPopup = true;    
        //return new pagereference('/'+key+'/e?retURL=/apex/VerificationsSelect');
    }
    
    
    public class VerificationMasterWrap {
        
        public VerificationMaster__c objVer {get;set;}
        public Boolean selected {get;set;}
        
        public VerificationMasterWrap(VerificationMaster__c v) {

            objVer = v;
            selected = false;
        }
    }
}