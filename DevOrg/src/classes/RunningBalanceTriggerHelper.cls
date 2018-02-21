public with sharing class RunningBalanceTriggerHelper {

	public static Boolean preventUpdate = false;


	public void calculateRunningBalance(Payment__c[] newPayments, Map<Id, Payment__c> oldPayments) {
	    
	    for (Payment__c p : newPayments) {
	        if (p.Transaction_Type__c == 'Fee' && p.Transaction_Amount__c > 0) {
	            p.Transaction_Amount__c = p.Transaction_Amount__c * -1;
	        }
	    }
	        
	    Map<String, Double> repaymentsMap = new Map<String, Double>();

	    Set<String> repaymentIds = new Set<String>();

	    for (Payment__c p : newPayments) {
	        if (!repaymentIds.contains(p.Repayment__c) && (p.Status__c == 'Settled' || p.Status__c == 'Fees Applied') && !p.Funding_Payment__c) {
	            repaymentIds.add(p.Repayment__c);
	        }
	    }

	    for (Repayment__c r : [select Id, Total_Outstanding_Amount__c from Repayment__c where Id in :repaymentIds]) {
	        if (!repaymentsMap.containsKey(r.Id)) {
	            repaymentsMap.put(r.Id, r.Total_Outstanding_Amount__c);
	        }
	        
	    }

	    for (Payment__c p : newPayments) {
	        if (repaymentsMap.containsKey(p.Repayment__c) && p.Transaction_Amount__c != null &&
	                            (p.Status__c == 'Settled' || p.Status__c == 'Fees Applied')) {

            	if (oldPayments != null && !preventUpdate && (oldPayments.get(p.Id).Status__c == 'Settled' || oldPayments.get(p.Id).Status__c == 'Fees Applied')) {
	                p.Running_Balance__c = repaymentsMap.get(p.Repayment__c) + oldPayments.get(p.Id).Transaction_Amount__c - p.Transaction_Amount__c;    
	            }
	            else {                
	                p.Running_Balance__c = repaymentsMap.get(p.Repayment__c) - p.Transaction_Amount__c;
	            }
	            
	            repaymentsMap.put(p.Repayment__c, p.Running_Balance__c); 
	        }
	        
	    }		
	}
}