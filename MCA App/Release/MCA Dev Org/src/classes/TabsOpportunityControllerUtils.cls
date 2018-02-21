public with sharing class TabsOpportunityControllerUtils {

  public static Opportunity getOpportunity(Id id) {
  
    Opportunity result =
    [SELECT 
    
      (SELECT Subject, ActivityDate, Status, Priority, OwnerId, Description FROM Tasks), 
      (SELECT Commission_Fee__c, Profit_Amount__c, ROR_per__c, Servicing_Fee__c, Syndicated_By__c, Syndication_Amt__c FROM Syndication__r), 
      (SELECT Id, Name, Contact__c, Date_Submitted__c, Funder__c, Program__c, Status_Date__c, Status__c FROM Submissions__r), 
      (SELECT Name, Recv_d__c, Requested_by__c, Status__c, Type__c FROM Items_Needed__r), 
      (SELECT Amount_Due__c, Amount__c, Due_Date__c, Due_From_Account__c, Payback_Funded__c, Percentage__c, Type__c FROM Commissions__r), 
      (SELECT Account__c, Amount_Due__c, Bill_Amount_Due__c, Due_Date__c, Payback_Funded__c, Percentage__c, Type__c FROM Payables__r), 
      (SELECT ContactId, Role, IsPrimary, SystemModstamp FROM OpportunityContactRoles), 
      (SELECT Submission__c, Opportunity__c, Amount__c, Deal_Type__c, Details__c, Funder__c, Holdback__c, PMT_Schedule__c, Payback_Amt__c, Payment_Amt__c, Rate__c, Status__c, Term_Months__c FROM Offers__r), 
      (SELECT Name, Active__c, Balance__c, Daily_Payment__c, Funder__c, Maturity_Date__c FROM Loan_Balances__r), 
      (SELECT Month__c, Number_of_Transactions_All__c, Processor_Name__c, Total_Net_Processed_All__c, Year__c FROM Credit_Cards__r), 
      (SELECT Average_Daily_Balance__c, Deposits__c, Month__c, Number_of_NSFs__c, Number_of_Negative_Days__c, Year__c FROM Bank_Accounts__r)
       
    FROM Opportunity o
    WHERE Id = :Id];
      
  
    return result;
  }
 
  public static String[] getFieldsMapping(String objectName) {
  
    String[] result = new String[] {'Name'};
    
    if ('Submission__c'.equals(objectName)) {
      //result = new String[] {'Name', 'Funder__c', 'Date_Submitted__c', 'Status__c', 'Status_Date__c', 'Contact__c', 'Program__c'};
    }
    
    return result;
  }


}