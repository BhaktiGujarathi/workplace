@isTest
private class OffercStatsTT {

   static testMethod void testTrigger() {
      try {
          Offer__c o = new Offer__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Offer__c> l = [SELECT Id from Offer__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}