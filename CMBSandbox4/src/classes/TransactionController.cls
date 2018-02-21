public with sharing class TransactionController {
	
	public Boolean disableInput {get; set;}
	public Apexpages.StandardController controller;
	public boolean blnShowBills{set;get;}
	public boolean blnEditMode{set;get;}
	public boolean blnTransType{set;get;}
	public String strTransName{set; get;}
	public boolean blnCreditTransLineItems{set;get;}
	public boolean blnDebitTransLineItems{set;get;}
	public boolean blnError{set;get;}
	public String strAccountName{set;get;}
	public String totalTransactionAmount{set;get;}
	public Decimal totalAmount{set;get;}
	//InvoiceList of Transaction Wrapper
	public List<TransactionWrapper> invoiceList {get; set;}
	
	//public List<Invoice__c> lstInvoices{set; get;}
	//public List<Bill__c> lstBills{set; get;}
	
	public Transaction__c objTranscation;
	//For Wrapper
	public List<TransactionWrapper> wrappers {get; set;}
	public TransactionWrapper wrapper{get;set;}

	public set<String> stInvoiceStatus = new set<String>{'Sent', 'Partially Paid'};
	public List<String> lstStatuses = new List<String>();
	public Transaction__c merch { get; set; }
	
	public static final String TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT = Label.TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT; 
	
	/*
	*	Set Default values to Visual Force page
	*/  
	public TransactionController(ApexPages.StandardController stdController) {
		controller   = stdController;
		blnShowBills = true;
		blnEditMode  = false;
		//blnCreditTransLineItems = false;
		blnDebitTransLineItems = false;
		blnError = false;
		totalAmount=0.00;
		
		//Create Related List
		objTranscation = (Transaction__c)controller.getRecord();
		List<Account> lstAccount = [select Name From Account Where Id=:objTranscation.Account__c];
		if(lstAccount.size() > 0)
			strAccountName = lstAccount.get(0).Name;
		
		
		strTransName = [select Name FROM RecordType WHERE Id =: objTranscation.RecordTypeId limit 1].Name;
		
		 List<Status__c> cslstStatus = Status__c.getall().values();
		 for(Status__c csObj: cslstStatus){
		 	lstStatuses.add(csObj.Name);
		 }
		  //For multiple rows
		  wrappers=new List<TransactionWrapper>();
		  Id transactionId = objTranscation.Id;
		  this.merch = getMerchandise(transactionId);
		  disableInput = true;
	}
	
	 //To Sace Transaction Update
	 public PageReference save() {
        controller.save();//invoke standard Save method
        blnEditMode = false;
        blnShowBills = true;
        return Apexpages.currentPage();//refresh current page
    }
    
    // Method called on click of the Clone button
    public PageReference ClonePage(){
    	return new PageReference('/'+objTranscation.Id+'/e?clone=1&retURL='+objTranscation.Id);
    }
    
    //Redirect VF to Standard Edit Page of Transaction 
    public PageReference Edit_val() {
        blnEditMode = true;
        return new PageReference('/'+ objTranscation.Id+'/e?retURL=%2F'+objTranscation.Id);
    }
    
    //To Cancel Edit Fucntionality
    public PageReference cancelEdit() {
        blnEditMode = false;
        return Apexpages.currentPage();//refresh current page
    }
    
   
    //Reset Transaction Line Items
    public PageReference resetTransaction() {
    	totalAmount = 0.00;
    	invoiceList=null;
        return null;
    }
    
    //Create New Transaction Line Items Again Transaction
    public PageReference createCreditTranscations() {
    	totalAmount = 0.00;
    	if( strTransName == 'Debit'){
    		blnDebitTransLineItems = true;
    	}else{
    		blnCreditTransLineItems = true;
    	}
    	invoiceList=null;
        return null;
    }
   
    //Cancel Credit Transaction Line Items
    public PageReference cancelCreditTranscations() {
        blnDebitTransLineItems = false;
    	blnCreditTransLineItems = false;
    	return null;
    }
  
 //Create Multiple Transaction Line Items against Transaction. 
 public class TransactionWrapper
 {
 	 public Transaction_Line_Credit__c acc {get; private set;}
 	 public Transaction_Line_Credit__c cred {get; private set;}
 	 public Transaction_Line_Debit__c debitacc {get; private set;}
 	 public Transaction_Line_Debit__c debt {get; private set;}
 	 public Invoice__c invc{get;set;}
 	 public Bill__c bill{get;set;}
	 public Boolean selected {get; set;}
	
	  public TransactionWrapper(Invoice__c invoice, Transaction_Line_Credit__c credits)//Id id)
	 {
		  invc = invoice;
		  cred = credits;
		  selected = false;
	 }
	 
	 public TransactionWrapper(Bill__c tempbill, Transaction_Line_Debit__c debits)//Id id)
	 {
		  bill = tempbill;
		  debt = debits;
		  selected = false;
	 }
 }
 
	/*
		To Credit Related Transaction Line Items
	*/ 
   public PageReference processSelected() {
		List<Invoice__c> selectedInvoices = new List<Invoice__c>();
		List<Transaction_Line_Credit__c> selectedLineItems = new List<Transaction_Line_Credit__c>();
		
		totalAmount = 0.00;
		for(TransactionWrapper cCon: getInvoices()) {
			if( cCon.cred.Amount__c != null){
				totalAmount += cCon.cred.Amount__c; 
				selectedInvoices.add(cCon.invc);
				selectedLineItems.add(cCon.cred);
			}
		}
		
		if(selectedLineItems.size() > 0){
			try{
				List<Transaction__c> lstTempTran = [SELECT Amt_Non_Hourly__c FROM Transaction__c WHERE Id=:objTranscation.Id limit 1];
				if(lstTempTran.size() > 0){
					Decimal tempAmount = lstTempTran.get(0).Amt_Non_Hourly__c!= null?lstTempTran.get(0).Amt_Non_Hourly__c:0.00;
					totalAmount += getRollupAmount();
					
					if(totalAmount <= tempAmount){
						insert selectedLineItems;
						blnCreditTransLineItems = false;	
						blnError = false;		
						invoiceList=null;	  
				    }else{
					    blnCreditTransLineItems = true;
						blnError = true;
						ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT);
						ApexPages.addMessage(myMsg); 
				    }
				}
			}catch(Exception e){
				blnCreditTransLineItems = true;
				blnError = true;
				ApexPages.addMessages(e);
			}
		}
	
	    return null;
	}
	
	//To Get All Invoices and Create Transacton Credit Line Items
	public List<TransactionWrapper> getInvoices() {
		if(invoiceList == null) {
				
			invoiceList = new List<TransactionWrapper>();
			for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
			 				   Invoice_Amount_Paid__c, Date_Sent__c, Amount_Due__c
							   From Invoice__c 
							   WHERE Account__c =: objTranscation.Account__c
							   AND Status__c NOT IN : lstStatuses]) 
			{
	
				Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
				invoiceList.add(new TransactionWrapper(c, newCredit));
			}
		}		
		return invoiceList;
	}

	/***Credit Related Trans End***/
	 public PageReference processSelectedDebits() {
 	
		List<Bill__c> selectedInvoices = new List<Bill__c>();
		List<Transaction_Line_Debit__c> selectedLineItems = new List<Transaction_Line_Debit__c>();
		
		totalAmount = 0.00;
		for(TransactionWrapper cCon: getBills()) {
			//if(cCon.selected == true) {
			if(cCon.debt.Amount__c != null){
				totalAmount += cCon.debt.Amount__c; 
				selectedInvoices.add(cCon.bill);
				selectedLineItems.add(cCon.debt);
			}
		}

		if(selectedLineItems.size() > 0){
			try{
				List<Transaction__c> lstTempTran = [SELECT Amt_Non_Hourly__c FROM Transaction__c WHERE Id=:objTranscation.Id limit 1];
				if(lstTempTran.size() > 0){
					Decimal tempAmount = lstTempTran.get(0).Amt_Non_Hourly__c != null?lstTempTran.get(0).Amt_Non_Hourly__c:0.00;
					totalAmount += getRollupAmount();
					if(totalAmount <= tempAmount){
						insert selectedLineItems;
						blnDebitTransLineItems = false;	
						blnError = false;	
						invoiceList=null;
					}else{
						blnDebitTransLineItems = true;
						blnError = true;
						ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT);
						ApexPages.addMessage(myMsg); 	
					}
				}				
			}catch(Exception e){
				blnDebitTransLineItems = true;
				blnError = true;
				ApexPages.addMessages(e);
				//return ApexPages.currentPage();
			}
		}
		
        return null;
	}
	
	//To Get All Bills and Create Transacton Line Debit Items
	public List<TransactionWrapper> getBills() {
		
		if(invoiceList == null) {
			invoiceList = new List<TransactionWrapper>();
			for(Bill__c b: [select Id, Name, Bill_Date__c, Amount_Due__c,
							Bill_Amount_Due__c,
							 Due_Date__c,
			 				   Memo__c, Status__c, Bill_Amount_Paid__c, Amount_Roll_Up__c
							   From Bill__c 
							   WHERE Vendor__c =: objTranscation.Account__c
							   AND Status__c NOT IN : lstStatuses]) {
	
				Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Bill__c = b.Id, Transaction__c = objTranscation.Id);
				invoiceList.add(new TransactionWrapper(b, newDebit));
			}
		}
		return invoiceList;
	}
	
    //Field set to Create detail page section
    public List<Schema.FieldSetMember> getColumn1Fields() {
        return SObjectType.Transaction__c.FieldSets.TransactionFieldSetColumn1.getFields();
    }
    
    //Field set to Create detail page section
    public List<Schema.FieldSetMember> getColumn2Fields() {
        return SObjectType.Transaction__c.FieldSets.TransactionFieldSetColumn2.getFields();
    }
	
	//Field set to Create detail page section
    public List<Schema.FieldSetMember> getColumn3Fields() {
        return SObjectType.Transaction__c.FieldSets.TransactionFieldSetColumn3.getFields();
    }
    
	public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Transaction__c.FieldSets.TransactionFieldSet.getFields();
    }
    
	//TO get Transaction Details page Record
    private Transaction__c getMerchandise(Id transactionId) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Transaction__c WHERE Id=\''+transactionId+'\' LIMIT 1';
  		
        return Database.query(query);
    }
 	
 	 public void autoPopulate1() {}
 	/*
 		1)On Select of Check Box: 
 			Amount_Due, Paid Date and Total of Transaction LineItems autopopulated.
 		2)On Blur of Amount Due Input Field:Total of Transaction LineItems Amount autopopulated.
 	*/
 	public PageReference autoPopulate() {
 	 	totalAmount = 0.00;
 	 	if( strTransName == 'Debit'){
 	 		for(TransactionWrapper cCon: getBills()) {
				if( cCon.debt.Amount__c != null){
					totalAmount += cCon.debt.Amount__c; 
					system.debug('**totalAmount**'+totalAmount);
				}
			}
 	 	}else{
	 	 	for(TransactionWrapper cCon: getInvoices()) {
				if( cCon.cred.Amount__c != null){
					totalAmount += cCon.cred.Amount__c; 
					system.debug('**totalAmount**'+totalAmount);
				}
			}
 	 	}
 	 	totalAmount += getRollupAmount();
 	 	system.debug('*after rollup*totalAmount**'+totalAmount);
 	 	return null;
 	 }
 	 
 	 
 	 //To Set Current Date on Transaction Line Item. Event onChnage is applied
 	 public String getCurrentDate(){
 	 	Date tempdate = System.today();
 	 	Integer dd = tempdate.day();
 	 	Integer mm = tempdate.month();
 	 	Integer yyyy = tempdate.year();
 	 	return mm+'/'+dd+'/'+yyyy;
 	 }
 	 private Decimal getRollupAmount(){
 	 	AggregateResult[] groupedResults;//=[Select SUM(t.Amount__c)  am From Transaction_Line_Debit__c t WHERE Transaction__c =: objTranscation.Id];
 	 	if( strTransName == 'Debit'){
 	 		groupedResults=[Select SUM(t.Amount__c)  amt From Transaction_Line_Debit__c t WHERE Transaction__c =: objTranscation.Id];
 	 	}else{
 	 		groupedResults=[Select SUM(t.Amount__c)  amt From Transaction_Line_Credit__c t WHERE Transaction__c =: objTranscation.Id];
 	 	}
 	 	
 	 	Decimal amount=0.00;
		for (AggregateResult ar : groupedResults)  {
			if(ar.get('amt') != null)
				amount = Decimal.valueOf(String.valueOf(ar.get('amt')));
		}
 	 	return amount; 	 	
 	 }
}