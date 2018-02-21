/******************************************************************************************
 *  Author   : Ravindra Babu Nagaboina
 *  Company  : NSI DMCC
 *  Date     : 04rd Jan 2017
 --------------------------------------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No   Date            Updated By          Description
 ----------------------------------------------------------------------------------------              
 V1.0  04/Jan/2016      Ravi                Created
 V1.1  13/Mar/2017      Siva                #337 Added methods to mask the contact number
 V1.2 # 29-03-2017 # Sivasankar # Logic to send the OTP
*******************************************************************************************/
public with sharing class UtilityHelperCls {
    
    /********* Utility Variables ********************/
    public static map<Id,RecordType> mapInventoryRecordTypes = new map<Id,RecordType>();
    
    /********* End of Utility variables ********************/
    
    /********* Utility Methods ********************/
    public static map<Id,RecordType> LoadRecordTypes(map<Id,RecordType> mapRecordTypes, string sObjectName,Boolean isLoad){
        if(mapRecordTypes != null && mapRecordTypes.isEmpty() == false && isLoad == false){
            return mapRecordTypes;
        }else if(mapRecordTypes.isEmpty() || isLoad == true){
            if(sObjectName != null){
                mapRecordTypes = new map<Id,RecordType>([select Id,Name,DeveloperName from RecordType where isActive = true AND sObjectType =: sObjectName ]);
            }
        }
        return mapRecordTypes;
    }
    /********* End of Utility Methods ********************/
    
    /**
    * Returns the "Name" field for a given SObject (e.g. Case has CaseNumber, Account has Name)
    **/
    @testvisible private static Boolean areSearchFieldsTextType(SobjectType sobjType,String searchFields){
        
        //describes lookup obj and gets its name field
        Boolean areTextTypes = true;
        Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
        for(schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
            Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
            if( ! (fieldDescObj.getType() == Schema.DisplayType.String || fieldDescObj.getType() == Schema.DisplayType.Phone || fieldDescObj.getType() == Schema.DisplayType.Email)  ){
                areTextTypes = false;
                break;
            }
        }
        return areTextTypes;
    }
    //V1.1.Start
    /*********************************************************************************************
    * @Description : Method to encrypt the mobile number                                         *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public static String encryptMobile(String mobileforEncrypt){
        PasswordCryptoGraphy mobileEncrypt = new PasswordCryptoGraphy();
        //Assign the key value
        mobileEncrypt.strKey = Label.Mobile_Encryption_key;
        mobileEncrypt.strActualPassword = mobileforEncrypt;
        mobileEncrypt.encryptMobilePhone();
        return mobileEncrypt.strResult;
    }
    
    /*********************************************************************************************
    * @Description : Method to encrypt the mobile number                                         *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public static String decryptMobile(String mobileforDecrypt){
        PasswordCryptoGraphy mobileEncrypt = new PasswordCryptoGraphy();
        //Assign the key value
        mobileEncrypt.strKey = Label.Mobile_Encryption_key;
        mobileEncrypt.decryptMobilePhone(mobileforDecrypt);
        return mobileEncrypt.strResult;
    }
    
    /*********************************************************************************************
    * @Description : Method to remove the first zero from the mobile number                      *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public static String removeFirstZero(String mobile){
        if(String.isNotBlank(mobile) && mobile.startsWith('0')){
            mobile = (mobile.subStringAfter('0')).trim();
            removeFirstZero(mobile);
        }
        return mobile;
    }
    
    /*********************************************************************************************
    * @Description : Get the access token                                                        *
    * @Params      : void                                                                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    public static string AcessToken(){
        string Environment = 'login';  
        string accsToken = '';
        string ErrorDesc = '';  
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        if(org.IsSandbox)
            Environment = 'test';
        string URI = 'https://'+Environment+'.salesforce.com/services/oauth2/token?grant_type=password&'+'client_id=' + Label.Metadata_ConsumerKey + '&client_secret=' + Label.Metadata_SecretKey + '&username=' + Label.Damac_Username + '&password=' + Label.Damac_Password;//+Label.Metadata_SecurityToken
        JSONParser parser1;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URI);
        req.setMethod('POST');
        Http http = new Http();
        if(!Test.isRunningTest()){
            HTTPResponse res = http.send(req);
            accsToken = '';
            system.debug('AccessToken==>'+res.getBody());
            parser1 = JSON.createParser(res.getBody());
        }else{
            String result = '{"id":"https://test.salesforce.com/id/00Dg0000003L0MREA0/005g0000000vZSKAA2","issued_at":"1398932139767","token_type":"Bearer","instance_url":"https://cs17.salesforce.com","signature":"oQ7eOe8SIHMoqZw6XTX7qsoalf43WPMfJG9foXDhph8=","access_token":"00Dg0000003L0MR!AQUAQPMYBxWQE7EQj8U6q17.6IHneCQ0Fj.N2Reek.i5xA8Z.UFol_.v7iypTySMU1nKaEg0tciXmKyCwCGFPdZtuk_M5dQr"}';
            parser1 = JSON.createParser(result);
        }
        if(parser1!=null){
            while(parser1.nextToken() != null) {
                if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'access_token')) {
                    parser1.nextToken();
                    accsToken = parser1.getText();
                }
                if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'error_description')) {
                    parser1.nextToken();
                    ErrorDesc = parser1.getText();
                }
            }
        }
        return accsToken;
    }
    
    //V1.2.Start
    /*********************************************************************************************
    * @Description : Method to send the OTP                                                      *
    * @Params      : String mobileNumber it should starts with country code ex: 9719087654321    *
    * @Return      : Map<String,Inquiry__c>                                                      *
    *********************************************************************************************/
    @future (callout=true)
    public static void sendsms(String mobileNumber,string messageBody){
        system.debug('SRMob==>'+mobileNumber);
        system.debug('strMessage==>'+messageBody);
        
        //if(String.isBlank(mobileNumber))
            //return 'Mobile number can\'t be blank.';
        //if(String.isBlank(messageBody))
            //return 'SMS body can\'t be blank.';
        if(String.isNotBlank(mobileNumber) && mobileNumber.startsWith('00')){
            mobileNumber = mobileNumber.replaceFirst('00', '+');    
        }
        //Encode the message in UTF-8
        String SMSMessage = EncodingUtil.urlEncode(messageBody, 'UTF-8');
        String encodeUserName = EncodingUtil.urlEncode(Label.SMS_Username, 'UTF-8');
        string decryptedSMSPassWrd = test.isRunningTest() == false ? PasswordCryptoGraphy.DecryptPassword(Label.SMS_Password) : '123456' ;  // V1.1 
        decryptedSMSPassWrd = EncodingUtil.urlEncode(decryptedSMSPassWrd, 'UTF-8');
        //mobileNumber = EncodingUtil.urlEncode(mobileNumber, 'UTF-8');
        
        //Creating a HTTP request to SMSCountry with the sms parameters       
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000); //milliseconds      
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');//
        req.setHeader('Content-Length','0');
        
        //Setting the SMS endpoint with required parameters
        req.setEndpoint('http://api.smscountry.com/SMSCwebservice_bulk.aspx?user='+encodeUserName+'&passwd='+decryptedSMSPassWrd+'&mobilenumber='+mobileNumber+'&message='+SMSMessage+'&sid=DAMAC&Mtype=N&DR=Y');
        req.setMethod('POST');
        try{
            if(!System.Test.isRunningTest()){  //to prevent callouts while running test class
                //Sending the HTTP request
                res = http.send(req);
                Log__c objLog = new Log__c(Description__c= JSON.serialize(res.getBody()),Type__c='HTTP Callout to SMS'+mobileNumber);
                insert objLog;
                system.debug('***Body was:' + res.getBody());
            }
            //return JSON.serialize(res.getBody());
        } catch(System.CalloutException ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage()+'==SMS==='+SMSMessage;
            objLog.Type__c = 'HTTP Callout to SMS'+mobileNumber;
            insert objLog; 
            //return objLog.Description__c;
        }
        
    }
    //V1.2.End
}