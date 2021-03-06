@isTest
public with sharing class TestTransactionController {

public static final String INV_DUE_AMT_LESS_THAN_CRED_AMT_PAID  = 'Amount Paid Exceeds Receivable Due Amount.';
public static final String TRAN_AMT_MUST_BE_FILLED = Label.Transaction_TransactionAmountmustBeFilled;  
public static final String Tran_AMT_MUST_BE_POS_VAL = Label.Transaction_TransactionAmountMustBePositive;
public static final String TRAN_AMT_EXCEEDS_REC_DUE_AMT = Label.Transaction_PaidAmountExceedRecDueAmt;
public static final String AMOUNT_PAID_MUST_BE_POSITIVE = Label.Transaction_AmountPaidMustBePositive;
public static final String BILL_PAID_AMT_EXCEEDS_BALANCE_AMT = Label.Transaction_BillPaidAmountExceedsBalanceAmount;

    static Id prepareTestData(){
        //Common data
        List<RecordType> recordTypes = [select Id, Name FROM RecordType Where Name='Debit' OR Name='Credit'];
        Map<String, Id> mapTransRecordTypes = new Map<String, Id>();
        for(RecordType objRecordType : recordTypes){
            mapTransRecordTypes.put(objRecordType.Name, objRecordType.Id);
        }
        
        Account objAccount = new Account(Name='Test', Type='Analyst', Industry='Energy');
        insert objAccount; 
        
        Contact objContact = new Contact(LastName='Last', AccountId = objAccount.Id);
        insert objContact;
        
        Opportunity objOpp = new Opportunity(Name='Opp1', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting');
        insert objOpp;  
        
        Receivable__c objInvoice = new Receivable__c( Status__c='Open', Due_From_Account__c = objAccount.Id);
        insert objInvoice;
        
        
        Transaction__c objTransaction = new Transaction__c( Date__c=System.Today(), status__c='Open', Amount__c =20000.00, Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id,   Contact__c= objContact.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
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
        
        Account objAccount = new Account(Name='Test', Type='Analyst', Industry='Energy');
        insert objAccount; 
        
        Opportunity objOpp = new Opportunity(Name='Opp1', AccountId=objAccount.Id, CloseDate = System.today(), StageName='Prospecting');
        insert objOpp;
        
        Contact objContact = new Contact(LastName='Last', AccountId = objAccount.Id);
        insert objContact;
    
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=20000.00 );
        insert objBill; 
        
        Transaction__c objTransaction = new Transaction__c(Date__c=System.Today(), status__c='Open', Amount__c=20000.00, Pmt_Method__c='Cash', Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, Contact__c= objContact.Id, RecordTypeId = mapTransRecordTypes.get('Debit'));
        insert objTransaction;
        
        return objTransaction.Id;
    }
    
    static testMethod void testCreditTransaction() {
        
        Id objId = prepareTestData();
        Transaction__c objTransaction = [SELECT Name, Date__c, status__c, Amount__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
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
            objTransController.wrapper.selected = true;
	        objTransController.autoPopulate1();
	        objTransController.wrapper.selected = false;   
	        objTransController.autoPopulate1();   
            objTransController.wrapper.cred.Amount__c = 200000.00;
            objTransController.wrapper.cred.Date__c = System.Today();
            objTransController.wrapper.cred.Memo__c = 'test';
            //objTransController.wrapper.selected = true;
            objTransController.processSelected();
            lstMsgs = ApexPages.getMessages(); 
            if(lstMsgs.size() > 0){
                System.assertEquals(Label.Transaction_LineItemAmountExceedsTransactionAmount,'Amount In Transaction Line Item Exceeds Transaction Amount' );
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
            objTransController.wrappers = objTransController.getInvoices();
            objTransController.wrapper = objTransController.wrappers.get(0);    
            objTransController.wrapper.cred.Amount__c = -2000.00;
            objTransController.wrapper.selected = true;
            objTransController.processSelected();
            List<ApexPages.Message> lstMsgs1 = ApexPages.getMessages(); 
            if(lstMsgs1.size() > 0){
                system.debug('@@@@lstMsgs1'+lstMsgs1);
                System.assertequals(AMOUNT_PAID_MUST_BE_POSITIVE,lstMsgs1.get(1).getSummary());
            }
        }
    }
        static testMethod void testDebitTransaction(){
        Id objId = prepareDebitTestData();
        Transaction__c objTransaction = [SELECT Name, Date__c, status__c, Amount__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
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
            objTransController.wrapper.selected = true;
	        objTransController.autoPopulate1();
	        objTransController.wrapper.selected = false;   
	        objTransController.autoPopulate1(); 
            objTransController.wrapper.debt.Amount__c = 2000.00;
            objTransController.wrapper.debt.Date__c = System.Today();
            objTransController.wrapper.debt.Memo__c = 'test';
            //objTransController.wrapper.selected = true;
            objTransController.processSelectedDebits();
            //System.assertequals(Label.Transaction_LineItemAmountExceedsTransactionAmount,ApexPages.getMessages().get(0).getSummary());
        
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
            List<apexPages.Message> lstMsgs = ApexPages.getMessages(); 
            if(lstMsgs.size() > 0){
                System.assertEquals(Label.Transaction_LineItemAmountExceedsTransactionAmount,lstMsgs.get(0).getSummary() );
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
            
            objTransController.wrappers = objTransController.getBills();
            objTransController.wrapper = objTransController.wrappers.get(0);    
            objTransController.wrapper.debt.Amount__c = 200000.00;
            objTransController.wrapper.selected = true;
            objTransController.processSelectedDebits();
            List<apexPages.Message> lstMsgs1 = ApexPages.getMessages(); 
            if(lstMsgs1.size() > 0){
                system.debug('@@@@'+lstMsgs1);
                System.assertEquals(BILL_PAID_AMT_EXCEEDS_BALANCE_AMT,lstMsgs1.get(0).getSummary() );
            }
            
            objTransController.wrappers = objTransController.getBills();
            objTransController.wrapper = objTransController.wrappers.get(0);    
            objTransController.wrapper.debt.Amount__c = -2000.00;
            objTransController.wrapper.selected = true;
            objTransController.processSelectedDebits();
            List<apexPages.Message> lstMsgs2 = ApexPages.getMessages(); 
            system.debug('@@@@lstMsgs2'+lstMsgs2);
            if(lstMsgs2.size() > 0){
                system.debug('@@@@lstMsgs2'+lstMsgs2);
                System.assertEquals(AMOUNT_PAID_MUST_BE_POSITIVE,lstMsgs2.get(1).getSummary() );
            }
            objTransController.resetTransaction();
        objTransController.cancelCreditTranscations();
        }
    }
    static testMethod void testCreditTransaction_new(){
        
        List<RecordType> recordTypes = [select Id, Name FROM RecordType Where Name='Debit' OR Name='Credit'];
        Map<String, Id> mapTransRecordTypes = new Map<String, Id>();
        for(RecordType objRecordType : recordTypes){
            mapTransRecordTypes.put(objRecordType.Name, objRecordType.Id);
        }
        
        Account objAccount = new Account(Name='Test', Type='Analyst', Industry='Energy');
        insert objAccount;
        
        Receivable__c objInvoice = new Receivable__c(Amount__c=200.00, Status__c='Open', Due_From_Account__c = objAccount.Id);
        insert objInvoice;
        
        Transaction__c objTransaction1 = new Transaction__c( Date__c=System.Today(), status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        //insert objTransaction1;
        
        TransactionController_New controller = new TransactionController_New(new ApexPages.StandardController(objTransaction1));
        controller.objTranscation = objTransaction1; 
        controller.save();
        
        List<ApexPages.Message> lstMsgs = ApexPages.getMessages(); 
           
        System.assertequals(TRAN_AMT_MUST_BE_FILLED ,lstMsgs.get(0).getSummary());
        lstMsgs.clear();
        
        Transaction__c objTransaction2 = new Transaction__c( Date__c=System.Today(),Amount__c = -10 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        
        controller.objTranscation = objTransaction2; 
        controller.save();
        lstMsgs = ApexPages.getMessages();
        
        System.assertequals(Tran_AMT_MUST_BE_POS_VAL ,lstMsgs.get(1).getSummary());
        
        Transaction__c objTransaction3 = new Transaction__c( Date__c=System.Today(),Amount__c = 2000 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        controller.objTranscation = objTransaction3;
        //Create New Transaction Line Items
        controller.create();  
        //get all TransactionWrapper and update those
        controller.wrappers = controller.getInvoices();
        controller.wrapper = controller.wrappers.get(0);
        controller.wrapper.selected = true;
        controller.autoPopulate1();
        controller.wrapper.selected = false;   
        controller.autoPopulate1();
        controller.wrapper.cred.Amount__c = 300.00;
        controller.wrapper.cred.Date__c = System.Today();
        controller.wrapper.cred.Memo__c = 'test';
        
        controller.save();
        
        lstMsgs = ApexPages.getMessages();
       
        System.assertequals(TRAN_AMT_EXCEEDS_REC_DUE_AMT ,lstMsgs.get(2).getSummary());
        
        Transaction__c objTransaction4 = new Transaction__c( Date__c=System.Today(),Amount__c = 3000 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        controller.objTranscation = objTransaction4;
        //Create New Transaction Line Items
        controller.create();  
        controller.totalAmount = 20000.00;
        controller.wrappers = controller.getInvoices();
        controller.wrapper = controller.wrappers.get(0);    
        controller.wrapper.cred.Amount__c = 20000.00;
        controller.wrapper.cred.Date__c = System.Today();
        controller.wrapper.cred.Memo__c = 'test';
        controller.wrapper.selected = true;
        controller.save();
        lstMsgs = ApexPages.getMessages(); 
        
        System.assertEquals(Label.Transaction_LineItemAmountExceedsTransactionAmount,lstMsgs.get(3).getSummary() );
        Transaction__c objTransaction5 = new Transaction__c( Date__c=System.Today(),Amount__c = 3000 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        controller.objTranscation = objTransaction5;
        //Create New Transaction Line Items
        controller.create();  
        //controller.totalAmount = 20000.00;
        controller.wrappers = controller.getInvoices();
        controller.wrapper = controller.wrappers.get(0);    
        controller.wrapper.cred.Amount__c = -100;
        controller.wrapper.cred.Date__c = System.Today();
        controller.wrapper.cred.Memo__c = 'test';
        controller.wrapper.selected = true;
        controller.save();
        lstMsgs = ApexPages.getMessages(); 
       
        System.assertEquals(AMOUNT_PAID_MUST_BE_POSITIVE ,lstMsgs.get(4).getSummary() );
        
        Transaction__c objTransaction6 = new Transaction__c( Date__c=System.Today(),Amount__c = 3000 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        controller.objTranscation = objTransaction6;
        //Create New Transaction Line Items
        controller.create();  
        //controller.totalAmount = 20000.00;
        controller.wrappers = controller.getInvoices();
        controller.wrapper = controller.wrappers.get(0);    
        controller.wrapper.cred.Amount__c = 100;
        controller.wrapper.cred.Date__c = System.Today();
        controller.wrapper.cred.Memo__c = 'test';
        controller.wrapper.selected = true;
        controller.save();
        
        controller.getCheckedValuesCredit();
        controller.getCheckedValuesCredit();
        controller.ViewSortedData_Receivable();
        controller.resetTransaction();
        controller.getSortDirection();
        controller.ClonePage();
        controller.Edit_val();
        controller.cancelEdit();
        controller.cancelCreditTranscations();
    }
    
    static testMethod void testDebitTransaction_new(){
        
        List<RecordType> recordTypes = [select Id, Name FROM RecordType Where Name='Debit' OR Name='Credit'];
        Map<String, Id> mapTransRecordTypes = new Map<String, Id>();
        for(RecordType objRecordType : recordTypes){
            mapTransRecordTypes.put(objRecordType.Name, objRecordType.Id);
        }
        
        Account objAccount = new Account(Name='Test', Type='Analyst', Industry='Energy');
        insert objAccount;
        
        Payable__c objBill = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=1000.00 );
        insert objBill;      
       
        Transaction__c objTransaction3 = new Transaction__c( Date__c=System.Today(),Amount__c = 2000 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Debit'));
        TransactionController_New controller = new TransactionController_New(new ApexPages.StandardController(objTransaction3));
        controller.objTranscation = objTransaction3;
         //Create New Transaction Line Items
        controller.create();  
                //get all TransactionWrapper and update those
        controller.wrappers = controller.getBills();
        controller.wrapper = controller.wrappers.get(0); 
        controller.wrapper.selected = true;
        controller.autoPopulate1();
        controller.wrapper.selected = false;   
        controller.autoPopulate1();
        controller.wrapper.debt.Amount__c = 2000.00;
        controller.wrapper.debt.Date__c = System.Today();
        controller.wrapper.debt.Memo__c = 'test';
        controller.save();
        List<ApexPages.Message> lstMsgs = ApexPages.getMessages(); 
        lstMsgs = ApexPages.getMessages();
        System.assertequals(BILL_PAID_AMT_EXCEEDS_BALANCE_AMT,lstMsgs.get(0).getSummary());
            
        Transaction__c objTransaction6 = new Transaction__c( Date__c=System.Today(),Amount__c = 3000 , status__c='Open', Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, RecordTypeId = mapTransRecordTypes.get('Debit'));
        controller.objTranscation = objTransaction6;
        //Create New Transaction Line Items
        controller.create();  
        //controller.totalAmount = 20000.00;
        controller.wrappers = controller.getBills();
        controller.wrapper = controller.wrappers.get(0);    
        controller.wrapper.debt.Amount__c = 200.00;
        controller.wrapper.debt.Date__c = System.Today();
        controller.wrapper.debt.Memo__c = 'test';
        controller.wrapper.selected = true;
        controller.save();
        
        controller.getCheckedValues();
        controller.getCheckedValues();
        controller.ViewSortedData_PayableName();
    }
}