/*Modified by :Ashwini 
 *Date: Description:to add negative value to amount paid to credits
 *Shorthand:MCA-729
 *     Date            Author           Description
 *  05/27/2016       Yogesh M         Added method for filters on 
 *                                    Credit and Debit Tables
 *                   Yogesh M         Added Methods for creating paybales for
 *                                    Multiple Accounts.
 *
  */
public with sharing class TransactionController_New {

    public Boolean disableInput {get; set;}
    public Integer sizeOfPayables{get; set;}
    public Integer sizeOfReceivables{get; set;}
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
    public boolean blnCheckbox{get; set;}
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
    public static final String TRAN_CRED_LINE_ITEM_AMT_MATCH_TRAN_AMT = Label.TransactionCreditAmountMustEqualTransactionAmount;
    public static final String TRAN_DEBT_LINE_ITEM_AMT_MATCH_TRAN_AMT = Label.TransactionDebitAmountMustEqualTransactionAmount;
    public static final String TRAN_AMT_EXCEEDS_REC_DUE_AMT = Label.Transaction_PaidAmountExceedRecDueAmt;
    public static final String BILL_PAID_AMT_EXCEEDS_BALANCE_AMT = Label.Transaction_BillPaidAmountExceedsBalanceAmount;
    public static final String TRAN_AMT_MUST_BE_FILLED = Label.Transaction_TransactionAmountmustBeFilled;
    public static final String Tran_AMT_MUST_BE_POS_VAL = Label.Transaction_TransactionAmountMustBePositive;
    public static final String AMOUNT_PAID_MUST_BE_POSITIVE = Label.Transaction_AmountPaidMustBePositive;
    public static final String NEED_TO_INPUT_ACCOUNT = Label.Transaction_NeedToInputAccount;
    public static final String STAGE_PAID = 'Paid';
    public static final String STAGE_Cancelled = 'Cancelled';
    public String sortDirection  {get; set;}
    public String sortExpression {get; set;}
    
    public Static Boolean selectAllCreditCheckBox                                       {get; set;}
    public Static Boolean selectAllDebitCheckBox                                        {get; set;}
    public static Boolean selectAllPayAccCheckBox                                       {get; set;}
    // for sorting
    public Boolean isSorted;
    public static String pFieldToSort                                                   {get; set;}
    
    // For Filter
    public Receivable__c objRec                                                         {get; set;}
    public Receivable__c objRecForDate                                                  {get; set;}
    public Payable__c objPay                                                            {get; set;}
    public Payable__c objPayForDate                                                     {get; set;}
    public Boolean isFilter;
    public Integer counterVal                                                           {get; set;}
    public List<TransactionWrapper> listWrappers                                        {get; set;}
    
    // for multiple account transaction functinality
    public Boolean accountsFlag                                                         {get; set;}
    public Boolean multipleAccounts                                                     {get; set;}
    public List<PayAccount> payAccountLst                                               {get; set;}
    public Set<Id> accountIdsSet                                                        {get; set;}
    
    public string indexToSelect                                                         {get; set;}
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     } 
    
    /*
    *   Set Default values to Visual Force page
    */ 
    public TransactionController_New(ApexPages.StandardController stdController) {
        try{
            counterVal = 0;
            isFilter = false;
            objRec = new Receivable__c();
            objRec.Status__c = null;
            objRecForDate = new Receivable__c();
            objRec.Due_From_Account__r = new Account();
            
            objPay = new Payable__c();
            objPay.Status__c = null;
            objPayForDate = new Payable__c();
            objPay.Account__r = new Account();
            
            accountsFlag = false;
            multipleAccounts = false;
            payAccountLst = new List<PayAccount>();
            accountIdsSet = new Set<Id>();
            
            listWrappers = new List<TransactionWrapper>();
            invoiceList = new List<TransactionWrapper>();
            isSorted = false;
            controller   = stdController;
            blnShowBills = true;
            blnEditMode  = false;
            blnNewMode = true;
            selectAllCreditCheckBox = false;
            selectAllDebitCheckBox = false;
            selectAllPayAccCheckBox = false;
            blnCreditTransLineItems = false;
            
            blnDebitTransLineItems = false;
            blnError = false;
            totalAmount=0.00;
            state = false;
            sortDirection = 'ASC';
            sortExpression = 'name';
            pFieldToSort = '';
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
                System.debug('---111---'+e.getMessage());
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
        //return new Pagereference('/'+dsr.getKeyPrefix()+'/o');
        return new Pagereference('/'+dsr.getKeyPrefix());
        //return Apexpages.currentPage();//refresh current page
    }
   
    //Reset Transaction Line Items
    public PageReference resetTransaction() {
        totalAmount = 0.00;
        
        selectAllDebitCheckBox = false;
        selectAllCreditCheckBox = false;
        blnCheckboxDebit = false;
        blnCheckbox = false;
        for(TransactionWrapper wrapperInstance : invoiceList)
        {
            wrapperInstance.selected = false;
            if(strTransName == 'Debit')
            {
                wrapperInstance.debt.Amount__c = NULL;
                wrapperInstance.debt.Date__c = NULL;
                wrapperInstance.debt.Memo__c = NULL;
            }
            else
            {
                wrapperInstance.cred.Amount__c = null;
                wrapperInstance.cred.Date__c = null;
                wrapperInstance.cred.Memo__c = null;
            }
        }
        //isFilter = false;
        return null;
        
    }
    //Create New Transaction Line Items Again Transaction
    public void create(){
        List<Account> lstAccount = [select Name, Type From Account Where Id=:objTranscation.Account__c];
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
        clearRecFilter();
        clearPayFilter();
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
         /*if(multipleAccounts)
         {
             saveMultipleTransaction();
         }
         else
         {*/
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
             
             if(objTranscation.Account__c == null && multipleAccounts==false)
             {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,NEED_TO_INPUT_ACCOUNT);
                ApexPages.addMessage(myMsg);
                return null;
             }
            autopopulate();

            if(totalAmount <> objTranscation.Amount__c)
            {
                ApexPages.Message myMsg;
                if(strTransName == 'Credit'){
                     myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_CRED_LINE_ITEM_AMT_MATCH_TRAN_AMT );
                }
                else {
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_DEBT_LINE_ITEM_AMT_MATCH_TRAN_AMT );
                }
                ApexPages.addMessage(myMsg);
                return null;
            }
            else
            {
                Savepoint svPntTransaction = Database.setSavepoint();
                try{
                    objTranscation.Status__c ='Pending';
                   if(objTranscation.Id == null)
                   {
                       if(multipleAccounts == true && strTransName == 'Debit')
                       {
                            Id devRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Debit - Multiple').getRecordTypeId();
                            strTransName = 'Debit - Multiple';
                            objTranscation.RecordTypeId = devRecordTypeId;
                       }
                        insert objTranscation;
                   }
                   else
                       update objTranscation;
                    
                    
                   List<Transaction_Line_Credit__c> selectedLineItems = new List<Transaction_Line_Credit__c>();
                   List<Transaction_Line_Debit__c> selectedLineItemsDebit = new List<Transaction_Line_Debit__c>();

                   
                   if(strTransName == 'Credit'){
                       for(TransactionWrapper cCon: invoiceList) {
                            if( cCon.cred.Amount__c != null){
                                /*if(cCon.cred.Amount__c == 0){//MCA-729
                                    ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,AMOUNT_PAID_MUST_BE_POSITIVE);
                                   ApexPages.addMessage(myMsg1);
                                    return null;
                                }*/
                                if(cCon.invc.Amount_Due__c < cCon.cred.Amount__c){
                                    ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,TRAN_AMT_EXCEEDS_REC_DUE_AMT);
                                    ApexPages.addMessage(myMsg1);
                                    Database.rollback(svPntTransaction);
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
                        for(TransactionWrapper cCon: invoiceList) {
                            
                        if(cCon.debt.Amount__c != null){
                        
                          /*  if(cCon.bill.Bill_Amount_Due__c < cCon.debt.Amount__c){
                             ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,BILL_PAID_AMT_EXCEEDS_BALANCE_AMT);
                                ApexPages.addMessage(myMsg1);   
                                     return null;
                            }
                            else{
                           */ 
                                cCon.debt.Transaction__c = objTranscation.Id;
                                selectedLineItemsDebit.add(cCon.debt);
                            //}
                           
                            }
                        }//end of for
                    insert selectedLineItemsDebit;
                   }
                }//end of try

                catch(Exception e){
                        ApexPages.addMessages(e);
                        Database.rollback(svPntTransaction);
                        return null;
                        //return ApexPages.currentPage();
                    }
            }//end of else-big
        //}
        Schema.DescribeSObjectResult dsr = Transaction__c.SObjectType.getDescribe();
        return new PageReference('/'+dsr.getKeyPrefix());
        //return new PageReference('/'+objTranscation.Id);//refresh current page
    }
    
    //To Get All Invoices and Create Transacton Credit Line Items
    public List<TransactionWrapper> getInvoices() {
        List<Receivable__c> recList = new List<Receivable__c>();
        if(objTranscation.Account__c != null)
        {
            List<Account> lstAccount = [select Name, Type From Account Where Id=:objTranscation.Account__c];
            if(lstAccount.size() > 0)
                strAccountName = lstAccount.get(0).Name;
        }
        if(isFilter) {
            invoiceList.clear();
            listWrappers.clear();
        }
        
        if(invoiceList == null || invoiceList.isEmpty()) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null)
             {
                try 
                {
                    recList = Database.query(baseQueryRece());
                    if(!recList.isEmpty())
                    {
                    for(Receivable__c c :recList) {
                        Transaction_Line_Credit__c newCredit = new Transaction_Line_Credit__c(Receivable__c = c.Id, Transaction__c = objTranscation.Id);
                        invoiceList.add(new TransactionWrapper(c, newCredit));
                    }//end for 
                    }
                }
                catch(Exception ex) 
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Recievable records found');
                    ApexPages.addMessage(myMsg);
                }
            }
        }
        sizeOfReceivables = invoiceList.size();
        autoPopulate(); 
        return invoiceList;
    }
    
     //To Get All Bills and Create Transacton Line Debit Items //getCheckedValuesCredit
    public List<TransactionWrapper> getBills() {
        if(objTranscation.Account__c != null)
        {
            List<Account> lstAccount = [select Name, Type From Account Where Id=:objTranscation.Account__c];
            if(lstAccount.size() > 0)
                strAccountName = lstAccount.get(0).Name;
        }
        if(isFilter) {
            invoiceList.clear();
            //
        }
        if(invoiceList == null || invoiceList.isEmpty()) {
            invoiceList = new List<TransactionWrapper>();
             if(objTranscation.Account__c != null  || !accountIdsSet.isEmpty())
             {
                 try 
                 {
                    for(Payable__c c :Database.query(baseQueryPay())) {
                        Transaction_Line_Debit__c newDebit = new Transaction_Line_Debit__c(Payable__c = c.Id, Transaction__c = objTranscation.Id);
                        invoiceList.add(new TransactionWrapper(c, newDebit));
                    }
                 }
                 catch(Exception ex) 
                 {
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Payable records found');
                     ApexPages.addMessage(myMsg);
                 }
             }
        }
        sizeOfPayables = invoiceList.size(); 
        autoPopulate();
        return invoiceList;
    }
    
    
    //On click of Select all checkbox- all debit line items get selected
    public PageReference getCheckedValues() {
         if(blnCheckboxDebit != true){
         {
            for(TransactionWrapper wrapperInstance : invoiceList) 
            {
                wrapperInstance.selected = true;
                if(wrapperInstance.debt.Amount__c == NULL)
                {
                    wrapperInstance.debt.Amount__c = wrapperInstance.bill.Bill_Amount_Due__c;
                }
                if(wrapperInstance.debt.Date__c == NULL)
                {
                    wrapperInstance.debt.Date__c = System.today();
                }
                if(wrapperInstance.debt.Memo__c == NULL)
                {
                    wrapperInstance.debt.Memo__c = wrapperInstance.bill.Memo__c;
                }
            }
            blnCheckboxDebit = true;
            selectAllDebitCheckBox = true;
        }
         }
         else{
         {
            for(TransactionWrapper wrapperInstance : invoiceList) 
            {
                wrapperInstance.selected = false;
                wrapperInstance.debt.Amount__c = NULL;
                wrapperInstance.debt.Date__c = NULL;
                wrapperInstance.debt.Memo__c = NULL;
                
            }
            blnCheckboxDebit = false;
            selectAllDebitCheckBox = false;
        }
         }
        autoPopulate(); 
        return null;
    }

    //On click of Select all checkbox- all credit line items get selected
    public PageReference getCheckedValuesCredit() {
        if(blnCheckbox != true){
        {
            for(TransactionWrapper wrapperInstance : invoiceList) 
            {
                wrapperInstance.selected = true;
                if(wrapperInstance.cred.Amount__c == NULL)
                {
                    wrapperInstance.cred.Amount__c = wrapperInstance.invc.Amount_Due__c;
                }
                if(wrapperInstance.cred.Date__c == NULL)
                {
                    wrapperInstance.cred.Date__c = System.today();
                }
                if(wrapperInstance.cred.Memo__c == NULL)
                {
                    wrapperInstance.cred.Memo__c = wrapperInstance.invc.Memo__c;
                }

            }
            blnCheckbox = true;
            selectAllCreditCheckBox = true;
        }
        }
        else{
         {
            for(TransactionWrapper wrapperInstance : invoiceList) 
            {
                wrapperInstance.selected = false;
                wrapperInstance.cred.Amount__c = null;
                wrapperInstance.cred.Date__c = null;
                wrapperInstance.cred.Memo__c = null;
            }
            blnCheckbox=false;
            selectAllCreditCheckBox = false;
        }
        } 
        autoPopulate();
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
        if(strTransName == 'Debit'){
            for(TransactionWrapper cCon: invoiceList) {
                if(cCon.selected == true)
                {
                    if(cCon.debt.Amount__c == null)
                    {
                        cCon.debt.Amount__c = cCon.bill.Bill_Amount_Due__c;
                    }
                    if(cCon.debt.Date__c == null)
                    {
                        cCon.debt.Date__c = System.today();
                    }
                    if(cCon.debt.Memo__c == null)
                    {
                        cCon.debt.Memo__c = cCon.bill.Memo__c;
                    }
                }
                else
                {
                    cCon.debt.Amount__c = null; 
                    cCon.debt.Date__c = null;
                    cCon.debt.Memo__c = null;
                }
                
            }
            if(selectAllDebitCheckBox == true) {
                selectAllDebitCheckBox = false;
                blnCheckboxDebit = false;
            }
        }else{
        
            for(TransactionWrapper cCon: invoiceList) {
                if(cCon.selected == true){
                    if(cCon.cred.Amount__c == NULL)
                    {
                        cCon.cred.Amount__c = cCon.invc.Amount_Due__c;
                    }
                    if(cCon.cred.Date__c == NULL)
                    {
                        cCon.cred.Date__c = System.today();
                    }
                    if(cCon.cred.Memo__c == NULL)
                    {
                        cCon.cred.Memo__c = cCon.invc.Memo__c;
                    }
                }
                else
                {
                    cCon.cred.Amount__c=null; 
                    cCon.cred.Date__c=null; 
                    cCon.cred.Memo__c = null;
                }
                
            }
            if(selectAllCreditCheckBox == true) {
                selectAllCreditCheckBox = false;
                blnCheckbox=false;
            }
        }
        autoPopulate();
     }
     
    /*
        1)On Select of Check Box: 
            Amount_Due, Paid Date and Total of Transaction LineItems autopopulated.
        2)On Blur of Amount Due Input Field:Total of Transaction LineItems Amount autopopulated.
    */
    public PageReference autoPopulate() {
        totalAmount = 0.00;
        if( strTransName == 'Debit'){
            for(TransactionWrapper cCon: invoiceList) {
                if( cCon.debt.Amount__c != null){
                    cCon.selected = true;
                    if(cCon.debt.Date__c == null)
                    {
                        cCon.debt.Date__c = System.today();
                    }
                    if(cCon.debt.Memo__c == null)
                    {
                        cCon.debt.Memo__c = cCon.bill.Memo__c;
                    }
                    totalAmount += cCon.debt.Amount__c; 
                }
            }
        }else if( strTransName == 'Credit') {
            for(TransactionWrapper cCon: invoiceList) {
                if(cCon.cred.Amount__c != null){
                    cCon.selected = true;
                    if(cCon.cred.Date__c == NULL)
                    {
                        cCon.cred.Date__c = System.today();
                    }
                    if(cCon.cred.Memo__c == NULL)
                    {
                        cCon.cred.Memo__c = cCon.invc.Memo__c;
                    }
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
      
   //To Set Current Date on Transaction Line Item. Event onChnage is applied
     public String getCurrentDate(){
        Date tempdate = System.today();
        Integer dd = tempdate.day();
        Integer mm = tempdate.month();
        Integer yyyy = tempdate.year();
        return mm+'/'+dd+'/'+yyyy;
     }
     
     public void sortAscInputFields()
     {
         pFieldToSort = Apexpages.currentPage().getParameters().get('sortField');
         String pFieldType = Apexpages.currentPage().getParameters().get('typeField');
         String prefixStr = '';
         prefixStr = [SELECT MasterLabel,
                                    Prefix__c
                             FROM PackageNamePrefix__mdt
                             WHERE MasterLabel = 'MCAApp'][0].Prefix__c;
         
         if(pFieldToSort.contains('Credit')) {
             if(prefixStr != null) 
                 sortExpression = prefixStr + pFieldToSort.substringAfter('Credit') +'__c';
             else 
               sortExpression = pFieldToSort.substringAfter('Credit') +'__c';  
         }
         else If (pFieldToSort.contains('Debit')) {
             if(prefixStr != null)
                 sortExpression = prefixStr + pFieldToSort.substringAfter('Debit') +'__c';
             else 
                 sortExpression = pFieldToSort.substringAfter('Debit') +'__c';
         }
         else If (pFieldToSort.contains('Receivable')) {
             if(prefixStr != null)
                 sortExpression = prefixStr + pFieldToSort.substringAfter('Receivable') +'__c';
             else 
                 sortExpression = pFieldToSort.substringAfter('Receivable') +'__c';
         }
         else If (pFieldToSort.contains('Payable')) {
             if(prefixStr != null)
                 sortExpression = prefixStr + pFieldToSort.substringAfter('Payable') +'__c';
             else 
                 sortExpression = pFieldToSort.substringAfter('Payable') +'__c';
         }
         else If (pFieldToSort.startsWith('Account')) {
                sortExpression = pFieldToSort.substringAfter('Account');
                payAccountLst = MultipleAccountTransaction.sortAccountList(payAccountLst, sortExpression, sortDirection, pFieldType);
         } 

         List<TransactionWrapper> pInvoices = new List<TransactionWrapper>();
         pInvoices.addAll(invoiceList);
         object obj1;
         object obj2;
         for(Integer i= 0; i< pInvoices.size(); i++)
         {

             for(Integer j = i+1; j < pInvoices.size(); j++)
             {
                 if(pFieldToSort.contains('Credit') && !sortExpression.contains('Name'))
                 {
                     obj1 = pInvoices[i].cred.get(sortExpression);
                     obj2 = pInvoices[j].cred.get(sortExpression); 
                 }
                 else if(pFieldToSort.contains('Debit') && !sortExpression.contains('Name'))
                 {
                     obj1 = pInvoices[i].debt.get(sortExpression);
                     obj2 = pInvoices[j].debt.get(sortExpression);
                 }
                 else if(pFieldToSort.contains('Receivable') && !sortExpression.contains('Name'))
                 {
                     obj1 = pInvoices[i].invc.get(sortExpression);
                     obj2 = pInvoices[j].invc.get(sortExpression);
                 }
                 else if(pFieldToSort.contains('Payable') && !sortExpression.contains('Name'))
                 {
                     obj1 = pInvoices[i].bill.get(sortExpression);
                     obj2 = pInvoices[j].bill.get(sortExpression);
                 }
                 if(sortDirection.equalsIgnoreCase('ASC'))
                 {
                 if(pFieldType.equalsIgnoreCase('Decimal'))
                 {
                    
                    if(obj1 != null && obj2 != null)
                    {
                        if((Decimal)obj1 > (Decimal)obj2)
                        {
                            swapWrapper(pInvoices, i, j);
                        }
                     }
                    else if(obj1 == null && obj2 != null)
                    {
                        swapWrapper(pInvoices, i, j);
                    }
                 }
                 
                 if(pFieldType.equalsIgnoreCase('Date'))
                 {
                     
                     if(obj1 != null && obj2 != null)
                    {
                         if((Date)obj1 > (Date)obj2)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                     }
                     else if(obj1 == null && obj2 != null)
                    {
                        swapWrapper(pInvoices, i, j);
                    }
                 }
                 
                 if(pFieldType.equalsIgnoreCase('String'))
                 {
                     if(obj1 != null && obj2 != null)
                     {
                         if((String)obj1 > (String)obj2)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                     }
                     else if(obj1 == null && obj2 != null)
                     {
                         swapWrapper(pInvoices, i, j);
                     }    
                 }
                 if(pFieldType.equalsIgnoreCase('Lookup'))
                     {
                        sortExpression = sortExpression;
                        if(pFieldToSort.contains('Receivable'))
                        {
                            obj1 = pInvoices[i].invc.Opportunity__r.Name;
                            obj2 = pInvoices[j].invc.Opportunity__r.Name;
                        }
                        else if(pFieldToSort.contains('Payable'))
                        {
                            if(pFieldToSort.contains('Opportunity'))
                            {
                                obj1 = pInvoices[i].bill.Opportunity__r.Name;
                                obj2 = pInvoices[j].bill.Opportunity__r.Name;
                            }
                            if(pFieldToSort.contains('Account'))
                            {
                                obj1 = pInvoices[i].bill.Account__r.Name;
                                obj2 = pInvoices[j].bill.Account__r.Name;
                            }
                        }
                        
                        if(obj1 != null && obj2 != null)
                        {
                            if((String)obj1 > (String)obj2)
                            {
                                 swapWrapper(pInvoices, i, j);
                            }
                        }
                        else if(obj1 == null && obj2 != null)
                        {
                             swapWrapper(pInvoices, i, j);
                        }    
                    }
                    if(pFieldType.equalsIgnoreCase('Name'))
                    {
                        sortExpression = sortExpression.substringbefore('__c');
                        if(pFieldToSort.contains('Receivable'))
                        {
                            obj1 = pInvoices[i].invc.get(sortExpression);
                            obj2 = pInvoices[j].invc.get(sortExpression);
                        }
                        else if(pFieldToSort.contains('Payable'))
                        {
                            obj1 = pInvoices[i].bill.get(sortExpression);
                            obj2 = pInvoices[j].bill.get(sortExpression);
                        }
                        
                        if(obj1 != null && obj2 != null)
                        {
                            if((String)obj1 > (String)obj2)
                            {
                                 swapWrapper(pInvoices, i, j);
                            }
                        }
                        else if(obj1 == null && obj2 != null)
                        {
                             swapWrapper(pInvoices, i, j);
                        }
                    }
                 }
                 else
                 {
                     if(pFieldType.equalsIgnoreCase('Decimal'))
                     {
                         if(obj1 != null && obj2 != null)
                         {
                            if((Decimal)obj1 < (Decimal)obj2)
                             {
                                 swapWrapper(pInvoices, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                        
                     }
                 
                     if(pFieldType.equalsIgnoreCase('Date'))
                     {
                         if(obj1 != null && obj2 != null)
                         {
                             if((Date)obj1 < (Date)obj2)
                             {
                                 swapWrapper(pInvoices, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                     }
                 
                     if(pFieldType.equalsIgnoreCase('String'))
                     {
                         if(obj1 != null && obj2 != null)
                         {
                             if((String)obj1 < (String)obj2)
                             {
                                 swapWrapper(pInvoices, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                     }
                     if(pFieldType.equalsIgnoreCase('Lookup'))
                     {
                        sortExpression = sortExpression;
                        if(pFieldToSort.contains('Receivable'))
                        {
                            obj1 = pInvoices[i].invc.Opportunity__r.Name;
                            obj2 = pInvoices[j].invc.Opportunity__r.Name;
                        }
                        else if(pFieldToSort.contains('Payable'))
                        {
                            if(pFieldToSort.contains('Opportunity'))
                            {
                                obj1 = pInvoices[i].bill.Opportunity__r.Name;
                                obj2 = pInvoices[j].bill.Opportunity__r.Name;
                            }
                            if(pFieldToSort.contains('Account'))
                            {
                                obj1 = pInvoices[i].bill.Account__r.Name;
                                obj2 = pInvoices[j].bill.Account__r.Name;
                            }
                        }
                        
                        if(obj1 != null && obj2 != null)
                         {
                             if((String)obj1 < (String)obj2)
                             {
                                 swapWrapper(pInvoices, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                    }
                    if(pFieldType.equalsIgnoreCase('Name'))
                    {
                        
                        sortExpression = sortExpression.substringbefore('__c');
                        if(pFieldToSort.contains('Receivable'))
                        {
                            obj1 = pInvoices[i].invc.get(sortExpression);
                            obj2 = pInvoices[j].invc.get(sortExpression);
                        }
                        else if(pFieldToSort.contains('Payable'))
                        {
                            obj1 = pInvoices[i].bill.get(sortExpression);
                            obj2 = pInvoices[j].bill.get(sortExpression);
                        }
                        if(obj1 != null && obj2 != null)
                         {
                             if((String)obj1 < (String)obj2)
                             {
                                 swapWrapper(pInvoices, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pInvoices, i, j);
                         }
                    }
                 }
             }
         }

         invoiceList.clear();
         invoiceList.addAll(pInvoices); 

     }
     // method to swap the wrapper instances
     public void swapWrapper(List<TransactionWrapper> pLst, Integer iIndex, Integer jIndex)
     {
        TransactionWrapper tempWraper = pLst[iIndex];
        pLst[iIndex] = pLst[jIndex];
        pLst[jIndex] = tempWraper;
        
     }
     
      // Dynamic query to fetch Credits
    public String baseQueryRece() 
    {
        return whereConditionRec('SELECT ID'
                                    +', Name'
                                    +', Date_Paid__c'
                                    +', Status__c'
                                    +', Amount__c'
                                    +', Type__c'
                                    +', Opportunity__c'
                                    +', Opportunity__r.Name'
                                    +', Due_Date__c'
                                    +', Receivable_Amount_Paid__c'
                                    +', Date_Sent__c'
                                    +', Amount_Due__c'
                                    +', Due_From_Account__c'
                                    +', Memo__c'
                                +' FROM Receivable__c');
    }//end baseQueryRece()
    
    //method to build dynamic query for Debit
    public String baseQueryPay() 
    {
        return whereConditionPay('SELECT Id'
                                        +', Name' 
                                        +', Payable_Date__c' 
                                        +', Amount_Due__c'
                                        +', Bill_Amount_Due__c'
                                        +', Account__c'
                                        +', Type__c'
                                        +', Account__r.Name'
                                        +', Account__r.Type'
                                        +', Due_Date__c'
                                        +', Opportunity__c'
                                        +', Opportunity__r.Name'
                                        +', Memo__c'
                                        +', Status__c' 
                                        +', Bill_Amount_Paid__c'
                                 +' FROM Payable__c');
    }
    
    // method to construct where condition
    public String whereConditionRec(String baseQuery) 
    {
        String queryString = '';
        
        queryString = baseQuery+ ' WHERE Due_From_Account__c =\''+objTranscation.Account__c
                                    +'\' AND Status__c NOT IN :lstStatuses';
        if(isFilter == true)
        {
            if(objRec.Due_From_Account__r.Type <> null)
                queryString = queryString + ' AND Due_From_Account__r.Type =\''+objRec.Due_From_Account__r.Type+'\'';
            if(objRec.Type__c <> null)
                queryString = queryString + ' AND Type__c =\''+objRec.Type__c+'\'';
            if(objRec.Status__c <> null)
                queryString = queryString + ' AND Status__c =\''+objRec.Status__c+'\'';
            if(objRec.Date_Sent__c <> null) 
                queryString = queryString + ' AND (Date_Sent__c <= '+dateConvert(objRec.Date_Sent__c)+'';
            if(objRecForDate.Date_Sent__c <> null) 
                queryString = queryString + ' AND Date_Sent__c >= '+dateConvert(objRecForDate.Date_Sent__c)+'';
            if(objRec.Date_Sent__c <> null) 
                queryString = queryString +' )';
            if(objRec.Due_Date__c <> null) 
                queryString = queryString + ' AND (Due_Date__c <= '+dateConvert(objRec.Due_Date__c)+'';
            if(objRecForDate.Due_Date__c <> null) 
                queryString = queryString + ' AND Due_Date__c >= '+dateConvert(objRecForDate.Due_Date__c)+'';
            if(objRec.Due_Date__c <> null) 
                queryString = queryString +' )';
                
            isFilter = false;
        }
        return queryString;
    }//end whereCondition() 
    
    // method to construct where condition
    public String whereConditionPay(String baseQuery) 
    {
        String queryString = '';
        if(multipleAccounts) {
            queryString = baseQuery+ ' WHERE Account__c IN : accountIdsSet';
        }
        else {
            queryString = baseQuery+ ' WHERE Account__c =\''+objTranscation.Account__c+'\'';
        }
        
        queryString = queryString +' AND Status__c NOT IN :lstStatuses';
        if(isFilter == true)
        {
            if(objPay.Account__r.Type <> null)
                queryString = queryString + ' AND Account__r.Type =\''+objPay.Account__r.Type+'\'';
            if(objPay.Type__c <> null)
                queryString = queryString + ' AND Type__c =\''+objPay.Type__c+'\'';
            if(objPay.Status__c <> null)
                queryString = queryString + ' AND Status__c =\''+objPay.Status__c+'\'';
            if(objPay.Payable_Date__c <> null) 
                queryString = queryString + ' AND (Payable_Date__c <= '+dateConvert(objPay.Payable_Date__c)+'';
            if(objPayForDate.Payable_Date__c <> null) 
                queryString = queryString + ' AND Payable_Date__c >= '+dateConvert(objPayForDate.Payable_Date__c)+'';
            if(objPay.Payable_Date__c <> null) 
                queryString = queryString +' )';
            if(objPay.Due_Date__c <> null) 
                queryString = queryString + ' AND (Due_Date__c <= '+dateConvert(objPay.Due_Date__c)+'';
            if(objPayForDate.Due_Date__c <> null) 
                queryString = queryString + ' AND Due_Date__c >= '+dateConvert(objPayForDate.Due_Date__c)+'';
            if(objPay.Due_Date__c <> null) 
                queryString = queryString +' )';
                
            isFilter= false;
        }
        return queryString;
    }//end whereCondition() 
    
    // method to get date value from datetime
    public String dateConvert(Date dValue) 
    {
        return (string.valueOf(dValue)).substringBefore(' ');
    }
    
    // method to clear invoices value
    public void clearInvoiceVal() 
    {
        resetTransaction();
        sortDirection = 'ASC';
        pFieldToSort = '';
        sortExpression= 'name';
        isFilter = true;
        selectAllCreditCheckBox = false;
        blnCheckbox = false;
        counterVal++;
    }
    
   // method to get filtered Debits
    public void fetchFilteredDebits() 
    {
        resetTransaction();
        sortDirection = 'ASC';
        pFieldToSort = '';
        sortExpression= 'name';
        isFilter = true;
        selectAllDebitCheckBox = false;
        blnCheckboxDebit = false;
        counterVal++;
    }
    // method to clear filters
    public void clearRecFilter() 
    {
        objRec.Due_From_Account__r.Type = null;
        objRec.Type__c = null;
        objRec.Status__c= null;
        objRec.Date_Sent__c = null;
        objRecForDate.Date_Sent__c = null;
        objRec.Due_Date__c = null;
        objRecForDate.Due_Date__c = null;
        isFilter = false;
        selectAllCreditCheckBox = false;
        blnCheckbox = false;
        sortDirection = 'ASC';
        pFieldToSort = '';
        sortExpression= 'name';
        resetTransaction();
        invoiceList.clear();
    }
    // method to clear Debit filters
    public void clearPayFilter() 
    {
        objPay.Account__r.Type = null;
        objPay.Type__c = null;
        objPay.Status__c= null;
        objPay.Payable_Date__c = null;
        objPayForDate.Payable_Date__c = null;
        objPay.Due_Date__c = null;
        objPayForDate.Due_Date__c = null;
        isFilter = false;
        selectAllDebitCheckBox = false;
        blnCheckboxDebit = false;
        sortDirection = 'ASC';
        pFieldToSort = '';
        sortExpression= 'name';
        resetTransaction();
        invoiceList.clear();
    }
    
    // method to show accounts with open Payables
    public void showAccounts()
    {
        objTranscation.Account__c = null;
        objTranscation.Amount__c = null;
        strAccountName = '';
        payAccountLst.clear();
        payAccountLst = MultipleAccountTransaction.fetchAccountWithOpenPayablesFromDB(
                                                                    payAccountLst, lstStatuses);
        if(!payAccountLst.isEmpty())
        {
            accountsFlag = true;
            invoiceList.clear();
        }
        else
        {
            accountsFlag = false;
            invoiceList.clear();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.TransactionErrorMsgForNoAccountForMultiplePayeeFound);
            ApexPages.addMessage(myMsg);
        }
        
    }
    
    // method to form a set of ids of accounts
    public void buildAccountIdSet()
    {
        accountIdsSet.clear();
        for(PayAccount payAccountObj : payAccountLst)
        {
            if(payAccountObj.isSelected == true)
                accountIdsSet.add(payAccountObj.accObj.Id);
        }
        clearPayFilter();
        resetTransaction();
        
        multipleAccounts = true;
        getBills();
    }
    
    // method to reset to single Payee 
    public void resetSinglePayee()
    {
        multipleAccounts = false;
        accountsFlag = false;
        accountIdsSet.clear();
        clearPayFilter();
    }
    
    // method to unselect the select all checkbox in one checkbox is unchecked
    public void allAccountUnselect()
    {
        if(selectAllPayAccCheckBox==true)
            selectAllPayAccCheckBox= false;
    }
    
    // wrapper class to hold account and its related payable list
    public class PayAccount
    {
        public Account accObj                                                           {get; set;}
        public Decimal totalAmountDue                                                   {get; set;}
        public List<Payable__c> payableLst                                              {get; set;}
        public Boolean isSelected                                                       {get; set;}
        
        public PayAccount(Account pAccObj, Decimal pTotalAmountDue, List<Payable__c> pPayLst)
        {
            accObj = pAccObj;
            totalAmountDue = pTotalAmountDue;
            payableLst = pPayLst;
            isSelected = false;
        }
    }
}