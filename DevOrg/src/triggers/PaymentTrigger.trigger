trigger PaymentTrigger on Payment__c (before insert, before update, after insert) {


    if (Trigger.isBefore) {

        if (Trigger.isInsert || Trigger.isUpdate) {

            RunningBalanceTriggerHelper runningBalanceTriggerHelper = new RunningBalanceTriggerHelper();
            runningBalanceTriggerHelper.calculateRunningBalance(Trigger.new, Trigger.oldMap);
        }

    }
    else if (Trigger.isAfter) {

        if (Trigger.isInsert) {

            PaymentExternalIdTriggerHelper paymentExternalIdTriggerHelper = new PaymentExternalIdTriggerHelper();
            paymentExternalIdTriggerHelper.setExternalId(Trigger.new);
        }
    }
}