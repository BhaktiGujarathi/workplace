trigger PaymentDetails on Payment_Detail__c (after insert, after update) {
    PaymentDetailHandler paymentDetailObj = new PaymentDetailHandler();
    if(trigger.isInsert) {
        paymentDetailObj.handleInsert(trigger.new);
    }
}