public with sharing class MCALoanBalanceTabController {

  public Loan_Balance__c[] loanBalances;
  public Container[] containers;

  public Loan_Balance__c[] newLoanBalances {get; set;}

  public Boolean editAll {get;set;}

  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}

  private Id opportunityId;

  public Decimal balanceTotal {get; set;}
  public Decimal paymentTotal {get; set;}

  public MCALoanBalanceTabController() {

    opportunityId = Apexpages.currentPage().getParameters().get('id');

    refresh();
  }

  public Container[] getContainers() {

    balanceTotal = 0;
    paymentTotal = 0;

    loanBalances = new Loan_Balance__c[] {};
    containers = new Container[] {};

    loanBalances.addAll(newLoanBalances);

    for (Loan_Balance__c lb :[SELECT
						                    Id,
						                    Active__c,
						                    Balance__c,
						                    Daily_Payment__c,
						                    Funder__c,
						                    Maturity_Date__c,
						                    Name
						                FROM Loan_Balance__c
						                WHERE Opportunity__c = :opportunityId]) {

      loanBalances.add(lb);
      balanceTotal += lb.Balance__c != null ? lb.Balance__c : 0;
      paymentTotal += lb.Daily_Payment__c != null ? lb.Daily_Payment__c : 0;

    }

    for (Integer i = 0; i < loanBalances.size(); i++) {
      containers.add(new Container(loanBalances[i], i));
    }


    return containers;

    //return loanBalances;
  }
	
  public void save(){}
  public void newLoanBalance() {
    newLoanBalances.add(new Loan_Balance__c(Opportunity__c = opportunityId));
  }

  public void refresh() {

    balanceTotal = 0;
    paymentTotal = 0;

    recordToDelete = null;
    editAll = false;

    newLoanBalances = new Loan_Balance__c[] {};
  }

  public void saveAllLoans() {

    upsert loanBalances;

    refresh();
  }

  public void editAll() {
  	refresh();
    editAll = true;
  }

  public void deleteLoanBalance() {

    if (recordToDelete != null) {
      Loan_Balance__c record = [SELECT Id FROM Loan_Balance__c WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void removeLoanBalance() {

    if (indexToRemove != null) {

      Container c = null;

      for (Container element :containers) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }
      //containers.remove(c.index);
      newLoanBalances.remove(c.index);
    }

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