public Class TestAuthenticationTypeWebService
{


public void TestBasicAuthWebService()
{
// Refer: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields.
/*
In Basic Authentication we need to set the suth cred in header on enery request.
it cannot be persist between consecutive request.
*/


//GET --->Endpoint :https://www.datamerch.com/api/v1/merchants/3456789
//O/p----> JSON data.
/*
         String username = '_yCxMqPDzNxMRurN1M8Z';
         String password = 'PN3QxCoEzg';
         HttpRequest req = new HttpRequest();
         req.setMethod('GET');
         req.setEndpoint('https://www.datamerch.com/api/v1/merchants/3456789');
         Blob headerValue = Blob.valueOf(username + ':' + password);
         String authorizationHeader = 'BASIC ' +
         EncodingUtil.base64Encode(headerValue);
         req.setHeader('Content-Type', 'application/json');
         req.setHeader('Authorization', authorizationHeader);
        // during get we do not set body
        
         Http http = new Http();
         HTTPResponse res = http.send(req);
         System.debug('>>>res : '+res.getBody());

*/

//POST --->Endpoint :https://www.datamerch.com/api/v1/merchants
//O/p----> JSON data.
/*

String username = '_yCxMqPDzNxMRurN1M8Z';
         String password = 'PN3QxCoEzg';
         HttpRequest req = new HttpRequest();
         req.setMethod('POST');
         req.setEndpoint('https://www.datamerch.com/api/v1/merchants');
         Blob headerValue = Blob.valueOf(username + ':' + password);
         String authorizationHeader = 'BASIC ' +
         EncodingUtil.base64Encode(headerValue);
         req.setHeader('Content-Type', 'application/json');
         req.setHeader('Authorization', authorizationHeader);
         
         //We Set the body
         req.setBody('{'+  
                           '"fein":"01-2224522",'+
                           '"legal_name":"ACME Company",'+
                           '"dba":"ACME",'+
                           '"street1":"123 First St.",'+
                           '"street2":"Suite 100",'+
                           '"city":"Los Angeles",'+
                           '"state":"CA",'+
                           '"business_phone":"123-456-7890",'+
                           '"business_startdate":"1/1/1985",'+
                           '"industry":"Combustables",'+
                           '"note_category":"Slow Pay",'+
                           '"note":"Merchant is a slow pay and/or default account."'+
                        '}');
        
         Http http = new Http();
         HTTPResponse res = http.send(req);
         System.debug('>>>res : '+res.getBody());




*/




}





}