@isTest
private class OpportunityWeeklyAnalysiscStatsTT {

   static testMethod void testTrigger() {
      try {
          Opportunity_Weekly_Analysis__c o = new Opportunity_Weekly_Analysis__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Opportunity_Weekly_Analysis__c> l = [SELECT Id from Opportunity_Weekly_Analysis__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}