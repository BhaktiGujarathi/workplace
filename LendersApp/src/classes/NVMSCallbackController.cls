public class NVMSCallbackController{
    public NVMSCallbackController(){
        System.debug('=================== ' + ApexPages.currentPage().getparameters());
    }
    
    Public PageReference updateOpportunitySetting(){
        String jobId = ApexPages.currentPage().getparameters().get('jobID');
        if(jobId != null && jobId.trim() != ''){
            NVMS_Configuration__c config = new NVMS_Configuration__c();
            config.name = jobId;
            config.value__c = 'Opportunity';
            insert config;
            
            
			List<Opportunity> oppList = [Select id from Opportunity where orderNumber__c = :jobId];
            if(oppList != null && !oppList.isEmpty()){
            	ApexPages.StandardController cont = new ApexPages.StandardController(oppList[0]); 
            	NVMSOrderFormExtension ext = new NVMSOrderFormExtension(cont);
				return ext.AttachOrderPDFDocument();
            }
        }
        return null;
    }
}