global with sharing class PaymentsProcessEmailService implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        Attachment att = new Attachment();
        Processor_Integration__c processorIntegration = queryProcessorIntegration(email.fromAddress, email.subject);
        
        if (processorIntegration.From_Addresses__c != null && email.TextAttachments != null) {
            
            for (Messaging.Inboundemail.TextAttachment a : email.TextAttachments) {

                if (a.fileName != null && a.fileName.indexOf('.csv') != -1) {
                    
                    att.Name = 'Imported File ' + System.now().format('MM-dd-YYYY') + '.csv';
                    att.Body = Blob.valueOf(a.body);

                    Payment__c[] payments = PaymentsProcessUtils.getPayments(processorIntegration.Id, Blob.valueOf(a.body));
                    
                    if (payments != null) {
                        for (Payment__c pay : payments) {
                        	pay.Payment_Method__c = 'Split Funding';
                        }
                    
                        PaymentsProcessUtils.insertPayments(payments, processorIntegration.Id, Blob.valueOf(a.body), 'Email', email.fromAddress);
                    }
                }
            }

            if (PaymentsProcessUtils.error == null) {
                result.success = true;
            }
            else {
                result.success = false; 
                result.message = PaymentsProcessUtils.error + '\n\n' + PaymentsProcessUtils.errorMessage;
                
                Split_Batch__c bil = new Split_Batch__c();
                bil.Date_Time__c = System.now();
                bil.Processor_Integration__c = processorIntegration.Id;
                bil.Import_Type__c = 'Email';
                bil.Email__c = email.fromAddress;
                bil.Error_Messages__c = result.message;
                bil.Rows_Imported__c = 0;
                insert bil;
                
                att.ParentId = bil.Id;
                insert att; 
                
            }
        }
        else {
            result.success = false;
        }
        
        return result;
    }
    

    private Processor_Integration__c queryProcessorIntegration(String fromAddress, String subject) {
        Processor_Integration__c result = null;

        for (Processor_Integration__c pi : [SELECT Name, From_Addresses__c, Record_Number__c FROM Processor_Integration__c]) {
            if (pi.From_Addresses__c != null && pi.From_Addresses__c.contains(fromAddress)) {
                return pi;
            }
            if (pi.Record_Number__c != null && subject == pi.Record_Number__c) {
                result = pi;
            }
        }
        
        return result;
    }
}