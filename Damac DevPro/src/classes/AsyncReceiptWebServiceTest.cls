/*
This is the test class for below classes
AsyncReceiptWebService
RetryWebservice
*/

@isTest 
private class AsyncReceiptWebServiceTest{

    @isTest static void Test1() {
    
    
    Test.startTest();
    string body = '';
    Date d = Date.newinstance(25,12,2021);
    
    Location__c loc=new Location__c();
    loc.Location_ID__c='123';
    insert loc;
    Inventory__c inv = new Inventory__c();
    inv.Unit_Location__c=loc.id;
    insert inv;
    
    NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
    SR.Delivery_mode__c='Email';
    SR.Deal_ID__c='1001';
    insert SR;
    
    List<id> SRids = new List<id>();
    SRids.add(SR.id);
    NSIBPM__SR_Doc__c srdoc= new NSIBPM__SR_Doc__c();
    srdoc.NSIBPM__Service_Request__c=SR.id;
    insert srdoc;
    
    Booking__c bk= new Booking__c();
    bk.Deal_SR__c=SR.id;
    bk.Booking_channel__c='Office';
    insert bk;
    
    Buyer__c PB= new Buyer__c();
    PB.Primary_Buyer__c=true;
    PB.Buyer_Type__c='Individual';
    PB.Booking__c=bk.id;
    PB.Phone_Country_Code__c='India: 0091';
    PB.Passport_Expiry_Date__c='25/03/2017';
    PB.CR_Registration_Expiry_Date__c='25/12/2017';
    PB.City__c='Dubai';
    PB.Country__c='United Arab Emirates';
    PB.Address_Line_1__c='street1';
    PB.Address_Changed__c=true;
    PB.Date_of_Birth__c='25/12/1990';
    PB.Email__c='test@test.com';
    PB.First_Name__c='Buyer';
    PB.Last_Name__c='test';
    PB.Nationality__c='Indian'; 
    PB.Passport_Number__c='PP123'; 
    PB.Phone__c='53532255';
    PB.Place_of_Issue__c='Delhi'; 
    PB.Title__c='Mr.';
    insert PB;
    
    Buyer__c JB= new Buyer__c();
    JB.Primary_Buyer__c=false;
    JB.Buyer_type__c='Individual';
    JB.Booking__c=bk.id;
    JB.Passport_Expiry_Date__c='25/11/2017';
    JB.CR_Registration_Expiry_Date__c='25/06/2017';
    jb.status__c='New';
    jb.Date_of_Birth__c='25/12/1990';
    jb.City__c='Dubai';
    jb.Country__c='United Arab Emirates';
    jb.Address_Line_1__c='street1';
    jb.Email__c='test@test.com';
    jb.First_Name__c='Buyer';
    jb.Last_Name__c='test';
    jb.Nationality__c='Indian'; 
    jb.Passport_Number__c='PP123'; 
    jb.Phone__c='53532255';
    jb.Phone_Country_Code__c='India: 0091';
    jb.Place_of_Issue__c='Delhi'; 
    jb.Title__c='Mr.';
    insert JB;
    
    Booking_Unit__c BU= new Booking_Unit__c ();
    BU.Booking__c=bk.id;
    BU.Inventory__c=inv.id;
    insert BU;
    
    Payment_Plan__c ppp = new Payment_Plan__c();
    ppp.TERM_ID__c='100';
    insert ppp;
    
    Payment_Plan__c pp = new Payment_Plan__c();
    pp.Parent_Payment_Plan__c=ppp.id;
    pp.Booking_Unit__c=BU.id;
    insert pp;
    
    Payment_Terms__c PT = new Payment_Terms__c();
    PT.Payment_Plan__c=pp.id;
    insert PT;
    
    List<id>recordids= new List<id>();
    recordids.add(bk.id);
    
    List<id>BUids= new List<id>();
    BUids.add(BU.id);
    
    Receipt__c rec= new Receipt__c();
    rec.Amount__c=100;
    rec.Booking_Unit__c=BU.id;
    insert rec;
    
    List<id>recids= new List<id>();
    recids.add(rec.id);
    
    NSIBPM__Document_Master__c DM = new NSIBPM__Document_Master__c();
    DM.NSIBPM__Code__c='SOA';
    insert DM;
    
    NSIBPM__Document_Master__c DM1 = new NSIBPM__Document_Master__c();
    DM1.NSIBPM__Code__c='SPA';
    insert DM1;
    
    NSIBPM__Document_Master__c DM2 = new NSIBPM__Document_Master__c();
    DM2.NSIBPM__Code__c='DP-INVOICE';
    insert DM2;
    
    NSIBPM__SR_Status__c st= new NSIBPM__SR_Status__c();
    st.NSIBPM__Code__c='SUBMITTED';
    insert st;
    
    NSIBPM__SR_Status__c st1= new NSIBPM__SR_Status__c();
    st1.NSIBPM__Code__c='AGREEMENT_GENERATED';
    insert st1;
    
    List<Booking_Unit__c> BUlist= new List<Booking_Unit__c>();
    Booking_Unit__c objBooking1 = new Booking_Unit__c();
                                  objBooking1.Booking__c= bk.ID;
                                  objBooking1.Inventory__c=inv.ID;
                                  objBooking1.Registration_ID__c=null;
                                  objBooking1.Registration_DateTime__c= Date.Today();
                                  objBooking1.IPMS_Status__c='test';
                                  objBooking1.Registration_ID__c=null;
    //insert objBooking1;
    RetryWebservice.retrybooking(SR.id);
    
    AsyncReceiptWebService.getIPMSsetting('IPMS_webservice');
    AsyncReceiptWebService.getCreatableFieldsSOQL('Inventory__c');
    
    AsyncReceiptWebService.GetDatetext(d);    
    AsyncReceiptWebService.preparesoapHeader('test');
    
    AsyncReceiptWebService.prepareReceipt(recids);
    AsyncReceiptWebService.sendReceipt(recids);
    body= SetResponse(rec.id);
    AsyncReceiptWebService.parseReceiptResponse(body);
    
    AsyncReceiptWebService.prepareRegistrationRequest(recordids);
    AsyncReceiptWebService.sendRegistrationRequest(recordids);
    body= SetRegResponse(BU.id,'1001');
    AsyncReceiptWebService.parseRegnResponse(body);
    
    AsyncReceiptWebService.invokeSPA(recordids);
    AsyncReceiptWebService.invokeSPAGeneration(recordids);
    body= SetDocResponse(BU.id,'SPA');
    AsyncReceiptWebService.parseSPAResponse(body);
    
    
    AsyncReceiptWebService.PreparePayPlan(recordids);
    AsyncReceiptWebService.SendPaymentPlan(recordids);
    body= SetResponse(PT.id);
    AsyncReceiptWebService.parsePaymentPlanResponse(body);
    
    AsyncReceiptWebService.invokeSOA(recordids);
    AsyncReceiptWebService.invokeSOAGeneration(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseSOAResponse(body);
    
    
    AsyncReceiptWebService.prepareRegnUpdate(recordids,'STATUS_UPDATE');
    AsyncReceiptWebService.sendRegnUpdate(recordids,'STATUS_UPDATE');
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseRegnUpdateResponse(body);
    
    AsyncReceiptWebService.prepareAttachDoc(SRids,'test');
    AsyncReceiptWebService.sendAttachDoc(SRids,'test');
    body= SetResponse(SRDoc.id);
    AsyncReceiptWebService.parseAttachDocResponse(body);
    
    AsyncReceiptWebService.prepareReceiptDoc(recordids);
    AsyncReceiptWebService.sendReceiptDoc(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseReceiptDocResponse(body);
    
    AsyncReceiptWebService.prepareReceiptDoc(recordids);
    AsyncReceiptWebService.sendReceiptDoc(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseReceiptDocResponse(body);
    
    AsyncReceiptWebService.prepareTbitsrequest(recordids);
    AsyncReceiptWebService.sendTbitsrequest(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseTbitsResponse(body);
    
    AsyncReceiptWebService.prepareJBrequest(recordids);
    AsyncReceiptWebService.sendJBrequest(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseJBResponse(body);
    
    AsyncReceiptWebService.preparePartyUpdate(recordids);
    AsyncReceiptWebService.sendPartyUpdate(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parsePartyUpdateResponse(body);
    
    AsyncReceiptWebService.prepareDSRrequest(recordids);
    AsyncReceiptWebService.sendDSRrequest(recordids);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parseDSRResponse(body);
    Test.stopTest();
    AsyncReceiptWebService.prepareRetrievePayPlan(BU.id);
    AsyncReceiptWebService.RetrievePayPlan(BU.id);
    body= SetResponse(BU.id);
    AsyncReceiptWebService.parsePayPlanResponse(body);
    
    BU.Registration_ID__c ='100100';
    update BU;
    RetryWebservice.retrySPA(SR.id);
    RetryWebservice.GetPayPlan(BU.id);
    
    
    }
     private static string SetResponse(String idval){
        string body = '';
        body+='<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
        body+='<env:Header/>';
        body+='<env:Body>';
          body+='<OutputParameters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
             body+='<X_RESPONSE_MESSAGE>';
                body+='<X_RESPONSE_MESSAGE_ITEM>';
                   body+='<PARAM_ID>'+idval+'</PARAM_ID>';
                   body+='<PROC_STATUS>S</PROC_STATUS>';
                   body+='<PROC_MESSAGE>Bank :SFDC Test Bank One Created for Vendor with Id:810117</PROC_MESSAGE>';
                   body+='<ATTRIBUTE1>810117</ATTRIBUTE1>';
                   body+='<ATTRIBUTE2>1274778</ATTRIBUTE2>';
                   body+='<ATTRIBUTE3>123</ATTRIBUTE3>';
                   body+='<ATTRIBUTE4 xsi:nil="true"/>';
                body+='</X_RESPONSE_MESSAGE_ITEM>';
             body+='</X_RESPONSE_MESSAGE>';
             body+='<X_RETURN_STATUS>S</X_RETURN_STATUS>';
             body+='<X_RETURN_MESSAGE>Process Completed successfully...</X_RETURN_MESSAGE>';
          body+='</OutputParameters>';
        body+='</env:Body>';
        body+='</env:Envelope>';
        body=body.trim();
        body= body.replaceAll('null', '');
        body=body.trim();
        
        return body;
    }
    private static string SetDocResponse(String idval,String stype){
        string body = '';
        body+='<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
        body+='<env:Header/>';
        body+='<env:Body>';
          body+='<OutputParameters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
             body+='<X_RESPONSE_MESSAGE>';
                body+='<X_RESPONSE_MESSAGE_ITEM>';
                   body+='<PARAM_ID>'+idval+'</PARAM_ID>';
                   body+='<PROC_STATUS>S</PROC_STATUS>';
                   body+='<PROC_MESSAGE>Bank :SFDC Test Bank One Created for Vendor with Id:810117</PROC_MESSAGE>';
                   body+='<ATTRIBUTE1>810117</ATTRIBUTE1>';
                   body+='<ATTRIBUTE2>1274778</ATTRIBUTE2>';
                   body+='<ATTRIBUTE3>'+stype+'</ATTRIBUTE3>';
                   body+='<ATTRIBUTE4 xsi:nil="true"/>';
                body+='</X_RESPONSE_MESSAGE_ITEM>';
             body+='</X_RESPONSE_MESSAGE>';
             body+='<X_RETURN_STATUS>S</X_RETURN_STATUS>';
             body+='<X_RETURN_MESSAGE>Process Completed successfully...</X_RETURN_MESSAGE>';
          body+='</OutputParameters>';
        body+='</env:Body>';
        body+='</env:Envelope>';
        body=body.trim();
        body= body.replaceAll('null', '');
        body=body.trim();
        
        return body;
    }
    private static string SetRegResponse(String idval,string dealid){
        string body = '';
        body+='<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
        body+='<env:Header/>';
        body+='<env:Body>';
          body+='<OutputParameters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
             body+='<X_RESPONSE_MESSAGE>';
                body+='<X_RESPONSE_MESSAGE_ITEM>';
                   body+='<PARAM_ID>'+idval+'</PARAM_ID>';
                   body+='<REQUEST_STATUS>S</REQUEST_STATUS>';
                   body+='<REQUEST_MESSAGE>Bank :SFDC Test Bank One Created for Vendor with Id:810117</REQUEST_MESSAGE>';
                   body+='<SOURCE_REFERENCE>'+dealid+'</SOURCE_REFERENCE>';
                   body+='<PARTY_ID>1274778</PARTY_ID>';
                   body+='<UNIT_ID>123</UNIT_ID>';
                   body+='<REGISTRATION_ID>1274779</REGISTRATION_ID>';
                   
                body+='</X_RESPONSE_MESSAGE_ITEM>';
             body+='</X_RESPONSE_MESSAGE>';
             body+='<X_REQUEST_STATUS>S</X_REQUEST_STATUS>';
             body+='<X_ERROR_MESSAGE>Process Completed successfully...</X_ERROR_MESSAGE>';
          body+='</OutputParameters>';
        body+='</env:Body>';
        body+='</env:Envelope>';
        body=body.trim();
        body= body.replaceAll('null', '');
        body=body.trim();
        
        return body;
    }
    
}