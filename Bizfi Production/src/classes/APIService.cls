public class APIService{
        
    public static Map<String, Object> accessToken(){
        QBF_Connect_Settings__c qbfConnect = QBF_Connect_Settings__c.getOrgDefaults();
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('APIKey',qbfConnect.APIKey__c);
        headerMap.put('ClientSecret',qbfConnect.ClientSecret__c);
        
        HttpRequest req = request(qbfConnect.EndPoint__c + '/GetAccessToken',headerMap, 'GET');
        
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(httpCallout(req));
        String due = (String)data.get('ExpiresOn');
        String secs = due.split('\\(')[1].split('\\-')[0];
        Object jSecs = (String)secs;
        data.put('ExpiresOn', jSecs);
        return data;
    }
    
    public static Map<String, Object> submitDeal(AccessTokenResult token, DealSubmission deal){
        QBF_Connect_Settings__c qbfConnect = QBF_Connect_Settings__c.getOrgDefaults();
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Accept','application/json; charset=utf-8');
        headerMap.put('AccessToken',token.AccessToken);
        headerMap.put('Content-Type','application/json');
        
        HttpRequest req = request(qbfConnect.EndPoint__c + '/SubmitDeal', headerMap, 'POST');
        String s = httpCallout(req, JSON.serialize(deal));
        Map<String, Object> dealResult = (Map<String, Object>)JSON.deserializeUntyped(s);
        return dealResult;
    }

    public static ConnectResult uploadDocument(AccessTokenResult token, Integer dealId, Blob file_body, String fileName){
        QBF_Connect_Settings__c qbfConnect = QBF_Connect_Settings__c.getOrgDefaults();
        String boundary = '----------------------------741e90d31eff';
        
        String uri = qbfConnect.EndPoint__c + '/UploadDocument';
        uri += '?dealId=' + dealId;
        uri += '&fileName=' + EncodingUtil.urlEncode(fileName, 'UTF-8');

        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('AccessToken',token.AccessToken);
        headerMap.put('Content-Type','multipart/form-data; boundary='+boundary);
        
        HttpRequest req = request(uri,headerMap,'POST');
        return (ConnectResult)JSON.deserialize(httpCallout(req,file_body),ConnectResult.class);
    } 


    public static ConnectResult uploadDocumentFromUrl(AccessTokenResult token, Integer dealId, String fileUrl){
        QBF_Connect_Settings__c qbfConnect = QBF_Connect_Settings__c.getOrgDefaults();
        String boundary = '----------------------------741e90d31eff';
        String uri = qbfConnect.EndPoint__c + '/UploadDocumentFromUrl';
        uri += '?dealId=' + dealId;
        uri += '&url=' + EncodingUtil.urlEncode(fileUrl, 'UTF-8');

        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('AccessToken',token.AccessToken);
        headerMap.put('Content-Type','application/pdf');
        headerMap.put('Content-Length','0');
        
        HttpRequest req = request(uri,headerMap,'POST');
        return (ConnectResult)JSON.deserialize(httpCallout(req),ConnectResult.class);
    }
    
    public static HttpRequest request(String endPoint, Map<String,String> headerMaps, String method){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        for (String mapKey : headerMaps.keySet()){
            req.setHeader(mapKey, headerMaps.get(mapKey));
        }
        return req;
    }
    
    public static String httpCallout(HttpRequest req){

        Http http = new Http();
        if(req.getEndpoint().contains('UploadDocumentFromUrl')){
            req.setCompressed(true);
            req.setTimeout(120000);
        }

        HTTPResponse res = http.send(req);
        return res.getBody();
   
    } 
    
    public static String httpCallout(HttpRequest req, String body){

        Http http = new Http();
        req.setBody(body);
        //
        req.setTimeOut(120000);
        //

        HTTPResponse res = http.send(req);
        return res.getBody();
   
    } 
    
    public static String httpCallout(HttpRequest req,Blob blobBody){

        Http http = new Http();
        req.setBodyAsBlob(blobBody);

        HTTPResponse res = http.send(req);
        return res.getBody();
        
    }
    
}