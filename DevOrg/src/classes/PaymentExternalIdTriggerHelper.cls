public with sharing class PaymentExternalIdTriggerHelper {
	
	public void setExternalId(Payment__c[] newPayments) {
	    Payment__c[] payments = new Payment__c[]{};
		
	    for (Payment__c p : newPayments) {
	        
	        if (p.Id != null) {
	        	Payment__c aux = new Payment__c(Id = p.Id);
	            string id = string.valueOf(aux.id);
	            String idDate = String.valueOf(Date.today().month()) + String.valueOf(Date.today().day()) + String.valueOf(Date.today().year()).substring(2,4);
	            aux.External_Transaction_ID__c = 'T' + idDate + id.substring((18 - (11 - (idDate.length()))),18);
	            payments.add(aux);
	        }
	    }

	    RunningBalanceTriggerHelper.preventUpdate = true;
	    update payments;
	    RunningBalanceTriggerHelper.preventUpdate = false;		
	}
}