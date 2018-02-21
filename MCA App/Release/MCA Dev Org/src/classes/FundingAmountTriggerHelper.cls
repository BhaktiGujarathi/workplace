public with sharing class FundingAmountTriggerHelper {
	

	public static void createFundingPayment(Map<Id, Repayment__c> repaymentsMap, Map<Id, Repayment__c> oldRepayments) {
		Map<String, Payment__c> paymentsMap = queryPayments(repaymentsMap.keySet());

		Payment__c[] payments = new Payment__c[]{};

		for (Repayment__c r : repaymentsMap.values()) {
			if (r.Net_Funding__c != null && r.Net_Funding__c > 0) {
				if (oldRepayments != null 
						&& oldRepayments.containsKey(r.Id) ) {
					
					if (paymentsMap.containsKey(r.Id)) {
						payments.add(updatePayment(paymentsMap.get(r.Id), r));
					}
					else {
						payments.add(createPayment(r));
					}
					
				}
				else {
					if (Trigger.oldMap == null) {
						payments.add(createPayment(r));
					}
				}
				
			}
		}

		upsert payments;
	}


	private static Map<String, Payment__c> queryPayments(Set<Id> repaymentsIds) {
		Map<String, Payment__c> payments = new Map<String, Payment__c>();
		for (Payment__c payment : [select Transaction_Amount__c
										, Effective_Date__c
										, Funding_Payment__c
										, Status__c
										, Repayment__c
									 from Payment__c
									where Repayment__c in : repaymentsIds
									  and Funding_Payment__c = true]) {

			payments.put(payment.Repayment__c, payment);
		}
		return payments;
	}


	private static Payment__c updatePayment(Payment__c payment, Repayment__c r) {
		payment.Transaction_Amount__c = r.Net_Funding__c;
		//payment.Effective_Date__c = Date.today();
		return payment;
	}


	private static Payment__c createPayment(Repayment__c r) {
		Map < String, Schema.RecordTypeInfo > rtMapByName = Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
	    Schema.RecordTypeInfo rtByName = rtMapByName.get('Credit');
	    String recTypeId = String.valueOf(rtByName.getRecordTypeId());

		Payment__c payment = new Payment__c();
		payment.RecordTypeId = recTypeId;
		payment.Transaction_Amount__c = r.Net_Funding__c;
		payment.Effective_Date__c = Date.today();
		payment.Funding_Payment__c = true;
		payment.Repayment__c = r.Id;
		payment.Status__c = 'Settled';
		payment.Running_Balance__c = r.Total_Outstanding_Amount__c;
		return payment;
	}


}