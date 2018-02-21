public with sharing class CETestDataUtility {
   /* 
    //Populates and returns a list of Opportunity records to be used in test classes
    public static List<Opportunity> getOpportunityRecords(Integer pCount){

        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        for(Integer oppCount = 1; oppCount <= pCount; oppCount++){
        
            lstOpportunity.add(new Opportunity(Name = 'Test Opportunity' + oppCount,
                                               StageName= 'Start Underwriting',
                                               CloseDate = system.today()+ 10));
        }//for
        return lstOpportunity;
    }//End getOpportunityRecords
    
   
    //Populates and returns a list of Payables records to be used in test classes
    public static List<McaApp__Payable__c> getPayableRecords(Integer pCount){

        List<McaApp__Payable__c> lstPayable = new List<McaApp__Payable__c>();
        
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Commission'));
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Bonus'));
                                          
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Origination Fee'));                              
        }//for
        return lstPayable;
    }//End getPayableRecords
    
    
    
    public static List<McaApp__Payable__c> getPayableRecordsForInternalISO(Integer pCount){
        Account tempAccInternalISO = new Account(name = 'Test');
        insert tempAccInternalISO;
       
        List<McaApp__Payable__c> lstPayable = new List<McaApp__Payable__c>();
        
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Commission',McaApp__Account__c = tempAccInternalISO.id));
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Bonus',McaApp__Account__c = tempAccInternalISO.id));
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Origination Fee',McaApp__Account__c = tempAccInternalISO.id));                              
        }//for
        return lstPayable;
    }//End getPayableRecordsForExternalISO
    
    
    public static List<McaApp__Payable__c> getPayableRecordsForExternalISO(Integer pCount){
        
        Account tempAccExternalISO = new Account(name = 'Test');
        insert tempAccExternalISO;
        List<McaApp__Payable__c> lstPayable = new List<McaApp__Payable__c>();
       
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Commission', McaApp__Account__c = tempAccExternalISO.id ));
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Bonus', McaApp__Account__c = tempAccExternalISO.id ));
            lstPayable.add(new McaApp__Payable__c(McaApp__Amount_Due__c = 30.00,
                                          McaApp__Type__c = 'Origination Fee', McaApp__Account__c = tempAccExternalISO.id ));                              
        }//for
        return lstPayable;
    }//End getPayableRecordsForInternalISO
    
    
   */
    
}