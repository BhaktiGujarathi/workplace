public class LeadLoanCalculatorController {
    
    private final static String USERNAME = 'cloudmybiz';
    private final static String PASSWORD = 'f3bXvb9m3Q';
    private final static String TOKEN= '7bb1100d806dd38b47c2dbed818516c051325ffabd5e807107f13e8d4f44b666';
    public String requestAmount {get;set;}
    public String requestTerm {get;set;}
    //Variable to display on VF page
    public String term {get;set;}
    public String rate {get;set;}
    public String amount {get;set;}
    public String closing_fee {get;set;}
    public String pay_count {get;set;}
    public String daily_prin_int {get;set;}
    public String daily_gfee {get;set;}
    public String daily_gfee_2 {get;set;}
    
    
    public LeadLoanCalculatorController (ApexPages.StandardController controller) { //Constructor
        Lead opp=[Select Amount_Requested__c,Term_Requested__c from Lead where id=:  ApexPages.currentPage().getParameters().get('id') limit 1];
        requestAmount=''+opp.Amount_Requested__c;
        requestTerm=''+opp.Term_Requested__c;
        callout(requestAmount,requestTerm); //Calling the callout method
        
        
    }
      public void callout(String LoanAmount, String LoanTerm) {  // Web Service Call out method
          string response = '';
          Http h = new Http();
          HttpRequest req = new HttpRequest();
          req.setEndpoint('http://demo.ioucentral.com/api/calculators/loans?token='+TOKEN+'&loan[amount]='+LoanAmount+'&loan[term]='+LoanTerm);
          req.setMethod('GET');
          Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
          String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
          req.setHeader('Authorization', authorizationHeader);
          HttpResponse res;
          try {
                res = h.send(req);
          }
          Catch (Exception ex)
          {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Service Unavailable : '+ex));
          }
          
          
          response = res.getBody();
          
          //Response Parsing
          JSONParser parser = JSON.createParser(response);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'term') term=parser.getText();
                    else if(fieldName == 'rate')             rate=parser.getText();
                    else if(fieldName == 'amount')           amount=parser.getText();
                    else if(fieldName == 'closing_fee')      closing_fee=parser.getText();
                    else if(fieldName == 'pay_count')        pay_count=parser.getText();
                    else if(fieldName == 'daily_prin_int')   daily_prin_int=parser.getText();
                    else if(fieldName == 'daily_gfee')       daily_gfee=parser.getText();
                    else if(fieldName == 'daily_gfee_2')     daily_gfee_2=parser.getText();
                }
            }
       }
}