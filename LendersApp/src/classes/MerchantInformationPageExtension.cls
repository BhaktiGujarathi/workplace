/*
*  Extension class for MerchantInformationPage Page
*
*  Revision History:
*
*  Version        Author                       Date                Description
*  1.0            Ashwini Singh                Jan/2016             Initial Draft       
*/


public with sharing class MerchantInformationPageExtension {

    // variables declaration
    public String inputString        {get; set;} // variable to get input from page for Post method
    public String feinString         {get; set;} // variable to hold FEIN from page parameters
    
    // variables used in callFromPage method 
    public String methodString;                   // to hold callout type
    public String sourceString;                   // to hold Opportunity Id
    public String accountIdString;                // to hold parentId <<Account>> of Opportunity
    public String urlString;                      // to hold URL of the Web service
    public String bodyString;                     // to hold body of callout
    
    // Object variables
    public Account accountObj        {get; set;}  // to hold parent object of opportunity
    public outerWrapper merchantobj  {get; set;}  // to hold wrapper response
    
    // constructor 
    public MerchantInformationPageExtension(ApexPages.standardController cntrllr) {

        merchantobj = new outerWrapper();
    }
    
    // method to make a callout to DataMearch web-service and return a response
    public String apiCalloutMethod(String pMethod, String pUrl, String pBody) {

        DataMerchAPIDetail__c dataMerchCS = DataMerchAPIDetail__c.getValues('Data Merch Detail');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();

        if (dataMerchCS <> null) {

            String username = dataMerchCS.UserName__c;
            String password = dataMerchCS.Password__c;
            req.setMethod(pMethod);
            req.setEndpoint(pUrl);
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);         

            res = http.send(req);

            if (res.getBody() == '[]') {

                apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Merchant with this FEIN exists!')); 
            }
            if(res.getStatus() == 'Unauthorized' || res.getStatusCode() == 401){
                apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The DataMerch Username or Password is incorrect. Please contact your administrator.'));
            }
        }
        else { // no record in custom setting
        
            apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'DataMerch Credentials not found!'));
        }
        
        return res.getBody();
    }
    
    // method to be called from Page
    // which in turn calls a method to make callout
    public void callFromPage() {

        feinString = apexPages.currentPage().getParameters().get('feinid'); 
        sourceString = apexPages.currentPage().getParameters().get('source');
        accountIdString = apexPages.currentPage().getParameters().get('RelatedAccount');

        if (accountIdString  == null) {

            Opportunity oppObj = [Select Id, AccountId, Account.McaApp__Federal_Tax_ID_No__c 
                      From Opportunity
                      Where Id =: sourceString];
            
            accountIdString  = string.valueOf(OppObj.AccountId);
            feinString =  string.valueOf(OppObj.Account.McaApp__Federal_Tax_ID_No__c);
        }    
        
        if (accountIdString  == null) {

            apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please associate an account with the opportunity!'));
        }
        else if (feinString == null) {

            apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No FEIN Id for associated account!'));
        }
        else if (accountIdString != null && feinString != null) {

            accountObj =    [SELECT Id, 
                                    McaApp__Federal_Tax_ID_No__c, 
                                    Name, 
                                    McaApp__Legal_Name__c, 
                                    Industry 
                            FROM Account 
                            WHERE Id =:accountIdString];

            methodString = 'GET';
            urlString = 'https://www.datamerch.com/api/v1/merchants/' + feinString.substring(3);           
            inputString = feinString;
            bodyString = '';

            String str1 = apiCalloutMethod(methodString, urlString, bodyString);
            String str2 = str1.removeEnd(']').removeStart('[');

            stringParse(str2); 
       }                              
    }
    
    // method to deserialize the response 
    public void stringParse(String pStringToParse) {

        if (!(String.isBlank(pStringToParse)) && pStringToParse != '[]') {

           merchantobj = (outerWrapper) JSON.deserialize(pStringToParse, outerWrapper.class);
        }
    }   
    
    // wrapper of note for merchant
    public class Note2 {

        public string category { get; set; }
        public string note { get; set; }
        public string created_at { get; set; }
    }
    
    // wrapper for notes list for merchant
    public class Note {

        public Note2 note { get; set; }
    }

    // wrapper for merchant 
    public class Merchant {

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
  
    // wrapper for merchant List
    public class outerWrapper {

        public Merchant merchant { get; set; }
    }
    
    // method to return to opportunity detail page
    public PageReference returnToOpportunity () {
        
        return new PageReference('/' + sourceString.trim() );
    }
}