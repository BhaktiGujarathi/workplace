@isTest
global class createBlankOrderMockTest implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-type','application/x-www-form-urlencoded');
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><i4>895141</i4></value></param></params></methodResponse>');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}