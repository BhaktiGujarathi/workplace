/* 
 * Utility class for populating and returning single / multiple records for the specified Sobject 
 * which would be used as test data for Test classes. Ensures single point of test data creation for 
 * all test classes on this org.
 *
 * Version     Author               	  Date              Comments
 * 1.0         Nachiket R. Deshpande      04/11/2014        Initial Draft
 */

public with sharing class TestDataUtility {
	
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
    
    //Populates and returns a list of Receivable records to be used in test classes
    public static List<Receivable__c> getReceivableRecords(Integer pCount){

        List<Receivable__c> lstReceivable = new List<Receivable__c>();
        
        for(Integer receivableCount = 1; receivableCount <= pCount; receivableCount++){
        
            lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Type__c = 'Commission'));
            
            lstReceivable.add(new Receivable__c(Amount__c = 30.00,
                                                Type__c = 'Bonus'));
                                                
        }//for
        return lstReceivable;
    }//End getReceivableRecords
    
    //Populates and returns a list of Payables records to be used in test classes
    public static List<Payable__c> getPayableRecords(Integer pCount){

        List<Payable__c> lstPayable = new List<Payable__c>();
        
        for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Commission'));
       // }
       // for(Integer payableCount = 1; payableCount <= pCount; payableCount++){
        	
            lstPayable.add(new Payable__c(Amount_Due__c = 30.00,
                                          Type__c = 'Bonus'));
        }//for
        return lstPayable;
    }//End getPayableRecords
    
    //Populates and returns a list of Campaign records to be used in test classes
    public static List<Campaign> getCampaignRecords(Integer pCount){

   	    List<Campaign> lstCampaign = new List<Campaign>();
   	    
   	    for(Integer campCount = 1; campCount <= pCount; campCount++){
        
            lstCampaign.add(new Campaign( Name = 'Test Campaign' + campCount,
                                          IsActive= True));
   	    }//for
   	    return lstCampaign;
    }//End getCampaignRecords

}