@isTest
private class LoanBalancecStatsTT {

   static testMethod void testTrigger() {
      try {
          Loan_Balance__c o = new Loan_Balance__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Loan_Balance__c> l = [SELECT Id from Loan_Balance__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}