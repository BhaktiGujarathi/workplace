@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        
        if(req.getEndpoint().contains('GetAccessToken')){
            res.setBody('{"ErrorMessage": null,"StatusCode": 0,"AccessToken": "PXitDKTu9kmJFQcbevMRdQ==","ExpiresOn": "/Date(1442992504896-0700)/"}');
        }
        else if(req.getEndpoint().contains('SubmitDeal')){
            res.setBody('{"ErrorMessage": null,"StatusCode": 5,"DealID": 107946,"ExternalDealID": "12-345-1337","ProcessedOn": "/Date(1442991791632-0700)/"}');
        }
        else if(req.getEndpoint().contains('UploadDocument')){
            res.setBody('{"ErrorMessage": null,"StatusCode": 0}');
        }
        else{
            res.setBody('{"ErrorMessage": null,"StatusCode": 0}');
        }
        res.setStatusCode(200);

        System.debug(res.getBody());
        return res; 
    }

}