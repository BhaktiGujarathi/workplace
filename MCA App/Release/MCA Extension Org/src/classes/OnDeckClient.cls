public with sharing class OnDeckClient {
    
    private static final String PREQUAL      = '/webconnect/user/prequalify';
    private static final String SUBMIT       = '/webconnect/application/submit';
    private static final String PREQUAL_TEST = '/webconnect/user/prequalifyTest';
    private static final String SUBMIT_TEST  = '/webconnect/application/submitTest';

    public Boolean isSendPrequal = false;
    
    private String username;
    private String password;
    private String url;
    private Boolean testMode;
    
    
    public OnDeckClient() {
        McaFundingApp__Bank_API_Settings__c settings = McaFundingApp__Bank_API_Settings__c.getInstance('OnDeck');

        if (settings != null) {
            username = settings.McaFundingApp__Username__c;
            password = settings.McaFundingApp__Password__c;
            url = settings.McaFundingApp__Api_Url__c;
            testMode = settings.McaFundingApp__Test_Mode__c;
        }
        else {
            throw new OnDeckException('No API Credentials defined for this Bank');
        }
    }
    
    private ResponseData sendRequest(String endpoint, String xmlBody) {
        string now = string.valueOf(datetime.now()).substring(0, 16);
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();  

        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(60000);
        request.setHeader('Content-Type', 'text/xml');
        request.setHeader('Accept', '*/*; q=0.5, application/xml');
        request.SetBody(xmlBody);

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);    
        
        ResponseData response = new ResponseData();
        
        if (!Test.isRunningTest()) {
            HttpResponse res = HttpProtocol.send(request);    
            response.status = res.getStatus();
            response.code = res.getStatusCode();
            response.body = res.getBody();
        }
        else {
            response.status = 'OK';
            response.code = 500;
            if (!isSendPrequal){
                response.body = '<xs:SubmitApplicationResponse xmlns:xs="http://xml.submit.application.webconnect.odc.com/XMLSchema">' +
                                    '<xs:DecisionStatus>approved</xs:DecisionStatus>' + 
                                    '<xs:CompanyName>Legal Name (***Test Only***)</xs:CompanyName>' +
                                    '<xs:BusinessID>f137bafd-8f0a-494a-8033-5004e962d740</xs:BusinessID>' +
                                    '<xs:ApplicationNumber>407821</xs:ApplicationNumber>' +
                                '</xs:SubmitApplicationResponse>';
            } 
            else {
                response.body = '<v2:PreQualificationResponse xmlns:v2="http://xml.webconnect.odc.com/XMLSchema/v2" xmlns:xs="http://xml.webconnect.odc.com/XMLSchema">' +
                                    '<v2:Prequalified>true</v2:Prequalified>' +
                                    '<v2:Offer>' +
                                        '<v2:LoanAmount>190000</v2:LoanAmount>' +
                                        '<v2:Term>18</v2:Term>' +
                                    '</v2:Offer>' +
                                '<v2:URL>https://online.ondeckcapital.com?ref=f137bafd-8f0a-494a-8033-5004e962d740</v2:URL>' +
                                    '<v2:BusinessID>f137bafd-8f0a-494a-8033-5004e962d740</v2:BusinessID>' +
                                '</v2:PreQualificationResponse>';
            }
        
        }
        
        return response;
    }
    
    
    public ResponseData sendPrequal(BusinessData businessData) {
        isSendPrequal = true;
        String xmlBody = OnDeckXMLParser.getPrequalXML(businessData);
        
        ResponseData response = sendRequest(url + (testMode ? PREQUAL_TEST : PREQUAL), xmlBody);
        OnDeckXMLParser.processPrequalResponse(businessData, response.body);
        
        return response;
    }
    
    
    public ResponseData sendSubmit(BusinessData businessData) {
        isSendPrequal = false;
        String xmlBody = OnDeckXMLParser.getSubmitXML(businessData);
        
        ResponseData response = sendRequest(url + (testMode ? SUBMIT_TEST : SUBMIT), xmlBody);
        OnDeckXMLParser.processSubmitResponse(businessData, response.body);

        return response;
    }   
    
    
    public class ResponseData {
        public String status;
        public Integer code;
        public String body;
        
        public Boolean isSuccess() {
            return (code == 200);
        }
        
        public Boolean isTestSuccess() {
            return (code == 500);
        }
    }
    
    
    
    
    public class BusinessData {
        public String taxID {get; set;}
        public String businessID {get; set;}
        public String businessName {get; set;}
        public String doingBusinessAs {get; set;}
        public String businessIndustry {get; set;}
        public String loanPurpose {get; set;}
        public Date businessInceptionDate {get; set;}
        public String businessPhone {get; set;}
        public Address address {get; set;}
        public Decimal annualRevenue {get; set;}
        public Decimal averageBankBalance {get; set;}
        public Decimal averageCreditCardVolume {get; set;}
        public Owner owner1 {get; set;}
        public Owner owner2 {get; set;}             
        public String prequalified {get; set;}
        public String prequalAmount {get; set;}
        public String prequalTerm {get; set;}
        public String url {get; set;}
        public String businessCredit {get; set;}
        public String personalCredit {get; set;}
        public String decisionStatus {get; set;}
        public String companyName {get; set;}
        public String applicationNumber {get; set;}
        public String[] errorCodes {get; set;}
        public String[] errorDescriptions {get; set;}
        
        public BusinessData() {
            address = new Address();
            errorCodes = new String[]{};
            errorDescriptions = new String[]{};
        } 
        
        public Boolean getIsSystemError() {
            for (String errorCode : errorCodes){
                if (!errorCode.equals('1000')){
                    return false;
                }
            }
            return ((errorCodes.size() == 1) && (errorCodes.get(0).equals('1000')));
        }
        
        public Boolean getIsSuccess() {
            return (errorCodes.isEmpty() && errorDescriptions.isEmpty());
        }
        
        public Decimal getPrequalAmountDecimal() {
            try {
                return Decimal.valueOf(prequalAmount);
            }
            catch(Exception e) {
                return 0;
            }
        }
    }
    
    
    public class Owner {
        public String ssn {get; set;}
        public String name {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public Date dob {get; set;}
        public Decimal ownershipPercentage {get; set;}
        public Address address {get; set;}
        
        public Owner() {
            address = new Address();
        }
    }
    
    
    public class Address {
        public String street {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String zip {get; set;}
    }
    
    
    
    public class SubmitData {
        public String[] errorCodes {get; set;}
        public String[] errorDescriptions {get; set;}
        
        public SubmitData() {
            errorCodes = new String[]{};
            errorDescriptions = new String[]{};     
        }
    }
    
    
    
    
    public class OnDeckException extends Exception {}
}