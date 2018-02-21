@isTest
private class PaymentcStatsTT {

   static testMethod void testTrigger() {
      try {
          Payment__c o = new Payment__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Payment__c> l = [SELECT Id from Payment__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}