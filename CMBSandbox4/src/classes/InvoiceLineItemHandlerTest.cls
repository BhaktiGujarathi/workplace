@isTest
private class InvoiceLineItemHandlerTest {
	//Test method to test after Insert method   
    static testMethod void onAfterInsertTest() {
    	//Account records
    	list<Account> accountList = insertAccounts(5);
    	System.debug('&&&&&&&accountList'+accountList);    	
    	insert accountList;
    	//Opportunity records
    	list<Opportunity> opportunityList = insertOpportunity(5,accountList);
    	insert opportunityList;
    	//Contact records  
    	list<Contact> contactList = insertContact(5,accountList);
    	insert contactList;
		//project records
		list<HarvestProject__c> harvestProjectList = insertHarvestProjects(5,opportunityList,accountList,contactList);
		insert harvestProjectList;
		//invoices records
		list<Invoice__c> invoiceList = insertInvoices(5,opportunityList,contactList,accountList);
		insert invoiceList;
		//invoiceLineItems records
		list<Line_Item__c> invoLineItemList = insertInvoiceLineItems(5,invoiceList,opportunityList,contactList,harvestProjectList);
		test.startTest();
		insert invoLineItemList;
		test.stopTest();	
		
		//Assertions
		List<Line_Item__c> assertList = [select Id,Opportunity__c
									     from Line_Item__c];
		System.assertEquals(assertList[0].Opportunity__c,opportunityList[0].Id);
    }
    //Test method to test afterupdate method
    static testMethod void onAfterUpdateTest() {
    	//Account records
    	list<Account> accountList = insertAccounts(5);
    	System.debug('&&&&&&&accountList'+accountList);    	
    	insert accountList;
    	//Opportunity records
    	list<Opportunity> opportunityList = insertOpportunity(5,accountList);
    	insert opportunityList;
    	//Contact records  
    	list<Contact> contactList = insertContact(5,accountList);
    	insert contactList;
		//project records
		list<HarvestProject__c> harvestProjectList = insertHarvestProjects(5,opportunityList,accountList,contactList);
		insert harvestProjectList;
		//invoices records
		list<Invoice__c> invoiceList = insertInvoices(5,opportunityList,contactList,accountList);
		insert invoiceList;
		//invoiceLineItems records
		list<Line_Item__c> invoLineItemList = insertInvoiceLineItems(5,invoiceList,opportunityList,contactList,harvestProjectList);
		insert invoLineItemList;
		
		list<HarvestProject__c> harvestProjectList1 = insertHarvestProjects(1,opportunityList,accountList,contactList);
		insert harvestProjectList1;
		
		List<Line_Item__c> lineItemUpdate = new list<Line_Item__c>();
		for(Line_Item__c itm : [select Id,HarvestProject__c from Line_Item__c]){			
			itm.HarvestProject__c = harvestProjectList1[0].Id;
			lineItemUpdate.add(itm);
		}
		System.debug('$$$$$ lineItemUpdate $$$$$$'+lineItemUpdate);
		test.startTest();
		update lineItemUpdate;
		test.stopTest();	
    }
    
    //Test method to test after Delete method
    static testMethod void onafterDelete() {
    	//Account records
    	list<Account> accountList = insertAccounts(5);
    	System.debug('&&&&&&&accountList'+accountList);    	
    	insert accountList;
    	//Opportunity records
    	list<Opportunity> opportunityList = insertOpportunity(5,accountList);
    	insert opportunityList;
    	//Contact records  
    	list<Contact> contactList = insertContact(5,accountList);
    	insert contactList;
		//project records
		list<HarvestProject__c> harvestProjectList = insertHarvestProjects(5,opportunityList,accountList,contactList);
		insert harvestProjectList;
		//invoices records
		list<Invoice__c> invoiceList = insertInvoices(5,opportunityList,contactList,accountList);
		insert invoiceList;
		//invoiceLineItems records
		list<Line_Item__c> invoLineItemList = insertInvoiceLineItems(5,invoiceList,opportunityList,contactList,harvestProjectList);
		insert invoLineItemList;
				
		List<Line_Item__c> lineItemDelete = new list<Line_Item__c>();
		lineItemDelete = [select Id From Line_Item__c];
		test.startTest();
		delete lineItemDelete;
		test.stopTest();	
    }
    
    
    //Test method to test after Delete method
    static testMethod void multiLineItemTest() {
    	//Account records
    	list<Account> accountList = insertAccounts(2);
    	System.debug('&&&&&&&accountList'+accountList);    	
    	insert accountList;
    	//Opportunity records
    	list<Opportunity> opportunityList = insertOpportunity(2,accountList);
    	insert opportunityList;
    	//Contact records  
    	list<Contact> contactList = insertContact(2,accountList);
    	insert contactList;
		//project records
		list<HarvestProject__c> harvestProjectList = new list<HarvestProject__c>();
		Integer j = 0;
		for(Integer i=0;i<10;i++){
			if(i<5)
			j=0;
			else
			j=1;
    		HarvestProject__c prjct = new HarvestProject__c();
    		prjct.Name = 'Test name';
    		prjct.Account__c = accountList[j].Id;
    		prjct.Opportunity__c = opportunityList[j].Id;
    		prjct.ProjectType__c = 'Other';
    		prjct.ProjectHourlyRate__c = 20;
    		prjct.SyncStatus__c = 'Status Unknown';
    		prjct.ClientProjectManager__c = contactList[j].Id;
    		harvestProjectList.add(prjct);
    	}
		insert harvestProjectList;
		//invoices records
		list<Invoice__c> invoiceList = insertInvoices(2,opportunityList,contactList,accountList);
		insert invoiceList;
		//invoiceLineItems records
		list<Line_Item__c> invoLineItemList = insertInvoiceLineItems(2,invoiceList,opportunityList,contactList,harvestProjectList);
		insert invoLineItemList;
				
		List<Line_Item__c> lineItemDelete = new list<Line_Item__c>();
		lineItemDelete = [select Id From Line_Item__c];
		test.startTest();
		delete lineItemDelete;
		test.stopTest();	
    }
    
    
    //Method will create dummy Account Records.    
    public static list<Account> insertAccounts(Integer cnt){
    	list<Account> accountList = new list<Account>();
    	for(Integer i=0; i<=cnt; i++){
    		Account acc = new Account();
    		System.debug('####value i=' +i);
    		acc.Name='TestAcc'+ i +'Acc';
    		accountList.add(acc);
    		System.debug('####accountList in function' +accountList);
    	}
    	//insert accountList;
    	return accountList;
    }
    
