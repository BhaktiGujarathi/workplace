@isTest
public class DETE_MockResponseClass implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;


    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();

        System.debug('...req DETE_MockResponseClass' + req);

        if( true == req.getEndpoint().contains('/joblink.delaware.gov') ) {
            res.setBody(DETE_DataFactory.STR_JOBLINK_RESPONSE);
            res.setStatusCode(200);
            res.setStatus('OK');

        } else if( true == req.getEndpoint().contains('/services.onetcenter.org')) {
            res.setBody(DETE_DataFactory.STR_ONET_RESPONSE);
            res.setStatusCode(200);
            res.setStatus('OK');
        }

        return res;
    }

    /*public string getJSONBody() {
        String json = '{'+
                          '"occupations": {'+
                            '"-sort": "name",'+
                            '"-start": "1",'+
                            '"-end": "2",'+
                            '"-total": "1110",'+
                            '"link": {'+
                              '"-href": "https://services.onetcenter.org/ws/online/occupations/?sort=name&start=3&end=4",'+
                              '"-rel": "next"'+
                            '},'+
                            '"occupation": ['+
                             '{'+
                                '"-href": "https://services.onetcenter.org/ws/online/occupations/13-2011.01/",'+
                                '"code": "13-2011.01",'+
                                '"title": "Accountants",'+
                                '"tags": {'+
                                  '"-bright_outlook": "true",'+
                                  '"-green": "false"'+
                                '}'+
                              '},'+
                              '{'+
                                '"-href": "https://services.onetcenter.org/ws/online/occupations/13-2011.00/",'+
                                '"code": "13-2011.00",'+
                                '"title": "Acco{'+
                          '"occupations": {'+
                            '"-sort": "name",'+
                            '"-start": "1",'+
                            '"-end": "1",'+
                            '"-total": "1110",'+
                            '"link": {'+
                              '"-href": "https://services.onetcenter.org/ws/online/occupations/?sort=name&start=2&end=2",'+
                              '"-rel": "next"'+
                            '},'+
                            '"occupation": {'+
                              '"-href": "https://services.onetcenter.org/ws/online/occupations/13-2011.01/",'+
                              '"code": "13-2011.01",'+
                              '"title": "Accountants",'+
                              '"tags": {'+
                                '"-bright_outlook": "true",'+
                                '"-green": "false"'+
                              '}'+
                            '}'+
                          '}';
        return json;
    }*/
}