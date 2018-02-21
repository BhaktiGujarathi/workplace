@isTest 
private class RestServicetoCreateEnquiryTest{

    @isTest static void Test1() {
      RestRequest req = new RestRequest();
      req.params.put('firstname','Test');
      req.params.put('lastname','Name');
      req.httpMethod = 'POST';      
      RestResponse res = new RestResponse();
  
      RestContext.request = req;
      RestContext.response = res;
  
      Test.startTest();
  
      RestServiceToCreateEnquiry.ResponseHandler results = RestServiceToCreateEnquiry.createEnquiry('firstname','lastname','email','title','telephone','Source','UTMSource','UTMMedium','UTMCampaign','HeardOfDAMAC','message','mobileCode','city','nationality','country',' campaignid');
  
      Test.stopTest();
  
     
    }
}