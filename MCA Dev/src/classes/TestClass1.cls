public with sharing class TestClass1 {
	private static String SERVER_URL;
    private static String SESSION_ID;
	public static void TestMethod1(){
 			String LOGIN_DOMAIN = 'login'; 
			String USERNAME = 'nexsalesintegration@outboxsystems.com';
			String PASSWORD = 'eternus@123';
			
			Http h = new Http(); 
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/28.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + USERNAME + '</username><password>' + PASSWORD + '</password></login></Body></Envelope>');
        
        HttpResponse response;
        
        if (!Test.isRunningTest()) {
            response = h.send(request);
       
	        system.debug('----Response Body-----'+response.getBody());
	        
	        Dom.XmlNode resultElmt = response.getBodyDocument().getRootElement()
	        .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
	        .getChildElement('loginResponse','urn:partner.soap.sforce.com')
	        .getChildElement('result','urn:partner.soap.sforce.com');
	        
	        SERVER_URL = resultElmt.getChildElement('serverUrl','urn:partner.soap.sforce.com').getText().split('/services')[0];
	        SESSION_ID = resultElmt.getChildElement('sessionId','urn:partner.soap.sforce.com').getText();
	        
	        system.debug('--SERVER_URL---'+SERVER_URL);
	        system.debug('--SESSION_ID---'+SESSION_ID);
        }    
	}
}