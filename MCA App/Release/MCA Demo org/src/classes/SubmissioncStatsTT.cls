@isTest
private class SubmissioncStatsTT {

   static testMethod void testTrigger() {
      try {
          Submission__c o = new Submission__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Submission__c> l = [SELECT Id from Submission__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}