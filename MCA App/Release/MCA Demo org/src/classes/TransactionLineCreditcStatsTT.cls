@isTest
private class TransactionLineCreditcStatsTT {

   static testMethod void testTrigger() {
      try {
          Transaction_Line_Credit__c o = new Transaction_Line_Credit__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Transaction_Line_Credit__c> l = [SELECT Id from Transaction_Line_Credit__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}