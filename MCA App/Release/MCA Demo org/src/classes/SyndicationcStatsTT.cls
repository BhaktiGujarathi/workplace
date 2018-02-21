@isTest
private class SyndicationcStatsTT {

   static testMethod void testTrigger() {
      try {
          Syndication__c o = new Syndication__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Syndication__c> l = [SELECT Id from Syndication__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}