public with sharing class DETE_OnetService {

    public static final String STR_CODE                 = 'code';
    public static final String STR_KEYWORD              = 'keyword=';
    public static final String STR_SOC_CODE             = 'SOC-CODE';
    public static final String STR_END_RANGE            = '&end=10000';
    public static final String STR_OCCUPATION_URL       = 'occupations?';
    public static final String STR_RELATED_OCCUPATION   = 'occupations/SOC-CODE/details/related_occupations';

    // Method to form request for Onet
    public static HttpRequest formOnetRequestFormat(String url) {
            DETE_ONET_Integration_Details__c onetIntegrationSetting =   DETE_ONET_Integration_Details__c.getOrgDefaults();

        if(  true == String.isBlank(onetIntegrationSetting.Endpoint_URL__c)
          || true == String.isBlank(onetIntegrationSetting.User_Name__c)
          || true == String.isBlank(onetIntegrationSetting.Password__c)
          || true == String.isBlank(url)
          ) {
              return new HttpRequest();
          }

          Blob headerValue = Blob.valueOf(onetIntegrationSetting.User_Name__c + ':' + onetIntegrationSetting.Password__c);
          String authorizationHeader = DETE_Util.STR_AUTHO_BASIC +
               EncodingUtil.base64Encode(headerValue);

          HttpRequest httpReq = new HTTPRequest();
          httpReq.setEndpoint(onetIntegrationSetting.Endpoint_URL__c + url);
          httpReq.setMethod(DETE_Util.STR_GETMETHOD);
          httpReq.setHeader(DETE_Util.STR_AUTHO_HEADER, authorizationHeader);

        return httpReq;
    }

    // Method to call out Onet Webservice
    public static Set<String> fetchDataFromOnet(String requestUrl) {
        HttpRequest httpRequest = formOnetRequestFormat(requestUrl);

        if(null == httpRequest ) {
            return new Set<String>();
        }

        HTTP http = new HTTP();
        HttpResponse httpResponse = http.send(httpRequest);

        if( httpResponse.getStatusCode() != DETE_Util.STATUS_CODE ) {
            return new Set<String>();
        }

        return parseXMLResponse(httpResponse.getBody());
    }

    // Method to fetch Set of related Occupation
    public static Set<String> parseXMLResponse(String reponseBody) {

        if( true == String.isBlank(reponseBody) ) {
            return new Set<String>();
        }

        Set<String> socCodeSet = new Set<String>();
        Dom.Document DomObj = new Dom.Document();
        DomObj.load(reponseBody);

        Dom.XmlNode nodeObj = DomObj.getRootElement();
        Dom.XmlNode [] childNodes = nodeObj.getchildelements() ; //Get all Record Elements

        for(Dom.XmlNode child : childNodes) { //Loop Through Records
             for (Dom.XmlNode childNodeRecords : child.getchildren() ) {
                 if (childNodeRecords.getname() == STR_CODE) {
                     socCodeSet.add(childNodeRecords.gettext());
                 }
             }
        }

         System.debug('...socCodeSet: ' + socCodeSet);
         return socCodeSet;
    }
}