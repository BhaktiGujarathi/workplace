@isTest
private class CEPayableTriggerHandlerTest {
/*
    //Test Method to test Rollup count onInsert of Payable Record
    static testMethod void testRollupOfPayableOnInsert() {
        
        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = CETestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;
       
       
                
        //Creating Test Payable Records using utility class
        List<McaApp__Payable__c> lstPayable = CETestDataUtility.getPayableRecords(10);
     
        lstPayable.addAll(CETestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(CETestDataUtility.getPayableRecordsForExternalISO(10));
        
        for(McaApp__Payable__c Payable : lstPayable){ 
            Payable.McaApp__Opportunity__c = lstOpportunity[0].Id;
            
        }//End for
        
        //Insert Payable
        Test.startTest();
        insert lstPayable;
        Test.stopTest(); 
        
        
        
    }//End testRollupOfPayableOnInsert
    
    //Test Method to test Rollup count onUpdate of Payable Record
    static testMethod void testRollupOfPayableOnUpdate() {
        
        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = CETestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;
        
        //Creating Test Payable Records using utility class
        List<McaApp__Payable__c> lstPayable = CETestDataUtility.getPayableRecords(10);
        //For Internal/External ISO
        lstPayable.addAll(CETestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(CETestDataUtility.getPayableRecordsForExternalISO(10));
        
        for(McaApp__Payable__c Payable : lstPayable){ 
            Payable.McaApp__Opportunity__c = lstOpportunity[0].Id;
        }//for
        
        //Insert Payable
        insert lstPayable;
        
        //Update Amount of Payable
        for(McaApp__Payable__c Payable : lstPayable){ 
            Payable.McaApp__Amount_Due__c = 40;
        }//for
        
        //Update Payable Records
        Test.startTest();
        update lstPayable;
        Test.stopTest();
        
       
        
    }//End testRollupOfPayableOnUpdate
    
    //Test Method to test Rollup count onDelete of Payable Record
    static testMethod void testRollupOfPayableOnDelete() {
        
        //Creating Test Opportunity Records using utility class
        List<Opportunity> lstOpportunity = CETestDataUtility.getOpportunityRecords(10);
        insert lstOpportunity;
        
        //Creating Test Payable Records using utility class
        List<McaApp__Payable__c> lstPayable = CETestDataUtility.getPayableRecords(10);
        List<McaApp__Payable__c> lstPayableWithNoOpp = CETestDataUtility.getPayableRecords(5);
        //For Internal/External ISO
        lstPayable.addAll(CETestDataUtility.getPayableRecordsForInternalISO(10));
        lstPayable.addAll(CETestDataUtility.getPayableRecordsForExternalISO(10));
        
        for(McaApp__Payable__c Payable : lstPayable){ 
            Payable.McaApp__Opportunity__c = lstOpportunity[0].Id;
        }//End for
        
        //Insert Payable
        insert lstPayable;
        insert lstPayableWithNoOpp;
        
        //Query Payable Record 
        list<McaApp__Payable__c> listPayable = [Select Id,
                                               McaApp__Amount_Due__c,
                                               McaApp__Type__c
                                        From McaApp__Payable__c Where Id = :lstPayable[0].Id];
        list<McaApp__Payable__c> listPayable2 = [Select Id,
                                               McaApp__Amount_Due__c,
                                               McaApp__Type__c
                                        From McaApp__Payable__c Where Id = :lstPayableWithNoOpp[0].Id];         
        //Delete Payable record         
        Test.startTest();
        delete listPayable;
        delete listPayable2;      
        Test.stopTest();  
        
    }//End testRollupOfPayableOnDelete  */
    
}//End PayableTriggerHandlerTest