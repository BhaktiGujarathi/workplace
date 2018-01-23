@isTest
global class MockClassForConcurIntegration implements HttpCalloutMock {

	String body ='';
	global MockClassForConcurIntegration(){
		body = '<root><Token>shdbjsd247257</Token></root>';
	}
	global MockClassForConcurIntegration(String par){
		this.body = par;		
	}
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
		//System.assertEquals(null, req.getEndpoint(), req.getEndpoint()+'Test URL');
		if(req.getEndpoint().contains('https://www.concursolutions.com/net2/oauth2/accesstoken.ashx')){
			body = '<Access_Token>'+
			'<Instance_Url>https://www.concursolutions.com/</Instance_Url>'+
			'<Token>0_HtnFeWwyvQH1IJuULgGsvb7tk=</Token>'+
			'<Expiration_date>1/3/2018 3:13:15 PM</Expiration_date>'+
			'<Refresh_Token>0_duexVPzRaQAjhtIrBtV9xaa5TvC99</Refresh_Token>'+
			'</Access_Token>';
		}
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
	
	
}