public without sharing class docAndPaymentDummyData {
    @InvocableMethod
    public static void createDummyData(List<ID> ids){
        /*
        List<Payment_Detail__c> lstPay = new List<Payment_Detail__c>();
        list<SR_Attachments__c> lstSrAttachment = new list<SR_Attachments__c>(); 
        for(Case objC : [select Id from Case where Id IN : ids]){
            Payment_Detail__c objPay = new Payment_Detail__c();
            objPay.Case__c = objC.Id;
            objPay.Amount_Paid__c = 0;
            objPay.Pending_Amount__c = 100;
            objPay.Payment_Detail__c = 'INVOICES WHICH ARE DUE IN 30 DAYS';
            lstPay.add(objPay);
      
            Payment_Detail__c objPay1 = new Payment_Detail__c();
            objPay1.Case__c = objC.Id;
            objPay1.Amount_Paid__c = 0;
            objPay1.Pending_Amount__c = 250;
            objPay1.Payment_Detail__c = 'ADMIN CHARGES';
            lstPay.add(objPay1);
      
            Payment_Detail__c objPay2 = new Payment_Detail__c();
            objPay2.Case__c = objC.Id;
            objPay2.Amount_Paid__c = 0;
            objPay2.Pending_Amount__c = 300;
            objPay2.Payment_Detail__c = 'OVERDUES TOWARDS INSTALMENTS';
            lstPay.add(objPay2);
      
            SR_Attachments__c objSR1 = new SR_Attachments__c();
            objSR1.Name = 'PASSPORT COPY OF BUYER';
            objSR1.isValid__c = false;
            objSR1.IsRequired__c = true;
            objSR1.Type__c = 'Passport';
            objSR1.Case__c = objC.Id;
            lstSrAttachment.add(objSR1);
      
            SR_Attachments__c objSR2 = new SR_Attachments__c();
            objSR2.Name = 'COMPANY DOCUMENT';
            objSR2.isValid__c = false;
            objSR2.IsRequired__c = true;
            objSR2.Type__c = 'Passport';
            objSR2.Case__c = objC.Id;
            lstSrAttachment.add(objSR2);
              
            SR_Attachments__c objSR3 = new SR_Attachments__c();
            objSR3.Name = 'PASSPORT COPY OF SELLER';
            objSR3.isValid__c = false;
            objSR3.IsRequired__c = true;
            objSR3.Type__c = 'Passport';
            objSR3.Case__c = objC.Id;
            lstSrAttachment.add(objSR3);
        }
        insert lstPay;
        insert lstSrAttachment;
        */
    }
}