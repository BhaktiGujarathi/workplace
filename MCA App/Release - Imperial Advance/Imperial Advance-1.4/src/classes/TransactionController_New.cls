public with sharing class TransactionController_New {

    public Boolean disableInput {get; set;}
    public Apexpages.StandardController controller;
    public boolean blnShowBills{set;get;}
    public boolean blnEditMode{set;get;}
    public boolean blnNewMode{set;get;}
    public boolean blnTransType{set;get;}
    public String strTransName{set; get;}
    public boolean blnCreditTransLineItems{set;get;}
    public boolean blnDebitTransLineItems{set;get;}
    public boolean blnError{set;get;}
    public String strAccountName{set;get;}
    public String totalTransactionAmount{set;get;}
    public Decimal totalAmount{set;get;}
    public String query ;
    public boolean blnCheckbox;
    public boolean blnCheckboxDebit;
    //InvoiceList of Transaction Wrapper
    public List<TransactionWrapper> invoiceList {get; set;}
    public Transaction__c objTranscation{get; set;}
    //For Wrapper
    public List<TransactionWrapper> wrappers {get; set;}
    public TransactionWrapper wrapper{get;set;}
    public set<String> stInvoiceStatus = new set<String>{'Sent', 'Partially Paid'};
    public List<String> lstStatuses = new List<String>();
    public Set<String> setStatuses = new Set<String>();
    public Transaction__c merch { get; set; }
    public boolean state{set;get;}
    public static final String TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT = Label.Transaction_LineItemAmountExceedsTransactionAmount; 
    //public static final String TRAN_LINE_ITEM_AMT_MATCH_TRAN_AMT = Label.TRAN_LINE_ITEM_AMT_MATCH_TRAN_AMT;
    public static final String TRAN_AMT_EXCEEDS_REC_DUE_AMT = Label.Transaction_PaidAmountExceedRecDueAmt;
    public static final String BILL_PAID_AMT_EXCEEDS_BALANCE_AMT = Label.Transaction_BillPaidAmountExceedsBalanceAmount;
    public static final String TRAN_AMT_MUST_BE_FILLED = Label.Transaction_TransactionAmountmustBeFilled;
    public static final String Tran_AMT_MUST_BE_POS_VAL = Label.Transaction_TransactionAmountMustBePositive;
    public static final String AMOUNT_PAID_MUST_BE_POSITIVE = Label.Transaction_AmountPaidMustBePositive;
    public static final String STAGE_PAID = 'Paid';
    public static final String STAGE_Cancelled = 'Cancelled';
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    
    public String sortExpression
    {
         get { return sortExp; }
         set
         {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
        }
    }
    
     public String getSortDirection()
     {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     } 
    
    /*
    *   Set Default values to Visual Force page
    */ 
    public TransactionController_New(ApexPages.StandardController stdController) {
        try{
            controller   = stdController;
            blnShowBills = true;
            blnEditMode  = false;
            blnNewMode = true;
            
            blnCreditTransLineItems = false;
            
            blnDebitTransLineItems = false;
            blnError = false;
            totalAmount=0.00;
            state = false;
            //Create Related List
             objTranscation = (Transaction__c)controller.getRecord();
             List<Status__c> cslstStatus = Status__c.getall().values();
             for(Status__c csObj: cslstStatus){
                lstStatuses.add(csObj.Name);
             }
             setStatuses.addAll(lstStatuses);
             
             strTransName = [select Name FROM RecordType WHERE Id =: objTranscation.RecordTypeId limit 1].Name;
             if( strTransName == 'Debit'){
                blnDebitTransLineItems = true;
                blnCreditTransLineItems = false;
            }else{
                blnCreditTransLineItems = true;
                blnDebitTransLineItems = false;
            }
              //For multiple rows
              wrappers=new List<TransactionWrapper>();
              disableInput = true;
         }
         catch(Exception e){
                ApexPages.addMessages(e);
                    //return ApexPages.currentPage();
        }
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
         //return new PageReference('/a19/o');
         
        Schema.DescribeSObjectResult dsr = Transaction__c.SObjectType.getDescribe(); 
        return new Pagereference('/'+dsr.getKeyPrefix()+'/o');
        //return Apexpages.currentPage();//refresh current page
    }
   
    //Reset Transaction Line Items
    public PageReference resetTransaction() {
        totalAmount = 0.00;
        invoiceList=null;
        return null;
    }
    //Create New Transaction Line Items Again Transaction
    public void create(){
        List<Account> lstAccount = [select Name From Account Where Id=:objTranscation.Account__c];
        if(lstAccount.size() > 0)
            strAccountName = lstAccount.get(0).Name;
        strTransName = [select Name FROM RecordType WHERE Id =: objTranscation.RecordTypeId limit 1].Name;
        if( strTransName == 'Debit'){
            blnDebitTransLineItems = true;
             blnCreditTransLineItems = false;
             
        }else{
            blnCreditTransLineItems = true;
            blnDebitTransLineItems = false;
        }
        invoiceList=null;
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
         public Transaction_Line_Credit__c acc {get;  set;}
         public Transaction_Line_Credit__c cred {get;  set;}
         public Transaction_Line_Debit__c debitacc {get;  set;}
         public Transaction_Line_Debit__c debt {get;  set;}
         public Receivable__c invc{get;set;}
         public Payable__c bill{get;set;}
         public Boolean selected {get; set;}
        
          public TransactionWrapper(Receivable__c invoice, Transaction_Line_Credit__c credits)//Id id)
         {
              invc = invoice;
              cred = credits;
              selected = false;
         }
         
         public TransactionWrapper(Payable__c tempbill, Transaction_Line_Debit__c debits)//Id id)
         {
              bill = tempbill;
              debt = debits;
              selected = false;
         }
     }
 
    //To Save Transaction Update
     public PageReference save() {
         if(objTranscation.Amount__c == null)
         {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_AMT_MUST_BE_FILLED);
            ApexPages.addMessage(myMsg);
            return null;
         }
         if(objTranscation.Amount__c < 0)
         {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Tran_AMT_MUST_BE_POS_VAL);
            ApexPages.addMessage(myMsg);
            return null;
         }
        autopopulate();
        if(totalAmount > objTranscation.Amount__c)
        {
            system.debug('@@@total'+totalAmount );
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT);
            ApexPages.addMessage(myMsg);
            return null;
        }
        else
        {
            try{
                objTranscation.Status__c ='Pending';
               if(objTranscation.Id == null)
                   insert objTranscation;
               else
                   update objTranscation;
               List<Transaction_Line_Credit__c> selectedLineItems = new List<Transaction_Line_Credit__c>();
               List<Transaction_Line_Debit__c> selectedLineItemsDebit = new List<Transaction_Line_Debit__c>();
               
               system.debug('************'+strTransName );
               
               if( strTransName == 'Credit'){
                   for(TransactionWrapper cCon: getInvoices()) {
                        if( cCon.cred.Amount__c != null){
                            if(cCon.cred.Amount__c < 0){
                                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,AMOUNT_PAID_MUST_BE_POSITIVE);
                                ApexPages.addMessage(myMsg1);   
                                return null;
                            }
                            if(cCon.invc.Amount_Due__c < cCon.cred.Amount__c){
                                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_AMT_EXCEEDS_REC_DUE_AMT);
                                ApexPages.addMessage(myMsg1);   
                                return null;
                            }
                            else{
                            cCon.cred.Transaction__c = objTranscation.Id;
                            selectedLineItems.add(cCon.cred);
                            }
                        }
                    }//end of for
                insert selectedLineItems;
               }
               else{
                    for(TransactionWrapper cCon: getBills()) {
                    if(cCon.debt.Amount__c != null){
                        if(cCon.bill.Bill_Amount_Due__c < cCon.debt.Amount__c){
                            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,BILL_PAID_AMT_EXCEEDS_BALANCE_AMT);
                            ApexPages.addMessage(myMsg1);   
                                 return null;
                        }
                        else{
                            cCon.debt.Transaction__c = objTranscation.Id;
                            selectedLineItemsDebit.add(cCon.debt);
                        }
                        }
                    }//end of for
                insert selectedLineItemsDebit;
               }
            }//end of try
            catch(Exception e){
                    ApexPages.addMessages(e);
                    //return ApexPages.currentPage();
                }
        }//end of else-big
        return new PageReference('/'+objTranscation.Id);//refresh current page
    }
    
    //To Get All Invoices and Create Transacton Credit Line Items
    public List<TransactionWrapper> getInvoices() {
        List<Account> lstAccount = [select Name From Account Where Id=:objTranscation.Account__c];
        if(lstAccount.size() > 0)
            strAccountName = lstAccount.get(0).Name;
        if(invoiceList == null) {
                
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Receivable__c c: [select Id, Name, Date_Paid__c, Status__c,Amount__c,
                                           Receivable_Amount_Paid__c, Date_Sent__c, Amount_Due__c, Due_From_Account__c
                                           From Receivable__c 
                                            WHERE Due_From_Account__c =: objTranscation.Account__c
                                           AND Status__c NOT IN : lstStatuses]) 
                {
        
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Receivable__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
             }
        }
      
        return invoiceList;
    }
    
    //To Get All Bills and Create Transacton Line Debit Items //getCheckedValuesCredit
    public List<TransactionWrapper> getBills() {
        if(invoiceList == null) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Payable__c b: [select Id, Name, Payable_Date__c, Amount_Due__c,
                                    Bill_Amount_Due__c,Account__c,
                                     Due_Date__c,
                                       Memo__c, Status__c, Bill_Amount_Paid__c
                                       From Payable__c 
                                       WHERE Account__c =: objTranscation.Account__c
                                       AND Status__c NOT IN : lstStatuses
                                       AND Bill_Amount_Due__c > 0]) {
        
                    Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Payable__c = b.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(b, newDebit));
                }
             }
        }
        system.debug('@@@'+invoiceList);   
        return invoiceList;
    }
    
    //On click of Select all checkbox- all debit line items get selected
    public PageReference getCheckedValues() {
        invoiceList = null;
        //blnCheckboxDebit
         if(blnCheckboxDebit != true){
        if(invoiceList == null) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Payable__c b: [select Id, Name, Payable_Date__c, Amount_Due__c,
                                    Bill_Amount_Due__c,Account__c,
                                     Due_Date__c,
                                       Memo__c, Status__c, Bill_Amount_Paid__c
                                       From Payable__c 
                                       WHERE Account__c =: objTranscation.Account__c
                                       AND Status__c NOT IN : lstStatuses
                                       AND Bill_Amount_Due__c > 0]) {
        
                    Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Payable__c = b.Id, Transaction__c = objTranscation.Id);
	                newDebit.Amount__c = b.Bill_Amount_Due__c;
	                newDebit.Date__c = System.today();
                    TransactionWrapper tw=new TransactionWrapper(b, newDebit);
                    tw.selected = true;
                    invoiceList.add(tw);
                    blnCheckboxDebit=true;
                }
             }
        }
         }
         else{
         	if(invoiceList == null) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Payable__c b: [select Id, Name, Payable_Date__c, Amount_Due__c,
                                    Bill_Amount_Due__c,Account__c,
                                     Due_Date__c,
                                       Memo__c, Status__c, Bill_Amount_Paid__c
                                       From Payable__c 
                                       WHERE Account__c =: objTranscation.Account__c
                                       AND Status__c NOT IN : lstStatuses
                                       AND Bill_Amount_Due__c > 0]) {
        
                    Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Payable__c = b.Id, Transaction__c = objTranscation.Id);
                    newDebit.Amount__c = null;
	                newDebit.Date__c = null;
                    TransactionWrapper tw=new TransactionWrapper(b, newDebit);
                    tw.selected = false;
                    invoiceList.add(tw);
                    blnCheckboxDebit=false;
                }
             }
        }
         }
        return null;
    }

    //On click of Select all checkbox- all credit line items get selected
    public PageReference getCheckedValuesCredit() {
        invoiceList = null;
        if(blnCheckbox != true){
        if(invoiceList == null) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Receivable__c c: [select Id, Name, Date_Paid__c, Status__c,Amount__c,
                                           Receivable_Amount_Paid__c, Date_Sent__c, Amount_Due__c, Due_From_Account__c
                                           From Receivable__c 
                                            WHERE Due_From_Account__c =: objTranscation.Account__c
                                           AND Status__c NOT IN : lstStatuses]) 
                {
        
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Receivable__c = c.Id, Transaction__c = objTranscation.Id);
	                newCredit.Amount__c = c.Amount_Due__c;
	                newCredit.Date__c = System.today();
                    TransactionWrapper tw=new TransactionWrapper(c, newCredit);
                    tw.selected = true;
                    invoiceList.add(tw);
                    blnCheckbox=true;
                }
             }
        }  
        }
        else{
        	if(invoiceList == null) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Receivable__c c: [select Id, Name, Date_Paid__c, Status__c,Amount__c,
                                           Receivable_Amount_Paid__c, Date_Sent__c, Amount_Due__c, Due_From_Account__c
                                           From Receivable__c 
                                            WHERE Due_From_Account__c =: objTranscation.Account__c
                                           AND Status__c NOT IN : lstStatuses]) 
                {
        
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Receivable__c = c.Id, Transaction__c = objTranscation.Id);
                    newCredit.Amount__c = null;
	                newCredit.Date__c = null;
                    TransactionWrapper tw=new TransactionWrapper(c, newCredit);
                    tw.selected = false;
                    invoiceList.add(tw);
                    blnCheckbox=false;
                }
             }
        }
        } 
        return null;
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
    
     public void autoPopulate1() {
     	/*if(blnCheckbox == true){
     		blnCheckbox = false;
     		removeEntryonUncheck();
     	}
     	blnCheckbox = true;*/
     	if( strTransName == 'Debit'){
            for(TransactionWrapper cCon: getBills()) {
            	if(cCon.selected != true)
                {
                    cCon.debt.Amount__c=null; 
                    cCon.debt.Date__c = null;
                }
            }
            }else{
            for(TransactionWrapper cCon: getInvoices()) {
              
                if(cCon.selected != true){
                    cCon.cred.Amount__c=null; 
                    cCon.cred.Date__c=null; 
                }
            }
        }
     	
     }
     
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
                }
            }
            }else{
            for(TransactionWrapper cCon: getInvoices()) {
              
                if( cCon.cred.Amount__c != null){
                    totalAmount += cCon.cred.Amount__c; 
                }
            }
        }
        totalAmount += getRollupAmount();
        return null;
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
     
     public PageReference setState(){
        state = true;
        return null;
     }
   
     public PageReference ViewSortedData_Receivable(){
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       invoiceList = null;
       invoiceList = new List<TransactionWrapper>();       
       string AccId = [select Id FROM Account WHERE Id =: objTranscation.Account__c limit 1].Id; 
       Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Receivable__c.fields.getMap();
        string fieldnames = ' ';
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            fieldnames += s + ',';
        }   
       fieldnames = fieldnames.substring(0,fieldnames.length()-1);
       string query = 'select '+ fieldnames+' From '+SObjectType.Receivable__c.Name +' WHERE Due_From_Account__c = \''+AccId+'\' order by ' +sortFullExp; 
       system.debug('@@@@'+query);
       List<Receivable__c> lstRecevaible = Database.query(query);
       for(Receivable__c c: lstRecevaible)
       {
            //if(c.Status__c == 'Pending')
            if(!setStatuses.contains(c.Status__c))
            {
                system.debug('@@@Status'+c.Status__c);
                Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Receivable__c = c.Id, Transaction__c = objTranscation.Id);
                invoiceList.add(new TransactionWrapper(c, newCredit));
            }
       }
        return null;
     }
     public PageReference ViewSortedData_PayableName() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       invoiceList = null;
       invoiceList = new List<TransactionWrapper>();       
       string AccId = [select Id FROM Account WHERE Id =: objTranscation.Account__c limit 1].Id;   
        Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Payable__c.fields.getMap();
        string fieldnames = ' ';
        for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            fieldnames += s + ',';
        }   
       fieldnames = fieldnames.substring(0,fieldnames.length()-1);
       query = 'select'+fieldnames+ ' From '+ 
                SObjectType.Payable__c.Name +' WHERE '+SObjectType.Payable__c.fields.Account__c.Name +' = \''+
                AccId+'\'' +' AND '+ SObjectType.Payable__c.fields.Bill_Amount_Due__c.Name  + ' > 0 order by '+sortFullExp;
       system.debug('query'+query);
       
       //query the database based on the sort expression
       List<Payable__c> lstPay= Database.query(query);
       for(Payable__c b:lstPay)
       {
            if(b.Status__c != STAGE_PAID || b.Status__c != STAGE_Cancelled)
            {
                Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Payable__c = b.Id, Transaction__c = objTranscation.Id);
                invoiceList.add(new TransactionWrapper(b, newDebit));
            }
       }
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
}