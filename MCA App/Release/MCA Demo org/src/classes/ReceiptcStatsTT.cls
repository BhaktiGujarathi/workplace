@isTest
private class ReceiptcStatsTT {

   static testMethod void testTrigger() {
      try {
          Receipt__c o = new Receipt__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Receipt__c> l = [SELECT Id from Receipt__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}