@isTest(seeAllData=false)
public class CLS_PaymentStatusUpdateTest {
    static testMethod void myUnitTest() {
      
        //string accId=string.valueof(objAccount.id);
        //CLS_Payment.Paymentformsubmit(accId,100,'a');
        
        PageReference pageRef = Page.PaymentStatusUpdate;
        Test.setCurrentPageReference(pageRef);
        
        
        Receipt__c R = new Receipt__c();
        //R.Customer__c=objAccount.id;
        R.Amount__c=100; 
        R.Receipt_Type__c='Card';
        R.Transaction_Date__c=system.now();           
               
        Id rt=Schema.SObjectType.Receipt__c.getRecordTypeInfosByName().get('Card').getRecordTypeId();
        R.RecordTypeId=rt;
        insert R;
        
        Test.starttest();
        Receipt__c newR =[select id,name,Payment_Gateway_Ref_No__c,Amount__c,Card_Amount__c from Receipt__c where Receipt_Type__c= 'Card' limit 1];
        String message = newR.name+'|1001312000011127|AED|1000.00|PENDING|5450545351321|CC|VISA|00000|No Error|01|Enrolled|07|120405|ACCEPT|No Fraud|YES|350.50|USD||||||';
        //Get the encryption key from custom label
            String keyval= Label.Encryption_Key;
            Blob cryptoKey = EncodingUtil.base64Decode(keyval);
            
            //Get the initialization vector 
            Blob iv = Blob.valueof('0123456789abcdef');
            
            //Convert the request string to Blob
            Blob data = Blob.valueOf(message);
            
            //Encrypt the data using Salesforce Crypto class
            Blob encryptedData = Crypto.encrypt('AES256', cryptoKey,iv, data);
            system.debug('EEEE=>'+encryptedData) ;
            
            // Convert the encrypted data to string
            String encryptedMessage  = EncodingUtil.base64Encode(encryptedData); 
            System.debug('EEEESSSS=>'+encryptedMessage);
        ApexPages.CurrentPage().getparameters().put('responseParameter',encryptedMessage);
        
        CLS_PaymentStatusUpdate cls1 = new CLS_PaymentStatusUpdate();
        cls1.updateReceipt();
        PageReference pageRef1 = Page.PaymentStatusUpdate;
        Test.setCurrentPageReference(pageRef1);
        String message1 = Label.Merchant_ID+'|'+newR.name+'|1001312000011127|AED|1000.00|FAILURE|5450545351321|CC|VISA|00000|No Error|01|Enrolled|07|120405|ACCEPT|No Fraud|YES|350.50|USD||||||';
          //Convert the request string to Blob
            Blob data1 = Blob.valueOf(message1);
            
            //Encrypt the data using Salesforce Crypto class
            Blob encryptedData1 = Crypto.encrypt('AES256', cryptoKey,iv, data1);
            system.debug('EEEE=>'+encryptedData) ;
            
            // Convert the encrypted data to string
            String encryptedMessage1  = EncodingUtil.base64Encode(encryptedData1); 
            System.debug('EEEESSSS=>'+encryptedMessage);
        ApexPages.CurrentPage().getparameters().put('responseParameter',encryptedMessage1);
        ApexPages.CurrentPage().getparameters().put('mode','query');
        CLS_PaymentStatusUpdate cls2 = new CLS_PaymentStatusUpdate();
        cls2.updateReceipt();
        
        
        
        Test.stoptest();
        
      
        
    }
}