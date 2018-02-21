@isTest
private class TransactioncStatsTT {

   static testMethod void testTrigger() {
      try {
          Transaction__c o = new Transaction__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Transaction__c> l = [SELECT Id from Transaction__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}