public with sharing class MCASalesHistoryTabController {

  public Bank_Account__c[] statements;
  public Credit_Card__c[] credits;
  
  public Bank_Account__c[] newStatements {get; set;}
  public Credit_Card__c[] newCredits {get; set;}
  
  public ContainerStatement[] containersStatements;
  public ContainerCard[] containersCards;
  
  public Boolean editAll {get;set;}
  
  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}
  
  private Id opportunityId;
  
  public Decimal depositsAverage {get; set;}
  public Decimal balanceAverage {get; set;}
  public Decimal nsfAverage {get; set;} 
  public Decimal negativeAverage {get; set;}
  
  public Decimal processedAverage {get; set;} 
  public Decimal transactionAverage {get; set;}  

  public MCASalesHistoryTabController() {
  	
    opportunityId = Apexpages.currentPage().getParameters().get('id');
    refresh();
  }
  
  public ContainerStatement[] getContainersStatements() {
  
    statements = new Bank_Account__c[] {};
    containersStatements = new ContainerStatement[] {};
    
    statements.addAll(newStatements);
    
    Integer n = 0;

    for (Bank_Account__c ba :[SELECT 
							                    Id, 
							                    Month__c, 
							                    Year__c, 
							                    Deposits__c, 
							                    Average_Daily_Balance__c, 
							                    Number_of_NSFs__c, 
							                    Number_of_Negative_Days__c 
							                FROM Bank_Account__c
							                WHERE Opportunity__c = :opportunityId]) {
    
      statements.add(ba);
    
		  depositsAverage += ba.Deposits__c != null ? ba.Deposits__c : 0;
		  balanceAverage += ba.Average_Daily_Balance__c != null ? ba.Average_Daily_Balance__c : 0;
		  nsfAverage += ba.Number_of_NSFs__c != null ? ba.Number_of_NSFs__c : 0;
		  negativeAverage += ba.Number_of_Negative_Days__c != null ? ba.Number_of_Negative_Days__c : 0;
		  
		  n ++;
    }
    
    if (n != 0) {
			depositsAverage /= n;
			balanceAverage /= n;
			nsfAverage /= n;
			negativeAverage /= n;
    }
                    
    for (Integer i = 0; i < statements.size(); i++) {
      containersStatements.add(new ContainerStatement(statements[i], i));
    }
    return containersStatements;
                    
    //return statements;
  }
  
  public ContainerCard[] getContainersCards() {
  
    credits = new Credit_Card__c[] {};
    containersCards = new ContainerCard[] {};
    
    credits.addAll(newCredits);
  
    Integer n = 0;
                         
    for (Credit_Card__c cc :[SELECT
							                  Id, 
							                  Month__c,
							                  Year__c,
							                  Total_Net_Processed_All__c,
							                  Number_of_Transactions_All__c,
							                  Processor_Name__c
							              FROM Credit_Card__c
							              WHERE Opportunity__c = :opportunityId]) {
		
		  credits.add(cc);
		
	    processedAverage += cc.Total_Net_Processed_All__c != null ? cc.Total_Net_Processed_All__c : 0;
	    transactionAverage += cc.Number_of_Transactions_All__c != null ? cc.Number_of_Transactions_All__c : 0;							     
	    n++;         
    }
          
    if (n != 0) {          
	    processedAverage /= n;
	    transactionAverage /= n;
    }
      
    for (Integer i = 0; i < credits.size(); i++) {
      containersCards.add(new ContainerCard(credits[i], i));
    }
    return containersCards;
                         
    //return credits;
  }
  
  public void refresh() {
  	
	  depositsAverage = 0;
	  balanceAverage = 0;
	  nsfAverage = 0; 
	  negativeAverage = 0;
	  
	  processedAverage = 0; 
	  transactionAverage = 0;    	

    recordToDelete = null;
    editAll = false;
    
    newStatements = new Bank_Account__c[] {};
    newCredits = new Credit_Card__c[] {};
  }

  public void editAll() {
  	refresh();
    editAll = true;
  }

  public void saveAll() {

  /*
    Bank_Account__c[] recordsToUpdateOne = new Bank_Account__c[] {};
    Credit_Card__c[] recordsToUpdateTwo = new Credit_Card__c[] {};
    
    for (Bank_Account__c record :statements) {
      
      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdateOne.add(record);
      }  
    }
    
    for (Credit_Card__c record :credits) {
      
      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdateTwo.add(record);
      }  
    }    
  
    upsert recordsToUpdateOne;
    upsert recordsToUpdateTwo; 
    */

    upsert statements;
    upsert credits; 
    
    refresh();
  }
 
  public void newStatement() {
  	newStatements.add(new Bank_Account__c(Opportunity__c = opportunityId));
  }
  
  public void newCredit() {
    newCredits.add(new Credit_Card__c(Opportunity__c = opportunityId));
  }  
  
  public void deleteStatement() {
  
    if (recordToDelete != null) {
	    Bank_Account__c record = [SELECT Id FROM Bank_Account__c WHERE Id = :recordToDelete];
	    delete record;
    }
  }
  
  public void deleteCredit() {
  
    if (recordToDelete != null) {
	    Credit_Card__c record = [SELECT Id FROM Credit_Card__c WHERE Id = :recordToDelete];
	    delete record;
    }
  }  
  
  public void removeCard() {
  
    if (indexToRemove != null) {
      
      ContainerCard c = null;
      
      for (ContainerCard element :containersCards) {
        
        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newCredits.remove(c.index);
    }
  
  }   
  
  public void removeStatement() {
  
    if (indexToRemove != null) {
      
      ContainerStatement c = null;
      
      for (ContainerStatement element :containersStatements) {
        
        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newStatements.remove(c.index);
    }
  
  }   
  
  public class ContainerCard {
  
    public Credit_Card__c card {get;set;}
    public Integer index {get;set;}
  
    public ContainerCard(Credit_Card__c instance, Integer index) {
      card = instance;
      this.index = index;
    }
  
  }       
  
  public class ContainerStatement {
  
    public Bank_Account__c statement {get;set;}
    public Integer index {get;set;}
  
    public ContainerStatement(Bank_Account__c instance, Integer index) {
      statement = instance;
      this.index = index;
    }
  
  }           
  
}