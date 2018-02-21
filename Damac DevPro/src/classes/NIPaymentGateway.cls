global class NIPaymentGateway{
    

    public static ID bookingUnitID {get;set;}
    public transient List<Booking_Unit__c> DataTableBU{set;get;}
    public transient List<NSIBPM__Service_Request__c> DataTableSR{set;get;}
    public transient List<Booking__c> DataTableBooking{set;get;}
    public transient List<Payment_Plan__c> DataTablePP{set;get;}    
    public transient List<Buyer__c> DataTableBuyer{set;get;}    
    
    
     public transient List<Schema.FieldSetMember> DataTable_SchemaBU {set;get;}
     public transient List<Schema.FieldSetMember> DataTable_SchemaSR {set;get;}
     public transient List<Schema.FieldSetMember> DataTable_SchemaBooking {set;get;}
     public transient List<Schema.FieldSetMember> DataTable_SchemaPP{set;get;} 
     public transient List<Schema.FieldSetMember> DataTable_SchemaBuyer{set;get;}
    public string Condition;
    //public decimal tokenAmt {get;set;}
    public static decimal tokenAmt {get;set;}
    Public id AccntID {get;set;}
    //public boolean isAmntPaid {get;set;}
    public static boolean isAmntPaid {get;set;}
    
    global NIPaymentGateway(){

        if(null != ApexPages.currentPage().getParameters().get('id'))
            bookingUnitID = ApexPages.currentPage().getParameters().get('id');
        if(bookingUnitID != null){
            DataTable_SchemaBU = readFieldSet('BUSiteView','Booking_Unit__c');
            DataTableBU = (List<Booking_Unit__c>)getobject('WHERE Status__c !=\'Removed\' and id =\''+ bookingUnitID +'\'','Booking_Unit__c');
            tokenAmt = DataTableBU[0].Token_Amount__c;
            isAmntPaid = DataTableBU[0].Token_Paid__c;
            //isAmntPaid = false; 
            System.debug('>>>>>>tokenAmt>>>>>>>>>>'+tokenAmt);
            DataTable_SchemaBooking = readFieldSet('BookingSiteView','Booking__c');            
            DataTableBooking = (List<Booking__c>)getobject(DataTableBU[0].Booking__c,'Booking__c');
            
            DataTable_SchemaSR = readFieldSet('SRSiteView','NSIBPM__Service_Request__c');
            DataTableSR = (List<NSIBPM__Service_Request__c>)getobject(DataTableBooking [0].Deal_SR__c,'NSIBPM__Service_Request__c');
            
            DataTable_SchemaPP = readFieldSet('PPSiteView','Payment_Plan__c'); 
            DataTablePP = (List<Payment_Plan__c>)getobject('WHERE Booking_Unit__c =\''+ DataTableBU[0].id +'\'','Payment_Plan__c');
            
            DataTable_SchemaBuyer = readFieldSet('BuyerSiteView','Buyer__c'); 
            DataTableBuyer = (List<Buyer__c>)getobject('WHERE Booking__c =\''+ DataTableBooking[0].id +'\'','Buyer__c');
            if(DataTableBuyer != null && !DataTableBuyer.isempty())
            for(Buyer__c b : DataTableBuyer){
                if(b.Primary_Buyer__c){
                    AccntID = b.Account__c != null ? b.account__c : null;
                    System.debug('>>>>>>AccntID>>>>>>>>>>'+AccntID);
                }
            }
        }
    }
    
    webservice static boolean CheckifPaid(ID buID){
        List<Booking_Unit__c> lstBU = (List<Booking_Unit__c>)getobject(buID,'Booking_Unit__c');
        if(lstBU != null && !lstBU.isempty()){
            system.debug('Inside==>');
          	return lstBU[0].Token_Paid__c;
        }
        return false;
    }
    
    webservice static string doPay(ID buID, Decimal amt){
        //ID accntID, 
        if(buID != null && amt != null){
            /*for(Receipt__c r : [select id,name from Receipt__c where Booking_Unit__c =: buID]){
                return 'Receipt already generated';
            }*/
            string message = Paymentformsubmit(buID,amt);
            System.debug('>>>>>>Message>>>>>>>>>>'+message);
            System.debug('>>>>>>Final URL>>>>>>>>>>'+'https://uat.timesofmoney.com/direcpay/secure/PaymentTransactionServlet?requestParameter='+message);
            return message;
        }
        //return 'Values -->'+buID +' -- '+amt;
        return null;
    }
    
    webservice static String Paymentformsubmit(string buID,Decimal amt){
        try{
            //string accId
            
            
            //Create a receipt record with values entered by the customer
            Receipt__c R = new Receipt__c();
            //R.Customer__c=accId;
            R.Amount__c=amt; 
            R.Receipt_Type__c='Card';
            R.Transaction_Date__c=system.now();           
            R.Booking_Unit__c = buID != null ? buID : null;       
            Id rt=Schema.SObjectType.Receipt__c.getRecordTypeInfosByName().get('Card').getRecordTypeId();
            R.RecordTypeId=rt;
            insert R;
            
            Receipt__c newR;
            
            //Query the newly created receipt record
            newR =[select id,name,Payer__c,Amount__c,Booking_Unit__c,Booking_Unit__r.Booking__c from Receipt__c where id=:R.id];
            system.debug('--check->'+newR.Payer__c+'---->'+newR.Booking_Unit__r.Booking__c+'-----'+newR.Booking_Unit__c);
            String payertype='Self';
            if(newR.Payer__c=='Self')
                payertype='Self';
            else
                payertype='Third Party';
            
            //get the Payer details
            Buyer__c Payer=[select id,First_Name__c,Last_Name__c,Email__c,Address_Line_1__c,City__c,Country__c,Booking__r.Deal_SR__c from Buyer__c where Payer__c= :payertype and Booking__c= :newR.Booking_Unit__r.Booking__c];
            
            //Getting the country code
            String payercountry=DamacUtility.getCountryCode(Payer.Country__c);
            
            //Setting the default state and PO values
            Map<String,String> StateMap = new Map<String,String>();
            Map<String,String> POMap = new Map<String,String>();
            for(NI_State_PO_values__mdt StatePOval :[select id,DeveloperName,State__c,PO__c from NI_State_PO_values__mdt]){
                StateMap.put(StatePOval.DeveloperName,StatePOval.State__c);
                POMap.put(StatePOval.DeveloperName,StatePOval.PO__c);
            }
            
            string cc,state,PO='';
            if(payercountry=='US'||payercountry=='CA')
                cc=payercountry;
            else
                cc='Others';
            
            state=StateMap.get(cc);
            PO = POMap.get(cc);
            
            if(payertype=='Third Party'){
                NSIBPM__Document_Master__c DM = [select id,NSIBPM__Code__c from NSIBPM__Document_Master__c where NSIBPM__Code__c ='Third party consent'];
            
                NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
                SRDoc.NSIBPM__Service_Request__c=Payer.Booking__r.Deal_SR__c;
                SRDoc.Booking_Unit__c=newR.Booking_Unit__c;
                SRDoc.NSIBPM__Generate_Document__c=true;            
                SRDoc.NSIBPM__Document_Master__c=DM.id;
                SRDoc.name='Third Party Consent';
                SRDoc.NSIBPM__Status__c='Generated';
                insert SRDoc;
            
            }
            
            /********** Create a pipe separated string of all fields to be sent in the request  **********************/
            //String message=newR.name+'|AED|'+amt+'|'+Label.Site_Domain+'/PaymentStatusUpdate|'+Label.Site_Domain+'/PaymentStatusUpdate|01|INTERNET|||||||Soloman|Vandy|Abhinav Nagar|Borivali|New York|NY|100255|US|merchant@test.com|34|344|34355344|3453453523|||John|Lenon|Phoenix Mill|Lower Parel|Mumbai|NY|123123|US|45|455|4534534|1321223122||test||1|Book|FALSE|aaa|bbb|ccc|ddd|eee|';
            //String message=newR.name+'|AED|'+newR.Amount__c+'|'+Label.Site_Domain+'/PaymentStatusUpdate|'+Label.Site_Domain+'/PaymentStatusUpdate|01|INTERNET|||||||||||||||||||||||||||||||||||||||||||||';
            String message=newR.name+'|AED|'+newR.Amount__c+'|'+Label.Site_Domain+'/PaymentStatusUpdate|'+Label.Site_Domain+'/PaymentStatusUpdate|01|INTERNET|||||||'+Payer.First_Name__c+'|'+Payer.Last_Name__c+'|'+Payer.Address_Line_1__c+'||'+Payer.City__c+'|'+state+'|'+PO+'|'+payercountry+'|'+Payer.Email__c+'||||||||||||||||||||||||||||||';
            
            system.debug('RRReqqMessage===>'+message);
            
            //Get the encryption key from custom setting
            String keyval= Label.Encryption_key;
            Blob cryptoKey = EncodingUtil.base64Decode(keyval);
            
            //Get the initialization vector from custom setting
            Blob iv = Blob.valueof('0123456789abcdef');
            
            //Convert the request string to Blob
            Blob data = Blob.valueOf(message);
            
            //Encrypt the data using Salesforce Crypto class
            Blob encryptedData = Crypto.encrypt('AES256', cryptoKey,iv, data);
            system.debug('EEEE=>'+encryptedData) ;
            
            // Convert the encrypted data to string
            String encryptedMessage  = EncodingUtil.base64Encode(encryptedData); 
            System.debug('EEEESSSS=>'+encryptedMessage);
            
            string decryptedMerchantID =  test.isrunningTest()==false ? Label.Merchant_ID :'123456'; // V1.0
            
            
            //Append the encrypted string to the MerchantID
            String req= decryptedMerchantID + '|' + encryptedMessage + '|';
            system.debug('RRRRR===>'+req);
            return req;        
        }                
        catch(Exception e){
            System.debug('>>>>>>>>>>>>>>'+e.getLineNumber() +'--->'+e.getmessage());
            return e.getMessage()+'-'+e.getLineNumber();     
        }
    }
    
   
    webservice static string decryptResponse(string resp){
        
        String keyval= Label.Encryption_key;
        Blob cryptoKey = EncodingUtil.base64Decode(keyval);
        
        //Get the initialization vector from custom setting
        Blob iv = Blob.valueof('0123456789abcdef');
        
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(resp);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', cryptoKey , encodedEncryptedBlob);
        String decryptedPasswordText = decryptedBlob.toString();
        System.debug('>>>>>decryptedPasswordText >>>>>>>>'+decryptedPasswordText);
        
        
        return decryptedPasswordText;
    }
    
    
    public static List<sobject> getobject(Id sobID,string sobjType) {
        SObjectType soType = Schema.getGlobalDescribe().get(sobjType);
        DescribeSObjectResult describeResult = soType.getDescribe();
        List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
        query += ' WHERE Id =: sobID LIMIT 1';
        System.debug('==>' + query);
        return Database.query(query);
        //return currSR;
    }
    
    public static List<sobject> getobject(string condition,string sobjType) {
        SObjectType soType = Schema.getGlobalDescribe().get(sobjType);
        DescribeSObjectResult describeResult = soType.getDescribe();
        List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
        //' WHERE Booking_Unit__c =: sobID';
        query += ' '+condition;
        System.debug('==>' + query);
        return Database.query(query);
        //return currSR;
    }
    
    //readFieldSet
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
      try{
           Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
           
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
            return fieldSetObj.getFields();
      }catch(exception ex){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Records')); 
          return null;
      }
    }  

}