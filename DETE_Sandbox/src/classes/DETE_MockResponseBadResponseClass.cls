@isTest
public class DETE_MockResponseBadResponseClass implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;


    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();

        System.debug('...req DETE_MockResponseClass' + req);

        if( true == req.getEndpoint().contains('/services.onetcenter.org')) {
            res.setBody(DETE_DataFactory.STR_ONET_RESPONSE);
            res.setStatusCode(400);
            res.setStatus('OK');
        }

        return res;
    }
}