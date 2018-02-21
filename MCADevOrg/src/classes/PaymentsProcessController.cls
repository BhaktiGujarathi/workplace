public with sharing class PaymentsProcessController {
    
    public Processor_Integration__c processorIntegration { get; set; }
    public PaymentWrapper[] payments { get; set; }
    public Map<String, String> columns { get; set; }
    public String csvFileName { get; set; }
    public Blob csvFileBody { get; set; }
    public String[] columnsInOrder { get; set; }
    public String paymentsCount { get; set; }
    
    private Payment__c [] insertPayments;

    
    public PaymentsProcessController() {
        payments = new PaymentWrapper[]{};

        for (Processor_Integration__c p : [SELECT Name FROM Processor_Integration__c 
                                            WHERE Id = :ApexPages.currentPage().getParameters().get('id')]) {
            processorIntegration = p;
        }
    }
    
    
    
    public void resetImport() {
        payments = new PaymentWrapper[]{};
    }
    
    
    
    public void processFile() {
        if (processorIntegration != null) {
	        if (csvFileBody != null) {
	
	            Payment__c[] ps = PaymentsProcessUtils.getPayments(processorIntegration.Id, csvFileBody);
	
	            if (ps != null) {
	                for (Payment__c p : ps) {
	                    PaymentWrapper pw = new PaymentWrapper(p);
	                    payments.add(pw);
	                }
	            }
	
	            if (PaymentsProcessUtils.warning != null) {
	                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, PaymentsProcessUtils.warning));
	            }
	            else if (PaymentsProcessUtils.error != null) {
	                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, PaymentsProcessUtils.error));
	            }
	            else if (payments!= null && payments.size() > 0) {
	                paymentsCount = String.valueOf(getInsertPayments().size());
	                showMessage();
	                showPaymentsRecords();
	            }
	            else {
	                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No payment records to process'));
	            }
	        } 
	        else {
	            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select the CSV file to process'));
	        }
        }
        else {
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There has been an error. Please review'));
        }
    }
    
    
    public void showMessage() {
        paymentsCount = String.valueOf(getInsertPayments().size());
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, paymentsCount + ' payment records will be processed'));
    }

    
    private void showPaymentsRecords() {
        columnsInOrder = new String[]{};
        Processor_Field_Mapping__c[] mappings = PaymentsProcessUtils.queryMappings(processorIntegration.Id);

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(PaymentsProcessUtils.OBJECT_NAME).getDescribe().fields.getMap();
        columns = new Map<String, String> {};
        
        for (Processor_Field_Mapping__c mapping : mappings) {
            for (Schema.SObjectField sField : fieldMap.Values()) {
                Schema.DescribeFieldResult f = sField.getDescribe();
                if (mapping.Field_Name__c != null && f.getName() == mapping.Field_Name__c) {
                    columns.put(f.getName(), f.getLabel() + ' (' + mapping.Index_Field_Label__c + ')');
                    columnsInOrder.add(f.getName());
                }
            }
        }
    }
    
    
    public Payment__c[] getInsertPayments() {
        
        insertPayments = new Payment__c[]{};

        for (PaymentWrapper pw : payments) {
            if (pw.selected) {
            	pw.payment.Payment_Method__c = pw.paymentMethod;
                insertPayments.add(pw.payment);
            }
        }
        
        return insertPayments;
    }


    public PageReference insertPayments() {
        try {
            insertPayments  = getInsertPayments();

            if (!insertPayments.isEmpty()) {
                String batchImportLogId = PaymentsProcessUtils.insertPayments(insertPayments, processorIntegration.Id, csvFileBody, 'Manual', '');
                
                if (PaymentsProcessUtils.warning == null && PaymentsProcessUtils.error == null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Your payments were processed correctly'));
                    return new PageReference('/' + batchImportLogId);
                }
            }
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You need to select at least 1 payment to be processed')); 
            }
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }

        return null;
    }   



    public class PaymentWrapper {
        public Boolean selected { get; set; }
        public String paymentMethod { get; set; }
        public Payment__c payment { get; set; }

        public PaymentWrapper(Payment__c payment) {
            this.selected = (payment.Repayment__c != null);
            this.payment = payment;
        }
    }
}