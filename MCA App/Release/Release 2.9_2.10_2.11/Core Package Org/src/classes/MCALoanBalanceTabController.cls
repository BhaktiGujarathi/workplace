public with sharing class MCALoanBalanceTabController {
  
 // public String inlineEdit {get; set;}

  public Loan_Balance__c[] loanBalances;
  public Container[] containers;

  public Loan_Balance__c[] newLoanBalances {get; set;}

  public Boolean editAll {get;set;}
  public Boolean isFirst;
  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}

  private Id opportunityId;

  public Decimal balanceTotal {get; set;}
  public Decimal paymentTotal {get; set;}
  
  public List<Account> banklist {get; Set;}
  public Integer bankSize {get; set;}
  
  public boolean funderPicklist{get; set;}
  public Boolean isUpdated;
  public Map<Id, Loan_Balance__c> mapIDANDloanBalance;
  public List<Loan_Balance__c> listToUpdate;
  public Boolean isValidation;
  
  public MCALoanBalanceTabController() {
    isFirst=true;
    isValidation = false;
    mapIDANDloanBalance = new Map<Id, Loan_Balance__c>();
    opportunityId = Apexpages.currentPage().getParameters().get('id');
   // inlineEdit = 'false';
    funderPicklist = false;
    refresh();
  }

  public Container[] getContainers() {

    balanceTotal = 0;
    paymentTotal = 0;
    loanBalances = new Loan_Balance__c[] {};
    loanBalances.addAll(newLoanBalances);
    if(isFirst && !editAll && !isValidation) {
        isFirst=false;
        for (Loan_Balance__c lb :[SELECT
                                        Id,
                                        Active__c,
                                        Balance__c,
                                        Daily_Payment__c,
                                        Funder__c,
                                        Maturity_Date__c,
                                        Name,
                                        Notes__c 
                                    FROM Loan_Balance__c
                                    WHERE Opportunity__c = :opportunityId]) {
        loanBalances.add(lb);
        balanceTotal += lb.Balance__c != null ? lb.Balance__c : 0;
        paymentTotal += lb.Daily_Payment__c != null ? lb.Daily_Payment__c : 0;
        system.debug('****Inside query***'+loanBalances);
        }
    }else{
        for (Container containerVal: containers) {
            if (recordToDelete!=null){
                if(containerVal.loanBalance.id<> recordToDelete){
                    loanBalances.add(containerVal.loanBalance);
                }
            }else if(containerVal.index!=indexToRemove) {
                   loanBalances.add(containerVal.loanBalance);
            }
            
       }
       //reinitializing for delete and remove
       recordToDelete=null;
       indexToRemove=-99;
    }
    containers = new Container[] {};
    for (Integer i = 0; i < loanBalances.size(); i++) {
      containers.add(new Container(loanBalances[i], i));
    }
    newLoanBalances=new List<Loan_Balance__c>();
    getBankNames();
    return containers;
  }
    
  
  public void newLoanBalance() {
    saveMessage();
    newLoanBalances.add(new Loan_Balance__c(Opportunity__c = opportunityId));
  }
  
  public void saveMessage(){
    isUpdated = false;
    checkoldAndNewVal();
    if(editAll !=true && isUpdated == true){
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
        updateInlineEditedValue();
    }
  }
  
  public void loanBalanceList(){
    mapIDANDloanBalance.clear();
    mapIDANDloanBalance = new Map<Id, Loan_Balance__c>([SELECT
                                                        Id,
                                                        Active__c,
                                                        Balance__c,
                                                        Daily_Payment__c,
                                                        Funder__c,
                                                        Maturity_Date__c,
                                                        Name,
                                                        Notes__c 
                                                    FROM Loan_Balance__c
                                                    WHERE Opportunity__c = :opportunityId]);
  }
  public void updateInlineEditedValue() {
        try{
            update listToUpdate;
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    public void checkoldAndNewVal() {
        listToUpdate = new List<Loan_Balance__c>();
        Loan_Balance__c  LoanBalenceValue = new Loan_Balance__c ();
        loanBalanceList();
        for (Container containerVal: containers) {
            if(containerVal.loanBalance.id != null){
                LoanBalenceValue = mapIDANDloanBalance.get(containerVal.loanBalance.id);
                if(LoanBalenceValue!= null) {       
                    if(containerVal.loanBalance.Active__c != LoanBalenceValue.Active__c
                    || containerVal.loanBalance.Balance__c != LoanBalenceValue.Balance__c
                    || containerVal.loanBalance.Daily_Payment__c != LoanBalenceValue.Daily_Payment__c
                    || containerVal.loanBalance.Funder__c != LoanBalenceValue.Funder__c
                    || containerVal.loanBalance.Maturity_Date__c != LoanBalenceValue.Maturity_Date__c
                    || containerVal.loanBalance.Name != LoanBalenceValue.Name
                    || containerVal.loanBalance.Notes__c  != LoanBalenceValue.Notes__c) {
                        listToUpdate.add(containerVal.loanBalance);
                        isUpdated = true;
                    }
                }
            }
        }
    }

  public void refresh() {
   balanceTotal = 0;
    paymentTotal = 0;   
    isFirst=true;
    editAll = false;
    recordToDelete = null;
    newLoanBalances = new Loan_Balance__c[] {};
    containers = new Container[] {};
  }
  
   public List<SelectOption> getBankNames()
    {
      List<SelectOption> options = new List<SelectOption>();
      List<RecordType> bankRecordTypeId = [Select r.Name, r.Id From RecordType r where r.Name = 'Bank'];
      banklist = new List<Account>();
      if(bankRecordTypeId.size() > 0)
        banklist = [Select Id, Name, RecordTypeId FROM Account where RecordTypeId =: bankRecordTypeId[0].Id  order by Name];
      bankSize = banklist.size();
      //options.add(new SelectOption('','--None--'));
      for (Integer j=0;j<banklist.size();j++)
      {
          String bankName = banklist[j].Name;
          options.add(new SelectOption(banklist[j].Id,bankName));
      }
      system.debug('*****options getBankNames****'+options);
      
      return options;
    }
  
   public void editAll() {
    editAll = true;
  }

  public void save(){}
  public void saveAllLoans() {
    isValidation = false;
    try{
        upsert loanBalances;
    }
    catch(Exception e){
        isValidation = true;
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
    }
    refresh();
  }

  public void deleteLoanBalance() {
    saveMessage();
    if (recordToDelete != null) {
      Loan_Balance__c record = [SELECT Id FROM Loan_Balance__c WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void removeLoanBalance() {
    saveMessage();
  }

  public class Container {

    public Loan_Balance__c loanBalance {get;set;}
    public Integer index {get;set;}

    public Container(Loan_Balance__c instance, Integer index) {
      loanBalance = instance;
      this.index = index;
    }

  }

}