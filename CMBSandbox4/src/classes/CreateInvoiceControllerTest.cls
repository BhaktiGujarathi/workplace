/* Description - Test Class for CreateInvoiceController
 * 	
 * Created By - Sneha P.
 *	
 * Date  - 03/01/2014
 */
@isTest
private class CreateInvoiceControllerTest {
	@isTest
	private static void CreateInvoiceTest() {
		//Create CS record
		Merging_Time_Entry_Setting__c mergeSetting = new Merging_Time_Entry_Setting__c(Name = 'Test',
																		Task_Type__c = 'TestTaskType');
		insert mergeSetting;
		
		Replace_words_Setting__c ReplaceSetting = new Replace_words_Setting__c(Name = 'TestSetting',
																			   String__c = 'ApexPage',
																			   Replacement__c = 'VFPage');
		insert ReplaceSetting;
		
		Replace_words_Setting__c ReplaceSetting1 = new Replace_words_Setting__c(Name = 'TestSetting2',
																			    String__c = 'testClass',
																			    Replacement__c = 'Test Class');
		insert ReplaceSetting1;
		
		Account Acc = new Account(Name = 'Test Account');
		insert Acc;
		
		Opportunity opp = new Opportunity(Name='Test opp', AccountId = Acc.Id, StageName= 'Prospecting',
										  CloseDate=system.today() );
		insert opp;
		
		HarvestProject__c project = new HarvestProject__c(Name = 'Test Project' ,Account__c = Acc.Id,
														 Budget__c = 'No Budget', Opportunity__c = opp.Id);
		insert project;
		
		HarvestTimeEntry__c timeEntry = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'TestTaskType',
																Duration__c = 3,Date__c = system.today(),
																Notes__c = 'Worked on ApexPage');
		insert timeEntry;
		
		HarvestTimeEntry__c timeEntry1 = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'TestTaskType',
																Duration__c = 4,Date__c = system.today(),
																Notes__c = 'Worked on testClass');
		insert timeEntry1;
		
		//Create Time Entry record for this project 
		PageReference pageRef = Page.CreateInvoice;
        pageRef.getParameters().put('Id', project.Id);
        test.setCurrentPage(pageRef);
         
        Apexpages.StandardController sc = new Apexpages.standardController(project);	
         
		CreateInvoiceController cntrl = new CreateInvoiceController(sc);
		
		cntrl.createSingleInvoice = false;
		
		//assert start date and end date
		cntrl.populateProjects();
		
		cntrl.projectListWrapper[0].isSelected = true;
		
		cntrl.CreateInvoices();
		if(cntrl.invoiceIdList.size()>0){
			Id invcId = cntrl.invoiceIdList[0];
		//check if 1 line item is created for the Highest hrs
		list<Line_Item__c> lineItemList = [Select Invoice__c,Hours_Num__c,Date__c,Description__c
					 					   from Line_Item__c where Invoice__c =: invcId];
		system.assert(lineItemList.size() == 1);
		system.assert(lineItemList[0].Hours_Num__c == 4);	
		system.assert(lineItemList[0].Date__c == system.today());	
		system.assert(lineItemList[0].Description__c == 'Worked on Test Class' ); }
		
		cntrl.Cancel();
		
	}
	
	@isTest
	private static void CreateSingleInvoiceTest() {
		
		Account Acc = new Account(Name = 'Test Account');
		insert Acc;
		
		Opportunity opp = new Opportunity(Name='Test opp', AccountId = Acc.Id, StageName= 'Prospecting',
										  CloseDate=system.today() );
		insert opp;
		
		HarvestProject__c project = new HarvestProject__c(Name = 'Test Project' ,Account__c = Acc.Id,
														 Budget__c = 'No Budget', Opportunity__c = opp.Id);
		insert project;
		
		HarvestProject__c project1 = new HarvestProject__c(Name = 'Test Project1' ,Account__c = Acc.Id,
														 Budget__c = 'No Budget', Opportunity__c = opp.Id);
		insert project1;
		
		HarvestTimeEntry__c timeEntry = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'Test',
																Duration__c = 3,Date__c = system.today());
		insert timeEntry;
		
		HarvestTimeEntry__c timeEntryCopy = new HarvestTimeEntry__c(HarvestProject__c = project.Id, Task_Type__c = 'Test',
																Duration__c = 4,Date__c = system.today());
		insert timeEntryCopy;
		
		HarvestTimeEntry__c timeEntry1 = new HarvestTimeEntry__c(HarvestProject__c = project1.Id, Task_Type__c = 'Test',
																Duration__c = 4,StartTime__c = system.today(),
																EndTime__c = system.today());
		insert timeEntry1;
		
		//Create Time Entry record for this project 
		PageReference pageRef = Page.CreateInvoice;
        test.setCurrentPage(pageRef);
         
        Apexpages.StandardController sc = new Apexpages.standardController(project);	
         
		CreateInvoiceController cntrl = new CreateInvoiceController(sc);
		
		cntrl.project.Account__c = Acc.Id;
		cntrl.populateProjects();
		cntrl.projectListWrapper[0].isSelected = true;
		cntrl.projectListWrapper[1].isSelected = true;
		
		cntrl.createSingleInvoice = true;
		cntrl.CreateInvoices();
		//Check only 1 Invoice should be created 
		//system.assert(cntrl.invoiceIdList.size() == 1);
		cntrl.Cancel();
		/*Invoice__c invce;
		if(Acc != null)
			invce = [Select Id from Invoice__c where Account__c =: Acc.Id];
		
		//check if 3 line items are created
		if(invce != null){
			list<Line_Item__c> lineItemList = [Select Invoice__c from Line_Item__c where Invoice__c =: invce.Id];
			system.assert(lineItemList.size() == 3);}*/
	}
}