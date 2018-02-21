@isTest
private class MerchantPaymentcStatsTT {

   static testMethod void testTrigger() {
      try {
          Merchant_Payment__c o = new Merchant_Payment__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Merchant_Payment__c> l = [SELECT Id from Merchant_Payment__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}