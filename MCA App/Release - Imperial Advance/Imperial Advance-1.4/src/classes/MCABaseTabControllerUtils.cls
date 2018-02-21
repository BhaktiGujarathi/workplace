public with sharing class MCABaseTabControllerUtils {

  public static String getQuery(String objectName) {
  
    String result = 'SELECT Id ';
    
    result += getObjectFields(objectName);
    result += ' FROM ' + objectName + ' WHERE ' + getOpportunityReferenceName(objectName) + ' = :opportunityId';
    
    return result;
  }
  
  public static String getOpportunityReferenceName(String objectName) {
  
    String result = 'Opportunity__c';
  
    if ('Task'.equals(objectName)) {
      result = 'WhatId';
    }       
    if ('OpportunityContactRole'.equals(objectName)) {
      result = 'OpportunityId';
    }    
    
    return result;
  }  
  
  public static sObject getNewRecord(String objectName) {
  
    return Schema.getGlobalDescribe().get(objectName).newSObject();
  }
  
  private static String getObjectFields(String objectName) {
  
    String result = '';
    
    if ('Bank_Account__c'.equals(objectName)) {
      result = '';
    }
    if ('Credit_Card__c'.equals(objectName)) {
      result = '';
    }
    if ('Submission__c'.equals(objectName)) {
      result = '';
    }
    if ('Offer__c'.equals(objectName)) {
      result = '';
    }
    if ('Stips__c'.equals(objectName)) {
      result = '';
    }
    if ('Payable__c'.equals(objectName)) {
      result = '';
    }
    if ('Receivable__c'.equals(objectName)) {
      result = '';
    }
    if ('Syndication__c'.equals(objectName)) {
      result = '';
    }
    if ('Loan_Balance__c'.equals(objectName)) {
      result = '';
    }        
    if ('OpportunityContactRole'.equals(objectName)) {
      result = '';
    }
    if ('Task'.equals(objectName)) {
      result = '';
    }             
    
    return result;
  }  

}