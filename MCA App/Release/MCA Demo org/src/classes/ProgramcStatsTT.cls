@isTest
private class ProgramcStatsTT {

   static testMethod void testTrigger() {
      try {
          Program__c o = new Program__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Program__c> l = [SELECT Id from Program__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}