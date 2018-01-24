public with sharing class RestAccessTokenViaAccessCode {
    // This is Partner Community login url
    static String endpointOrg = 'https://ap1.salesforce.com';

    /*
    * This method is main method to be executed inorder to get request body
    * perform partner user login and finally get the access token for loggedin user
    */
    public void performServiceCallout() {
        String urlMappingName = 'resources';
        String requestBody = createRequestBody();
        HttpResponse loginUserResponse = loginUser(requestBody);
        AuthorisationInfo authenticationInfo = 
                (AuthorisationInfo) JSON.deserialize(loginUserResponse.getbody(), AuthorisationInfo.class);
        System.debug('####authenticationInfo :'+authenticationInfo );
    }

    /*
    * This method creates the request body by setting the clientId, clientSecret and callbackUrl   
    */
    public String createRequestBody() {
        String clientId = 
            '3MVG9Y6d_Btp4xp5xYNS2pWZr5g7F2G8mJcTK7slcvRSAGs.DlvgytLWhXpGwrff7MfsY3UgXHV2Em2bLGkqz';
        String clientSecret = '8285276997755548721';
        String callbackUrl = 'https://localhost:8081/callback';
        // This code is generated once you add partner user's username & password
        String code = 'aPrxaSyVmC8fBbfXCb3.mM1PPFrLiPRaBB1Rl75y7ZeeAlYQ5P2U_zpSTePvZhf26Ll7wjRbng%3D%3D';
         //   'aPrx8yPWn0CtxznaAYWJTRhQwD7PLTEz2F4fgg9G6.7.gFVjIoPR33Q158To9uro64xAm65hJA%3D%3D';
        String reqbody =
                        'grant_type=authorization_code&code=' + code + '&client_id=' + clientId +
                        '&client_secret=' + clientSecret +
                        '&redirect_uri=' + callbackUrl;
        return reqbody;
    }

    /*
    * Performs the user login according to the request body set
    */
    public HttpResponse loginUser(String requestBody) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setBody(requestBody);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setEndpoint(endpointOrg + '/services/oauth2/token');
        HttpResponse response = h.send(request);
        return response;
    }
    
    /*
    * Maintains all the authentication information related to logged in user
    */
    public class AuthorisationInfo {
        public String id {get; set;}
        public String issued_at {get; set;}
        public String instance_url {get; set;}
        public String signature {get; set;}
        public String access_token {get; set;}
    }
}