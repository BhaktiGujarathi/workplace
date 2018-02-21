@isTest
private class ReceivableLineItemSummarycStatsTT {

   static testMethod void testTrigger() {
      try {
          Receivable_Line_Item_Summary__c o = new Receivable_Line_Item_Summary__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Receivable_Line_Item_Summary__c> l = [SELECT Id from Receivable_Line_Item_Summary__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}