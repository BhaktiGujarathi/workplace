global with sharing class RequiredDocument {
    
    public String name;
    public String requiredDocumentId; 
    public String programId;
    
    public RequiredDocument(Required_Documents__c doc) {
    	name = doc.Name;
    	requiredDocumentId = doc.Required_Document_Id__c;
    	programId = doc.Program__c; 
    }
        
}