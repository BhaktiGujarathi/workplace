public with sharing class TransactionControllerTest {
    
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
    //InvoiceList of Transaction Wrapper
    public List<TransactionWrapper> invoiceList {get; set;}
    
    public Transaction__c objTranscation{get; set;}
    //For Wrapper
    public List<TransactionWrapper> wrappers {get; set;}
    public TransactionWrapper wrapper{get;set;}

    public set<String> stInvoiceStatus = new set<String>{'Sent', 'Sent - Partially Paid'};
    public List<String> lstStatuses = new List<String>();
    public Transaction__c merch { get; set; }
    
    public static final String TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT = Label.TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT; 
    public static final String BILL_PAID_AMT_EXCEEDS_BALANCE_AMT = Label.BILL_PAID_AMT_EXCEEDS_BALANCE_AMT;
    public static final String TRAN_LINE_ITEM_AMT_EXCEEDS_INV_DUE_AMT = Label.TRAN_LINE_ITEM_AMT_EXCEEDS_INV_DUE_AMT;
   // public static final String TRAN_LINE_ITEM_AMT_MATCH_TRAN_AMT = Label.TRAN_LINE_ITEM_AMT_MATCH_TRAN_AMT;
    /*
    *   Set Default values to Visual Force page
    */  
     private String sortDirection = 'ASC';
       private String sortExp = 'name';
    
       public String sortExpression
       {
         get
         {
            return sortExp;
         }
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
     
    public TransactionControllerTest(ApexPages.StandardController stdController) {
        try{
            controller   = stdController;
            blnShowBills = true;
            blnEditMode  = false;
            blnNewMode = true;
            //blnCreditTransLineItems = false;
            blnDebitTransLineItems = false;
            blnError = false;
            totalAmount=0.00;
            
            //Create Related List
            objTranscation = (Transaction__c)controller.getRecord();
             List<Status__c> cslstStatus = Status__c.getall().values();
             for(Status__c csObj: cslstStatus){
                lstStatuses.add(csObj.Name);
             }
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
            //  Id transactionId = objTranscation.Id;
            //  this.merch = getMerchandise(transactionId);
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
       Schema.DescribeSObjectResult dsr = Transaction__c.SObjectType.getDescribe(); 
       return new Pagereference('/'+dsr.getKeyPrefix()+'/o');
        //return new PageReference('/a0P/o');
       
    }
    
   
    //Reset Transaction Line Items
    public PageReference resetTransaction() {
        totalAmount = 0.00;
        invoiceList=null;
        return null;
    }
    //Create New Transaction Line Items Again Transaction
    public void create(){
        
        system.debug('inside create()');
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
 
    //To Sace Transaction Update
     public PageReference save() {
        autopopulate();
        if(totalAmount > objTranscation.Amt_Non_Hourly__c)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_LINE_ITEM_AMT_EXCEEDS_TRAN_AMT);
            ApexPages.addMessage(myMsg);
            return null;
        }
        else
        {
            try{
            //controller.save();//invoke standard Save method
               //insert objTranscation;
               if(objTranscation.Id == null)
                   insert objTranscation;
               else
                   update objTranscation;
               List<Transaction_Line_Credit__c> selectedLineItems = new List<Transaction_Line_Credit__c>();
               List<Transaction_Line_Debit__c> selectedLineItemsDebit = new List<Transaction_Line_Debit__c>();
               if( strTransName == 'Credit'){
                   for(TransactionWrapper cCon: getInvoices()) {
                        if( cCon.cred.Amount__c != null){
                            if(cCon.invc.Amount_Due__c < cCon.cred.Amount__c){
                                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_LINE_ITEM_AMT_EXCEEDS_INV_DUE_AMT);
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
            for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
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

    //To Get All Bills and Create Transacton Line Debit Items
    public List<TransactionWrapper> getBills() {
          //invoiceList = null;
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
    
     public void autoPopulate1() {}
    /*
        1)On Select of Check Box: 
            Amount_Due, Paid Date and Total of Transaction LineItems autopopulated.
        2)On Blur of Amount Due Input Field:Total of Transaction LineItems Amount autopopulated.
    */
    public PageReference autoPopulate() {
        system.debug('inside autoPopulate');
        totalAmount = 0.00;
        if( strTransName == 'Debit'){
            for(TransactionWrapper cCon: getBills()) {
                if( cCon.debt.Amount__c != null){
                    totalAmount += cCon.debt.Amount__c; 
                    system.debug('**totalAmount**'+totalAmount);
                }
            }
            }else{
            //system.debug('getInvoices'+getInvoices());
            for(TransactionWrapper cCon: getInvoices()) {
                if( cCon.cred.Amount__c != null){
                    totalAmount += cCon.cred.Amount__c; 
                    system.debug('**totalAmountCredit**'+totalAmount);
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
     
     public PageReference getCheckedValuesCredit() {
      system.debug('inside if'+invoiceList);
        invoiceList = null;         
        if(invoiceList == null) {
            system.debug('inside if');    
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses]) 
            {
     system.debug('inside if'+c.Total_Amount_Due__c);
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);             
                    newCredit.Amount__c = c.Total_Amount_Due__c;
                    newCredit.Date__c = System.today();
                    TransactionWrapper tw=new TransactionWrapper(c, newCredit);
                    tw.selected = true;
                    invoiceList.add(tw);
                }
             }
        }   
        return null;
    }
    
    public PageReference getCheckedValues() {
    system.debug('inside if'+invoiceList);
         invoiceList = null;
        if(invoiceList == null) {
        system.debug('inside if');
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                 for(Bill__c b: [select Id, Name, Bill_Date__c, Amount_Due__c,
                            Bill_Amount_Due__c,
                             Due_Date__c,
                               Memo__c, Status__c, Bill_Amount_Paid__c, Amount_Roll_Up__c
                               From Bill__c 
                               WHERE Vendor__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses]) {
                system.debug('inside if'+b.Bill_Amount_Due__c);
                Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Bill__c = b.Id, Transaction__c = objTranscation.Id);
                    newDebit.Amount__c = b.Bill_Amount_Due__c;
                    newDebit.Date__c = System.today();
                    TransactionWrapper tw=new TransactionWrapper(b, newDebit);
                    tw.selected = true;
                    invoiceList.add(tw);
                }
             }
        }
        return null;
    }
    
    
     
      public PageReference ViewSortedData_Name() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       //string query = 
      //List<Receivable__c> lstRecevaible = Database.query('select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,Amount__c,Receivable_Amount_Paid__c, Date_Sent__c, Amount_Due__c, Due_From_Account__c From Receivable__c WHERE Due_From_Account__c =: '+objTranscation.Account__c +'AND Status__c NOT IN  '+lstStatuses+' order by '+sortFullExp);
       invoiceList = null;
       invoiceList = new List<TransactionWrapper>();
       if(sortDirection=='ASC'){
      for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Name ASC]) 
                {
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       }
       else{
        for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Name DESC]) 
                {
                   Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       
       }
       //query the database based on the sort expression
      // accounts = Database.query('Select id, Name, BillingCity, BillingCountry, Phone from Account order by ' + sortFullExp + ' limit 1000');
       return null;
   }
   
    public PageReference ViewSortedData_SentDate() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       //string query = 
      //List<Receivable__c> lstRecevaible = Database.query('select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,Amount__c,Receivable_Amount_Paid__c, Date_Sent__c, Amount_Due__c, Due_From_Account__c From Receivable__c WHERE Due_From_Account__c =: '+objTranscation.Account__c +'AND Status__c NOT IN  '+lstStatuses+' order by '+sortFullExp);
       invoiceList = null;
       invoiceList = new List<TransactionWrapper>();
       if(sortDirection=='ASC'){
      for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Date_Sent__c ASC]) 
                {
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       }
       else{
        for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Date_Sent__c DESC]) 
                {
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       
       }
       //query the database based on the sort expression
      // accounts = Database.query('Select id, Name, BillingCity, BillingCountry, Phone from Account order by ' + sortFullExp + ' limit 1000');
       return null;
   }
   
   public PageReference ViewSortedData_Amount() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       invoiceList = null;
       invoiceList = new List<TransactionWrapper>();
       if(sortDirection=='ASC'){
      for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Price_Conga__c ASC]) 
                {
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       }
       else{
        for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Price_Conga__c DESC]) 
                {
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       
       }
       return null;
   }
    public PageReference ViewSortedData_AmoutDue() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       invoiceList = null;
       invoiceList = new List<TransactionWrapper>();
       if(sortDirection=='ASC'){
      for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Total_Amount_Due__c ASC]) 
                {
                   Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
                    invoiceList.add(new TransactionWrapper(c, newCredit));
                }
       }
       else{
        for(Invoice__c c: [select Id, Name, Date_Paid__c, Status__c,Price_Conga__c,
                               Total_Amount_Paid__c, Date_Sent__c, Total_Amount_Due__c,Amount_Due__c
                               From Invoice__c 
                               WHERE Account__c =: objTranscation.Account__c
                               AND Status__c NOT IN : lstStatuses
                                           order by Total_Amount_Due__c DESC]) 
                {
                    Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Invoice__c = c.Id, Transaction__c = objTranscation.Id);
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
       System.debug('objTranscation.Account__c'+objTranscation.Account__c);
       string AccId = [select Id FROM Account WHERE Id =: objTranscation.Account__c limit 1].Id;
       System.debug('Id'+AccId);
       
       String query = 'select Id, Name, Bill_Date__c, Amount_Due__c, Bill_Amount_Due__c,Due_Date__c,Memo__c, Status__c, Bill_Amount_Paid__c, Amount_Roll_Up__c From Bill__c  WHERE Vendor__c = \''+AccId+'\'' +' AND Bill_Amount_Due__c > 0 order by '+sortFullExp;
       system.debug('query'+query);
       //query the database based on the sort expression
       List<Bill__c> lstPay= Database.query(query);
       for(Bill__c b:lstPay)
       {
            Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Bill__c = b.Id, Transaction__c = objTranscation.Id);
            invoiceList.add(new TransactionWrapper(b, newDebit));
       }
       return null;
   }
}