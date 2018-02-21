/* Description - Test Class for LineItemHandler
 * 
 *  Created By - Sneha P.
 * 
 *  Date - 13/01/2014
 *
 */
@isTest
public with sharing class LineItemHandlerTest {
    @isTest
    private static void LineItemHandlerTest() {
        //Create CS record
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
                                                         ProjectHourlyRate__c = 22);
        insert project;
        
        HarvestTimeEntry__c timeEntry = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'TestTaskType',
                                                                Duration__c = 3,Date__c = system.today(),
                                                                Notes__c = 'Worked on ApexPage');
        insert timeEntry;
        
        HarvestTimeEntry__c timeEntry1 = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'TestTaskType',
                                                                Duration__c = 4,Date__c = system.today(),
                                                                Notes__c = 'Worked on testClass');
        insert timeEntry1;
        HarvestTimeEntry__c timeEntry3 = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'TestTaskType',
                                                                Duration__c = 4,Date__c = system.today(),
                                                                Notes__c = 'Worked on testClass');
        insert timeEntry3;
        
        // create invoice and Line Item for the above Project and Time Entries
        Invoice__c invoice = new Invoice__c(Account__c = Acc.Id,Opportunity__c = opp.Id,
                                                Harvest_Project__c = project.id,Status__c = 'Open',
                                                Invoice_Type__c = 'Hours',  Rate__c = project.ProjectHourlyRate__c, Override__c=true);
        insert invoice;
        
        Line_Item__c lineItem = new Line_Item__c(Contractor__c = timeEntry.Developer_Company__c,Task_Type__c = timeEntry.Task_Type__c,
                                                     Task_Harvest__c = timeEntry.Task_Type__c,
                                                     Invoice__c =  invoice.Id,
                                                     Time_Entry__c = timeEntry.Id,
                                                     Developer_Name__c = timeEntry.Developer_Name__c ,
                                                     Opportunity__c = invoice.Opportunity__c,
                                                     Description__c =timeEntry.Notes__c,
                                                     Date__c = timeEntry.Date__c,
                                                     Hours_Num__c = timeEntry.Duration__c,
                                                     Credit_Reason__c='Deposit/PrePaid',
                                                     Credit_Hrs__c = 200);
        
        Line_Item__c lineItem1 = new Line_Item__c(Contractor__c = timeEntry1.Developer_Company__c,Task_Type__c = timeEntry1.Task_Type__c,
                                                     Task_Harvest__c = timeEntry1.Task_Type__c,
                                                     Invoice__c =  invoice.Id,
                                                     Time_Entry__c = timeEntry1.Id,
                                                     Developer_Name__c = timeEntry1.Developer_Name__c ,
                                                     Opportunity__c = invoice.Opportunity__c,
                                                     Description__c =timeEntry1.Notes__c,
                                                     Date__c = timeEntry1.Date__c, Hours_Num__c = timeEntry1.Duration__c,
                                                     Credit_Reason__c='Deposit/PrePaid',
                                                     Credit_Hrs__c = 300);
                                                     
        Line_Item__c lineItem2 = new Line_Item__c(Date__c = System.today() ,Opportunity__c = invoice.Opportunity__c,
                                                    Invoice__c =  invoice.Id, Description__c='Test',Credit_Hrs__c=10);
                                                    
        insert lineItem2;
        
         lineItem2.Time_Entry__c  = timeEntry3.Id;
         update lineItem2;     
        
        list<Line_Item__c> lstLineItems = new list<Line_Item__c>();
        lstLineItems.add(lineItem);
        lstLineItems.add(lineItem1);
        
        
        
        test.startTest();
        insert lstLineItems;
        
                
            //Query the Line Item to check harvest(project) is populated
            lineItem = [Select Id,HarvestProject__c,Credit_Hrs__c from Line_Item__c where Time_Entry__c =: timeEntry.Id];
            lineItem1 = [Select Id,HarvestProject__c,Credit_Hrs__c from Line_Item__c where Time_Entry__c =: timeEntry1.Id];
            
            system.assert(timeEntry.HarvestProject__c == lineItem.HarvestProject__c);
            system.assert(timeEntry1.HarvestProject__c == lineItem1.HarvestProject__c);
                
                
            
            
            
            timeEntry = [Select Id,Credit_Hrs__c 
                         from HarvestTimeEntry__c where ID =:  timeEntry.Id];
            timeEntry1 = [Select Id,Credit_Hrs__c
                          from HarvestTimeEntry__c where ID =:  timeEntry1.Id];
            
            system.assert(timeEntry.Credit_Hrs__c == lineItem.Credit_Hrs__c);
            system.assert(timeEntry1.Credit_Hrs__c == lineItem1.Credit_Hrs__c);
            
            
            //Update the Credit hrs of Line Item and check if the timeEntries Credit hrs are updated
            
            lstLineItems.clear();
            lineItem.Credit_Hrs__c = 80;
            lstLineItems.add(lineItem);
            lineItem1.Credit_Hrs__c = 100;
            lstLineItems.add(lineItem1);
            
            update lstLineItems;
            
            timeEntry = [Select Id,Credit_Hrs__c,Credit_Reason__c,
                                Invoiced_by_CMB__c,Invoiced_Time_Entry__c 
                         from HarvestTimeEntry__c where ID =:  timeEntry.Id];
            timeEntry1 = [Select Id,Credit_Hrs__c,Credit_Reason__c,
                                 Invoiced_by_CMB__c,Invoiced_Time_Entry__c
                          from HarvestTimeEntry__c where ID =:  timeEntry1.Id];
            
            system.assert(timeEntry.Credit_Hrs__c == lineItem.Credit_Hrs__c);
            system.assert(timeEntry1.Credit_Hrs__c == lineItem1.Credit_Hrs__c);
            
            timeEntry.Invoiced_by_CMB__c = true;
            update timeEntry;
            timeEntry1.Invoiced_by_CMB__c = true;
            timeEntry1.Invoiced_Time_Entry__c = timeEntry.Id;
            timeEntry1.Credit_Reason__c = 'Multiple Entries for the Task Type';
            update timeEntry1;
            
            lineItem1.Time_Entry__c = null;
            update lineItem1;
            
            lineItem1 = [Select Id, HarvestProject__c,Credit_Hrs__c from Line_Item__c where Id=: lineItem1.Id];
            //system.assert(null == lineItem1.HarvestProject__c);
            
            //Delete  the invoice, check if Line Item trigger is fired and Time Entry is updated\
            try{
            	delete invoice;
            }
            catch(DmlException e)
            {
              /*System.assertequals('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY' , 
                                 e.getDmlStatusCode(0));*/
            }
            for(HarvestTimeEntry__c UpdatedTimeEntry : [Select Invoiced_by_CMB__c from HarvestTimeEntry__c 
                                                        where HarvestProject__c =: project.Id ]){
                
                //system.assert(UpdatedTimeEntry.Invoiced_by_CMB__c == false);                                        
            }
        
        test.stopTest();
    }
}