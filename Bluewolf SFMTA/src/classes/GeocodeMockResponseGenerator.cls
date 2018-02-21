@isTest
public class GeocodeMockResponseGenerator implements HttpCalloutMock{
    protected string bodyAsString;

    public GeocodeMockResponseGenerator(string body){
        this.bodyAsString = body;
    }

    public HttpResponse respond(HttpRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setBody(bodyAsString);
        return resp;
    }
}