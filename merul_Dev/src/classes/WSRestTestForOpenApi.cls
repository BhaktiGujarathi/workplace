/*

Refer:http://www.worldofsalesforce.com/2016/05/IntegratingSalesforceOrgtoanotherSalesforceOrg.html

*/


public class WSRestTestForOpenApi 
{ 
    
    private static String YOUR_REMOTE_ACCESS_APP_CONSUMER_KEY = '3MVG9Y6d_Btp4xp5xYNS2pWZr5g7F2G8mJcTK7slcvRSAGs.DlvgytLWhXpGwrff7MfsY3UgXHV2Em2bLGkqz';
    private static String YOUR_REMOTE_ACCESS_APP_CONSUMER_SECRET = '8285276997755548721';
    private static String USERNAME_IN_TARGET_ORG = 'merulkumar_shah@ymail.com';
    private static String PASSWORD_IN_TARGET_ORG = 'm@9428740414';
    private static String SECURITY_TOKEN_IN_TARGET_ORG = 'bEBu2vfkn0Gpz1Vm1m1kZfPPX';
    //private static String LOGIN_URL = URL.getSalesforceBaseUrl().toExternalForm(); 
    private static String LOGIN_URL = 'https://ap1.salesforce.com/';
    
        
    private static JSONObject oauthLogin(String loginUri, String clientId, String clientSecret, String username, String password) 
    {
        HttpRequest req = new HttpRequest(); 
 
        req.setMethod('POST');
        req.setEndpoint(loginUri+'services/oauth2/token');
        req.setBody('grant_type=password' +
            '&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8'));
    
        Http http = new Http();
  
        HTTPResponse res = http.send(req);

        System.debug('BODY: ' + res.getBody());
        System.debug('STATUS:' + res.getStatus());
        System.debug('STATUS_CODE:' + res.getStatusCode());           
        //System.debug('respose is here'+res);    
        return new JSONObject (res.getBody()); 
    }
    
    //public static String restTest(String objName) 
    public static String restTest() 
    {
      
      
      
       HttpRequest req = new HttpRequest();
      
       req.setMethod('GET');
               
       String jsonStr;//='{"PRIMARY_CONTACT_FIRST_NAME":"ResTFN","PRIMARY_CONTACT_LAST_NAME":"RESTLN","PARTICIPANT_NAME":"Participant 1","PARTICIPANT_ORG_ID":"","PARTICIPANT_CONTACT_TITLE":"RestTitle","PARTICIPANT_CONTACT_EMAIL":"prachi_gupta15@infosys.com","PARTICIPANT_CONTACT_PHONE_NUMBER":"121211","REGISTRATION_DATE":"02/02/2014","PROGRAM_TYPE":"PSP"}';
       
       
       // req.setBody('{"parentId":"a1cR0000000FYjC","listOfAttachments":[{  "name":"test.txt","attachmentBody":"dGVzdA=="} ,{"name":"test2.txt","attachmentBody":"dGVzdA=="}]}');       
      
        req.setTimeout(5000);  
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json'); 
       
          req.setEndpoint('http://api.openweathermap.org/data/2.5/weather?q=London,uk');   
        
      //  req.setHeader('Authorization', 'OAuth '+ accessToken);

        Http http = new Http();
  
        HTTPResponse res = http.send(req); 
        System.debug('BODY: ' + res.getBody());
        System.debug('STATUS:' + res.getStatus());
        System.debug('STATUS_CODE:' + res.getStatusCode());
       // RestTest.ThankYou();
       System.debug('Body '+  res.getBody());
        return res.getBody();
        
        return null;

    }
    
  
     
    
   }