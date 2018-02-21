trigger RepaymentTrigger on Repayment__c (after insert, after update) {

	FundingAmountTriggerHelper.createFundingPayment(Trigger.newMap, Trigger.oldMap);
}