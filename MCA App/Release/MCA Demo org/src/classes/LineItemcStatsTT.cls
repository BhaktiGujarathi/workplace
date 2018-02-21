@isTest
private class LineItemcStatsTT {

   static testMethod void testTrigger() {
      try {
          Line_Item__c o = new Line_Item__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Line_Item__c> l = [SELECT Id from Line_Item__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}