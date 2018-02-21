public with sharing class MerchantInformationPageExtension {

    public String inputString        {get; set;}
    public String outputString       {get; set;}
    public String feinString         {get; set;}
    public String noteString         {get; set;}

    public String methodString;
    public String sourceString;
    public String accountIdString;
    public String urlString;
    public String bodyString;
    
    public Account accountObj         {get; set;}
    public outerWrapper merchantobj {get; set;}
    
    
    public MerchantInformationPageExtension(ApexPages.standardController cntrllr) {
        merchantobj = new outerWrapper();
    }
    public String apiCalloutMethod(String pMethod, String pUrl, String pBody) {
         String username = '_yCxMqPDzNxMRurN1M8Z';
         String password = 'PN3QxCoEzg';
         HttpRequest req = new HttpRequest();
         req.setMethod(pMethod);
         req.setEndpoint(pUrl);
         Blob headerValue = Blob.valueOf(username + ':' + password);
         String authorizationHeader = 'BASIC ' +
         EncodingUtil.base64Encode(headerValue);
         req.setHeader('Content-Type', 'application/json');
         req.setHeader('Authorization', authorizationHeader);
         if(!pMethod.Equals('GET')) {
             req.setBody(pBody);
         }         
         Http http = new Http();
         HTTPResponse res = http.send(req);
         System.debug('>>>res : '+res);
         system.debug('>>>res.getBody()' +res.getBody());
         if(res.getBody() == '[]') {
            apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Merchant with this FEIN exists!!')); 
         }
         return res.getBody();
    }
    
    public void callFromPage() {
        
            feinString = apexPages.currentPage().getParameters().get('feinid'); 
            sourceString = apexPages.currentPage().getParameters().get('source');
            system.debug('>>> sourceString' +sourceString);
            accountIdString = apexPages.currentPage().getParameters().get('RelatedAccount');
            accountObj = [SELECT Id, Federal_Tax_ID_No__c, Name, Legal_Name__c, Industry FROM Account WHERE Id =:accountIdString];
            methodString = 'GET';
            urlString = 'https://www.datamerch.com/api/v1/merchants/'+feinString.substring(3);           
            inputString = feinString;
            bodyString = '';
            String str1 = apiCalloutMethod(methodString, urlString, bodyString);
            String str2 = str1.removeEnd(']').removeStart('[');
            stringParse(str2);                               
        
    }
    
    public void stringParse(String pStringToParse) {
        if(!(String.isBlank(pStringToParse)) && pStringToParse != '[]')
           merchantobj = (outerWrapper) JSON.deserialize(pStringToParse, outerWrapper.class);
    }   
    
    public class Note2
    {
        public string category { get; set; }
        public string note { get; set; }
        public string created_at { get; set; }
    }

    public class Note
    {
        public Note2 note { get; set; }
    }

    public class Merchant
    {
        public string fein { get; set; }
        public string legal_name { get; set; }
        public string dba { get; set; }
        public object address { get; set; }
        public string street1 { get; set; }
        public string street2 { get; set; }
        public string city { get; set; }
        public string state { get; set; }
        public string business_phone { get; set; }
        public string business_startdate { get; set; }
        public string industry { get; set; }
        public List<Note> notes { get; set; }
    }

    public class outerWrapper 
    {
        public Merchant merchant { get; set; }
    }
    
    public PageReference returnToOpportunity () {
        return new PageReference('/'+sourceString.trim() );
    }
}