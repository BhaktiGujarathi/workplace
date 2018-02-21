trigger PaymentTermsTrigger on Payment_Terms__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  TriggerFactoryCls.createHandler(Payment_Terms__c.sObjectType);
}