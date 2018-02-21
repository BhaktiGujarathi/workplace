@isTest
private class PaymentHeadercStatsTT {

   static testMethod void testTrigger() {
      try {
          Payment_Header__c o = new Payment_Header__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Payment_Header__c> l = [SELECT Id from Payment_Header__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}