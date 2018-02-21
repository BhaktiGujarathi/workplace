/* 
 *  Description -  Test Class for OpportunityTriggerHandler
 *
 *  Version     Author                 Date              Description
 *  1.0         Nachiket R. Deshpande  10/11/2014        Initial Draft
 *                                                          
 */
 
@isTest
private class CalculateRollupOnCampaignTest {

   
    
   /* static testMethod void testRollUpOfCampaignOnAfterInsert() {
    	
    	//Creating Test Campaign Records using utility class
        List<Campaign> lstCampaign = TestDataUtility.getCampaignRecords(200);
        insert lstCampaign;
        
        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        for(Opportunity objOpp : lstOpportunity ){
        	objOpp.CampaignId = lstCampaign[0].Id;
        }
        
        //Insert Opportunity Record
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
       
        List<Campaign> listCampaign = [Select Id,
                                              Total_Commissions_Receivable__c,
                                              Total_Receivables__c,
                                              Total_Commissions_Payable__c,
                                              Total_Payables__c
                                       From Campaign Where Id =: lstOpportunity[0].CampaignId];
                                            
        //Asserts to check Rollup of Amount on Opportunity by Payable
        system.assertEquals(listCampaign[0].Total_Commissions_Receivable__c, 0);
        system.assertEquals(listCampaign[0].Total_Receivables__c, 0);
        system.assertEquals(listCampaign[0].Total_Commissions_Payable__c, 0);
        system.assertEquals(listCampaign[0].Total_Payables__c, 0);
    }
    */
    static testMethod void testRollUpOfCampaignOnUpdate() {
    	
    	//Creating Test Campaign Records using utility class
        List<Campaign> lstCampaign = TestDataUtility.getCampaignRecords(900);
        insert lstCampaign;
        
        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(900);
        for(Opportunity objOpp : lstOpportunity ){
        	objOpp.CampaignId = lstCampaign[0].Id;
        }
        
        test.starttest();
        insert lstOpportunity;
        test.stoptest();
        system.debug('****lstOpportunity****'+lstOpportunity.size());

        List<Opportunity> listOpportunityToCheckBeforeInsert = [Select Id,
			                                              Total_Commissions_Receivable__c,
			                                              Total_Receivables__c,
			                                              Total_Commissions_Payable__c,
			                                              Total_Payables__c 
                                       From Opportunity Where Id =: lstOpportunity[0].Id];

        system.debug('****listOpportunityToCheckBeforeInsert****'+listOpportunityToCheckBeforeInsert.size());
        
        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(1200);
        
        for(Payable__c Payable : lstPayable){ 
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//End for
        
        //Insert Payable records
        insert lstPayable;
        system.debug('****lstPayable****'+lstPayable.size());
        
                //Creating Test Receivable Records using utility class
        /*List<Receivable__c> lstReceivable = TestDataUtility.getReceivableRecords(900);
        
        for(Receivable__c receivable : lstReceivable){ 
            receivable.Opportunity__c = lstOpportunity[0].Id;
        }//End for
        
        //Insert Receivable records
        insert lstReceivable;
        */
        //system.debug('****lstReceivable****'+lstReceivable.size());
        
        system.debug('****lstOpportunity befor update****'+lstOpportunity.size());
        
        List<Opportunity> listOpportunityToCheckAfterInsert = [Select Id,
			                                              Total_Commissions_Receivable__c,
			                                              Total_Receivables__c,
			                                              Total_Commissions_Payable__c,
			                                              Total_Payables__c
                                       From Opportunity Where Id =: lstOpportunity[0].Id];

        system.debug('****listOpportunityToCheckAfterInsert****'+listOpportunityToCheckAfterInsert.size());

        List<Campaign> listCampaign = [Select Id,
                                              Total_Commissions_Receivable__c,
                                              Total_Receivables__c,
                                              Total_Commissions_Payable__c,
                                              Total_Payables__c
                                       From Campaign Where Id =: lstOpportunity[0].CampaignId];
       	system.debug('****listCampaign after update****'+listCampaign.size());                                     
        //Asserts to check Rollup of Amount on Campaign 
        system.assertEquals(listCampaign[0].Total_Commissions_Receivable__c, 27000);
        system.assertEquals(listCampaign[0].Total_Receivables__c, 54000);
        system.assertEquals(listCampaign[0].Total_Commissions_Payable__c, 27000);
        system.assertEquals(listCampaign[0].Total_Payables__c, 54000);
        
    }
    
    //Test Method to test Rollup count On Campaign onDelete of  Record
    /*static testMethod void testRollupOfCampaignOnDelete() {
    	
    	//Creating Test Campaign Records using utility class
        List<Campaign> lstCampaign = TestDataUtility.getCampaignRecords(200);
        insert lstCampaign;
        
    	//Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        for(Opportunity objOpp : lstOpportunity ){
        	objOpp.CampaignId = lstCampaign[0].Id;
        }
        insert lstOpportunity;
        
        //Creating Test Receivable Records using utility class
        List<Receivable__c> lstReceivable = TestDataUtility.getReceivableRecords(200);
        
        for(Receivable__c receivable : lstReceivable){ 
            receivable.Opportunity__c = lstOpportunity[0].Id;
            receivable.Opportunity__c = lstOpportunity[1].Id;
        }//End for
        
        //Insert Receivable records
        insert lstReceivable;
        
        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(200);
        
        for(Payable__c Payable : lstPayable){ 
            Payable.Opportunity__c = lstOpportunity[0].Id;
            Payable.Opportunity__c = lstOpportunity[1].Id;
        }//End for
        
        //Insert Payable records
        insert lstPayable;
        
        for(Opportunity objOpp : lstOpportunity ){
        	objOpp.CampaignId = lstCampaign[0].Id;
        }
        
        //Delete opportunity Record
        Test.startTest();
        delete lstOpportunity[0];
        Test.stopTest();
      
        //Query Total Commission Payable and Total Receivable, Total Payable , Total Commission Payable from Campaign
        List<Campaign> listCampaign = [Select Id,
                                              Total_Commissions_Receivable__c,
                                              Total_Receivables__c,
                                              Total_Commissions_Payable__c,
                                              Total_Payables__c
                                       From Campaign Where Id =: lstOpportunity[0].CampaignId];
        
        //Asserts to check Rollup of Amount on Campaign
        system.assertEquals(listCampaign[0].Total_Commissions_Receivable__c, 6000);
        system.assertEquals(listCampaign[0].Total_Receivables__c, 6000);
        system.assertEquals(listCampaign[0].Total_Commissions_Payable__c, 6000);
        system.assertEquals(listCampaign[0].Total_Payables__c, 12000);
        
    }//End testRollupOfCampaignOnDelete
    */
    //Test Method to test Rollup count On Campaign onDelete of  Record
   /* static testMethod void testRollupOfCampaignOnNoOpportunity() {
    	
    	//Creating Test Campaign Records using utility class
        List<Campaign> lstCampaign = TestDataUtility.getCampaignRecords(200);
        insert lstCampaign;
        
    	//Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        for(Opportunity objOpp : lstOpportunity ){
        	objOpp.CampaignId = lstCampaign[0].Id;
        }
        insert lstOpportunity;
        
        for(Opportunity objOpp : lstOpportunity ){
        	objOpp.CampaignId = null;
        }
        
        //Update opportunity Records
        Test.startTest();
        update lstOpportunity;
        Test.stopTest();
      
        //Query Total Commission Payable and Total Receivable, Total Payable , Total Commission Payable from Campaign
        List<Campaign> listCampaign = [Select Id,
                                              Total_Commissions_Receivable__c,
                                              Total_Receivables__c,
                                              Total_Commissions_Payable__c,
                                              Total_Payables__c
                                       From Campaign Where Id =: lstCampaign[0].Id];
                                            
        //Asserts to check Rollup of Amount on Campaign
        system.assertEquals(listCampaign[0].Total_Commissions_Receivable__c, 0.00);
        system.assertEquals(listCampaign[0].Total_Receivables__c, 0.00);
        system.assertEquals(listCampaign[0].Total_Commissions_Payable__c, 0.00);
        system.assertEquals(listCampaign[0].Total_Payables__c, 0.00);
        
    }//End testRollupOfCampaignOnDelete
    */
}//CalculateRollupOnCampaignTest