    //Method will create dummy Opportunity Records.
    public static list<Opportunity> insertOpportunity(Integer cnt,
                                                      list<Account> accountList){
    	list<Opportunity> opportunityList = new list<Opportunity>();
    	for(Integer i=0;i<cnt;i++){
    		Opportunity opp = new Opportunity();
    		opp.Name='TestOpp';
    		opp.AccountId = accountList[i].Id;
    		opp.CloseDate = System.today();
    		opp.StageName ='Prospecting';
    		opp.ForecastCategoryName = 'Pipeline';
    		opportunityList.add(opp);
    	}
    	//insert opportunityList;
    	return opportunityList;
    }
    
    //Method will create dummy Contact Records.
    public static list<Contact> insertContact (Integer cnt,
                                               list<Account> accountList){
    	list<Contact> contactList = new list<Contact>();
    	for(Integer i=0;i<cnt;i++){
    		Contact con = new Contact();
    		con.LastName='TestLastName';
    		con.AccountId = accountList[i].Id;
    		con.Contact_Type__c = 'Other';
    		con.Tip_of_The_Week__c ='Added - Active';
    		contactList.add(con);
    	}
    	//insert contactList;
    	return contactList;
    }
    
    //Method will create dummy Invoices Records.
    public static list<Invoice__c> insertInvoices(Integer cnt,
    												list<Opportunity> opportunityList,
    												list<Contact> contactList,
    												list<Account> accountList){
    	list<Invoice__c> invoiceList = new list<Invoice__c>();
    	for(Integer i=0;i<cnt;i++){
    		Invoice__c inv = new Invoice__c();
    		inv.Invoice_Type__c='Hours';
    		inv.Account__c = accountList[i].Id;
    		inv.Billing_Contact__c = contactList[i].Id;
    		inv.Opportunity__c = opportunityList[i].Id;
    		inv.Rate__c = 5 + i;
    		inv.Description__c = 'Test Desc';
    		invoiceList.add(inv);
    	}
    	//insert invoiceList;
    	return invoiceList;
    }
    
    //Method will create dummy Harvest project Records.
    public static list<HarvestProject__c> insertHarvestProjects (Integer cnt,
                                                    list<Opportunity> opportunityList,
                                                    list<Account> accountList,
                                                    list<Contact> contactList){
    	list<HarvestProject__c> harvestProjectList = new list<HarvestProject__c>();
    	for(Integer i=0;i<cnt;i++){
    		HarvestProject__c prjct = new HarvestProject__c();
    		prjct.Name = 'Test name';
    		prjct.Account__c = accountList[i].Id;
    		prjct.Opportunity__c = opportunityList[i].Id;
    		prjct.ProjectType__c = 'Other';
    		prjct.ProjectHourlyRate__c = 20;
    		prjct.SyncStatus__c = 'Status Unknown';
    		prjct.ClientProjectManager__c = contactList[i].Id;
    		harvestProjectList.add(prjct);
    	}
    	//insert harvestProjectList;
    	return harvestProjectList;
    }
    //Method will create dummy InvoiceLineItems Records.
    public static list<Line_Item__c> insertInvoiceLineItems(Integer cnt,
                                                    list<Invoice__c> invoiceList,
                                                    list<Opportunity> opportunityList,
                                                    list<Contact> contactList,
                                                    list<HarvestProject__c> harvestProjectList){
    	list<Line_Item__c> invoLineItemList = new list<Line_Item__c>();
    	for(Integer i=0;i<cnt;i++){
    		Line_Item__c inv = new Line_Item__c();
    		inv.Date__c = System.today();
    		inv.Invoice__c = invoiceList[i].Id;
    		inv.Opportunity__c = opportunityList[i].Id;
    		inv.HarvestProject__c =harvestProjectList[i].id;
    		inv.Description__c = 'Test Desc';
    		invoLineItemList.add(inv);
    	}
    	//insert invoLineItemList;
    	return invoLineItemList;
    }
}