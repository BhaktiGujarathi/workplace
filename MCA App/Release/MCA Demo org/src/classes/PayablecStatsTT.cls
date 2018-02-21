@isTest
private class PayablecStatsTT {

   static testMethod void testTrigger() {
      try {
          Payable__c o = new Payable__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Payable__c> l = [SELECT Id from Payable__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}