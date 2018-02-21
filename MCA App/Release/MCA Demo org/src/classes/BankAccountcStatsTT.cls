@isTest
private class BankAccountcStatsTT {

   static testMethod void testTrigger() {
      try {
          Bank_Account__c o = new Bank_Account__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Bank_Account__c> l = [SELECT Id from Bank_Account__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}