@isTest
public with sharing class TestTransactionLineCreditHandler {
	public static final string COMPLETED = 'Completed';
	public static final string PENDING = 'Pending';
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
        
        Receivable__c objInvoice = new Receivable__c( Status__c='Open', Due_From_Account__c = objAccount.Id, Amount__c=1000);
        insert objInvoice;
        
        Receivable__c objInvoice1 = new Receivable__c( Status__c='Open', Due_From_Account__c = objAccount.Id, Amount__c=2000);
        insert objInvoice1;
        
        Transaction__c objTransaction = new Transaction__c( Date__c=System.Today(), Amount__c =1000.00, Pmt_Method__c='Cash',Bank_Depostied__c = 'Visa', Account__c= objAccount.Id,   Contact__c= objContact.Id, RecordTypeId = mapTransRecordTypes.get('Credit'));
        insert objTransaction;
        
        Transaction_Line_Credit__c objLineCredit = new Transaction_Line_Credit__c(Amount__c=500, Receivable__c=objInvoice.Id, Transaction__c=objTransaction.Id);
        insert objLineCredit;
        
        Transaction_Line_Credit__c objLineCredit1 = new Transaction_Line_Credit__c(Amount__c=500, Receivable__c=objInvoice.Id, Transaction__c=objTransaction.Id);
        insert objLineCredit1;
        
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
    
        Payable__c objPayable = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=21000.00 );
        insert objPayable; 
        
        Payable__c objPayable1 = new Payable__c(Account__c=objAccount.Id, Status__c = 'Open - Ready to Pay', Amount_Due__c=2000.00 );
        insert objPayable1;
        
        Transaction__c objTransaction = new Transaction__c(Date__c=System.Today(), status__c='Open', Amount__c=1000.00, Pmt_Method__c='Cash', Bank_Depostied__c = 'Visa', Account__c= objAccount.Id, Contact__c= objContact.Id, RecordTypeId = mapTransRecordTypes.get('Debit'));
        insert objTransaction;
        
        Transaction_Line_Debit__c objLineDebit = new Transaction_Line_Debit__c(Amount__C = 500, Payable__c = objPayable.Id, Transaction__c = objTransaction.Id);
        insert objLineDebit;
        
        Transaction_Line_Debit__c objLineDebit1 = new Transaction_Line_Debit__c(Amount__C = 500, Payable__c = objPayable.Id, Transaction__c = objTransaction.Id);
        insert objLineDebit1;
        return objTransaction.Id;
    }
    
    static testMethod void testCreditTransaction() {
    	 Id objId = prepareTestData();
    	 Transaction__c objTransaction = new Transaction__c();
        objTransaction = [SELECT Name, Date__c, status__c, Amount__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
                                         FROM Transaction__c 
                                         where Id=:objId limit 1];
        
        test.startTest();                           
       // System.assertEquals(COMPLETED,objTransaction.Status__c);
        
        List<Transaction_Line_Credit__c> lstLineCredit = [Select Id, Name, Receivable__c,Receivable__r.Receivable_Amount_Paid__c from Transaction_Line_Credit__c where Transaction__c=:objTransaction.Id];
        System.assertEquals(1000,lstLineCredit[0].Receivable__r.Receivable_Amount_Paid__c);
        
        if(lstLineCredit.size()>0)
        	delete lstLineCredit[0];
        
        objTransaction = [SELECT Name, Date__c, status__c, Amount__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
                                         FROM Transaction__c 
                                         where Id=:objId limit 1];	
        System.assertEquals(PENDING,objTransaction.Status__c);
        
        Receivable__c objReceivable1 = [select Id, Name, Receivable_Amount_Paid__c from Receivable__c where id =: lstLineCredit[0].Receivable__r.Id];
        System.assertEquals(500,objReceivable1.Receivable_Amount_Paid__c);
        test.stopTest();
    }
    
     static testMethod void testDebitTransaction() {
     	Id objId = prepareDebitTestData();
     	
     	Transaction__c objTransaction = new Transaction__c();
        objTransaction = [SELECT Name, Date__c, status__c, Amount__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
                                         FROM Transaction__c 
                                         where Id=:objId limit 1];
        
        test.startTest();                           
        //System.assertEquals(COMPLETED,objTransaction.Status__c);
        
        List<Transaction_Line_Debit__c> lstLineDebit = [select Id, Name, Amount__c from Transaction_Line_Debit__c where Transaction__c =: objTransaction.Id];
        if(lstLineDebit.size()>0)
        	delete lstLineDebit[0];
        	
        objTransaction = [SELECT Name, Date__c, status__c, Amount__c, Pmt_Method__c, Bank_Depostied__c, Account__c, Contact__c, RecordTypeId 
                                         FROM Transaction__c 
                                         where Id=:objId limit 1];	
        
       	System.assertEquals(PENDING,objTransaction.Status__c);
     }
}