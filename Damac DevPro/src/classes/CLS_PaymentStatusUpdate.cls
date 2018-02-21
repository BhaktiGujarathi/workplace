/******************************************************************************************
 *  Name        : CLS_PaymentStatusUpdate 
 *  Author      : Kaavya Raghuram
 *  Company     : NSI 
 *  Date        : 2017-03-09
 *  Description : This class is to update the payment details obtained from payment gateway 
 
                      
*******************************************************************************************/


global class CLS_PaymentStatusUpdate {     
 
    String RNo,PGRef,BankRef,CepgStatus,message;
    String paymentPurpose,fiDate,payinst,processcharge,payamt; 
    String EncResp;
    String mode='';
    public CLS_PaymentStatusUpdate() {  
      
      //Get Response parameter from the Payment gateway
      EncResp=ApexPages.currentPage().getParameters().get('responseParameter');
      mode=ApexPages.currentPage().getParameters().get('mode');
      system.debug('Enccc===>'+EncResp);
    }  
    
    global PageReference updateReceipt(){
        
        String DecStr=DecryptStr(EncResp);   
          
        DecStr = DecStr.replace('|','--SEPARATOR--');        
        system.debug('DSSSSS==>'+DecStr);
        
        /****Get response parameters from the decrypted message***/
        List<String> RespParams=DecStr.split('--SEPARATOR--');
        system.debug('Response Params=====>'+ RespParams); 
        if(mode=='query')
        RNo=RespParams[1]; 
        else
        RNo=RespParams[0];        
        system.debug('RRRNo===>'+RNo);   
        
        //Get the transation receipt record for the payment done on the portal sidebar
        Receipt__c updR =[select id,name,Amount__c,Card_Type__c,Payment_Status__c,Payment_Gateway_Ref_No__c,PG_Error_Code__c,PG_Error_Message__c 
            from Receipt__c where name=:RNo];
        
        if(mode=='query'){
        
            //Update the values from the response parameter onto the rceipt record
            updR.Payment_Gateway_Ref_No__c=RespParams[2];        
            updR.Payment_Status__c=RespParams[5];            
            updR.Card_Type__c=RespParams[7];
            updR.PG_Error_Code__c=RespParams[8];
            updR.PG_Error_Message__c=RespParams[9];
            
            update updR;
            
            /* 
            updR.Processing_Charges__c=Integer.valueof(processcharge);
            updR.Amount__c=Integer.valueof(payamt);
            */                        
            return null;
        }
        else{
        
            //Update the values from the response parameter onto the rceipt record
            updR.Payment_Gateway_Ref_No__c=RespParams[1];        
            updR.Payment_Status__c=RespParams[4];
            updR.Bank_Ref_No__c=RespParams[5];
            updR.Card_Type__c=RespParams[7];
            updR.PG_Error_Code__c=RespParams[8];
            updR.PG_Error_Message__c=RespParams[9];
            
            update updR;
            List<id> rids= new List<id>();
            if(updR.Payment_Status__c=='SUCCESS'){
                rids.add(updR.id);
                 system.enqueueJob(new AsyncReceiptWebservice (rids,'Receipt Creation'));
            }
            /* 
            updR.Processing_Charges__c=Integer.valueof(processcharge);
            updR.Amount__c=Integer.valueof(payamt);
            */
            
            //Return to the Portal Home Page     
            //PageReference pageRef = new PageReference(Label.Community_URL+'/'+updR.id);
            PageReference pageRef = new PageReference('/Payment_Thank_You?id='+updR.id);
            return pageRef;    
        }
        
    }
    
    global String DecryptStr(String EncStr){
        /*****Decrypt the encrypted response message****/
        //Convert the encrypted string to Blob
        Blob encryptedData= EncodingUtil.base64Decode(EncStr); 
        
        //Get the encryption key from custom setting
        String keyval= Label.Encryption_Key;
        Blob cryptoKey = EncodingUtil.base64Decode(keyval);
        
        //Get the initialization vector from custom setting
        Blob iv = Blob.valueof('0123456789abcdef');
        
        //Decrypt the data using Salesforce Crypto class
        Blob decryptedData = Crypto.decrypt('AES256', cryptoKey,iv,encryptedData);
        system.debug('DDDDD==>'+decryptedData);
        
        // Convert the decrypted data to string
        String decryptedDataString = decryptedData.toString();
        system.debug('DSSSSS==>'+decryptedDataString);
        
        return decryptedDataString;
    }
}