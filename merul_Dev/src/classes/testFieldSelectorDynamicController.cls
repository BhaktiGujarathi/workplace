public class testFieldSelectorDynamicController {
    public String fieldName{get;set;}
    public String objectName{get;set;}
    Public Map<String,Schema.SObjectType> schemaCall = Schema.getGlobalDescribe();
    Public sObject sObjectName{get;set;}
    
    
    
    public PageReference onload() {
    
       sObjectName = schemaCall.get('Opportunity').newSObject();
       fieldName='infydisdespune__DeliveryInstallationStatus__c';
       
       return null;
    }

    public PageReference save() {
       String s=''+sObjectName.get(fieldName);
       system.debug('%%%%%%%%'+s);
       
       
       return null;
    }


}