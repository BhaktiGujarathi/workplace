public Class WSSoap
{


//Java Client : http://www.dhruvsoft.com/blog/creating-custom-apex-soap-based-on-web-services-in-salesforce-com-and-accessing-from-java-application/


// Java Client Using connector: http://salesforcecodes.blogspot.in/2015/04/integration-between-java-app-and.html
public void loginSOAPEnvelop()
{

//----------------------------------------------------------------------
// Login via SOAP/XML web service api to establish session
//----------------------------------------------------------------------

HttpRequest request = new HttpRequest();
request.setEndpoint('https://login.salesforce.com/services/Soap/u/29.0');
request.setMethod('POST');
request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
request.setHeader('SOAPAction', 'login');
//not escaping username and password because we're setting those variables above
//in other words, this line "trusts" the lines above
//if username and password were sourced elsewhere, they'd need to be escaped below
request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + 'merulkumar_shah@ymail.com' + '</username><password>' + 'm*9825336806' + '</password></login></Body></Envelope>');
system.debug('$$$$$$ '+(new Http()).send(request));




}


public void partnerLoginMethod()
{

/*  Custom webservice and partner WSDL

partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
   
 
  String username = '<Your username here>';
  String password = '<Your password here>';
   
  partnerSoapSforceCom.LoginResult loginResult = sp.login(username, password);
   
  system.debug('   loginResult ' + loginResult);
   // Custom class generated------->soapSforceCom200608Apex
   
  soapSforceCom200608Apex.Apex apexWebSvc = new soapSforceCom200608Apex.Apex();
  soapSforceCom200608Apex.SessionHeader_element sessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
  sessionHeader.sessionId = loginResult.sessionId;
   
  // The Web services have a maximum timeout of 2 minutes. The timeout value
  // is in milliseconds.
  apexWebSvc.timeout_x = 120000;
  apexWebSvc.SessionHeader = sessionHeader;
   
  soapSforceCom200608Apex.RunTestsRequest testsRequest = new soapSforceCom200608Apex.RunTestsRequest();
  testsRequest.allTests = true;
           
  soapSforceCom200608Apex.RunTestsResult testResults = apexWebSvc.runTests(testsRequest);
 
*/


}









}