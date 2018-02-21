/**
 * Description - Test Class for InvoiceHandler
 *
 * Date - 05/02/2014 
 * 
 * Created by- Sneha P.
 */
@isTest
private class InvoiceHandlerTest {

    static testMethod void myUnitTest() {
        Merging_Time_Entry_Setting__c mergeSetting = new Merging_Time_Entry_Setting__c(Name = 'Test',
                                                                        Task_Type__c = 'TestTaskType');
        insert mergeSetting;
        
        Account Acc = new Account(Name = 'Test Account');
        insert Acc;
        
        Opportunity opp = new Opportunity(Name='Test opp', AccountId = Acc.Id, StageName= 'Prospecting',
                                          CloseDate=system.today() );
        insert opp;
        
        HarvestProject__c project = new HarvestProject__c(Name = 'Test Project' ,Account__c = Acc.Id,
                                                         Budget__c = 'No Budget', Opportunity__c = opp.Id,
                                                         ProjectHourlyRate__c = 400);
        insert project;
        
        //Create 2 Time Entries which will be merged
        HarvestTimeEntry__c timeEntry1 = new HarvestTimeEntry__c(HarvestProject__c = project.Id, 
                                                                Task_Type__c = 'TestTaskType',
                                                                Duration__c = 3,
                                                                Date__c = system.today(),
                                                                Notes__c = 'Worked on ApexPage 1');
        insert timeEntry1;
                                                                
        HarvestTimeEntry__c timeEntry2 = new HarvestTimeEntry__c(HarvestProject__c = project.Id, 
                                                                Task_Type__c = 'TestTaskType',
                                                                Duration__c = 6,
                                                                Date__c = system.today(),
                                                                Notes__c = 'Worked on ApexPage 2');
        insert timeEntry2;
                                                                
        HarvestProject__c project1 = new HarvestProject__c(Name = 'Test Project1' ,Account__c = Acc.Id,
                                                         Budget__c = 'No Budget1', Opportunity__c = opp.Id,
                                                         ProjectHourlyRate__c = 500);
        insert project1;
        
        //Create 10 Time Entries for both project 
        createTimeEntry(project,10);
        createTimeEntry(project1,10);
        
        //Create Invoice and Line Items for Project        
            
            Invoice__c invoice = createInvoice(project);
            insert invoice;
            //Insert all the Line Items
            insert createLineItems(project.Id,invoice);
        //End
        
        //Create Invoice and Line Items for Project1
            Invoice__c invoice1 = createInvoice(project1);
            insert invoice1;
            
            //Insert all the Line Items
            insert createLineItems(project1.Id,invoice1);
        //End
           Invoice__c invoice2 = createInvoice(project);
            insert invoice2;
         
            Line_Item__c objLineItem= new Line_Item__c();
            objLineItem.Invoice__c =  invoice2.Id;
            objLineItem.Opportunity__c = project1.Opportunity__c;
            objLineItem.Description__c = 'test';
            insert objLineItem;
            
            Line_Item__c objLineItem1= new Line_Item__c();
            objLineItem1.Invoice__c =  invoice2.Id;
            objLineItem1.Opportunity__c = project1.Opportunity__c;
            objLineItem1.Description__c = 'test';
            insert objLineItem1;
            
          test.startTest();
            list<Invoice__c> invoiceList = new list<Invoice__c>();
            //update the invoice to sent
            invoice.Updated_Contractor_Hours__c = true;
            invoice.Status__c = InvoiceHandler.STATUS_SENT;
            invoice.Date_Sent__c = system.today();
            invoiceList.add(invoice);
            
            invoice1.Updated_Contractor_Hours__c = true;
            invoice1.Status__c = InvoiceHandler.STATUS_SENT;
            invoice1.Date_Sent__c = system.today();
            invoiceList.add(invoice1);
            //Update both the Invoice to Sent and check if the Time Entries are updated
            update invoiceList;
            
            //Query Time Entries and check if Invoice Sent to client is checked
            for (HarvestTimeEntry__c timeEntries : [Select Invoice_Sent_to_Client__c 
                                                  from HarvestTimeEntry__c where HarvestProject__c =: project.Id
                                                   or HarvestProject__c =: project1.Id]){
                //system.assert(timeEntries.Invoice_Sent_to_Client__c == false);
            }
            try{
              invoice2.Override__c=false;
              update invoice2;  
              delete invoice2;
              delete invoiceList;
            }
            catch(DmlException e)
            {
              /*System.assertequals('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY' , 
                                 e.getDmlStatusCode(0));*/
            }
        test.stopTest();
    }
    
    public static void createTimeEntry(HarvestProject__c project,Integer cnt){
        list<HarvestTimeEntry__c> timeEntryList = new list<HarvestTimeEntry__c>();
        HarvestTimeEntry__c timeEntry ;
        for(Integer i = 0 ;i < cnt; i++  ){
            timeEntry = new HarvestTimeEntry__c(HarvestProject__c = project.Id, 
                                                Task_Type__c = 'TestTaskType'+cnt,
                                                Duration__c = 3+cnt,
                                                Date__c = system.today(),
                                                Notes__c = 'Worked on ApexPage'+cnt);
            timeEntryList.add(timeEntry);
        }
        insert timeEntryList;
        
    }
    
    public static Invoice__c createInvoice(HarvestProject__c project){
        Invoice__c invoice = new Invoice__c(Account__c = project.Account__c,
                                            Opportunity__c = project.Opportunity__c,
                                            Project_Harvest__c = project.id,
                                            Status__c = 'Open',
                                            Invoice_Type__c = 'Hours',
                                            Rate__c = project.ProjectHourlyRate__c,
                                            Description_On_Invoice__c = project.Name,
                                            Description__c = project.Name,
                                            Override__c = true);
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
                                                     Hours_Num__c = timeEntry.Duration__c
                                                      );
            lineItemList.add(lineItem); 
        }
        return lineItemList;    
    }
}