public without sharing class OTPService {
    @future (callout=true)
    public static void Sendtextmessage(list<String> lstPhoneNumbers){
        List<OTP__c> lstotp =  new List<OTP__c>();
        for(String PhoneNumber : lstPhoneNumbers){
	        HttpRequest req = new HttpRequest();
	        HttpResponse res = new HttpResponse();
	        Http http = new Http(); 
	        String user= 'salesforce';
	        String passwd= 'D@$al3sF0rc387!';
	        req.setMethod('POST' ); // Method Type
	        req.setEndpoint('http://api.smscountry.com/SMSCwebservice_bulk.aspx'); 
	        string otpnumber = String.valueOf(Math.random()).substring(8,12);
	        string otpMessage = 'Dear customer, your booking of property has been initiated to verify please use OTP:'+ otpnumber;// Server Url
	        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); // Content TypeAuthorization=' + authorization
	        //req.setHeader('user', user);
	        //req.setHeader('passwd', passwd);
	        req.setBody('user='+ user + '&passwd=' + passwd +'&message=' + otpMessage + '&mobilenumber=' + PhoneNumber + '&sid=DAMAC GRP'); // Request Parameters
	        try {
	            system.debug('Request Body---'+req.getBody());
	            system.debug('Request Header---'+req.getHeader('Authorization'));
	            system.debug('Request Header---'+req.getHeader('Content-Type'));
	            res = http.send(req);
	            if(res.getBody() != null){
	                // Parse Response
	                system.debug('Response---'+res.getBody());
	                if('SMS message(s) sent' == res.getBody()){
	                     system.debug('Message Send Sucessfully');
	                     OTP__c otp =  new OTP__c();
	                     /*
	                     lstotp = [Select Phone_Number__c from OTP__c where Phone_Number__c = :PhoneNumber Limit 1];
	                     if(lstotp.size() > 0){
	                      otp = lstotp[0];
	                     }
	                     */
	                     otp.OTP_Number__c = otpnumber;
	                     otp.Phone_Number__c = PhoneNumber;
	                     lstotp.add(otp);
	                }
	            }
	        } catch(Exception e) {
	            System.debug('Error***** '+ e);
	        }
        }
        if(!lstotp.isEmpty()){
            try{
                upsert lstotp Phone_Number__c;
            }catch(exception ex){
                System.debug('DML Exception*****: '+ ex);
            }
        }
    }
}