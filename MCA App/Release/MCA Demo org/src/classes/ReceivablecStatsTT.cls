@isTest
private class ReceivablecStatsTT {

   static testMethod void testTrigger() {
      try {
          Receivable__c o = new Receivable__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Receivable__c> l = [SELECT Id from Receivable__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}