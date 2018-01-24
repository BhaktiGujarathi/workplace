/**
 * @author Pat Patterson - ppatterson@salesforce.com
 */
/*

Ref: https://developer.salesforce.com/forums/?id=906F000000099zbIAA
this code is found in one of the comment of the mentioned link 

*/
public abstract class OAuthRestController {
    static String clientId = '3MVG9Y6d_Btp4xp5xYNS2pWZr5mpHo_GA3ZLaW1MhJlz18U_iUlSS934PELNeAaKGTiLEwk78_iQAillyvZk9'; // Set this in step 3
    static String clientSecret = '4363967558636294197'; // Set this in step 3
    //static String redirectUri = '<a href="https://c.na12.visual.force.com/apex/RestCall';" target="_blank" rel="nofollow">https://c.na12.visual.force.com/apex/RestCall</a>'; // YOUR PAGE URL IN THE SOURCE ORG
    // static String loginUrl = '<a href="https://yourdomain-developer-edition.my.salesforce.com';" target="_blank" rel="nofollow">https://yourdomain-developer-edition.my.salesforce.com';</a> // YOUR MY DOMAIN URL IN THE TARGET ORG
    
    static String redirectUri = 'https://c.na12.visual.force.com/apex/RestCall'; // YOUR PAGE URL IN THE SOURCE ORG
    static String loginUrl = 'https://login.salesforce.com'; // YOUR MY DOMAIN URL IN THE TARGET ORG
    
    
    static String cookieName = 'oauth';

    public PageReference login() 
    {
        // Get a URL for the page without any query params
        String url = ApexPages.currentPage().getUrl().split('\\?')[0];
       
        System.debug('url is '+url);

        String oauth = (ApexPages.currentPage().getCookies().get(cookieName) != null ) ?
            ApexPages.currentPage().getCookies().get(cookieName).getValue() : null;
       /* if (oauth != null) {
            // TODO - Check for expired token
        }
       
        System.debug('oauth='+oauth);
        if (oauth != null) {
            // All done
            return null;
        }*/
       
        // If we get here we have no token
        PageReference pageRef;
       
        if (! ApexPages.currentPage().getParameters().containsKey('code')) {
            // Initial step of OAuth - redirect to OAuth service
            System.debug('OAuth Step 1');
       
            String authuri = loginUrl+'/services/oauth2/authorize?'+
                'response_type=code&client_id='+clientId+'&redirect_uri='+redirectUri;
                           
            pageRef = new PageReference(authuri);
            return pageRef ;
        } else {
            // Second step of OAuth - get token from OAuth service
            String code = ApexPages.currentPage().getParameters().get('code');

            System.debug('OAuth Step 2 - code:'+code);
               
            String body = 'grant_type=authorization_code&client_id='+clientId+
                '&redirect_uri='+redirectUri+'&client_secret='+clientSecret+
                '&code='+code;
            System.debug('body is:'+body);
               
            HttpRequest req = new HttpRequest();
            req.setEndpoint(loginUrl+'/services/oauth2/token');
            req.setMethod('POST');
            req.setBody(body);
       
            Http h = new Http();
            HttpResponse res = h.send(req);
   
            String resp = res.getBody();
            System.debug('FINAL RESP IS:'+EncodingUtil.urlDecode(resp, 'UTF-8'));
           
            ApexPages.currentPage().setCookies(new Cookie[]{new Cookie(cookieName,
                res.getBody(), null,-1,false)});
               
           
          
        }
       
        return null;
    }
   
    public static String getRestTest() {
        String oauth = (ApexPages.currentPage().getCookies().get(cookieName) != null ) ?
            ApexPages.currentPage().getCookies().get(cookieName).getValue() : null;
        JSONObject oauthObj = new JSONObject( new JSONObject.JSONTokener(oauth));
           
        String accessToken = oauthObj.getValue('access_token').str,
               instanceUrl = oauthObj.getValue('instance_url').str;

        HttpRequest req = new HttpRequest();
 
        req.setMethod('GET');
        req.setEndpoint(instanceUrl+'/services/apexrest/superpat/TestRest?name=Pat');
        req.setHeader('Authorization', 'OAuth '+accessToken);

        Http http = new Http();
 
        HTTPResponse res = http.send(req);

        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
       
        return res.getBody();
    }
}