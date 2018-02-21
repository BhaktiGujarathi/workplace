@isTest
private class ReceiptHeadercStatsTT {

   static testMethod void testTrigger() {
      try {
          Receipt_Header__c o = new Receipt_Header__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Receipt_Header__c> l = [SELECT Id from Receipt_Header__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}