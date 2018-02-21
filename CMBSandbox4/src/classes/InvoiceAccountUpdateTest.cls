/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InvoiceAccountUpdateTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account Acc = new Account(Name = 'Test Account');
        insert Acc;
        
        Account Acc1 = new Account(Name = 'Test Account');
        insert Acc1;
        
        Contact con = new Contact(LastName = 'Test',
                                  AccountId = Acc.Id,
                                  Contact_Type__c = 'Vendor',
                                  Tip_of_The_Week__c = 'Removed by CMB');
        insert con;
        
        Contact con1 = new Contact(LastName = 'Test',
                                  AccountId = Acc1.Id,
                                  Contact_Type__c = 'Vendor',
                                  Tip_of_The_Week__c = 'Removed by CMB');
        insert con1;
        
        Opportunity opp = new Opportunity(Name='Test opp', AccountId = Acc.Id, StageName= 'Prospecting',
                                          CloseDate=system.today() );
        insert opp;
        
        Opportunity opp1 = new Opportunity(Name='Test opp', AccountId = Acc1.Id, StageName= 'Prospecting',
                                          CloseDate=system.today() );
        insert opp1;
        
        Invoice__c invoice = createInvoice(Acc, opp, con);
        insert invoice;
        
        invoice.Account__c = Acc1.Id;
        invoice.Billing_Contact__c = con1.Id;
        invoice.Opportunity__c = opp1.id;
        invoice.Hours__c = 20;
        checkRecursive.runBefore = true;
        update invoice;
        
        checkRecursive.runBefore = true;
        delete invoice;
        
    }
    
    public static Invoice__c createInvoice(Account Acc, Opportunity opp, Contact con){
        Invoice__c invoice = new Invoice__c(Account__c = Acc.Id,
                                            Opportunity__c = opp.Id,
                                            Billing_Contact__c = con.Id,
                                            Status__c = 'Open',
                                            Invoice_Type__c = 'Hours',
                                            Rate__c = 10,
                                            Description__c = 'test',
                                            Hours__c = 10,
                                            Override__c = true,
                                            Terms__c ='Net 15',
                                            Adjustment__c = 10
                                            );
        return invoice; 
    }
    
    public static list<Line_Item__c> createLineItems(Id projectId,Invoice__c invoice ){
        
        list<Line_Item__c> lineItemList = new list<Line_Item__c>();
        Line_Item__c lineItem;
        
        for(HarvestTimeEntry__c  timeEntry : [Select Task_Type__c,Notes__c,Date__c,Duration__c 
                                              from HarvestTimeEntry__c where HarvestProject__c =: projectId]){
            lineItem = new Line_Item__c(Task_Type__c = timeEntry.Task_Type__c,
                                                     Task_Harvest__c = timeEntry.Task_Type__c,
                                                     Invoice__c =  invoice.Id,
                                                     Time_Entry__c = timeEntry.Id,
                                                     Opportunity__c = invoice.Opportunity__c,
                                                     Description__c = timeEntry.Notes__c,
                                                     Date__c = timeEntry.Date__c,
                                                     Hours_Num__c = timeEntry.Duration__c,
                                                     Finish__c = System.today() + 1,
                                                     Start__c = System.today(),
                                                     Credit_Hrs__c = 30
                                                      );
            lineItemList.add(lineItem); 
        }
        return lineItemList;
    }
        public static list<Transaction_Line_Credit__c> createTransLineCredit( Transaction__c trans , Invoice__c invoice ){
            list<Transaction_Line_Credit__c> transLineCreditList = new list<Transaction_Line_Credit__c>(); 
            Transaction_Line_Credit__c transLineCredit;
            for(Integer i=0;i<5;i++){
                    transLineCredit = new Transaction_Line_Credit__c (
                                                                      Invoice__c = invoice.Id,
                                                                      Date__c = System.today(),
                                                                      Transaction__c = trans.Id,
                                                                      Amount__c = 00
                                                                      );
                    
                    transLineCreditList.add(transLineCredit);
            }
            return transLineCreditList;
    }
}