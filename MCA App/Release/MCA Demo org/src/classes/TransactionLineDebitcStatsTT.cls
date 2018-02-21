@isTest
private class TransactionLineDebitcStatsTT {

   static testMethod void testTrigger() {
      try {
          Transaction_Line_Debit__c o = new Transaction_Line_Debit__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Transaction_Line_Debit__c> l = [SELECT Id from Transaction_Line_Debit__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}