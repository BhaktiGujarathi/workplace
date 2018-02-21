@isTest (seealldata=true)
private class PaymentsProcessTest {

    private static testMethod void EmailTest() {
    	PaymentsProcessFieldMappingController controller = new PaymentsProcessFieldMappingController();
        controller.processorIntegration = createProcessorIntegration();
    	
    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    	email.plainTextBody = 'Text body';
        email.fromAddress ='test@test.test';
        String contactEmail = 'jsmith@salesforce.com';
        email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
        email.subject = 'Test subject';

        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = documentBody();
        attachment.fileName = 'Test.csv';
        attachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };

        PaymentsProcessEmailService ppes = new PaymentsProcessEmailService();
        Test.startTest();

        Messaging.InboundEmailResult result = ppes.handleInboundEmail(email, env);
        Test.stopTest();
    }
    
    
    private static testMethod void PaymentProcessControllerTest() {
        Repayment__c repayment = createRepayment();

    	Processor_Integration__c pi = createProcessorIntegration();
    	ApexPages.currentPage().getParameters().put('id', pi.Id);
        PaymentsProcessFieldMappingController mappingController = new PaymentsProcessFieldMappingController();
        mappingController.processorIntegration = pi;
        mappingController.init();
        Processor_Field_Mapping__c mapping = createMapping(pi, 8, 'Merchant_ID__c', 'Merchant Id');
        mappingController.mappings.add(new PaymentsProcessFieldMappingController.MappingsWrapper(mapping));
        mappingController.save();

        PaymentsProcessController controller = new PaymentsProcessController();
        controller.processorIntegration = pi;
        controller.csvFileName = 'Test';
        controller.csvFileBody = craeteDocument();
        controller.processFile();

        controller.insertPayments();
        
    }
    
    private static testMethod void PaymentsProcessFieldMappingControllerTest() {
    	PaymentsProcessFieldMappingController controller = new PaymentsProcessFieldMappingController();
    	controller.processorIntegration = createProcessorIntegration();
        ApexPages.currentPage().getParameters().put('id', controller.processorIntegration.Id);
    	controller.init();

    	Processor_Field_Mapping__c mapping = createMapping(controller.processorIntegration, 7, 'Date__c', 'Date');
    	controller.mappings.add(new PaymentsProcessFieldMappingController.MappingsWrapper(mapping));

        System.assertEquals(1, controller.mappings.size());
    	controller.editFieldMapping();
        System.assertEquals(true, controller.editMode);

    	controller.save();

        System.assertEquals(false, controller.editMode);
    	controller.idDeleteMapping = mapping.Id;
    	controller.deleteFieldMapping();
        System.assertEquals(0, controller.mappings.size());
    	controller.cancel();

        controller.addNewFieldMapping();
        System.assertEquals(1, controller.mappings.size());
        System.assertEquals(true, controller.editMode);

        controller.save();
        System.assertEquals(1, controller.mappings.size());
        System.assertEquals(true, controller.editMode);

    	
    }


    private static testMethod void runningBalanceTriggerTest() {
        Account account = new Account();
        account.Name = 'Test';
        insert account;

        Repayment__c repayment = new Repayment__c();
        repayment.Status__c = 'Active';
        repayment.Intial_Repayment_Amount__c = 10000;
        repayment.Payment_Amount__c = 10000;
        repayment.Payee_Account__c = account.Id;
        repayment.Next_Hit_Date__c = Date.Today().addDays(1);
        insert repayment;

        Payment__c payment = new Payment__c();
        payment.Repayment__c = repayment.Id;
        payment.Transaction_Amount__c = 1000;
        payment.Status__c = 'Settled';
        insert payment;

        payment = [select Running_Balance__c from Payment__c where Id = : payment.Id];

        System.assertEquals(9000, payment.Running_Balance__c);
    }


    private static String documentBody() {
        return 'report_name,cash_company,settle_date,merch_footer,merchant_total_vol,merch_total_hold,file_date,merch_no,merch_name,total_vol,hold_amt,hold_rate,sourcefile\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076236804102 => ,$174.00,$0.00,11/24/2014,475076236804102,CHARITO BEAUTY SALON,$174.00,$41.76,24.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076236804102 => ,$169.00,$0.00,11/24/2014,475076236804102,CHARITO BEAUTY SALON,$169.00,$40.56,24.00 %,DB\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076236804102 => ,$23.00,$0.00,11/24/2014,475076236804102,CHARITO BEAUTY SALON,$23.00,$5.52,24.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076236804102 => ,$428.00,$0.00,11/24/2014,475076236804102,CHARITO BEAUTY SALON,$428.00,$102.72,24.00 %,DB\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076236804102 => ,$28.00,$0.00,11/24/2014,475076236804102,CHARITO BEAUTY SALON,$28.00,$6.72,24.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076236804102 => ,$61.00,$0.00,11/24/2014,475076236804102,CHARITO BEAUTY SALON,$61.00,$14.64,24.00 %,DB\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103268 => ,$98.49,$0.00,11/24/2014,475076123103268,DALES GROCERY,$98.49,$48.25,49.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103268 => ,$83.81,$0.00,11/24/2014,475076123103268,DALES GROCERY,$83.81,$41.06,49.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103268 => ,$77.27,$0.00,11/24/2014,475076123103268,DALES GROCERY,$77.27,$37.86,49.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076326900592 => ,$754.11,$0.00,11/24/2014,475076326900592,DEBBIES DINER,$754.11,$263.92,35.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076326900592 => ,$692.56,$0.00,11/24/2014,475076326900592,DEBBIES DINER,$692.56,$242.39,35.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103061 => ,$130.93,$0.00,11/24/2014,475076123103061,PLUS ONE HAIR STUDIO,$130.93,$37.96,29.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103061 => ,$123.37,$0.00,11/24/2014,475076123103061,PLUS ONE HAIR STUDIO,$123.37,$35.77,29.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103061 => ,$101.15,$0.00,11/24/2014,475076123103061,PLUS ONE HAIR STUDIO,$101.15,$29.33,29.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103776 => ,$509.88,$0.00,11/24/2014,475076123103776,SOPHISTICATED ELEGANCE HAIR GA,$509.88,$158.05,31.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076123103776 => ,$130.74,$0.00,11/24/2014,475076123103776,SOPHISTICATED ELEGANCE HAIR GA,$130.74,$40.53,31.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 403903349900034 => ,\"$1,623.26\",$0.00,11/24/2014,403903349900034,SOUTHERN GOLF TOURS AND GOLF PACKAGES,\"$1,623.26\",$194.79,12.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076349900147 => ,\"$2,533.90\",$0.00,11/24/2014,475076349900147,STEREO PLUS,\"$2,533.90\",$380.07,15.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076349900147 => ,$816.76,$0.00,11/24/2014,475076349900147,STEREO PLUS,$816.76,$122.51,15.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076326101357 => ,$112.20,$0.00,11/24/2014,475076326101357,SWAGG,$112.20,$38.14,34.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076326101357 => ,$45.04,$0.00,11/24/2014,475076326101357,SWAGG,$45.04,$15.31,34.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076326101357 => ,$95.01,$0.00,11/24/2014,475076326101357,SWAGG,$95.01,$32.30,34.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076349900589 => ,$19.00,$0.00,11/24/2014,475076349900589,TO DUC PHO INC,$19.00,$4.18,22.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076349900589 => ,$10.00,$0.00,11/24/2014,475076349900589,TO DUC PHO INC,$10.00,$2.20,22.00 %,CR\n' + 
'ACH Settlement Report,\"BUSINESS CREDIT & CAPITAL,LLC.\",Settlement Date: 11/24/2014,Total for 475076349900589 => ,$21.03,$0.00,11/24/2014,475076349900589,TO DUC PHO INC,$21.03,$4.62,22.00 %,CR\n';
    }


    private static Blob craeteDocument() {
        Blob csv = Blob.valueOf(documentBody()); 

        return csv;
    }


    private static Repayment__c createRepayment() {

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Repayment__c; 
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Account payee = new Account();
        payee.Name = 'Test';
        insert payee;

        Repayment__c repayment = new Repayment__c();
        repayment.Payee_Account__c = payee.Id;
        repayment.Intial_Repayment_Amount__c = 10000;
        repayment.Next_Hit_Date__c = Date.today().addDays(1);
        repayment.Status__c = 'Active';
        repayment.Payment_Amount__c = 10000;
        repayment.recordtypeid = recordTypeInfo.get('Splits').getRecordTypeId();
        insert repayment; 

        return repayment;
    }

    
    private static Processor_Integration__c createProcessorIntegration() {
    	Processor_Integration__c processorIntegration = new Processor_Integration__c();
        processorIntegration.From_Addresses__c = 'test@test.test';
        insert processorIntegration;
    	
    	return processorIntegration;
    }

    
    private static Processor_Field_Mapping__c createMapping(Processor_Integration__c pi, Integer index, String name, String label) {
    	Processor_Field_Mapping__c mapping = new Processor_Field_Mapping__c();
    	mapping.Index__c = index;//7;
    	mapping.Field_Name__c = name;//'Date__c';
    	mapping.Field_Label__c = label;//'Date';
    	mapping.Processor_Name__c = pi.Id;

    	insert mapping;
    	
    	return mapping;//new PaymentsProcessFieldMappingController.MappingsWrapper(mapping);
    	
    }
    
}