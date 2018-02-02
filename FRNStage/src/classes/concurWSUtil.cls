global class concurWSUtil {

    WebService static String concurWS(String authzKEY) {
        String username = 'WebAdmin@frnmail.com';
        String password = 'Welcome@2';
          
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(username+':'+password);
        String authorizationHeader = 'OAuth ' + authzKEY;
        
        req.setEndpoint('https://www.concursolutions.com/api/travel/trip/v1.1');    
        req.setHeader('Authorization',authorizationHeader);     
        req.setMethod('GET');  
        // req.setHeader('Authorization', 'OAuth 0_G7Xyj/d39PBhLyg2fugya/6co=</');  
     
        Http http = new Http(); 
        HTTPResponse res = http.send(req);  
        System.debug('BODY: '+res.getBody());  
        System.debug('STATUS:'+res.getStatus()); 
        System.debug('STATUS_CODE:'+res.getStatusCode());
        return res.getStatus();     
    }    
}