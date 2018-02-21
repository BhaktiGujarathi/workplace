/**
 */
@isTest
public class TestTransactionController {

	public static final String INV_DUE_AMT_LESS_THAN_CRED_AMT_PAID	= 'Transaction Amount Exceeds Invoice Due Amount';
	
	static Id prepareTestData(){
		//Common data
		List<RecordType> recordTypes = [select Id, Name FROM RecordType Where Name='Debit' OR Name='Credit'];
		Map<String, Id> mapTransRecordTypes = new Map<String, Id>();
		for(RecordType objRecordType : recordTypes){
			mapTransRecordTypes.put(objRecordType.Name, objRecordType.Id);
		}
		
		Account objAccount = new Account(Name='Test', Type='Analyst', Sub_Type__c='Test', Industry='Energy');
		insert objAccount; 
		
		
		Contact objContact = new Contact(LastName='Last', AccountId = objAccount.Id, Contact_Type__c = 'Customer', Tip_of_The_Week__c='Added - Active');
		insert objContact;
		
		Opportunity objOpp = new Opportunity(Name='Opp1', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting', ForecastCategoryName='Pipeline' );
		insert objOpp;
		
		Project__c objProject = new Project__c(Name='Test Project', Phase__c='1', Opportunity__c = objOpp.Id);
		insert objProject;
		
		Invoice__c objInvoice = new Invoice__c(Invoice_Type__c='Hours', Rate__c=20.00, 	Description__c='test desc', Account__c=objAccount.Id, Billing_Contact__c=objContact.Id, Opportunity__c=objOpp.Id, 	Project__c=objProject.Id, Status__c='Open',Updated_Contractor_Hours__c=true);
		insert objInvoice;
		
		Line_Item__c objInvoiceLineItems = new Line_Item__c(Start__c=System.now(), Finish__c = System.now().addMonths(1), Opportunity__c=objOpp.Id, Invoice__c = objInvoice.Id, Description__c ='test', Date__c = system.today(), Credit_Hrs__c=20); 
		insert objInvoiceLineItems;
		
		Transaction__c objTransaction = new Transaction__c(Date__c=System.Today(), Type__c='Rev - Other', status__c='Open', Amt_Non_Hourly__c=20000.00, Pmt_Method__c='Cash',
					 Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, 	Contact__c= objContact.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
		insert objTransaction;
		
		return objTransaction.Id;
	}
	
	static Id prepareDebitTestData(){
		//Common data
		List<RecordType> recordTypes = [select Id, Name FROM RecordType Where Name='Debit' OR Name='Credit'];
		Map<String, Id> mapTransRecordTypes = new Map<String, Id>();
		for(RecordType objRecordType : recordTypes){
			mapTransRecordTypes.put(objRecordType.Name, objRecordType.Id);
		}
		
		Account objAccount = new Account(Name='Test', Type='Analyst', Sub_Type__c='Test', Industry='Energy');
		insert objAccount; 
		
		
		Contact objContact = new Contact(LastName='Last', AccountId = objAccount.Id, Contact_Type__c = 'Customer', Tip_of_The_Week__c='Added - Active');
		insert objContact;
	
		Bill__c objBill = new Bill__c(Name='Bill1', Vendor__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=20000.00, Upload_to_SF__c = 'No Need' );
		insert objBill;	
		
		Transaction__c objTransaction = new Transaction__c( Date__c=System.Today(), Type__c='Rev - Other', status__c='Open', Amt_Non_Hourly__c=20000.00, Pmt_Method__c='Cash',
					 Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, 	Contact__c= objContact.Id, RecordTypeId = mapTransRecordTypes.get('Debit'));
		insert objTransaction;
		
		return objTransaction.Id;
	}
	
    static testMethod void testCreditTransaction() {
    	Id objId = prepareTestData();
    	Transaction__c objTransaction = [SELECT Name, Date__c, Type__c, status__c, Amt_Non_Hourly__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
    									 FROM Transaction__c 
    									 where Id=:objId limit 1];
    									 
        if( objTransaction != null){
        	PageReference pageRef = Page.Transaction;
        	Test.setCurrentPageReference(pageRef);
        	TransactionController objTransController = new TransactionController(new ApexPages.StandardController(objTransaction));
        	PageReference editPageRef = objTransController.Edit_val();
        	//System.assertEquals(editPageRef.getUrl(), Page.Transaction.getUrl());
        	System.assertEquals(editPageRef.getUrl(), '/'+objTransaction.Id+'/e?retURL=%2F'+objTransaction.Id);
        	
        	//update Transaction
        	objTransaction.Pmt_Method__c = 'Wire';
        	PageReference savePageRef = objTransController.save();
        	System.assertEquals(savePageRef.getUrl(), Page.Transaction.getUrl());
        	
        	PageReference cancelPageRef = objTransController.cancelEdit();
        	System.assertEquals(cancelPageRef.getUrl(), Page.Transaction.getUrl()); 
        	
        	//Create New Transaction Line Items
        	objTransController.createCreditTranscations();  
        		//get all TransactionWrapper and update those
        	objTransController.wrappers = objTransController.getInvoices();
        	objTransController.wrapper = objTransController.wrappers.get(0); 	
        	objTransController.wrapper.cred.Amount__c = 2000.00;
        	objTransController.wrapper.cred.Date__c = System.Today();
        	objTransController.wrapper.cred.Memo__c = 'test';
        	objTransController.wrapper.selected = true;
        	objTransController.processSelected();
        	
        	List<ApexPages.Message> lstMsgs = ApexPages.getMessages(); 
        	if(lstMsgs.size() > 0){
        		System.assertequals(INV_DUE_AMT_LESS_THAN_CRED_AMT_PAID,lstMsgs.get(0).getSummary());
        	}
        	
        	
        	//Create New Transaction Line Items
        	objTransController.createCreditTranscations();  
        	objTransController.totalAmount = 200000.00;
        	objTransController.wrappers = objTransController.getInvoices();
        	objTransController.wrapper = objTransController.wrappers.get(0); 	
        	objTransController.wrapper.cred.Amount__c = 200000.00;
        	objTransController.wrapper.cred.Date__c = System.Today();
        	objTransController.wrapper.cred.Memo__c = 'test';
        	objTransController.wrapper.selected = true;
        	objTransController.processSelected();
        	lstMsgs = ApexPages.getMessages(); 
        	if(lstMsgs.size() > 0){
        		System.assertEquals(Label.TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT,lstMsgs.get(0).getSummary() );
        	}
        	
			//Create New Transaction Line Items
        	objTransController.createCreditTranscations();  
        	objTransController.totalAmount = null;
        	objTransController.processSelected();
        	lstMsgs = ApexPages.getMessages(); 
        	
        	//CancelCreditTransaction
        	objTransController.cancelCreditTranscations();
        	//objTransController.autoPopulate();
        	objTransController.ClonePage();
        	objTransController.getCurrentDate();
        	
        }
    }
        static testMethod void testDebitTransaction(){
    	Id objId = prepareDebitTestData();
    	Transaction__c objTransaction = [SELECT Name, Date__c, Type__c, status__c, Amt_Non_Hourly__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
    									 FROM Transaction__c 
    									 where Id=:objId limit 1];
    									 
        if( objTransaction != null){
        	PageReference pageRef = Page.Transaction;
        	Test.setCurrentPageReference(pageRef);
        	TransactionController objTransController = new TransactionController(new ApexPages.StandardController(objTransaction));
        	PageReference editPageRef = objTransController.Edit_val();
        	//System.assertEquals(editPageRef.getUrl(), Page.Transaction.getUrl());
        	System.assertEquals(editPageRef.getUrl(), '/'+objTransaction.Id+'/e?retURL=%2F'+objTransaction.Id);
        	
        	//update Transaction
        	objTransaction.Pmt_Method__c = 'Wire';
        	PageReference savePageRef = objTransController.save();
        	System.assertEquals(savePageRef.getUrl(), Page.Transaction.getUrl());
        	
        	PageReference cancelPageRef = objTransController.cancelEdit();
        	System.assertEquals(cancelPageRef.getUrl(), Page.Transaction.getUrl()); 
        	
        	
        	//System.assertEquals(resetPageRef.getUrl(), null); 
        	
        	//Create New Transaction Line Items
        	objTransController.createCreditTranscations();  
        		//get all TransactionWrapper and update those
        	objTransController.wrappers = objTransController.getBills();
        	objTransController.wrapper = objTransController.wrappers.get(0); 	
        	objTransController.wrapper.debt.Amount__c = 2000.00;
        	objTransController.wrapper.debt.Date__c = System.Today();
        	objTransController.wrapper.debt.Memo__c = 'test';
        	objTransController.wrapper.selected = true;
        	objTransController.processSelectedDebits();
        	//System.assertequals(Label.TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT,ApexPages.getMessages().get(0).getSummary());
        
        	//Test Validation	
        	objTransController.createCreditTranscations();  
        	objTransController.totalAmount = 200000.00;
        	objTransController.wrappers = objTransController.getBills();
        	objTransController.wrapper = objTransController.wrappers.get(0); 	
        	objTransController.wrapper.debt.Amount__c = 2000.00;
        	objTransController.wrapper.debt.Date__c = System.Today();
        	objTransController.wrapper.debt.Memo__c = 'test';
        	objTransController.wrapper.selected = true;
        	objTransController.processSelectedDebits();
        	List<apexPages.Message>	lstMsgs = ApexPages.getMessages(); 
        	if(lstMsgs.size() > 0){
        		System.assertEquals(Label.TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT,lstMsgs.get(0).getSummary() );
        	}
        	
        	//Test Validation	
        	objTransController.createCreditTranscations();  
        	objTransController.totalAmount = null;
        	objTransController.wrappers = objTransController.getBills();
        	objTransController.wrapper = objTransController.wrappers.get(0); 	
        	objTransController.wrapper.debt.Amount__c = 2000.00;
        	objTransController.wrapper.debt.Date__c = System.Today();
        	objTransController.wrapper.debt.Memo__c = 'test';
        	objTransController.wrapper.selected = true;
        	objTransController.processSelectedDebits();
        	objTransController.autoPopulate();
        	//Exception can not be handle from page
        	
        	PageReference resetPageRef = objTransController.resetTransaction();
        	//objTransController.autoPopulate();
        }
    }
}