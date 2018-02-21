public with sharing class MCARecordValidator {

  public static Boolean isRecordValid(sObject record) {
  
    String objectName = record.getSObjectType().getDescribe().getName();
    Boolean result = false;
    
    if (objectName.equals('Bank_Account__c')) {
      result =  IsConcreteRecordValid((Bank_Account__c) record);
    }
    if (objectName.equals('Credit_Card__c')) {
      result = IsConcreteRecordValid((Credit_Card__c) record);
    }
    if (objectName.equals('Submission__c')) {
      result = IsConcreteRecordValid((Submission__c) record);
    }
    if (objectName.equals('Offer__c')) {
      result = IsConcreteRecordValid((Offer__c) record);
    }
    if (objectName.equals('Syndication__c')) {
      result = IsConcreteRecordValid((Syndication__c) record);
    }
    if (objectName.equals('Stips__c')) {
      result = IsConcreteRecordValid((Stips__c) record);
    }
    if (objectName.equals('Payable__c')) {
      result = IsConcreteRecordValid((Payable__c) record);
    }
    if (objectName.equals('Receivable__c')) {
      result = IsConcreteRecordValid((Receivable__c) record);
    }    
    
    return result;
  }
  
  private static Boolean IsConcreteRecordValid(Bank_Account__c record) {
  
    Boolean result = false;
    
    result = record.Month__c != null;
    result |= record.Year__c != null;
    result |= record.Deposits__c != null;
    result |= record.Average_Daily_Balance__c != null;
    result |= record.Number_of_NSFs__c != null;
    result |= record.Number_of_Negative_Days__c != null;    
    
    return result;
  }

  private static Boolean IsConcreteRecordValid(Credit_Card__c record) {
  
    Boolean result = false;
    
    result = record.Month__c != null;
    result |= record.Year__c != null;
    result |= record.Total_Net_Processed_All__c != null;
    result |= record.Number_of_Transactions_All__c != null;
    result |= record.Processor_Name__c != null;
  
    return result;
  }

  private static Boolean IsConcreteRecordValid(Submission__c record) {
  
    Boolean result = false;
    
    result = record.Funder__c != null;
    result |= record.Date_Submitted__c != null;
    result |= record.Status__c != null;
    result |= record.Status_Date__c != null;
    result |= record.Contact__c != null;
    result |= record.Program__c != null;
  
    return result;
  }

  private static Boolean IsConcreteRecordValid(Offer__c record) {
  
    Boolean result = false;
    
    result = record.Deal_Type__c != null;
    result |= record.Amount__c != null;
    result |= record.Rate__c != null;
    result |= record.Term_Months__c != null;
    result |= record.Holdback__c != null;
    result |= record.Payment_Amt__c != null;
    result |= record.Details__c != null;
    result |= record.PMT_Schedule__c != null;
    result |= record.Status__c != null;
    result |= record.Send__c != null;
  
    return result;
  }  

  private static Boolean IsConcreteRecordValid(Syndication__c record) {
  
    Boolean result = false;
    
    result = record.Syndication_Amt__c != null;
    result |= record.Servicing_Fee__c != null;
    result |= record.Commission_Fee__c != null;
    result |= record.Syndicated_By__c != null;
  
    return result;
  }  
  
  private static Boolean IsConcreteRecordValid(Stips__c record) {
  
    Boolean result = false;
    
    result = record.Recv_d__c != null;
    result |= record.Name != null;
    result |= record.Type__c != null;
    result |= record.Status__c != null;
    result |= record.Requested_by__c != null;
  
    return result;
  }

  private static Boolean IsConcreteRecordValid(Payable__c record) {
  
    Boolean result = false;
    
    result = record.Type__c != null;
    result |= record.Account__c != null;
    result |= record.Amount_Due__c != null;
    result |= record.Percentage__c != null;
    result |= record.Payback_Funded__c != null;
    result |= record.Due_Date__c != null;
      
    return result;
  }    
  
  private static Boolean IsConcreteRecordValid(Receivable__c record) {
  
    Boolean result = false;
    
    result = record.Type__c != null;
    result |= record.Due_From_Account__c != null;
    result |= record.Amount__c != null;
    result |= record.Percentage__c != null;
    result |= record.Payback_Funded__c != null;
    result |= record.Due_Date__c != null;
      
    return result;
  }     

}