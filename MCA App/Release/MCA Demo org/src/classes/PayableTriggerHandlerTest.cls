/* 
 *  Description -  Test Class for PayableTriggerHandler
 *
 *  Version     Author                 Date              Description
 *  1.0         Nachiket R. Deshpande  04/11/2014        Initial Draft
 *                                                          
 */


@isTest
private class PayableTriggerHandlerTest {

    //Test Method to test Rollup count onInsert of Payable Record
    static testMethod void testRollupOfPayableOnInsert() {
    	
    	//Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;
        
        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(200);
        
        for(Payable__c Payable : lstPayable){ 
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//End for
        
        //Insert Payable
        Test.startTest();
        insert lstPayable;
        Test.stopTest(); 
        
        //Query Total Commission Payable and Total Payable from Opportunity
        List<Opportunity> listOpportunity = [Select Id,
                                                    Total_Commissions_Payable__c,
                                                    Total_Payables__c
                                             From Opportunity Where Id = :lstOpportunity[0].Id];
                                            
        //Asserts to check Rollup of Amount on Opportunity by Payable
        system.assertEquals(listOpportunity[0].Total_Commissions_Payable__c, 6000);
        system.assertEquals(listOpportunity[0].Total_Payables__c, 12000);
        
    }//End testRollupOfPayableOnInsert
    
    //Test Method to test Rollup count onUpdate of Payable Record
    static testMethod void testRollupOfPayableOnUpdate() {
    	
    	//Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;
        
        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(200);
        
        for(Payable__c Payable : lstPayable){ 
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//for
        
        //Insert Payable
        insert lstPayable;
        
        //Update Amount of Payable
        for(Payable__c Payable : lstPayable){ 
            Payable.Amount_Due__c = 40;
        }//for
        
        //Update Payable Records
        Test.startTest();
        update lstPayable;
        Test.stopTest();
        
        //Query Total Commission Payable and Total Payable from Opportunity
        List<Opportunity> listOpportunity = [Select Id,
                                                    Total_Commissions_Payable__c,
                                                    Total_Payables__c
                                             From Opportunity Where Id = :lstOpportunity[0].Id];
                                            
        //Asserts to check Rollup of Amount on Opportunity by Payable
        system.assertEquals(listOpportunity[0].Total_Commissions_Payable__c, 8000);
        system.assertEquals(listOpportunity[0].Total_Payables__c, 16000);
        
    }//End testRollupOfPayableOnUpdate
    
    //Test Method to test Rollup count onDelete of Payable Record
    static testMethod void testRollupOfPayableOnDelete() {
    	
    	//Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = TestDataUtility.getOpportunityRecords(200);
        insert lstOpportunity;
        
        //Creating Test Payable Records using utility class
        List<Payable__c> lstPayable = TestDataUtility.getPayableRecords(200);
        
        for(Payable__c Payable : lstPayable){ 
            Payable.Opportunity__c = lstOpportunity[0].Id;
        }//End for
        
        //Insert Payable
        insert lstPayable;
        
        //Query Payable Record 
        list<Payable__c> listPayable = [Select Id,
        									   Amount_Due__c,
        									   Type__c
        							    From Payable__c Where Id = :lstPayable[0].Id];
        //Delete Payable record	
        Test.startTest();
        delete listPayable;
        Test.stopTest();
        //Query Total Commission Payable and Total Payable from Opportunity
        List<Opportunity> listOpportunity = [Select Id,
                                                    Total_Commissions_Payable__c,
                                                    Total_Payables__c
                                             From Opportunity Where Id = :lstOpportunity[0].Id];
                                            
        //Asserts to check Rollup of Amount on Opportunity by Payable
        system.assertEquals(listOpportunity[0].Total_Commissions_Payable__c, 5970);
        system.assertEquals(listOpportunity[0].Total_Payables__c, 11970);
        
    }//End testRollupOfPayableOnDelete
}//End PayableTriggerHandlerTest