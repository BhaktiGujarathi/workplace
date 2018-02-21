public with sharing class POCofIntegrationPageController {
    public String selectedMethod     {get; set;}
    public String selectedCategory   {get; set;}
    public String inputString        {get; set;}
    public String outputString       {get; set;}
    public String feinString         {get; set;}
    public String nameString         {get; set;}
    public String cityString         {get; set;}
    public String stateString        {get; set;}
    public string noteString         {get; set;}
    public String dbaString          {get; set;}
    public String street1String      {get; set;}
    public String street2String      {get; set;}
    public String phoneString        {get; set;}
    public String startDate2String   {get; set;}
    public String industryString     {get; set;}
    
    public Boolean inputFlag         {get; set;}
    public Boolean grp1Flag          {get; set;}
    public Boolean grp2Flag          {get; set;}
    public Boolean grp3Flag          {get; set;}
    
    public String methodString;
    public String urlString;
    public String bodyString;
    
    public POCofIntegrationPageController() {
        inputFlag = false;
        grp1Flag  = false;
        grp2Flag  = false;
        grp3Flag  = false;
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
        if(selectedMethod.Equals('GET')) {
            methodString = 'GET';
            urlString = 'https://www.datamerch.com/api/v1/merchants/'+feinString.substring(3);           
            inputString = feinString;
            bodyString = '';
            String str1 = apiCalloutMethod(methodString, urlString, bodyString);
            outputString = (((((str1.remove('{')).replace('"', ' ')).remove('}').replace(',', '<br />')).replace('[','<br />')).replace(']','<br />'));
            
            
        }
        else if(selectedMethod.Equals('POST Merchant')){
            methodString = 'POST';
            urlString = 'https://www.datamerch.com/api/v1/merchants';
            bodyString = '{'+  
                           '"fein":"' +feinString+ '",' +
                           '"legal_name":"' +nameString+ '",'+
                           '"dba":"ACME",'+
                           '"street1":"123 First St.",'+
                           '"street2":"Suite 100",'+
                           '"city":"' +cityString+ '",'+
                           '"state":"' +stateString+ '",'+
                           '"business_phone":"123-456-7890",'+
                           '"business_startdate":"1/1/1985",'+
                           '"industry":"Combustables",'+
                           '"note_category":"' +selectedCategory+ '",'+
                           '"note":"' +noteString+ '"'+
                        '}';
            //inputString = (((bodyString.removeStart('{')).replace('"', ' ')).removeEnd('}').replace(',', '<br />'));
            inputString = apiCalloutMethod(methodString, urlString, bodyString);
            outputString = (((((inputString.removeStart('{')).replace('"', ' ')).removeEnd('}').replace(',', '<br />')).replace('[','<br />')).replace(']','<br />'));
            
        }
        else if(selectedMethod.Equals('POST Note')){
            methodString = 'POST';
            urlString = 'https://www.datamerch.com/api/v1/notes';
            bodyString = '{'+
                            '"fein": "' +feinString+ '",'+
                            '"note_category": "' +selectedCategory+ '",'+
                            '"note": "' +noteString+'"'+
                          '}';
            //inputString = (((bodyString.removeStart('{')).replace('"', ' ')).removeEnd('}'));
            inputString = apiCalloutMethod(methodString, urlString, bodyString);
            outputString = (((((inputString.removeStart('{')).replace('"', ' ')).removeEnd('}').replace(',', '<br />')).replace('[','<br />')).replace(']','<br />'));
            
        }
        else {    
            apexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select a valid method!!'));
        }
    }
    
    public void enterInput() {
        inputFlag = true;
        selectedCategory = '';
        inputString = '';
        outputString = '';
        feinString = '';
        nameString  = ''; 
        cityString = '';
        stateString = '';
        noteString = '';
        dbaString = '';
        street1String = '';
        street2String = '';
        phoneString = '';
        startDate2String = '';
        industryString = '';
        if(selectedMethod.Equals('GET')) {
            grp1Flag  = true;
            grp2Flag  = false;
            grp3Flag  = false;
        } else if(selectedMethod.Equals('POST Merchant')) {
            grp1Flag  = true;
            grp2Flag  = true;
            grp3Flag  = true;
        } else if(selectedMethod.Equals('POST Note')) {
            grp1Flag  = true;
            grp2Flag  = false;
            grp3Flag  = true;
        }
        
    }
}