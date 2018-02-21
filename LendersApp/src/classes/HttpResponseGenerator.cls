@isTest
global class HttpResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
    	
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"merchant":{"fein":"12-3456789","legal_name":"Ashwini Singh","dba":"","address":null,"street1":"","street2":"","city":"Washington","state":"DC","business_phone":"","business_startdate":null,"industry":"","notes":[{"note":{"category":"Slow Pay","note":"he pays in small ","created_at":"2015-12-30 16:07:28 UTC"}}]}}]');
        res.setStatusCode(200);
        return res;
    }
}