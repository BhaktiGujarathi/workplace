@isTest 
global class MockHttpCalloutClass implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req){
        System.assertEquals('https://www.google.com/recaptcha/api/siteverify', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
       	HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"success": "true"}');
        return res;
    }
}