public with sharing class IntegrationSetupController {
    public ACHCredentials__c credential { get; set; }
    public String mode { get; set; }
    
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
    
    public IntegrationSetupController() {
    	mode = 'list';
    	
    }
    
    public ACHCredentials__c[] getCredentials() {
        ACHCredentials__c[] credentials = new ACHCredentials__c[]{};
        
        for (ACHCredentials__c credential : ACHCredentials__c.getAll().values()) {
            credentials.add(credential);
        }
        
        return credentials;        
    }
    
    
    
    public String getSubtitle() {
        if (mode == 'new') {
            return ((credential.Id == null) ? 'New ' : 'Edit ') + 'Integration Setup';
        }
        else {
            return 'Home';
        }
    }
    
    
    
    public void newSetup() {
    	mode = 'new';
    	credential = new ACHCredentials__c();
    }
    
    
    
    public void save() {
    	try {
    	   upsert credential;	
    	   mode = 'list';
    	} 
    	catch (Exception ex) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
    	}
    }
    
    
    
    public void edit() {
    	credential = ACHCredentials__c.getInstance(ApexPages.currentPage().getParameters().get('bank'));
    	if (credential != null) {
            mode = 'new';
        }
    }
    
    
    
    public void deleteIntegration() {
    	credential = ACHCredentials__c.getInstance(ApexPages.currentPage().getParameters().get('bank'));
        if (credential != null) {
            try {
                delete credential;
            }
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }       
        }
    }
    
    
    
    public void cancel() {
    	mode = 'list';
    }
    
}