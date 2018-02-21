/**************************************************************************************************
* Name               : AsynReceiptWebService 
* Description        : This is the queuable webservice class for the below webservices
-Receipt Creation
-Registration Creation
-SPA Generation
-Payment Plan 
-Statement of Account Generation
-Registration Updation
-Attachment API
-Receipt Doc Service
-Tbits service
-Joint Buyer service
-Party Update Service
-DSR Service
-Payment Plan Retreive
- Add Inner (Option Object ) SOQL in Booking Unit Soql in @Method prepareRegistrationRequest @Line332 (Naresh)
- Add for Loop for Passing Option Object Record @Method prepareRegistrationRequest @Line755 (Naresh)

* Created Date       : 13/03/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    13/03/2017 
  1.1         Naresh (Accely) 2/7/2017                                                         
**************************************************************************************************/
global class AsyncReceiptWebservice implements Queueable, Database.AllowsCallouts {
    public List<id> recordids = new List<id>();
    public string servicetype;
    
    //Defining the constructor
    public AsyncReceiptWebservice (List<Id> rids, string svctype){
        recordids=rids;
        servicetype=svctype; 
        
    }
    //The execute method for the queuable class which contains the callout
    public void execute(QueueableContext context) {
        if(servicetype=='Receipt Creation')
            sendReceipt(recordids);
        if(servicetype=='Registration Creation')
            sendRegistrationRequest(recordids);
        if(servicetype=='SPA')
            invokeSPAGeneration(recordids);  
        if(servicetype=='PaymentPlan')
            SendPaymentPlan(recordids); 
        if(servicetype=='SOA')
            invokeSOAGeneration(recordids);  
        if(servicetype=='Agent Update')
            sendRegnUpdate(recordids,'AGENT_UPDATE');      
        if(servicetype=='Doc Ok')
            sendRegnUpdate(recordids,'DOC_OK');
        if(servicetype=='Delivery Mode')
            sendRegnUpdate(recordids,'DISPATCH_MODE');
        if(servicetype=='Booking Cancellation')
            sendRegnUpdate(recordids,'BOOKING_CANCELLATION');  
        if(servicetype=='ChangePC')
            sendRegnUpdate(recordids,'CHANGE_PC'); 
        if(servicetype=='StatusUpdate')
            sendRegnUpdate(recordids,'STATUS_UPDATE');
        if(servicetype=='OktoCall')
            sendRegnUpdate(recordids,'CALL_GENERATION');    
        if(servicetype=='SendDoc')
            sendAttachDoc(recordids,'Docs'); 
        if(servicetype=='ReceiptDoc')
            sendReceiptDoc(recordids);
        if(servicetype=='Tbitsfiles')
            sendTbitsrequest(recordids);      
        if(servicetype=='Joint Buyer')      
            sendJBrequest(recordids); 
        if(servicetype=='Party Update')      
            sendPartyUpdate(recordids);
        if(servicetype=='DSR')
            sendDSRrequest(recordids);   
        if(servicetype=='Retrieve PayPlan')
            RetrievePayPlan(recordids[0]);            
    }
    
    global static string endurl;
    global static string usrname;
    global static string pwd;  
    /**********************Getting the IPMS integration setting*********************************/ 
    
    public static void getIPMSsetting(String servicename){
        system.debug('***SSS***'+servicename);
        IPMS_Integration_Settings__mdt ipms= [select id,Endpoint_URL__c,Password__c,  Username__c from IPMS_Integration_Settings__mdt where DeveloperName = :servicename];
        endurl=ipms.Endpoint_URL__c;
        usrname=ipms.Username__c;      
        pwd=PasswordCryptoGraphy.DecryptPassword(ipms.Password__c);
        system.debug('***IPMS***'+ipms);
        
        system.debug('***PWD***'+pwd);
        
    }
    
    /**********************Preparing the general header for the http request*********************************/
    
    public static string preparesoapHeader(string body){
        
        body+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/" xmlns:proc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
        body+='<soapenv:Header>';
        body+='<xxdc:SOAHeader>';
        //body+='<!--Optional:-->';
        body+='<xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility>';
        //body+='<!--Optional:-->';
        body+='<xxdc:RespApplication>ONT</xxdc:RespApplication>';
        //body+='<!--Optional:-->';
        body+='<xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
        //body+='<!--Optional:-->';
        body+='<xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
        //body+='<!--Optional:-->';
        body+='<xxdc:Org_Id/>';
        body+='</xxdc:SOAHeader>';
        body+='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
        body+='<wsse:UsernameToken>';
        body+='<wsse:Username>'+usrname+'</wsse:Username>';
        body+='<wsse:Password>'+pwd+'</wsse:Password>';
        body+='</wsse:UsernameToken>';
        body+='</wsse:Security>';
        body+='</soapenv:Header>';
        return body;
    }
    
    /**********************Preparing the request body for the receipt request*********************************/
    public static string prepareReceipt(List<id> rids){
        
        string recQuery = getCreatableFieldsSOQL('Receipt__c');
        recQuery+=' where Id in :rids';
        List<Receipt__c> rcptlist= database.query(recQuery);
        String reqno='123456';
        if(rcptlist.size()>0)
            reqno =rcptlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        // String currdate= system.now
        string body = '';
        body+= preparesoapHeader(body); 
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        //body+='<!--Optional:-->';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        //body+='<!--Optional:-->';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        //body+='<!--Optional:-->';
        body+='<proc:P_REQUEST_NAME>CREATE RECEIPT</proc:P_REQUEST_NAME>';
        //body+='<!--Optional:-->';
        body+='<proc:P_REQUEST_MESSAGE>';
        //body+='<!--Zero or more repetitions:-->';
        for(Receipt__c rec: rcptlist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            //body+='<!--Optional:SFDC ID-->';
            body+='<proc:PARAM_ID>'+rec.Id+'</proc:PARAM_ID>';
            //body+='<!--Optional:RECEIPT_NUMBER-->';
            body+='<proc:ATTRIBUTE1>'+rec.Name+'</proc:ATTRIBUTE1>';
            //body+='<!--Optional:REG_ID-->';
            body+='<proc:ATTRIBUTE2>'+rec.Registration_Id__c+'</proc:ATTRIBUTE2>';
            //body+='<!--Optional:CURRENCY_CODE-->';
            body+='<proc:ATTRIBUTE3>'+rec.BU_Currency__c+'</proc:ATTRIBUTE3>'; //AED
            //body+='<!--Optional:AMOUNT-->';
            body+='<proc:ATTRIBUTE4>'+rec.IPMS_Token_Amount__c+'</proc:ATTRIBUTE4>';
            //body+='<!--Optional:RECEIPT_METHOD-->';
            body+='<proc:ATTRIBUTE5>Direct Receipt in the Bank</proc:ATTRIBUTE5>'; 
            //body+='<!--Optional:BANK_ACCOUNT_NUM-->';
            String banknum ='';
            if(rec.Unit_Country__c == 'Saudi Arabia')
                banknum=Label.Saudi_Bank_Account_No;
            else 
                banknum='Master/Visa/Amex/Diners -CC';
            body+='<proc:ATTRIBUTE6>'+banknum+'</proc:ATTRIBUTE6>'; 
            body+='<proc:ATTRIBUTE7>TOKEN</proc:ATTRIBUTE7>'; 
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        
        return body.trim();
    }   
    
    /**********************Callout for the receipt creation*********************************/
    
    
    webservice static void sendReceipt(List<Id> rids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareReceipt(rids);
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120 * 1000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseReceiptResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+rids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Receipt Creation';
                insert objLog;             
            }   
        } 
    }
    
    /**********************Parsing the response received for receipt request*********************************/
    public static void parseReceiptResponse(string body){
        
        string ipmsrcptid,status,statusmsg,recId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<Id, String> ReceiptStatusMap = new Map<Id, String>();
        Map<Id, String> ReceiptStatusMsgMap = new Map<Id, String>();
        Map<Id, String> ReceiptMap = new Map<Id, String>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Text>>>>>>>>'+child5.getText());
                            if(child5.getName()=='PROC_STATUS') 
                                status = child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                                statusmsg = child5.getText();
                            if(child5.getName()=='PARAM_ID') 
                                recId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE1') 
                                ipmsrcptid = child5.getText();
                        }
                        ReceiptMap.put(recId,ipmsrcptid);
                        ReceiptStatusMap.put(recId,status);
                        ReceiptStatusMsgMap.put(recId,statusmsg);
                    }
                }
            }
        }
        List<id> BUids= new List<id>();
        List<Receipt__c> reclist= [select id,Booking_Unit__c,IPMS_Receipt_ID__c,IPMS_Status__c from Receipt__c where id in :ReceiptMap.keyset()];
        try{
            if(reclist.size()>0){
                for(Receipt__c rec :reclist){
                    String ipmsstatus=ReceiptStatusMsgMap.get(rec.id);
                    if(ipmsstatus.length()>255)
                        rec.IPMS_Status__c=ipmsstatus.left(255);
                    else
                        rec.IPMS_Status__c=ipmsstatus;
                    if(ReceiptStatusMap.get(rec.id)=='S'){
                        rec.IPMS_Receipt_ID__c=ReceiptMap.get(rec.id);
                        if(rec.IPMS_Receipt_ID__c!=null) 
                            BUids.add(rec.Booking_Unit__c);
                    }
                }
                update reclist;
                List<Id> SRIds = new List<id>();
                if(BUids.size()>0){
                    List<Booking_Unit__c>BUlist = [select id,Token_paid__c,Token_Paid_Time__c,Status__c from Booking_Unit__c where Status__c!='Removed' and id in:BUids];
                    for(Booking_Unit__c BU:BUlist){
                        BU.Token_Paid__c=true;
                        BU.Token_Paid_Time__c= system.now();
                        SRIds.add(BU.SR_Id__c);
                    }
                    update BUlist;
                }
                /*
//Converting the inquiry into account
Integer tokenCount=0;
integer bucount=0;
for(Booking_Unit__c BU : [select id, Booking__c,Booking__r.Deal_SR__c,Token_Paid__c from Booking_Unit__c where SR_Id__c in:SRIds]){
//AllBuids.add(BU.id);
//BookingIds.add(BU.Booking__c);
//system.debug('BU'+BU.id+'---SPACount==='+BU.SR_Docs__r.size());
bucount++;
if(BU.Token_Paid__c)
tokenCount++;
}
Set<Id> inquiryIdsSet= new Set<Id>();
if(bucount==tokencount){
for(Buyer__c b:[select id,Inquiry__c from Buyer__c where Inquiry__c!=null AND Booking__r.Deal_SR__c in :SRIds]){
inquiryIdsSet.add(b.Inquiry__c);
} 
system.debug('II==== '+inquiryIdsSet);
if(!inquiryIdsSet.isEmpty()){
InquiryConversionProcess.convertInquiry(inquiryIdsSet);
}
}*/
            }
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+ReceiptMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response For Receipt Creation';
            insert objLog;             
        }    
        
    }
    
    /*************************************************************************************************************************/
    
    /**********************Preparing the request body for the registration request*********************************/
    public static string prepareRegistrationRequest(List<id> bookingids){
        
        string body = '';
        String errormsg='';
        string bookingQuery = getCreatableFieldsSOQL('Booking__c');
        bookingQuery=bookingQuery.remove('FROM Booking__c');
        bookingQuery+=',Deal_SR__r.name,Deal_SR__r.Campaign__r.Campaign_Name__c,Deal_SR__r.Promotion__r.Promotion_Title__c,Deal_SR__r.Delivery_mode__c,Deal_SR__r.Deal_ID__c,Deal_SR__r.Agency__r.Vendor_ID__c from Booking__c';        
        bookingQuery +=' where id in:bookingids';
        system.debug('QQQQ=='+bookingQuery);
        List<Booking__c> bookings = database.query(bookingQuery);
        if(bookings.size()>0){
            Booking__c booking= bookings[0];
            String dealid= booking.Deal_SR__r.Deal_ID__c;
            system.debug('DEAL ID=='+dealid);
            
            //Getting the booking units
            string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
            BUQuery=BUQuery.remove('FROM Booking_Unit__c');
            BUQuery+=',Booking__r.Deal_SR__r.Agency__r.Vendor_ID__c,Booking__r.Deal_SR__r.Delivery_mode__c,(Select PromotionName__c,  CampaignName__c,  OptionsName__c,  SchemeName__c, TemplateIdPN__c,  TemplateIdCN__c,  TemplateIdOP__c,  TemplateIdSN__c From Options__r limit 1),Booking__r.Booking_channel__c,Booking__r.Deal_SR__r.Promotion__r.Promotion_Title__c,Inventory__r.Building_Location__r.name,Inventory__r.Property_Country__c,Inventory__r.Release_ID__c,Inventory__r.Org_ID__c,Inventory__r.Location_Code__c,Inventory__r.Area_Sqft__c,Inventory__r.Building_ID__c,Inventory__r.Property_ID__c FROM Booking_Unit__c';
            BUQuery+=' where Status__c!=\'Removed\' and Registration_ID__c=null and Booking__c in:bookingids';
            List<Booking_Unit__c> units= database.query(BUQuery);  
            if(units.size()>0){
                String RegBulk='';
                if(units.size()>4)
                    RegBulk='B';
                else
                    RegBulk='R'; 
                
                
                Map<String,Id> UnitMap = new Map<String,Id>();        
                
                Map<Id,Id> PrimaryBuyers = new Map<Id,Id>();
                Map<Id,List<Buyer__c>> JointBuyers = new Map<Id,List<Buyer__c>>();       
                
                //Querying the buyers
                string buyerQuery = getCreatableFieldsSOQL('Buyer__c');
                buyerQuery +=' where Booking__c in:bookingids';
                List<Buyer__c> buyerlist = database.query(buyerQuery);
                Id accid;
                if(buyerlist.size()>0){
                    Buyer__c PBuyer= new Buyer__c();
                    for(Buyer__c b: buyerlist){
                        
                        if(b.Primary_Buyer__c){
                            PBuyer= b;
                            PrimaryBuyers.put(b.Booking__c, b.account__c);
                            system.debug('B.AAAA==='+b.account__c);
                            accid=b.account__c;
                        }
                        else if(b.Is_3rd_Party__c==false){
                            if(!jointBuyers.containsKey(b.Booking__c)){
                                JointBuyers.put(b.Booking__c, new List<Buyer__c>{b});
                            }
                            else{
                                List<Buyer__c> existing = jointBuyers.get(b.Booking__c);
                                existing.add(b);
                                JointBuyers.put(b.Booking__c, existing);
                            }
                        }    
                    }
                    if(Pbuyer!=null){
                        //Getting the Deal team values  
                        string PCId,DOSId,HOSId,HODId,SalesOffice='';
                        /*
PCId='53580';
DOSId='53058';
HOSId='53561';
HODId='249';
SalesOffice='PARK-TOWER';
*/
                        
                        List<Deal_Team__c> dealteamlist = [select id,Associated_Deal__c,Associated_PC__r.IPMS_Employee_ID__c,Associated_DOS__r.IPMS_Employee_ID__c,Associated_HOS__r.IPMS_Employee_ID__c,Associated_HOD__r.IPMS_Employee_ID__c,User_Sales_Office__c from Deal_Team__c where Associated_Deal__c =:Booking.Deal_SR__c];
                        for(Deal_Team__c DT :dealteamlist ){
                            
                            PCId=DT.Associated_PC__r.IPMS_Employee_ID__c;
                            SalesOffice=DT.User_Sales_Office__c;           
                            DOSId=DT.Associated_DOS__r.IPMS_Employee_ID__c;            
                            HOSId=DT.Associated_HOS__r.IPMS_Employee_ID__c;            
                            HODId=DT.Associated_HOD__r.IPMS_Employee_ID__c;
                            
                        }
                        
                        //Payment Plan and Payment Term Details
                        string PayQuery = getCreatableFieldsSOQL('Payment_Terms__c');
                        PayQuery=PayQuery.remove('FROM Payment_Terms__c');
                        PayQuery+=',Payment_Plan__r.Booking_Unit__c,Payment_Plan__r.Booking_Unit__r.Registration_ID__c,Payment_Plan__r.Booking_Unit__r.Booking__c,Payment_Plan__r.Parent_Payment_Plan__r.TERM_ID__c';
                        PayQuery+=' FROM Payment_Terms__c where Payment_Plan__r.Booking_Unit__r.Booking__c in:bookingids';
                        List<Payment_Terms__c> Paylist= database.query(PayQuery); 
                        
                        Map<id,List<Payment_Terms__c>> PayMap = new Map<id,List<Payment_Terms__c>>();
                        for(Payment_Terms__c PT :Paylist){
                            if(!PayMap.containsKey(PT.Payment_Plan__r.Booking_Unit__c)){
                                PayMap.put(PT.Payment_Plan__r.Booking_Unit__c, new List<Payment_Terms__c>{PT});
                            }
                            else{
                                List<Payment_Terms__c> existing = PayMap.get(PT.Payment_Plan__r.Booking_Unit__c);
                                existing.add(PT);
                                PayMap.put(PT.Payment_Plan__r.Booking_Unit__c, existing);
                            }
                        }
                        if(PayMap.values().size()>0){
                            
                            system.debug('PayMAp===='+PayMap);
                            try{
                                body+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_sfdc_registration_ws/" xmlns:cre="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_sfdc_registration_ws/create_booking/">';
                                
                                body+='<soapenv:Header>';
                                body+='<xxdc:SOAHeader>';
                                body+='<xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility>';
                                body+='<xxdc:RespApplication>ONT</xxdc:RespApplication>';
                                body+='<xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
                                body+='<xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
                                body+='<xxdc:Org_Id/>';
                                body+='</xxdc:SOAHeader>';
                                body+='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
                                body+='<wsse:UsernameToken>';
                                body+='<wsse:Username>'+usrname+'</wsse:Username>';
                                body+='<wsse:Password>'+pwd+'</wsse:Password>';
                                body+='</wsse:UsernameToken>';
                                body+='</wsse:Security>';
                                body+='</soapenv:Header>';
                                body+='<soapenv:Body>';
                                body+='<cre:InputParameters>';
                                body+='<cre:P_SOURCE_REFERENCE>'+booking.name+'</cre:P_SOURCE_REFERENCE>';
                                body+='<cre:P_CUST_RECORD>';
                                String partytype='';
                                if(PBuyer.Buyer_Type__c=='Individual')
                                    partytype='PERSON';
                                else if(PBuyer.Buyer_Type__c=='Corporate')
                                    partytype='ORGANIZATION';
                                body+='<cre:PARTY_TYPE>'+partytype+'</cre:PARTY_TYPE>';
                                body+='<cre:PARTY_ID>'+PBuyer.Party_Id__c+'</cre:PARTY_ID>';
                                body+='<cre:EXT_CUST_NUMBER>'+PBuyer.name+'</cre:EXT_CUST_NUMBER>'; 
                                body+='<cre:PARTY_TITLE>'+PBuyer.Title__c+'</cre:PARTY_TITLE>';
                                body+='<cre:PARTY_FIRST_NAME>'+PBuyer.First_Name__c+'</cre:PARTY_FIRST_NAME>';
                                body+='<cre:PARTY_MIDDLE_NAME></cre:PARTY_MIDDLE_NAME>';
                                body+='<cre:PARTY_LAST_NAME>'+PBuyer.Last_Name__c+'</cre:PARTY_LAST_NAME>';
                                body+='<cre:ORGANIZATION_NAME>'+PBuyer.Organisation_Name__c+'</cre:ORGANIZATION_NAME>';
                                body+='<cre:WHY_DUBAI></cre:WHY_DUBAI>'; //not required
                                body+='<cre:WHY_DAMAC></cre:WHY_DAMAC>'; //not required
                                body+='<cre:INTRODUCED_BY></cre:INTRODUCED_BY>'; //*************
                                body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                body+='<cre:ATTRIBUTE6></cre:ATTRIBUTE6>';
                                body+='<cre:ATTRIBUTE7></cre:ATTRIBUTE7>';
                                body+='<cre:ATTRIBUTE8></cre:ATTRIBUTE8>';
                                body+='<cre:ATTRIBUTE9></cre:ATTRIBUTE9>';
                                body+='<cre:ATTRIBUTE10></cre:ATTRIBUTE10>';
                                body+='</cre:P_CUST_RECORD>';
                                
                                body+='<cre:P_CUST_ADDRESS>';
                                body+='<cre:ADDRESS1>'+PBuyer.Address_Line_1__c+'</cre:ADDRESS1>'; 
                                body+='<cre:ADDRESS2>'+PBuyer.Address_Line_2__c+'</cre:ADDRESS2>';
                                body+='<cre:ADDRESS3>'+PBuyer.Address_Line_3__c+'</cre:ADDRESS3>';
                                body+='<cre:ADDRESS4>'+PBuyer.Address_Line_4__c+'</cre:ADDRESS4>';
                                body+='<cre:CITY>'+PBuyer.City__c+'</cre:CITY>';
                                body+='<cre:POSTAL_CODE></cre:POSTAL_CODE>';
                                body+='<cre:STATE></cre:STATE>';
                                body+='<cre:COUNTRY>'+PBuyer.Country__c+'</cre:COUNTRY>';
                                body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                body+='<cre:ATTRIBUTE6></cre:ATTRIBUTE6>';
                                body+='<cre:ATTRIBUTE7></cre:ATTRIBUTE7>';
                                body+='<cre:ATTRIBUTE8></cre:ATTRIBUTE8>';
                                body+='<cre:ATTRIBUTE9></cre:ATTRIBUTE9>';
                                body+='<cre:ATTRIBUTE10></cre:ATTRIBUTE10>';
                                body+='</cre:P_CUST_ADDRESS>';
                                
                                body+='<cre:P_CUST_CONTACT>';
                                body+='<cre:PRIMARY_FLAG></cre:PRIMARY_FLAG>'; //*********
                                body+='<cre:HOME_COUNTRY_CODE></cre:HOME_COUNTRY_CODE>';
                                body+='<cre:HOME_AREA_CODE></cre:HOME_AREA_CODE>';
                                body+='<cre:HOME_NUMBER></cre:HOME_NUMBER>';
                                body+='<cre:WORK_COUNTRY_CODE></cre:WORK_COUNTRY_CODE>';
                                body+='<cre:WORK_AREA_CODE></cre:WORK_AREA_CODE>';
                                body+='<cre:WORK_NUMBER></cre:WORK_NUMBER>';
                                if(PBuyer.Phone_Country_Code__c!=null && PBuyer.Phone_Country_Code__c.contains(': 00')){
                                    List<string> codes=PBuyer.Phone_Country_Code__c.split(': 00');                            
                                    body+='<cre:MOBILE_COUNTRY_CODE>'+codes[1]+'</cre:MOBILE_COUNTRY_CODE>';    
                                }                        
                                body+='<cre:MOBILE_AREA_CODE></cre:MOBILE_AREA_CODE>';
                                body+='<cre:MOBILE_NUMBER>'+PBuyer.Phone__c+'</cre:MOBILE_NUMBER>';
                                body+='<cre:FAX_COUNTRY_CODE></cre:FAX_COUNTRY_CODE>';
                                body+='<cre:FAX_AREA_CODE></cre:FAX_AREA_CODE>';
                                body+='<cre:FAX_NUMBER></cre:FAX_NUMBER>';
                                body+='<cre:EMAIL_ADDRESS>'+PBuyer.Email__c+'</cre:EMAIL_ADDRESS>';
                                body+='<cre:URL></cre:URL>';
                                body+='<cre:NATIONALITY>'+PBuyer.Nationality__c+'</cre:NATIONALITY>';
                                body+='<cre:PASSPORT_NUMBER>'+PBuyer.Passport_Number__c+'</cre:PASSPORT_NUMBER>';
                                String ppdate='';
                                if(PBuyer.Passport_Expiry_Date__c!=null){
                                    String[] strDate = PBuyer.Passport_Expiry_Date__c.split('/');
                                    Integer myIntDate = integer.valueOf(strDate[0]);                            
                                    Integer myIntMonth = integer.valueOf(strDate[1]);                           
                                    Integer myIntYear = integer.valueOf(strDate[2]);                            
                                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                    ppdate=GetDatetext(d);
                                    body+='<cre:PASSPORT_ISSUE_DATE>'+ppdate+'</cre:PASSPORT_ISSUE_DATE>';
                                }
                                body+='<cre:PASSPROT_ISSUE_PLACE>'+PBuyer.Place_of_Issue__c+'</cre:PASSPROT_ISSUE_PLACE>';
                                body+='<cre:CR_NUMBER>'+PBuyer.CR_Number__c+'</cre:CR_NUMBER>';
                                body+='<cre:CR_REG_PLACE>'+PBuyer.CR_Registration_Place__c+'</cre:CR_REG_PLACE>';
                                String crdate='';
                                if(PBuyer.CR_Registration_Expiry_Date__c!=null){
                                    String[] strDate = PBuyer.CR_Registration_Expiry_Date__c.split('/');
                                    Integer myIntDate = integer.valueOf(strDate[0]);                            
                                    Integer myIntMonth = integer.valueOf(strDate[1]);                           
                                    Integer myIntYear = integer.valueOf(strDate[2]);                            
                                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);                                
                                    crdate=GetDatetext(d);
                                    system.debug('CCRRDate===>'+crdate);
                                    body+='<cre:CR_REG_DATE>'+crdate+'</cre:CR_REG_DATE>';
                                }                            
                                body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                body+='</cre:P_CUST_CONTACT>';
                                
                                body+='<cre:P_CUST_AR_DATA>';
                                body+='<cre:TITLE_NUM_AR>'+PBuyer.Title_Arabic__c+'</cre:TITLE_NUM_AR>';
                                if(PBuyer.Buyer_Type__c=='Individual'){
                                    body+='<cre:FIRST_NAME_AR>'+PBuyer.First_Name_Arabic__c+'</cre:FIRST_NAME_AR>';
                                    body+='<cre:MIDDLE_NAME_AR></cre:MIDDLE_NAME_AR>'; // Added 2 lines as Arabic Last Name is appended in SPA Doc - June 15 #1300 AT
                                    body+='<cre:LAST_NAME_AR>'+PBuyer.Last_Name_Arabic__c+'</cre:LAST_NAME_AR>';
                                }
                                else if(PBuyer.Buyer_Type__c=='Corporate'){
                                    body+='<cre:FIRST_NAME_AR>'+PBuyer.Organisation_Name_Arabic__c+'</cre:FIRST_NAME_AR>';
                                    //body+='<cre:MIDDLE_NAME_AR></cre:MIDDLE_NAME_AR>'; // Comenting 2 lines as Arabic Last Name is appended in SPA Doc - June 15 #1300 AT
                                    //body+='<cre:LAST_NAME_AR>'+PBuyer.Last_Name_Arabic__c+'</cre:LAST_NAME_AR>'; 
                                }
                                body+='<cre:NATIONALITY_AR>'+PBuyer.Nationality_Arabic__c+'</cre:NATIONALITY_AR>';
                                body+='<cre:PASSPORT_NUMBER_AR>'+PBuyer.Passport_Number__c+'</cre:PASSPORT_NUMBER_AR>';
                                body+='<cre:CR_NUMBER_AR>'+PBuyer.CR_Number__c+'</cre:CR_NUMBER_AR>';
                                body+='<cre:CR_REG_DATE_AR>'+crdate+'</cre:CR_REG_DATE_AR>';
                                body+='<cre:CR_REG_PLACE_AR>'+PBuyer.CR_Registration_Place_Arabic__c+'</cre:CR_REG_PLACE_AR>';
                                body+='<cre:EMAIL_ADDRESS_AR>'+PBuyer.Email__c+'</cre:EMAIL_ADDRESS_AR>';
                                body+='<cre:PASSPORT_ISSUE_DATE_AR>'+ppdate+'</cre:PASSPORT_ISSUE_DATE_AR>';
                                body+='<cre:PASSPORT_ISSUE_PLACE_AR>'+PBuyer.Place_of_Issue_Arabic__c+'</cre:PASSPORT_ISSUE_PLACE_AR>';
                                if(PBuyer.Phone_Country_Code__c!=null && PBuyer.Phone_Country_Code__c.contains(': 00')){
                                    List<string> codes=PBuyer.Phone_Country_Code__c.split(': 00');                            
                                    body+='<cre:MOBILE_COUNTRY_CODE_AR>'+codes[1]+'</cre:MOBILE_COUNTRY_CODE_AR>';   
                                }                                      
                                body+='<cre:MOBILE_AREA_CODE_AR></cre:MOBILE_AREA_CODE_AR>';
                                body+='<cre:MOBILE_NUMBER_AR>'+PBuyer.Phone__c+'</cre:MOBILE_NUMBER_AR>';
                                body+='<cre:PHONE_COUNTRY_CODE_AR></cre:PHONE_COUNTRY_CODE_AR>';
                                body+='<cre:PHONE_AREA_CODE_AR></cre:PHONE_AREA_CODE_AR>';
                                body+='<cre:PHONE_NUMBER_AR></cre:PHONE_NUMBER_AR>';
                                body+='<cre:PHONE_EXTENTION_AR></cre:PHONE_EXTENTION_AR>';
                                body+='<cre:FAX_COUNTRY_CODE_AR></cre:FAX_COUNTRY_CODE_AR>';
                                body+='<cre:FAX_AREA_CODE_AR></cre:FAX_AREA_CODE_AR>';
                                body+='<cre:FAX_NUMBER_AR></cre:FAX_NUMBER_AR>';
                                body+='<cre:FAX_EXTENSION_AR></cre:FAX_EXTENSION_AR>';
                                body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                body+='</cre:P_CUST_AR_DATA>';
                                
                                body+='<cre:P_CUST_AR_ADDRESS>';
                                body+='<cre:ADDRESS1_AR>'+PBuyer.Address_Line_1_Arabic__c+'</cre:ADDRESS1_AR>';
                                body+='<cre:ADDRESS2_AR>'+PBuyer.Address_Line_2_Arabic__c+'</cre:ADDRESS2_AR>';
                                body+='<cre:ADDRESS3_AR>'+PBuyer.Address_Line_3_Arabic__c+'</cre:ADDRESS3_AR>';
                                body+='<cre:ADDRESS4_AR>'+PBuyer.Address_Line_4_Arabic__c+'</cre:ADDRESS4_AR>';
                                body+='<cre:CITY_AR>'+PBuyer.City_Arabic__c+'</cre:CITY_AR>';
                                body+='<cre:COUNTRY_AR>'+PBuyer.Country_Arabic__c+'</cre:COUNTRY_AR>';
                                body+='<cre:POSTAL_CODE_AR></cre:POSTAL_CODE_AR>';
                                body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                body+='</cre:P_CUST_AR_ADDRESS>';
                                
                                body+='<cre:P_REGISTRATION_RECORDS>';
                                for(Booking_Unit__c unit: units){
                                    //Getting the delivery mode
                                    string deliveryMode = '';
                                    if(unit.Booking__r.Deal_SR__r.Delivery_mode__c == 'Email')
                                        deliveryMode = 'E';
                                    if(unit.Booking__r.Deal_SR__r.Delivery_mode__c == 'Dispatch')
                                        deliveryMode = 'D';
                                    if(unit.Booking__r.Deal_SR__r.Delivery_mode__c =='Print at Sales Office')
                                        deliveryMode = 'P';  
                                    
                                    //Getting the location     
                                    string loc = '';
                                    if(unit.Inventory__r.Property_Country__c == 'UK')
                                        loc = 'UK';
                                    else 
                                        loc= 'DP';
                                    
                                    //Getting the booking channel
                                    string bookingchannel = '';
                                    if(unit.Booking__r.Booking_channel__c == 'Office')
                                        bookingchannel = 'OFF';
                                    if(unit.Booking__r.Booking_channel__c == 'Web')
                                        bookingchannel = 'WEB';
                                    if(unit.Booking__r.Booking_channel__c == 'Mobile')
                                        bookingchannel = 'MOB';
                                    
                                    //Getting the payment plan     
                                    List<Payment_Terms__c> PTlist=PayMap.get(unit.id);
                                    String termid='';
                                    if(PTlist.size()>0)
                                        termid=PTlist[0].Payment_Plan__r.Parent_Payment_Plan__r.TERM_ID__c;
                                    
                                    body+='<cre:P_REGISTRATION_RECORDS_ITEM>';
                                    //body+='<cre:EXT_CUST_NUMBER>'+unit.id+'</cre:EXT_CUST_NUMBER>';    //will be removed                                
                                    body+='<cre:LOCATION>'+loc+'</cre:LOCATION>';
                                    body+='<cre:BOOKING_TYPE>Normal</cre:BOOKING_TYPE>';
                                    
                                    body+='<cre:PAYMENT_TERM_ID>'+termid+'</cre:PAYMENT_TERM_ID>'; 
                                    body+='<cre:RELEASE_ID>'+unit.Inventory__r.Release_ID__c+'</cre:RELEASE_ID>';
                                    body+='<cre:ORG_ID>'+unit.Inventory__r.Org_ID__c+'</cre:ORG_ID>';
                                    body+='<cre:UNIT_ID>'+unit.Unit_Location_ID__c+'</cre:UNIT_ID>';
                                    body+='<cre:UNIT_NAME>'+unit.Inventory__r.Location_Code__c+'</cre:UNIT_NAME>';                                     
                                    body+='<cre:BUILDING_ID>'+unit.Inventory__r.Building_ID__c+'</cre:BUILDING_ID>';
                                    body+='<cre:PROPERTY_ID>'+unit.Inventory__r.Property_ID__c+'</cre:PROPERTY_ID>';
                                    body+='<cre:AREA_SQFT>'+unit.Inventory__r.Area_Sqft__c+'</cre:AREA_SQFT>';                                 
                                    body+='<cre:SALES_PERSON_ID>'+PCId+'</cre:SALES_PERSON_ID>'; 
                                    body+='<cre:DOS_ID>'+DOSId+'</cre:DOS_ID>'; 
                                    body+='<cre:HOS_ID>'+HOSId+'</cre:HOS_ID>'; 
                                    body+='<cre:HEAD_OF_DEPT_ID>'+HODId+'</cre:HEAD_OF_DEPT_ID>'; 
                                    body+='<cre:AGENT_ID>'+unit.Booking__r.Deal_SR__r.Agency__r.Vendor_ID__c+'</cre:AGENT_ID>';
                                    body+='<cre:BOOKING_AGENT_ID></cre:BOOKING_AGENT_ID>';  //For UK
                                    body+='<cre:HOD>'+unit.Related_Campaign_Name__c+'</cre:HOD>';
                                    body+='<cre:PROMOTER></cre:PROMOTER>'; ///***********
                                    body+='<cre:BASE_PRICE>'+unit.Selling_Price__c+'</cre:BASE_PRICE>';
                                    body+='<cre:RESERVATION_PRICE>'+unit.Requested_Price__c+'</cre:RESERVATION_PRICE>';
                                    body+='<cre:PROMOTION>'+unit.Related_Promotion_Title__c+'</cre:PROMOTION>'; 
                                    body+='<cre:SALES_OFFICE>'+SalesOffice+'</cre:SALES_OFFICE>'; 
                                    body+='<cre:UNPAID_PARKING>'+unit.No_of_parking__c+'</cre:UNPAID_PARKING>';
                                    body+='<cre:EXTRA_OPTION_1></cre:EXTRA_OPTION_1>';
                                    body+='<cre:EXTRA_AMOUNT_1></cre:EXTRA_AMOUNT_1>';
                                    body+='<cre:EXTRA_OPTION_2></cre:EXTRA_OPTION_2>';
                                    body+='<cre:EXTRA_AMOUNT_2></cre:EXTRA_AMOUNT_2>';
                                    body+='<cre:REMARKS></cre:REMARKS>';
                                    body+='<cre:ADDITIONAL_REQUEST></cre:ADDITIONAL_REQUEST>';
                                    body+='<cre:SPECIAL_CONDITION></cre:SPECIAL_CONDITION>';
                                    body+='<cre:SELLER_SOLICITOR></cre:SELLER_SOLICITOR>'; //For UK
                                    body+='<cre:BUYER_SOLICITOR_NAME></cre:BUYER_SOLICITOR_NAME>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_FIRM></cre:BUYER_SOLICITOR_FIRM>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_ADDR_1></cre:BUYER_SOLICITOR_ADDR_1>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_ADDR_2></cre:BUYER_SOLICITOR_ADDR_2>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_POST_CODE></cre:BUYER_SOLICITOR_POST_CODE>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_PHONE_NO></cre:BUYER_SOLICITOR_PHONE_NO>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_DX_NO></cre:BUYER_SOLICITOR_DX_NO>';//For UK
                                    body+='<cre:BUYER_SOLICITOR_EMAIL></cre:BUYER_SOLICITOR_EMAIL>';//For UK
                                    body+='<cre:BOOKING_CHANNEL>'+bookingchannel+'</cre:BOOKING_CHANNEL>';
                                    body+='<cre:BOOKING_REFERENCE></cre:BOOKING_REFERENCE>';
                                    body+='<cre:DELIVERY_MODE>'+deliveryMode+'</cre:DELIVERY_MODE>';
                                    body+='<cre:CM_PRICE_SQFT></cre:CM_PRICE_SQFT>'; //***********
                                    body+='<cre:DEAL_ID>'+dealid+'</cre:DEAL_ID>'; 
                                    body+='<cre:DEAL_TYPE></cre:DEAL_TYPE>'; //***********              
                                    body+='<cre:R_B_FLAG>'+RegBulk+'</cre:R_B_FLAG>';
                                    
                                    body+='<cre:JB_TABLE_REC>';
                                    
                                    if(JointBuyers.containsKey(unit.Booking__c)){
                                        for(Buyer__c jb: JointBuyers.get(unit.Booking__c)){
                                            body+='<cre:JB_TABLE_REC_ITEM>';
                                            body+='<cre:JB_REC_ID>'+jb.Buyer_Id__c+unit.Booking_Unit_No__c+'</cre:JB_REC_ID>'; 
                                            body+='<cre:JB_TITLE_EN>'+jb.Title__c+'</cre:JB_TITLE_EN>';
                                            if(jb.Buyer_Type__c=='Individual')
                                                body+='<cre:JB_FIRST_NAME_EN>'+jb.First_Name__c+'</cre:JB_FIRST_NAME_EN>';
                                            else if(jb.Buyer_Type__c=='Corporate')
                                                body+='<cre:JB_FIRST_NAME_EN>'+jb.Organisation_Name__c+'</cre:JB_FIRST_NAME_EN>';
                                            //body+='<cre:JB_FIRST_NAME_EN>'+jb.First_Name__c+'</cre:JB_FIRST_NAME_EN>'; // Duplicate Line commented for JB issue
                                            body+='<cre:JB_MIDDLE_NAME_EN></cre:JB_MIDDLE_NAME_EN>';
                                            body+='<cre:JB_LAST_NAME_EN>'+jb.Last_Name__c+'</cre:JB_LAST_NAME_EN>';
                                            body+='<cre:JB_NATIONALITY_EN>'+jb.NATIONALITY__c+'</cre:JB_NATIONALITY_EN>';
                                            body+='<cre:JB_PASSPORT_NO_EN>'+jb.Passport_Number__c+'</cre:JB_PASSPORT_NO_EN>';
                                            body+='<cre:JB_CR_NO_EN>'+jb.CR_Number__c+'</cre:JB_CR_NO_EN>';
                                            body+='<cre:JB_CR_REG_PLACE_EN>'+jb.CR_Registration_Place__c+'</cre:JB_CR_REG_PLACE_EN>';
                                            String jbcrdate='';
                                            if(jb.CR_Registration_Expiry_Date__c!=null){
                                                String[] strDate = jb.CR_Registration_Expiry_Date__c.split('/');
                                                Integer myIntDate = integer.valueOf(strDate[0]);                            
                                                Integer myIntMonth = integer.valueOf(strDate[1]);                           
                                                Integer myIntYear = integer.valueOf(strDate[2]);                            
                                                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                                jbcrdate=GetDatetext(d);
                                                body+='<cre:JB_CR_REG_DATE_EN>'+jbcrdate+'</cre:JB_CR_REG_DATE_EN>';
                                            }                                                            
                                            body+='<cre:JB_HOME_PHONE_EN></cre:JB_HOME_PHONE_EN>';
                                            body+='<cre:JB_WORK_PHONE_EN></cre:JB_WORK_PHONE_EN>';
                                            body+='<cre:JB_MOBILE_PHONE_EN>'+jb.Phone__c+'</cre:JB_MOBILE_PHONE_EN>';
                                            body+='<cre:JB_FAX_EN></cre:JB_FAX_EN>';
                                            body+='<cre:JB_EMAIL_EN>'+jb.Email__c+'</cre:JB_EMAIL_EN>';
                                            String jppdate='';
                                            if(jb.Passport_Expiry_Date__c!=null){
                                                String[] strDate = jb.Passport_Expiry_Date__c.split('/');
                                                Integer myIntDate = integer.valueOf(strDate[0]);                            
                                                Integer myIntMonth = integer.valueOf(strDate[1]);                           
                                                Integer myIntYear = integer.valueOf(strDate[2]);                            
                                                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                                jppdate=GetDatetext(d);
                                                body+='<cre:JB_PASSPORT_ISSUE_DATE_EN>'+jppdate+'</cre:JB_PASSPORT_ISSUE_DATE_EN>';
                                            }
                                            body+='<cre:JB_PASSPORT_ISSUE_PLACE_EN>'+jb.Place_of_Issue__c+'</cre:JB_PASSPORT_ISSUE_PLACE_EN>';
                                            body+='<cre:JB_ADDRESS1_EN>'+jb.Address_Line_1__c+'</cre:JB_ADDRESS1_EN>'; 
                                            body+='<cre:JB_ADDRESS2_EN>'+jb.Address_Line_2__c+'</cre:JB_ADDRESS2_EN>'; 
                                            body+='<cre:JB_ADDRESS3_EN>'+jb.Address_Line_3__c+'</cre:JB_ADDRESS3_EN>';
                                            body+='<cre:JB_ADDRESS4_EN>'+jb.Address_Line_4__c+'</cre:JB_ADDRESS4_EN>';
                                            body+='<cre:JB_CITY_EN>'+jb.City__c+'</cre:JB_CITY_EN>';        
                                            body+='<cre:JB_ZIP_EN></cre:JB_ZIP_EN>';
                                            body+='<cre:JB_COUNTRY_EN>'+jb.Country__c+'</cre:JB_COUNTRY_EN>';    
                                            body+='<cre:JB_TITLE_AR>'+jb.Title_Arabic__c+'</cre:JB_TITLE_AR>';
                                            if(jb.Buyer_Type__c=='Individual')
                                                body+='<cre:JB_FIRST_NAME_AR>'+jb.First_Name_Arabic__c+'</cre:JB_FIRST_NAME_AR>';
                                            else if(jb.Buyer_Type__c=='Corporate')
                                                body+='<cre:JB_FIRST_NAME_AR>'+jb.Organisation_Name_Arabic__c+'</cre:JB_FIRST_NAME_AR>';                                                   
                                            body+='<cre:JB_MIDDLE_NAME_AR></cre:JB_MIDDLE_NAME_AR>';
                                            body+='<cre:JB_LAST_NAME_AR>'+jb.Last_Name_Arabic__c+'</cre:JB_LAST_NAME_AR>';    
                                            body+='<cre:JB_NATIONALITY_AR>'+jb.Nationality_Arabic__c+'</cre:JB_NATIONALITY_AR>';
                                            body+='<cre:JB_PASSPORT_NO_AR>'+jb.Passport_Number__c+'</cre:JB_PASSPORT_NO_AR>';
                                            body+='<cre:JB_CR_NO_AR>'+jb.CR_Number__c+'</cre:JB_CR_NO_AR>';
                                            body+='<cre:JB_CR_REG_PLACE_AR>'+jb.CR_Registration_Place_Arabic__c+'</cre:JB_CR_REG_PLACE_AR>';
                                            body+='<cre:JB_CR_REG_DATE_AR>'+jbcrdate+'</cre:JB_CR_REG_DATE_AR>';
                                            body+='<cre:JB_HOME_PHONE_AR></cre:JB_HOME_PHONE_AR>';
                                            body+='<cre:JB_WORK_PHONE_AR></cre:JB_WORK_PHONE_AR>';
                                            body+='<cre:JB_MOBILE_PHONE_AR>'+jb.Phone__c+'</cre:JB_MOBILE_PHONE_AR>';
                                            body+='<cre:JB_FAX_AR></cre:JB_FAX_AR>';
                                            body+='<cre:JB_EMAIL_AR>'+jb.Email__c+'</cre:JB_EMAIL_AR>';
                                            body+='<cre:JB_PASSPORT_ISSUE_DATE_AR>'+jppdate+'</cre:JB_PASSPORT_ISSUE_DATE_AR>';
                                            body+='<cre:JB_PASSPORT_ISSUE_PLACE_AR>'+jb.Place_of_Issue_Arabic__c+'</cre:JB_PASSPORT_ISSUE_PLACE_AR>';
                                            body+='<cre:JB_ADDRESS1_AR>'+jb.Address_Line_1_Arabic__c+'</cre:JB_ADDRESS1_AR>';
                                            body+='<cre:JB_ADDRESS2_AR>'+jb.Address_Line_2_Arabic__c+'</cre:JB_ADDRESS2_AR>';
                                            body+='<cre:JB_ADDRESS3_AR>'+jb.Address_Line_3_Arabic__c+'</cre:JB_ADDRESS3_AR>';
                                            body+='<cre:JB_ADDRESS4_AR>'+jb.Address_Line_4_Arabic__c+'</cre:JB_ADDRESS4_AR>';
                                            body+='<cre:JB_CITY_AR>'+jb.City_Arabic__c+'</cre:JB_CITY_AR>';
                                            body+='<cre:JB_ZIP_AR></cre:JB_ZIP_AR>';
                                            body+='<cre:JB_COUNTRY_AR>'+jb.Country_Arabic__c+'</cre:JB_COUNTRY_AR>';
                                            body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                            body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                            body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                            body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                                                          
                                            body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                            body+='</cre:JB_TABLE_REC_ITEM>';
                                        }
                                    }                                       
                                    
                                    body+='</cre:JB_TABLE_REC>';
                                    //body+='<cre:UNIT_SBL_ID></cre:UNIT_SBL_ID>';
                                    //Payment Terms
                                    body+='<cre:PT_TABLE_REC>';
                                    //integer i=1000;
                                    for(Payment_Terms__c PT : PayMap.get(unit.id)){
                                        //<!--Zero or more repetitions:-->
                                        
                                        body+='<cre:PT_TABLE_REC_ITEM>';
                                        //<!--Optional:-->
                                        body+='<cre:TERM_ID></cre:TERM_ID>';
                                        //<!--Optional:-->
                                        body+='<cre:LINE_ID>'+PT.SF_Line_ID__c+'</cre:LINE_ID>';
                                        body+='<cre:INSTALLMENT>'+PT.Installment__c+'</cre:INSTALLMENT>';
                                        //<!--Optional:-->
                                        body+='<cre:PERCENT_VALUE>'+PT.Percent_Value__c+'</cre:PERCENT_VALUE>';
                                        //<!--Optional:-->
                                        //<!--P_PAYMENT_DATE (DD-MON-YYYY):-->
                                        String pdate='';
                                        if(PT.Payment_Date__c!=null){
                                            pdate=GetDatetext(PT.Payment_Date__c);
                                            body+='<cre:PAYMENT_DATE>'+pdate+'</cre:PAYMENT_DATE>';
                                        }                                                      
                                        //<!--P_EXPECTED_DATE (DD-MON-YYYY):-->
                                        String exdate='';
                                        if(PT.Expected_Date__c!=null){
                                            exdate=GetDatetext(PT.Expected_Date__c);
                                            body+='<cre:EXPECTED_DATE>'+exdate+'</cre:EXPECTED_DATE>';
                                        }
                                        
                                        body+='<cre:MILESTONE_EVENT>'+PT.Milestone_Event__c+'</cre:MILESTONE_EVENT>';
                                        //<!--Optional:-->
                                        body+='<cre:MILESTONE_EVENT_ARABIC>'+PT.Milestone_Event_Arabic__c+'</cre:MILESTONE_EVENT_ARABIC>';
                                        //<!--Optional:-->
                                        body+='<cre:PAYMENT_AMOUNT>'+PT.Payment_Amount__c+'</cre:PAYMENT_AMOUNT>';
                                        //<!--Optional:-->
                                        body+='<cre:DESCRIPTION>'+PT.Description__c+'</cre:DESCRIPTION>';
                                        //<!--Optional:-->
                                        body+='<cre:EVENT_DAYS>'+PT.Event_Days__c+'</cre:EVENT_DAYS>';                                     
                                        body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';                                      
                                        body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                        body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                        body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                        body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                        body+='<cre:ATTRIBUTE6></cre:ATTRIBUTE6>';
                                        body+='<cre:ATTRIBUTE7></cre:ATTRIBUTE7>';
                                        body+='<cre:ATTRIBUTE8></cre:ATTRIBUTE8>';
                                        body+='<cre:ATTRIBUTE9></cre:ATTRIBUTE9>';
                                        body+='<cre:ATTRIBUTE10></cre:ATTRIBUTE10>';
                                        body+='</cre:PT_TABLE_REC_ITEM>';
                                    }   
                                    body+='</cre:PT_TABLE_REC>';
                                    if(!unit.Options__r.isEmpty()){
                                        for(Option__c op : unit.Options__r) {
                                           if(!String.isBlank(op.PromotionName__c)){
                                              body+='<cre:ATTRIBUTE1>'+op.TemplateIdPN__c+'</cre:ATTRIBUTE1>';
                                           }else{
                                                 body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                           }  
                                           if(!String.isBlank(op.CampaignName__c)){
                                              body+='<cre:ATTRIBUTE2>'+op.TemplateIdCN__c+'</cre:ATTRIBUTE2>';
                                           }else{
                                            body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                           } 
                                           if(!String.isBlank(op.OptionsName__c)){
                                              body+='<cre:ATTRIBUTE3>'+op.TemplateIdOP__c+'</cre:ATTRIBUTE3>';
                                           }else{
                                            body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                           }  
                                           if(!String.isBlank(op.SchemeName__c)){
                                              body+='<cre:ATTRIBUTE4>'+op.TemplateIdSN__c+'</cre:ATTRIBUTE4>';
                                           }else{
                                            body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                           }   
                                        }
                                    }else{
                                            body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                            body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                            body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                            body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                    }
                                    
                                    
                                    //body+='<cre:ATTRIBUTE1></cre:ATTRIBUTE1>';
                                    //body+='<cre:ATTRIBUTE2></cre:ATTRIBUTE2>';
                                    //body+='<cre:ATTRIBUTE3></cre:ATTRIBUTE3>';
                                    //body+='<cre:ATTRIBUTE4></cre:ATTRIBUTE4>';
                                    body+='<cre:ATTRIBUTE5></cre:ATTRIBUTE5>';
                                    body+='<cre:ATTRIBUTE6></cre:ATTRIBUTE6>';
                                    body+='<cre:ATTRIBUTE7></cre:ATTRIBUTE7>';
                                    body+='<cre:ATTRIBUTE8></cre:ATTRIBUTE8>';
                                    body+='<cre:ATTRIBUTE9></cre:ATTRIBUTE9>';
                                    body+='<cre:ATTRIBUTE10></cre:ATTRIBUTE10>';
                                    
                                    body+='</cre:P_REGISTRATION_RECORDS_ITEM>';
                                }
                                body+='</cre:P_REGISTRATION_RECORDS>';
                                body+='</cre:InputParameters>';
                                body+='</soapenv:Body>';
                                body+='</soapenv:Envelope>';
                                system.debug('xxdc_registration_process_ws-check '+body);
                            }
                            catch(Exception ex) {                        
                                body='Error';
                                errormsg ='Ids=='+bookingids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();                                 
                            }  
                        }
                        else{
                            body='Error';
                            errormsg ='Booking Ids=='+bookingids+'- Payment Terms not found';                
                        }
                    }
                    else{
                        body='Error';
                        errormsg ='Booking Ids=='+bookingids+'- Primary Buyer not found';                
                    }
                }
                else{
                    body='Error';
                    errormsg ='Booking Ids=='+bookingids+'-Buyer not found';                
                }
            }
            else{
                body='Error';            
                errormsg ='Booking Ids=='+bookingids+'-Units not found';             
            }
        }
        else{
            body='Error';          
            errormsg ='Ids=='+bookingids+'-Booking not found';
            
        }
        if(body=='Error'){
            Log__c objLog = new Log__c();
            objLog.Description__c =errormsg;
            objLog.Type__c = 'Error creating request for Registration Creation';
            insert objLog;
        }
        return body.trim();
    }
    
    /**********************Callout for the registration creation*********************************/
    
    webservice static void sendRegistrationRequest(List<id> bookingids){
        
        getIPMSsetting('IPMS_Regn_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareRegistrationRequest(bookingids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120 * 1000);
        
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                if(reqXML!='Error'){
                    HTTPResponse res = http.send(req);
                    
                    System.debug('>>>>>Response>>>>>>'+res.getbody());
                    
                    parseRegnResponse(res.getBody());
                }
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+bookingids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Registration Creation';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for registration creation request*********************************/
    public static void parseRegnResponse(string body){
        
        string reqstatus,regId,status,statusmsg,unitid,partyId,dealid,errormsg = '';
        List<String> unitidlist = new List<String>();
        Map<string,string> unitaccmap= new Map<string,string>();
        Map<string,string> unitmap = new Map<string,string>();
        Map<string,string> unitstatusmap = new Map<string,string>();
        Map<string,string> unitstatusmsgmap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    System.debug('>>>>Child3>>>>>>>>'+child3.getName());
                    System.debug('>>>>Child3 Val>>>>>>>>'+child3.getText());
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        System.debug('>>>>Child4 Val>>>>>>>>'+child4.getText());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Val>>>>>>>>'+child5.getText());
                            
                            if(child5.getName()=='SOURCE_REFERENCE'){
                                dealid = child5.getText();
                            }
                            if(child5.getName()=='PARTY_ID'){
                                partyId = child5.getText();
                            }
                            if(child5.getName()=='REGISTRATION_ID'){
                                regId = child5.getText();
                            }
                            if(child5.getName()=='UNIT_ID'){
                                unitid = child5.getText();
                            }
                            if(child5.getName()=='REQUEST_STATUS') 
                                status = child5.getText();
                            if(child5.getName()=='REQUEST_MESSAGE') 
                                statusmsg = child5.getText();
                        }
                        unitmap.put(unitid,regid);
                        unitstatusmap.put(unitid,status);
                        unitstatusmsgmap.put(unitid,statusmsg);
                        unitaccmap.put(unitid,partyid);
                    }
                    if(child3.getName()=='X_REQUEST_STATUS'){
                        reqstatus= child3.getText();                        
                    }
                    if(child3.getName()=='X_ERROR_MESSAGE'){
                        errormsg= child3.getText();                     
                    }
                }
                if(child2.getName()!='OutputParameters'){
                    reqstatus= 'Error';                     
                }
            }
        }
        system.debug('DEALID===='+dealid);
        system.debug('ReqStatsus===='+reqstatus);
        system.debug('Error Message===='+errormsg);
        
        //if(reqstatus=='S'){
        try{
            List<Booking_Unit__c> BUlist= [select id, Booking__c,Inventory__c,Registration_ID__c,Registration_DateTime__c,IPMS_Status__c,Unit_Location_ID__c,SR_Id__c,Booking__r.Deal_SR__r.Deal_ID__c from Booking_Unit__c where Status__c!='Removed' and Registration_ID__c=null AND Booking__r.name=:dealid AND Unit_Location_ID__c in:unitmap.keyset()];
            system.debug('BUlist===='+BUlist);
            List<id> bids= new List<id>();
            List<String> SRids= new List<String>();
            List<id> RejectSRids= new List<id>();
            List<id> BookingIds = new List<id>();
            List<id> InvIds = new List<id>();
            Map<id,string> unitbookmap = new Map<id,string>();
            if(BUlist.size()>0){
                for(Booking_Unit__c BU :BUlist){
                    BU.Registration_ID__c=unitmap.get(BU.Unit_Location_ID__c);
                    BU.IPMS_Status__c=unitstatusmsgmap.get(BU.Unit_Location_ID__c);  
                    
                    bids.add(BU.Booking__c);
                    if(unitstatusmap.get(BU.Unit_Location_ID__c)=='S'){
                        BookingIds.add(BU.Booking__c);
                        InvIds.add(BU.Inventory__c);
                        SRids.add(BU.SR_Id__c);
                        BU.Registration_DateTime__c=system.now();
                    } 
                    else{
                        RejectSRids.add(BU.SR_Id__c);
                    }
                    
                    unitbookmap.put(BU.Booking__c,BU.Unit_Location_ID__c);
                }
                update BUlist;
                system.debug('SRids==='+SRids);
                //Blanking out token paid due time if registration is errored
                if(RejectSRids.size()>0){
                    List<NSIBPM__Service_Request__c> RejectSRList=[select id,Token_Deposit_Due_Date_Time__c,Registration_Date__c,Registration_DateTime__c,NSIBPM__Internal_SR_Status__c,NSIBPM__External_SR_Status__c from NSIBPM__Service_Request__c where id in :RejectSRids];
                    for(NSIBPM__Service_Request__c SR :RejectSRList){                       
                        SR.Token_Deposit_Due_Date_Time__c=null;                                               
                    }
                    update RejectSRList;
                }
                
                //Updating Inventory
                DAMAC_Constants.skip_InventoryTrigger=true;
                if(Invids.size()>0){
                    List<Inventory__c> invlist =[select id, Status__c from Inventory__c where id in:Invids];
                    for(Inventory__c inv :invlist){
                        inv.Status__c='Booked';
                    }
                    update invlist;
                }
                
                //Checking if all booking units have got registration id
                Integer regCount=0;
                integer bucount=0;
                system.debug('SRids1==='+SRids);
                if(SRids.size()>0){
                    for(Booking_Unit__c BU : [select id,Registration_ID__c, Booking__c,Booking__r.Deal_SR__c,Token_Paid__c,SR_Id__c,Status__c from Booking_Unit__c where Status__c!='Removed' and SR_Id__c in:SRids]){ 
                        
                        bucount++;
                        if(BU.Registration_ID__c!=null)
                            regCount++;
                    }
                    system.debug('BUUU==='+bucount);
                    system.debug('RegU==='+regCount);
                    //Updating the registration details on SR if all units have reg id                    
                    if(bucount==regCount){

                        /* Calling method to get payment method and duration mapping. */
                        Map<String,Integer> paymentMethodDurationMap = new Map<String,Integer>();
                        
                        for(Payment_Method_Mapping__mdt thisMapping : [SELECT MasterLabel, Payment_Method_Type__c, Time_Out_Duration__c, Proof_of_Payment_Required__c FROM Payment_Method_Mapping__mdt]) {
                            paymentMethodDurationMap.put(thisMapping.Payment_Method_Type__c, Integer.valueOf(thisMapping.Time_Out_Duration__c));
                            //paymentMethodPopRequiredMap.put(thisMapping.Payment_Method_Type__c, thisMapping.Proof_of_Payment_Required__c);
                        }
                        System.debug('#### SR UPDATE');
                        // Iterate over the booking units
                        integer duration=0;
                        List<Booking_Unit__c> allBUlist= [select id,Registration_ID__c,Payment_Method__c, Booking__c,Booking__r.Deal_SR__c,Token_Paid__c,SR_Id__c,Status__c from Booking_Unit__c where Status__c!='Removed' and SR_Id__c in:SRids];
                        for(Booking_Unit__c BU : allBUlist){
                            system.debug('#### payment method = '+BU.Payment_Method__c);
                            if(String.isNotBlank(BU.Payment_Method__c)){
                                if(paymentMethodDurationMap.containsKey(BU.Payment_Method__c)){
                                    duration = duration < paymentMethodDurationMap.get(BU.Payment_Method__c) ? paymentMethodDurationMap.get(BU.Payment_Method__c) : duration;                                            
                                }else{
                                    duration = Integer.valueOf(system.label.Inventory_Block_Duration);   
                                }   
                                //Setting the checkbox for sending out payment email          
                                if(BU.Payment_Method__c=='Online_Payment')
                                    BU.Send_Payment_Link__c=true;
                            }
                        }              
                        
                        Id srstatus=[select id,NSIBPM__Code__c from NSIBPM__SR_Status__c where NSIBPM__Code__c='SUBMITTED'].id;
                        List<NSIBPM__Service_Request__c> SRList=[select id,Token_Deposit_Due_Date_Time__c,NSIBPM__Submitted_Date__c,NSIBPM__Submitted_DateTime__c,Registration_Date__c,Registration_DateTime__c,NSIBPM__Internal_SR_Status__c,NSIBPM__External_SR_Status__c from NSIBPM__Service_Request__c where id in :SRids];
                        for(NSIBPM__Service_Request__c SR :SRList){                             
                            //Updating SR Status
                            SR.NSIBPM__Internal_SR_Status__c=srstatus;
                            SR.NSIBPM__External_SR_Status__c=srstatus;
                            SR.Registration_Date__c=system.today();
                            SR.Registration_DateTime__c=system.now();
                            SR.NSIBPM__Submitted_Date__c=system.today();
                            SR.NSIBPM__Submitted_DateTime__c=system.now();
                            if(SR.Token_Deposit_Due_Date_Time__c==null)
                                SR.Token_Deposit_Due_Date_Time__c=system.now().addHours(duration);    
                        }
                        system.debug(SRList);
                        update SRList;
                        
                        update allBUlist;
                    }
                }
                //Updating PartyID on Buyers.
                List<id> accids= new List<id>();
                Map<id,id> accbookmap = new Map<id,id>();
                Map<id,String> accpartymap = new Map<id,String>();
                Map<id,String> inqpartymap = new Map<id,String>();
                if(bids.size()>0){
                    List<Buyer__c>Pbuyers= [select id,Account__c,Status__c,Inquiry__c,Primary_Buyer__c,Party_ID__c,Booking__c,Is_3rd_Party__c from Buyer__c where Booking__c in:bids AND   Is_3rd_Party__c=false];//Primary_Buyer__c=true and 
                    for(Buyer__c PBuyer : Pbuyers){
                        if(PBuyer.Primary_Buyer__c){
                            PBuyer.Party_ID__c= unitaccmap.get(unitbookmap.get(PBuyer.Booking__c));
                            if(Pbuyer.Inquiry__c!=null){
                                inqpartymap.put(PBuyer.Inquiry__c,PBuyer.Party_ID__c);
                            }
                            if(PBuyer.Account__c!=null){
                                accids.add(PBuyer.Account__c);
                                accbookmap.put(PBuyer.Account__c,PBuyer.Booking__c); 
                                accpartymap.put(PBuyer.Account__c,PBuyer.Party_ID__c);
                            }
                        }
                        PBuyer.Status__c='Active';
                    }
                    update PBuyers;             
                }    
                
                //Updating PartyId on Inquiry
                if(inqpartymap.keyset().size()>0){
                    List<Inquiry__c> inqlist=[select id,Party_ID__c from Inquiry__c where id in:inqpartymap.keyset()];
                    for(Inquiry__c inq:inqlist){
                        if(inq.Party_ID__c==null)
                            inq.Party_ID__c=inqpartymap.get(inq.id);
                    }
                    update inqlist;
                }        
                //Updating PartyID on Account
                if(accpartymap.keyset().size()>0){
                    List<Account> acclist=[select id,Party_ID__c from Account where id in:accpartymap.keyset()];
                    for(Account acc:acclist){
                        if(acc.Party_ID__c==null)
                            acc.Party_ID__c=accpartymap.get(acc.id);
                    }
                    update acclist;
                }
                
                
                //Invoking the payment plan webservice
                /*
if(BookingIds.size()>0){
system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'PaymentPlan'));    
}*/
            }
        }catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+unitmap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response For Registration Creation';
            insert objLog;             
        }    
        
        //}
        if(reqstatus!='S'){
            if(reqstatus=='Error')
                errormsg=body;  
            Log__c objLog = new Log__c();
            objLog.Description__c = errormsg;
            objLog.Type__c = 'Webservice Callout Failure For Registration Creation';
            insert objLog;    
        }
        
    }
    
    /*************************************************************************************************************************/
    /****************************************SPA Creation Start*********************************************************/
    /**********************Preparing the request body for the SPA request*********************************/
    public static string invokeSPA(List<id> BUids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where id in :BUids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='SPA-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>SPA</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU :BUlist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            body+='<proc:PARAM_ID>'+BU.id+'</proc:PARAM_ID>';
            body+='<proc:ATTRIBUTE1>GENERATE</proc:ATTRIBUTE1>'; 
            body+='<proc:ATTRIBUTE2>'+BU.Registration_ID__c+'</proc:ATTRIBUTE2>';
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the SPA generation*********************************/
    webservice static void invokeSPAGeneration(List<id> BUids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = invokeSPA(BUids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseSPAResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+BUids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For SPA Generation';
                insert objLog;  
                // Update SR Banner
                if(BUids.size()>0 ){
                    list<id> srids = new list<id>();
                    system.debug(BUids+'BUids>>>>>>');
                    list<booking_unit__c> bus = [select id,SR_Id__c from booking_unit__c where id in:BUids];
                    system.debug(bus +'>>>>>>>>>');
                    for(booking_unit__c bu:bus){
                        srids.add(bu.SR_Id__c);
                    }
                    system.debug(srids);
                    list<NSIBPM__Service_Request__c> srToUpdate = [select id from NSIBPM__Service_Request__c where ID in:srids];
                    for(NSIBPM__Service_Request__c sr:srToUpdate){
                        sr.SPA_Generation_Status__c = label.SPA_Time_Out_Error_Message +'-'+ System.now().format();
                    }
                    update srToUpdate;
                }
                    
            }   
        } 
    }
    
    /**********************Parsing the response received for SPA request*********************************/
    
    public static void parseSPAResponse(string body){
        
        string regId,BUid,status,statusmsg,spaid,dpid,docurl,dpurl,docname,docid = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        Map<string,String> SPAMap = new Map<string,string>();
        Map<string,String> SPADocMap = new Map<string,string>();
        Map<string,String> DPDocMap = new Map<string,string>();
        Map<string,String> UrlMap = new Map<string,string>();
        Map<string,String> DocNameMap = new Map<string,string>();
        Map<string,String> DocStatusMap = new Map<string,string>();
        Map<string,String> DocStatusMsgMap = new Map<string,string>();
        Map<string,String> statusmsgMap = new Map<string,string>();
        List<String> BUids = new List<String>();
        List<String> doclist = new List<String>(); 
        list<string> failedBus = new list<string>();
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getText());
                            if(child5.getName()=='PARAM_ID') 
                                BUid=child5.getText();                                                       
                            if(child5.getName()=='ATTRIBUTE1') 
                                docurl= child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                                docid= child5.getText();
                            if(child5.getName()=='ATTRIBUTE3') //*******
                                docname= child5.getText();
                            if(child5.getName()=='PROC_STATUS')
                                status=child5.getText();                             
                            if(child5.getName()=='PROC_MESSAGE')
                                statusmsg=child5.getText();  
                            
                        }  
                        if(docname.contains('DP')){ //*****to be checked if(docname=='DP-INVOICE')
                            dpurl=docurl;
                            dpid=docid;
                            DPDocMap.put(BUid,docid);
                        }
                        if(docname.contains('SPA')){
                            spaid=docid;
                            
                            if(status=='S'){
                                SPAMap.put(BUid,docurl); 
                                SPADocMap.put(BUid,docid);
                            }
                        }
                        BUids.add(BUid);
                        statusmsgMap.put(BUid,statusmsg);
                        doclist.add(docid);
                        DocNameMap.put(docid,docname); 
                        DocStatusMap.put(docid,status);
                        DocStatusMsgMap.put(docid,statusmsg); 
                        UrlMap.put(docid,docurl);
                    }
                }
            }
        }
        Map<string,String> DocMap = new Map<string,string>();
        List<NSIBPM__Document_Master__c> DMlist = [select id,NSIBPM__Code__c from NSIBPM__Document_Master__c where NSIBPM__Code__c ='SPA' or NSIBPM__Code__c ='DP_INVOICE'];
        for(NSIBPM__Document_Master__c DM :DMList){
            DocMap.put(DM.NSIBPM__Code__c,DM.id);
        }
        //List<String> docs = doclist.split('*');
        List<Booking_Unit__c> BUlist= [select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,Delivery_Mode__c,IPMS_Status__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id in:BUids];//SPAMap.keyset()];
        List<Id>BookingIds = new List<id>();
        try{
            if(BUList.size()>0){
                for(Booking_Unit__c BU :BUlist){
                    BU.IPMS_Status__c='SPA generation- '+statusmsgMap.get(BU.id);
                    /*
//Creating the SR Doc for SPA
if(SPAMap.get(BU.id)!=null){

NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
SRDoc.NSIBPM__Service_Request__c=BU.Booking__r.Deal_SR__c;
SRDoc.Booking_Unit__c=BU.id;
SRDoc.Doc_URL__c=SPAMap.get(BU.id);
SRDoc.NSIBPM__Document_Master__c=DocMap.get('SPA');
SRDoc.name=BU.Registration_ID__c+'-'+DocNameMap.get(SPADocMap.get(BU.id));
SRDoc.NSIBPM__Is_Not_Required__c=true;
SRDoc.NSIBPM__Status__c='Generated';
SRDoc.IPMS_Document_ID__c=SPADocMap.get(BU.id);
SRDocList.add(SRDoc);
}

//Creating the SR Doc for DP Invoice
//if(DPDocMap.get(BU.id)!=null)
if(dpurl != null){
NSIBPM__SR_Doc__c SRDoc1 = new NSIBPM__SR_Doc__c();
SRDoc1.NSIBPM__Service_Request__c=BU.Booking__r.Deal_SR__c;
SRDoc1.Booking_Unit__c=BU.id;
//SRDoc1.Doc_URL__c=UrlMap.get(DPDocMap.get(BU.id));
SRDoc1.Doc_URL__c=dpurl;
SRDoc1.NSIBPM__Document_Master__c=DocMap.get('DP_INVOICE');
SRDoc1.name=BU.Registration_ID__c+'-'+DocNameMap.get(dpid);
SRDoc1.NSIBPM__Is_Not_Required__c=true;
SRDoc1.NSIBPM__Status__c='Generated';
SRDoc1.IPMS_Document_ID__c=dpid;//DPDocMap.get(BU.id);
SRDocList.add(SRDoc1);
}*/
                    for(integer i=0;i<doclist.size();i++){            
                        if(DocStatusMap.get(doclist[i])=='S'){ 
                            NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
                            SRDoc.NSIBPM__Service_Request__c=BU.Booking__r.Deal_SR__c;
                            SRDoc.Booking_Unit__c=BU.id;
                            SRDoc.Doc_URL__c=UrlMap.get(doclist[i]);
                            //SRDoc.NSIBPM__Document_Master__c=DM.id;
                            SRDoc.name=BU.Registration_ID__c+'-'+ DocNameMap.get(doclist[i]);
                            if(SRDoc.name.contains('SPA'))
                                SRDoc.NSIBPM__Document_Master__c=DocMap.get('SPA');
                            else if(SRDoc.name.contains('DP'))
                                SRDoc.NSIBPM__Document_Master__c=DocMap.get('DP_INVOICE');
                            SRDoc.NSIBPM__Status__c='Generated';
                            SRDoc.NSIBPM__Is_Not_Required__c=true;
                            SRDoc.IPMS_Document_ID__c=doclist[i];
                            SRDocList.add(SRDoc);
                        }
                        else{
                            failedBus.add(BU.id);
                            Log__c objLog = new Log__c();
                            objLog.Description__c ='Ids=='+BU.id+'--'+DocNameMap.get(doclist[i])+'===>'+DocStatusmsgMap.get(doclist[i]);
                            objLog.Type__c = 'Error updating response for SPA Generation';
                            insert objLog; 
                        }
                        
                    }   
                }
                
                update BUlist;
                //Update SR Banner
                if(failedBus.size()>0 ){
                    list<id> srids = new list<id>();
                    system.debug(failedBus+'BUids>>>>>>');
                    list<booking_unit__c> bus = [select id,SR_Id__c from booking_unit__c where id in:failedBus];
                    system.debug(bus +'>>>>>>>>>');
                    for(booking_unit__c bu:bus){
                        srids.add(bu.SR_Id__c);
                    }
                    system.debug(srids);
                    list<NSIBPM__Service_Request__c> srToUpdate = [select id from NSIBPM__Service_Request__c where ID in:srids];
                    for(NSIBPM__Service_Request__c sr:srToUpdate){
                        sr.SPA_Generation_Status__c = label.SPA_Error_Message;
                    }
                    update srToUpdate;
                }
                //
                if(SRDocList.size()>0){
                    system.debug('SRDOCList===='+SRDocList);
                    upsert SRDocList IPMS_Document_ID__c;
                    Id srstatus=[select id,NSIBPM__Code__c from NSIBPM__SR_Status__c where NSIBPM__Code__c='AGREEMENT_GENERATED'].id;
                    
                    List<id> AllBuids= new List<id>();
                    Integer SPACount=0;
                    for(Booking_Unit__c BU : [select id, Booking__c,Booking__r.Deal_SR__c,(select id,name,NSIBPM__Document_Master__c,Booking_Unit__c from SR_Docs__r where Docs_Sent__c = false AND NSIBPM__Document_Master__c= :DocMap.get('SPA') limit 1) from Booking_Unit__c where Status__c!='Removed' and Booking__r.Deal_SR__c =:BUlist[0].Booking__r.Deal_SR__c]){
                        AllBuids.add(BU.id);
                        BookingIds.add(BU.Booking__c);
                        system.debug('BU'+BU.id+'---SPACount==='+BU.SR_Docs__r.size());
                        SPACount+=BU.SR_Docs__r.size();
                    }
                    
                    
                    system.debug('BUCount==='+AllBuids.size());
                    system.debug('SPACount==='+SPACount);
                    
                    
                    
                    NSIBPM__Service_Request__c SR =[select id,SPA_Generation_Status__c ,Delivery_Mode__c,NSIBPM__Internal_SR_Status__c,NSIBPM__External_SR_Status__c,NSIBPM__Internal_SR_Status__r.NSIBPM__Code__c from NSIBPM__Service_Request__c where id= :BUlist[0].Booking__r.Deal_SR__c];
                    if(AllBUids.size()==SPACount){
                        if(SR.NSIBPM__Internal_SR_Status__r.NSIBPM__Code__c=='TOKEN_DEPOSIT_PAID'||SR.NSIBPM__Internal_SR_Status__r.NSIBPM__Code__c=='MANAGER_APPROVED'){
                            //Updating SR Status
                            SR.NSIBPM__Internal_SR_Status__c=srstatus;
                            SR.NSIBPM__External_SR_Status__c=srstatus;
                            SR.SPA_Generation_Status__c = null;
                            update SR;                  
                            
                            //Invoking the webservice to update status in IPMS
                            if(BookingIds.size()>0)
                                system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'StatusUpdate'));
                        }
                        //Emailing the SPAs to the primary buyers of the Delivery Mode is Email
                        if(SR.Delivery_Mode__c =='Email'){
                            //Id SRid=BUlist[0].Booking__r.Deal_SR__c;
                            //Id StepId='';
                            system.debug('SRIDDD==='+SR.id);
                            if(SR.id!=null){
                                NSIBPM__Step__c Step;
                                for(NSIBPM__Step__c thisStep : [select id from NSIBPM__Step__c where NSIBPM__Step_Template__r.NSIBPM__Code__c='SEND_DOCS' and NSIBPM__SR__c=:SR.id]){ //and Is_Closed__c=false 
                                    Step = thisStep;
                                    break;
                                }       
                                if(Step != null){                     
                                    SendEmailtoPB.sendEmailtoPB(SR.id,Step.id);
                                }
                                
                                List<NSIBPM__SR_Doc__c> SentSRDocList =[select id,name,Docs_Sent__c,NSIBPM__Document_Master__c,NSIBPM__Document_Master__r.Promotion_Letter__c ,Booking_Unit__c from NSIBPM__SR_Doc__c where Booking_Unit__c != null and Docs_to_be_sent__c = true and NSIBPM__Service_Request__c =:SR.id];
                                if(SentSRDocList.size()>0){
                                    for(NSIBPM__SR_Doc__c SRDoc : SentSRDocList){
                                        if(SRDoc.NSIBPM__Document_Master__r.Promotion_Letter__c==false)
                                            SRDoc.Docs_Sent__c=true;
                                    }
                                    update SentSRDocList;
                                }
                            }                           
                            
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+BUList+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for SPA Generation';
            insert objLog;
            
                //Update SR Banner
                if(BUids.size()>0 ){
                    list<id> srids = new list<id>();
                    system.debug(BUList+'BUids>>>>>>');
                    list<booking_unit__c> bus = [select id,SR_Id__c from booking_unit__c where id in:BUList];
                    system.debug(bus +'>>>>>>>>>');
                    for(booking_unit__c bu:bus){
                        srids.add(bu.SR_Id__c);
                    }
                    system.debug(srids);
                    list<NSIBPM__Service_Request__c> srToUpdate = [select id from NSIBPM__Service_Request__c where ID in:srids];
                    for(NSIBPM__Service_Request__c sr:srToUpdate){
                        sr.SPA_Generation_Status__c = label.SPA_Error_Message;
                    }
                    update srToUpdate;
                }
        }    
    }
    
    /*************************************************************************************************************************/
    /****************************************Payment plan Update*********************************************************/
    /**********************Preparing the request body for the payment plan update request*********************************/
    public static string PreparePayPlan(List<id> regids){
        
        string PayQuery = getCreatableFieldsSOQL('Payment_Terms__c');
        PayQuery=PayQuery.remove('FROM Payment_Terms__c');
        PayQuery+=',Payment_Plan__r.Booking_Unit__r.Registration_ID__c,Payment_Plan__r.Booking_Unit__r.Booking__c,Payment_Plan__r.Parent_Payment_Plan__r.TERM_ID__c';
        PayQuery+=' FROM Payment_Terms__c where Payment_Plan__r.Booking_Unit__r.Booking__c in :regids';
        List<Payment_Terms__c> Paylist= database.query(PayQuery); 
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>1234567</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>INS_UPD_PAYMENT_PLAN</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Payment_Terms__c PT :Paylist){
            //<!--Zero or more repetitions:-->
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            //<!--Mandatory:-->
            body+='<proc:PARAM_ID>'+PT.id+'</proc:PARAM_ID>';
            //<!--Registration Id Mandatory:-->
            body+='<proc:ATTRIBUTE1>'+PT.Payment_Plan__r.Booking_Unit__r.Registration_ID__c+'</proc:ATTRIBUTE1>';
            //<!--Term Id : Mandatory:-->
            body+='<proc:ATTRIBUTE2>'+PT.Payment_Plan__r.Parent_Payment_Plan__r.TERM_ID__c+'</proc:ATTRIBUTE2>';
            //<!--Term Line Id - Mandatory for Update, Null otherwise:-->
            body+='<proc:ATTRIBUTE3>'+PT.Line_ID__c+'</proc:ATTRIBUTE3>';
            //<!--P_INSTALLMENT:-->
            body+='<proc:ATTRIBUTE4>'+PT.Installment__c+'</proc:ATTRIBUTE4>';
            //<!--P_PERCENT_VALUE:-->
            body+='<proc:ATTRIBUTE5>'+PT.Percent_Value__c+'</proc:ATTRIBUTE5>';
            //<!--P_PAYMENT_DATE (DD-MON-YYYY):-->
            String pdate='';
            if(PT.Payment_Date__c!=null){
                pdate=GetDatetext(PT.Payment_Date__c);
                body+='<proc:ATTRIBUTE6>'+pdate+'</proc:ATTRIBUTE6>';
            }                                                      
            //<!--P_EXPECTED_DATE (DD-MON-YYYY):-->
            String exdate='';
            if(PT.Expected_Date__c!=null){
                exdate=GetDatetext(PT.Expected_Date__c);
                body+='<proc:ATTRIBUTE7>'+exdate+'</proc:ATTRIBUTE7>';
            }
            
            //<!--P_MILESTONE_EVENT:-->
            body+='<proc:ATTRIBUTE8>'+PT.Milestone_Event__c+'</proc:ATTRIBUTE8>';
            //<!--P_MILESTONE_EVENT_ARABIC:-->
            body+='<proc:ATTRIBUTE9>'+PT.Milestone_Event_Arabic__c+'</proc:ATTRIBUTE9>';
            //<!--P_PAYMENT_AMOUNT:-->
            body+='<proc:ATTRIBUTE10>'+PT.Payment_Amount__c+'</proc:ATTRIBUTE10>';
            //<!--P_DESCRIPTION:-->
            body+='<proc:ATTRIBUTE11>'+PT.Description__c+'</proc:ATTRIBUTE11>';
            //<!--P_EVENT_DAYS:-->
            body+='<proc:ATTRIBUTE12>'+PT.Event_Days__c+'</proc:ATTRIBUTE12>';
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
            
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the payment plan update*********************************/
    webservice static void SendPaymentPlan(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = PreparePayPlan(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parsePaymentPlanResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Payment Plan';
                insert objLog;             
            }   
        } 
    }
    
    /**********************Parsing the response received for PaymentPlan request*********************************/
    
    public static void parsePaymentPlanResponse(string body){
        
        string regId,buids,BUid,status,lineid,ptid = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        Map<string,String> LineMap = new Map<string,string>();
        Map<string,String> StatusMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getText());
                            if(child5.getName()=='PARAM_ID') 
                                PTid=child5.getText();                       
                            if(child5.getName()=='ATTRIBUTE1') 
                                lineid= child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                                status= child5.getText(); 
                        }  
                        LineMap.put(ptid,lineid);
                        StatusMap.put(ptid,status);  
                    }
                }
            }
        }
        
        List<Payment_Terms__c> PTList =[select id,Line_ID__c,IPMS_Status__c from Payment_Terms__c where id in :LineMap.keyset()];
        for(Payment_Terms__c PT :PTList){
            PT.Line_ID__c=LineMap.get(PT.id);
            PT.IPMS_Status__c=StatusMap.get(PT.id);
        }
        update PTList;
    }
    /*************************************************************************************************************************/
    /****************************************Statement of Account Creation Start*********************************************************/
    /**********************Preparing the request body for the SOA request*********************************/
    public static string invokeSOA(List<id> regids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where Booking__c in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='SOA-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>DP_SOA</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU :BUlist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            body+='<proc:PARAM_ID>'+BU.id+'</proc:PARAM_ID>';
            //body+='<proc:ATTRIBUTE1>'+BU.SOA_Stage_Id__c+'</proc:ATTRIBUTE1>'; 
            body+='<proc:ATTRIBUTE1></proc:ATTRIBUTE1>'; // Not Passing this as User Always requests a Fresh Copy of SOA May 28 2017
            body+='<proc:ATTRIBUTE2></proc:ATTRIBUTE2>'; //******
            body+='<proc:ATTRIBUTE3>'+BU.Registration_ID__c+'</proc:ATTRIBUTE3>';
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the SOA generation*********************************/
    webservice static void invokeSOAGeneration(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = invokeSOA(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseSOAResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For SOA Generation';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for SOA request*********************************/
    
    public static void parseSOAResponse(string body){
        
        string reqId,BUid,status,statusmsg,stageId,doclist = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        Map<string,String> DocMap = new Map<string,string>();
        List<String> BUids = new List<String>();
        Map<string,String> StageMap = new Map<string,string>();
        Map<string,String> StatusMap = new Map<string,string>();
        Map<string,String> ReqMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                                BUid=child5.getText();
                            BUids.add(BUid);                            
                            if(child5.getName()=='ATTRIBUTE1') 
                                doclist= child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                                reqId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE3') 
                                stageId= child5.getText();
                            if(child5.getName()=='PROC_STATUS')
                                status=child5.getText(); 
                            if(child5.getName()=='PROC_MESSAGE')
                                statusmsg=child5.getText();                            
                            
                        }  
                        StatusMap.put(BUid,statusmsg); 
                        if(status=='S'){
                            DocMap.put(BUid,doclist); 
                            StageMap.put(BUid,stageId);
                            ReqMap.put(BUid,reqId);
                            
                        }
                    }
                }
            }
        }
        
        NSIBPM__Document_Master__c DM = [select id,NSIBPM__Code__c from NSIBPM__Document_Master__c where NSIBPM__Code__c ='SOA'];
        //List<String> docs = doclist.split('*');
        List<Booking_Unit__c> BUlist= [select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,SOA_Request_ID__c,SOA_Stage_Id__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id in:BUids];
        if(BUList.size()>0){
            for(Booking_Unit__c BU :BUlist){
                if(DocMap.get(BU.id)!=null){
                    NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
                    SRDoc.NSIBPM__Service_Request__c=BU.Booking__r.Deal_SR__c;
                    SRDoc.Booking_Unit__c=BU.id;
                    SRDoc.Doc_URL__c=DocMap.get(BU.id);
                    SRDoc.NSIBPM__Document_Master__c=DM.id;
                    SRDoc.name=BU.Registration_ID__c+'- SOA';
                    SRDoc.NSIBPM__Status__c='Generated';
                    SRDoc.NSIBPM__Is_Not_Required__c=true;
                    SRDocList.add(SRDoc);
                }
                BU.SOA_Request_ID__c=ReqMap.get(BU.id);
                BU.SOA_Stage_Id__c=StageMap.get(BU.id);
                BU.IPMS_Status__c=StatusMap.get(BU.id);
            }
            update BUlist;
            
            if(SRDocList.size()>0)
                insert SRDocList; 
        }
    }
    
    /*************************************************************************************************************************/
    /****************************************Registration Updation*********************************************************/
    /**********************Preparing the request body for the registration update request*********************************/
    public static string prepareRegnUpdate(List<id> regids,String UpdType){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where Booking__c in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='UpdReg-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        List<Id>SRIds = new List<Id>();
        for(Booking_Unit__c BU : BUlist){
            SRIds.add(BU.SR_Id__c);
        }
        
        Integer LXcount=0;
        if(UpdType=='STATUS_UPDATE')
            LXcount=[select count() from NSIBPM__Step__c where NSIBPM__Step_Template__r.NSIBPM__Code__c='SPA_EXECUTION' and Is_Closed__c=false and NSIBPM__SR__c in :SRIds];
        
        
        string PCId,DOSId,HOSId,HODId,SalesOffice='';
        PCId='53580';
        DOSId='53058';
        HOSId='53561';
        HODId='249';
        SalesOffice='PARK-TOWER';
        /*
List<Deal_Team__c> dealteamlist = [select id,Associated_Deal__c,Associated_PC__r.IPMS_Employee_ID__c,Associated_DOS__r.IPMS_Employee_ID__c,Associated_HOS__r.IPMS_Employee_ID__c,Associated_HOD__r.IPMS_Employee_ID__c,User_Sales_Office__c from Deal_Team__c where Associated_Deal__c in :SRIds];

for(Deal_Team__c DT :dealteamlist ){

PCId=DT.Associated_PC__r.IPMS_Employee_ID__c;
SalesOffice=DT.User_Sales_Office__c;           
DOSId=DT.Associated_DOS__r.IPMS_Employee_ID__c;            
HOSId=DT.Associated_HOS__r.IPMS_Employee_ID__c;            
HODId=DT.Associated_HOD__r.IPMS_Employee_ID__c;

}*/
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>UPDATE_REGISTRATION</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU :BUlist){
            String vendorid,docok,delmode,callok,status='';
            if(UpdType=='AGENT_UPDATE')
                vendorid=BU.Vendor_ID__c;
            else if (UpdType=='DOC_OK'){
                if(BU.Doc_OK__c)
                    docok='Y';
                else
                    docok='N';
            }
            else if(UpdType=='DISPATCH_MODE')
                delmode=BU.Delivery_Mode__c;
            else if(UpdType=='BOOKING_CANCELLATION' || UpdType=='STATUS_UPDATE'){
                if(LXCount==0)
                    status=BU.SR_Status_Code__c;
                else
                    status='LX';
            }    
            else if (UpdType=='CALL_GENERATION')
                callok='Y';  
            
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            body+='<proc:PARAM_ID>'+BU.id+'</proc:PARAM_ID>';                            
            body+='<proc:ATTRIBUTE1>'+BU.Registration_ID__c+'</proc:ATTRIBUTE1>';
            body+='<proc:ATTRIBUTE2>'+UpdType+'</proc:ATTRIBUTE2>';
            body+='<proc:ATTRIBUTE3>'+docok+'</proc:ATTRIBUTE3>';
            body+='<proc:ATTRIBUTE4>'+vendorid+'</proc:ATTRIBUTE4>';
            body+='<proc:ATTRIBUTE5>'+delmode+'</proc:ATTRIBUTE5>';
            body+='<proc:ATTRIBUTE6>'+status+'</proc:ATTRIBUTE6>';
            if(UpdType=='CHANGE_PC'){
                body+='<proc:ATTRIBUTE7>'+PCId+'</proc:ATTRIBUTE7>';
                body+='<proc:ATTRIBUTE8>'+DOSId+'</proc:ATTRIBUTE8>';
                body+='<proc:ATTRIBUTE9>'+HOSId+'</proc:ATTRIBUTE9>';
                body+='<proc:ATTRIBUTE10>'+HODId+'</proc:ATTRIBUTE10>'; 
            }
            body+='<proc:ATTRIBUTE11>'+callok+'</proc:ATTRIBUTE11>';
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for Registration Updation*********************************/
    webservice static void sendRegnUpdate(List<id> regids,String UpdType){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareRegnUpdate(regids,UpdType);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseRegnUpdateResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c =UpdType+'--Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Registration Updation';
                insert objLog;             
            }    
        }
    }
    
    /**********************Parsing the response received for Registration Update request*********************************/
    
    public static void parseRegnUpdateResponse(string body){
        
        string reqId,BUid,status,stageId,doclist = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        
        List<String> BUids = new List<String>();
        Map<string,String> StatusMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                                BUid=child5.getText();
                            BUids.add(BUid);   
                            if(child5.getName()=='PROC_MESSAGE')
                                status=child5.getText();                             
                            
                        }                          
                        Statusmap.put(BUid,status);                        
                        
                    }
                }
            }
        }
        
        
        List<Booking_Unit__c> BUlist= [select id,Booking__c,SR_Status_Code__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,SOA_Request_ID__c,SOA_Stage_Id__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id in:Statusmap.keyset()];
        if(BUList.size()>0){
            for(Booking_Unit__c BU :BUlist){     
                BU.IPMS_Status__c='Status Update -'+BU.SR_Status_Code__c+'-'+StatusMap.get(BU.id);                
            }
            update BUlist;
        }
        
    }
    
    /*************************************************************************************************************************/
    /****************************************Attachment API*********************************************************/
    /**********************Preparing the request body for the attachment api request*********************************/
    public static string prepareAttachDoc(List<id> SRids,String UpdType){
        
        string SRDOCQuery = getCreatableFieldsSOQL('NSIBPM__SR_Doc__c');
        SRDOCQuery=SRDOCQuery.remove('FROM NSIBPM__SR_Doc__c');
        SRDOCQuery+=',NSIBPM__Service_Request__r.name,Buyer__r.Party_ID__c,Buyer__r.Primary_Buyer__c,NSIBPM__Document_Master__r.NSIBPM__Code__c';
        SRDOCQuery+=' FROM NSIBPM__SR_Doc__c where Buyer__r.Primary_Buyer__c =true AND NSIBPM__Status__c = \'Uploaded\' AND NSIBPM__Service_Request__c in :SRids';
        List<NSIBPM__SR_Doc__c> SRDoclist= database.query(SRDOCQuery); 
        system.debug('SRDOCs==='+SRDoclist);
        
        String reqno='123456';
        if(SRDoclist.size()>0)
            reqno ='Att-'+SRDoclist[0].NSIBPM__Service_Request__r.name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        List<id>SRDOCIds = new List<id>();
        for(NSIBPM__SR_Doc__c SRDoc :SRDoclist){
            SRDOCIds.add(SRDoc.NSIBPM__Doc_ID__c);
        }
        system.debug('SRDOCIdss==='+SRDOCIds);
        
        //Getting the attachments related to the SR Docs
        String AttQuery= getCreatableFieldsSOQL('Attachment');
        AttQuery+=' where id in :SRDOCIds';
        system.debug('AttQuery==='+attQuery);
        List<Attachment> Attachlist= database.query(AttQuery); 
        Map<id,String>FileMap = new Map<id,String>();
        for(Attachment att :Attachlist){
            FileMap.put(att.id,att.name);
        }
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>ATTACH_DOC_IN_EBS</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(NSIBPM__SR_Doc__c SRDoc :SRDoclist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            //<!--Mandatory:Source System ID-->
            body+='<proc:PARAM_ID>'+SRDoc.id+'</proc:PARAM_ID>';
            //<!--Mandatory:Primary Key Depending on the Entity-->
            body+='<proc:ATTRIBUTE1>'+SRDoc.Buyer__r.Party_ID__c+'</proc:ATTRIBUTE1>'; 
            //<!--Mandatory: eBS Entity Name Should be Defined to eBS-->
            body+='<proc:ATTRIBUTE2>Parties</proc:ATTRIBUTE2>';
            String filecat='Others';
            if(SRDOC.NSIBPM__Document_Master__r.NSIBPM__Code__c =='EMIRATES_ID_COPY') {
                if(SRDOc.Buyer__r.Primary_Buyer__c)
                    filecat='National ID';
                else
                    filecat='JB National ID';
            }
            else if(SRDOC.NSIBPM__Document_Master__r.NSIBPM__Code__c =='PASSPORT_NID_COPY'){
                if(SRDOc.Buyer__r.Primary_Buyer__c)
                    filecat='Passport';
                else
                    filecat='JB Passport';  
            }  
            filecat=
                //<!--Mandatory:File Category (Should be Defined to eBS)-->
                body+='<proc:ATTRIBUTE3>'+filecat+'</proc:ATTRIBUTE3>';
            //<!--Mandatory: Source file id-->
            body+='<proc:ATTRIBUTE4>'+SRDoc.name+'</proc:ATTRIBUTE4>';
            //<!--Mandatory:File Name Which is moved to eBS folder-->
            body+='<proc:ATTRIBUTE5>'+FileMap.get(SRDoc.NSIBPM__Doc_ID__c)+'</proc:ATTRIBUTE5>';
            //<!--Mandatory:File Description (Purpose of file)-->
            body+='<proc:ATTRIBUTE6>'+SRDoc.name+' </proc:ATTRIBUTE6>';
            //<!--Mandatory:File name in Source system-->
            body+='<proc:ATTRIBUTE7>'+FileMap.get(SRDoc.NSIBPM__Doc_ID__c)+'</proc:ATTRIBUTE7>';
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for Attachment Doc*********************************/
    webservice static void sendAttachDoc(List<id> SRids,String UpdType){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareAttachDoc(SRids,UpdType);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseAttachDocResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c =UpdType+'--Ids=='+SRids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Attachment API';
                insert objLog;             
            }   
        } 
    }
    
    /**********************Parsing the response received for Attachment Doc request*********************************/
    
    public static void parseAttachDocResponse(string body){
        
        string docid,reqId,BUid,status,stageId,doclist = '';
        Map<string,String> StatusMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                                docid=child5.getText();                            
                            if(child5.getName()=='PROC_MESSAGE')
                                status=child5.getText();                             
                            
                        }                          
                        Statusmap.put(docid,status);                        
                        
                    }
                }
            }
        }
        
        
        List<NSIBPM__SR_Doc__c> SRDocList= [select id,IPMS_Status__c from NSIBPM__SR_Doc__c where id in:Statusmap.keyset()];
        if(SRDocList.size()>0){
            for(NSIBPM__SR_Doc__c SRDoc :SRDoclist){     
                SRDoc.IPMS_Status__c=StatusMap.get(SRDoc.id);                
            }
            update SRDocList;
        }
    }    
    
    /*************************************************************************************************************************/
    /****************************************Receipt Doc creation Start*********************************************************/
    /**********************Preparing the request body for the receipt doc request*********************************/
    public static string prepareReceiptDoc(List<id> regids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where id in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='RecDoc-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>GENERATE_DP_RECEIPT</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU :BUlist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            body+='<proc:PARAM_ID>'+BU.id+'</proc:PARAM_ID>';
            body+='<proc:ATTRIBUTE1>'+BU.Receipt_Stage_Id__c+'</proc:ATTRIBUTE1>'; 
            body+='<proc:ATTRIBUTE2></proc:ATTRIBUTE2>'; //******
            body+='<proc:ATTRIBUTE3>'+BU.Receipt_ID__c+'</proc:ATTRIBUTE3>';
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the Receipt Doc generation*********************************/
    webservice static void sendReceiptDoc(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareReceiptDoc(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseReceiptDocResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Receipt Doc Generation';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for Receipt Doc request*********************************/
    
    public static void parseReceiptDocResponse(string body){
        
        string recid,reqId,BUid,status,statusmsg,stageId,docurl = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        Map<string,String> DocMap = new Map<string,string>();
        List<String> BUids = new List<String>();
        Map<string,String> StageMap = new Map<string,string>();
        Map<string,String> StatusMap = new Map<string,string>();
        Map<string,String> ReqMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                                BUid=child5.getText();                                                       
                            if(child5.getName()=='ATTRIBUTE1') 
                                docurl= child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                                reqId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE3') 
                                stageId= child5.getText();
                            if(child5.getName()=='PROC_STATUS')
                                status=child5.getText(); 
                            if(child5.getName()=='PROC_MESSAGE')
                                statusmsg=child5.getText();                            
                            
                        }  
                        StatusMap.put(BUid,statusmsg); 
                        if(status=='S'){
                            DocMap.put(BUid,docurl); 
                            StageMap.put(BUid,stageId);
                            ReqMap.put(BUid,reqId);
                            
                        }
                    }
                }
            }
        }
        
        //NSIBPM__Document_Master__c DM = [select id,NSIBPM__Code__c from NSIBPM__Document_Master__c where NSIBPM__Code__c ='SOA'];
        //List<String> docs = doclist.split('*');
        try{
            List<Booking_Unit__c> BUlist= [select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,Receipt_Stage_Id__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id in:StatusMap.keyset()];
            
            if(BUlist.size()>0){
                for(Booking_Unit__c BU :BUlist){
                    if(DocMap.get(BU.id)!=null){
                        NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
                        SRDoc.NSIBPM__Service_Request__c=BU.Booking__r.Deal_SR__c;
                        SRDoc.Booking_Unit__c=BU.id;
                        SRDoc.Doc_URL__c=DocMap.get(BU.id);
                        //SRDoc.NSIBPM__Document_Master__c=DM.id;
                        SRDoc.name=BU.Registration_ID__c+'- Receipt Document';
                        SRDoc.NSIBPM__Status__c='Generated';
                        SRDoc.NSIBPM__Is_Not_Required__c=true;
                        SRDocList.add(SRDoc);
                    }
                    //Rec.EBS_Request_ID__c=ReqMap.get(Rec.id);
                    BU.Receipt_Stage_Id__c=StageMap.get(BU.id);
                    BU.IPMS_Status__c='Receipt Doc Gen--'+StatusMap.get(BU.id);
                }
                update BUlist;
                
                if(SRDocList.size()>0)
                    insert SRDocList; 
            }
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+StatusMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for receipt doc';
            insert objLog;             
        }    
    }
    
    /*************************************************************************************************************************/
    /****************************************Tbits file creation Start*********************************************************/
    /**********************Preparing the request body for the tbits file request*********************************/
    public static string prepareTbitsrequest(List<id> regids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where id in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='Tbits-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>GET_TBITS_FILE</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU :BUlist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            body+='<proc:PARAM_ID>'+BU.id+'</proc:PARAM_ID>';
            body+='<proc:ATTRIBUTE1>'+BU.Registration_ID__c+'</proc:ATTRIBUTE1>';                             
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the Tbits file generation*********************************/
    webservice static void sendTbitsrequest(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareTbitsrequest(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseTbitsResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Tbits Generation';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for Tbits request*********************************/
    
    public static void parseTbitsResponse(string body){
        
        string BUid,status,statusmsg,docid,docname,docurl = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        Map<string,String> DocMap = new Map<string,string>();
        Map<string,String> UrlMap = new Map<string,string>();
        List<String> doclist = new List<String>(); 
        List<String> BUids = new List<String>();       
        Map<string,String> StatusMap = new Map<string,string>();
        
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    System.debug('>>>>>>>>child3>>>>>>'+child3.getName());
                    System.debug('>>>>>>>>child3>>>>>>'+child3.getText());
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getText());
                            if(child5.getName()=='PARAM_ID'){ 
                                BUid=child5.getText();  
                                BUids.add(BUid);
                            }                                                      
                            if(child5.getName()=='ATTRIBUTE1') 
                                docname= child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                                docurl= child5.getText();
                            if(child5.getName()=='ATTRIBUTE3') 
                                docid= child5.getText();
                            
                        } 
                        doclist.add(docid);
                        DocMap.put(docid,docname); 
                        UrlMap.put(docid,docurl);
                    }
                    if(child3.getName()=='X_RETURN_MESSAGE')
                        statusmsg=child3.getText();
                    if(child3.getName()=='X_RETURN_STATUS')
                        status=child3.getText(); 
                    StatusMap.put(BUid,statusmsg);
                }
            }
        }
        
        //NSIBPM__Document_Master__c DM = [select id,NSIBPM__Code__c from NSIBPM__Document_Master__c where NSIBPM__Code__c ='SOA'];
        //List<String> docs = doclist.split('*');
        
        try{
            Booking_Unit__c BU= [select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,SOA_Request_ID__c,SOA_Stage_Id__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id =:BUids[0]];
            for(integer i=0;i<doclist.size();i++){            
                
                NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
                SRDoc.NSIBPM__Service_Request__c=BU.Booking__r.Deal_SR__c;
                SRDoc.Booking_Unit__c=BU.id;
                SRDoc.Doc_URL__c=UrlMap.get(doclist[i]);
                //SRDoc.NSIBPM__Document_Master__c=DM.id;
                SRDoc.name=BU.Registration_ID__c+'-'+ DocMap.get(doclist[i]);
                SRDoc.NSIBPM__Status__c='Generated';
                SRDoc.NSIBPM__Is_Not_Required__c=true;
                SRDocList.add(SRDoc);
                
            }       
            BU.IPMS_Status__c='Tbits file -'+StatusMap.get(BU.id);
            update BU;
            
            if(SRDocList.size()>0)
                insert SRDocList; 
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+BUid+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for tbits file';
            insert objLog;             
        }    
        
    }
    
    /*************************************************************************************************************************/
    /****************************************Joint Buyer Service*********************************************************/
    /**********************Preparing the request body for the joint buyer request*********************************/
    public static string prepareJBrequest(List<id> regids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where Booking__c in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='JB-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        List<Id>SRIds = new List<Id>();
        for(Booking_Unit__c BU : BUlist){
            SRIds.add(BU.SR_Id__c);
        }
        List<string> statusval= new List<String>{'New','Updated','Removed'};
            string buyerQuery = getCreatableFieldsSOQL('Buyer__c');
        buyerQuery +=' where Primary_Buyer__c=false and  Is_3rd_Party__c=false and Status__c in :statusval AND  Booking__c in:regids';
        List<Buyer__c> buyerlist = database.query(buyerQuery);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>MANAGE_JB_DETAILS</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU: BUlist){
            for(Buyer__c jb :buyerlist){
                String vendorid,docok,delmode,callok,status='';
                body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                body+='<proc:PARAM_ID>'+jb.id+'</proc:PARAM_ID>';                            
                //<!--Operation (ADD,DELETE,UPDATE):-->
                string op='';
                if(jb.Status__c=='New')
                    op='ADD';
                else if(jb.Status__c=='Updated')
                    op='UPDATE';
                else if (jb.Status__c=='Removed')
                    op='DELETE';
                body+='<proc:ATTRIBUTE1>'+op+'</proc:ATTRIBUTE1>';
                //<!--ID:-->
                if(jb.IPMS_Buyer_ID__c!=null)
                    body+='<proc:ATTRIBUTE2>'+jb.IPMS_Buyer_ID__c+'</proc:ATTRIBUTE2>';
                else
                    body+='<proc:ATTRIBUTE2>'+jb.Buyer_ID__c+BU.Booking_Unit_No__c+'</proc:ATTRIBUTE2>';
                //<!--Registration ID:-->
                body+='<proc:ATTRIBUTE3>'+BU.Registration_ID__c+'</proc:ATTRIBUTE3>';
                //<!--P_JB_TITLE_EN:-->
                body+='<proc:ATTRIBUTE4>'+jb.Title__c+'</proc:ATTRIBUTE4>';
                //<!--First Name EN:-->
                if(jb.Buyer_Type__c=='Individual')
                    body+='<proc:ATTRIBUTE5>'+jb.First_Name__c+'</proc:ATTRIBUTE5>';
                else if(jb.Buyer_Type__c=='Corporate')
                    body+='<proc:ATTRIBUTE5>'+jb.Organisation_Name__c+'</proc:ATTRIBUTE5>';                                 
                
                //<!--P_JB_MIDDLE_NAME_EN:-->
                body+='<proc:ATTRIBUTE6></proc:ATTRIBUTE6>';
                //<!--P_JB_LAST_NAME_EN :-->
                body+='<proc:ATTRIBUTE7>'+jb.Last_Name__c+'</proc:ATTRIBUTE7>';
                //<!--P_JB_NATIONALITY_EN-->
                body+='<proc:ATTRIBUTE8>'+jb.NATIONALITY__c+'</proc:ATTRIBUTE8>';
                //<!--P_JB_PASSPORT_NO_EN-->
                body+='<proc:ATTRIBUTE9>'+jb.Passport_Number__c+'</proc:ATTRIBUTE9>';
                //<!--P_JB_CR_NO_EN-->
                body+='<proc:ATTRIBUTE10>'+jb.CR_Number__c+'</proc:ATTRIBUTE10>';
                //<!--P_JB_CR_REG_PLACE_EN-->
                body+='<proc:ATTRIBUTE11>'+jb.CR_Registration_Place__c+'</proc:ATTRIBUTE11>';
                String jbcrdate='';
                if(jb.CR_Registration_Expiry_Date__c!=null){
                    String[] strDate = jb.CR_Registration_Expiry_Date__c.split('/');
                    Integer myIntDate = integer.valueOf(strDate[0]);                            
                    Integer myIntMonth = integer.valueOf(strDate[1]);                           
                    Integer myIntYear = integer.valueOf(strDate[2]);                            
                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                    jbcrdate=GetDatetext(d);
                    //<!--P_JB_CR_REG_DATE_EN DD_MON-YYYY -->
                    body+='<proc:ATTRIBUTE12>'+jbcrdate+'</proc:ATTRIBUTE12>';
                }
                
                //<!--P_JB_HOME_PHONE_EN-->
                body+='<proc:ATTRIBUTE13></proc:ATTRIBUTE13>';
                //<!--P_JB_WORK_PHONE_EN -->
                body+='<proc:ATTRIBUTE14></proc:ATTRIBUTE14>';
                //<!--P_JB_MOBILE_PHONE_EN-->
                body+='<proc:ATTRIBUTE15>'+jb.Phone__c+'</proc:ATTRIBUTE15>';
                //<!--P_JB_FAX_EN :-->
                body+='<proc:ATTRIBUTE16></proc:ATTRIBUTE16>';
                //<!--P_JB_EMAIL_EN :-->
                body+='<proc:ATTRIBUTE17>'+jb.Email__c+'</proc:ATTRIBUTE17>';
                String jppdate='';
                if(jb.Passport_Expiry_Date__c!=null){
                    String[] strDate = jb.Passport_Expiry_Date__c.split('/');
                    Integer myIntDate = integer.valueOf(strDate[0]);                            
                    Integer myIntMonth = integer.valueOf(strDate[1]);                           
                    Integer myIntYear = integer.valueOf(strDate[2]);                            
                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                    jppdate=GetDatetext(d);
                    //<!--P_JB_PASSPORT_ISSUE_DATE_EN (DD-MON-YYYY)-->
                    body+='<proc:ATTRIBUTE18>'+jppdate+'</proc:ATTRIBUTE18>';
                }
                
                //<!--P_JB_PASSPORT_ISSUE_PLACE_EN-->
                body+='<proc:ATTRIBUTE19>'+jb.Place_of_Issue__c+'</proc:ATTRIBUTE19>';
                //<!--P_JB_ADDRESS1_EN-->
                body+='<proc:ATTRIBUTE20>'+jb.Address_Line_1__c+'</proc:ATTRIBUTE20>';
                //<!--P_JB_ADDRESS2_EN -->
                body+='<proc:ATTRIBUTE21>'+jb.Address_Line_2__c+'</proc:ATTRIBUTE21>';
                //<!--P_JB_ADDRESS3_EN -->
                body+='<proc:ATTRIBUTE22>'+jb.Address_Line_3__c+'</proc:ATTRIBUTE22>';
                //<!--P_JB_ADDRESS4_EN-->
                body+='<proc:ATTRIBUTE23>'+jb.Address_Line_4__c+'</proc:ATTRIBUTE23>';
                //<!--P_JB_CITY_EN:-->
                body+='<proc:ATTRIBUTE24>'+jb.City__c+'</proc:ATTRIBUTE24>';
                //<!--P_JB_ZIP_EN-->
                body+='<proc:ATTRIBUTE25></proc:ATTRIBUTE25>';
                //<!--P_JB_COUNTRY_EN-->
                body+='<proc:ATTRIBUTE26>'+jb.Country__c+'</proc:ATTRIBUTE26>';
                //<!--P_JB_TITLE_AR:-->
                body+='<proc:ATTRIBUTE27>'+jb.Title_Arabic__c+'</proc:ATTRIBUTE27>';
                //<!--P_JB_FIRST_NAME_AR:-->
                if(jb.Buyer_Type__c=='Individual')
                    body+='<proc:ATTRIBUTE28>'+jb.First_Name_Arabic__c+'</proc:ATTRIBUTE28>';
                else if(jb.Buyer_Type__c=='Corporate')
                    body+='<proc:ATTRIBUTE28>'+jb.Organisation_Name_Arabic__c+'</proc:ATTRIBUTE28>';                                
                //<!--P_JB_MIDDLE_NAME_AR:-->
                body+='<proc:ATTRIBUTE29></proc:ATTRIBUTE29>';
                //<!--P_JB_LAST_NAME_AR-->
                body+='<proc:ATTRIBUTE30>'+jb.Last_Name_Arabic__c+'</proc:ATTRIBUTE30>';
                //<!--P_JB_NATIONALITY_AR:-->
                body+='<proc:ATTRIBUTE31>'+jb.Nationality_Arabic__c+'</proc:ATTRIBUTE31>';
                //<!--P_JB_PASSPORT_NO_AR:-->
                body+='<proc:ATTRIBUTE32>'+jb.Passport_Number__c+'</proc:ATTRIBUTE32>';
                //<!--P_JB_CR_NO_AR:-->
                body+='<proc:ATTRIBUTE33>'+jb.CR_Number__c+'</proc:ATTRIBUTE33>';
                //<!--P_JB_CR_REG_PLACE_AR:-->
                body+='<proc:ATTRIBUTE34>'+jb.CR_Registration_Place_Arabic__c+'</proc:ATTRIBUTE34>';
                //<!--P_JB_CR_REG_DATE_AR (DD-MON-YYYY)-->
                body+='<proc:ATTRIBUTE35>'+jbcrdate+'</proc:ATTRIBUTE35>';
                //<!--JB_PASSPORT_ISSUE_DATE_AR(DD-MON-YYYY)-->
                body+='<proc:ATTRIBUTE36>'+jppdate+'</proc:ATTRIBUTE36>';
                //<!--P_JB_PASSPORT_ISSUE_PLACE_AR-->
                body+='<proc:ATTRIBUTE37>'+jb.Place_of_Issue_Arabic__c+'</proc:ATTRIBUTE37>';
                //<!--P_JB_ADDRESS1_AR:-->  
                body+='<proc:ATTRIBUTE38>'+jb.Address_Line_1_Arabic__c+'</proc:ATTRIBUTE38>';                          
                //<!--P_JB_ADDRESS2_AR:-->
                body+='<proc:ATTRIBUTE39>'+jb.Address_Line_2_Arabic__c+'</proc:ATTRIBUTE39>';
                //<!--P_JB_ADDRESS3_AR-->
                body+='<proc:ATTRIBUTE41>'+jb.Address_Line_3_Arabic__c+'</proc:ATTRIBUTE41>';                          
                //<!--P_JB_ADDRESS4_AR-->
                body+='<proc:ATTRIBUTE42>'+jb.Address_Line_4_Arabic__c+'</proc:ATTRIBUTE42>';                          
                //<!--P_P_JB_CITY_AR-->
                body+='<proc:ATTRIBUTE43>'+jb.City_Arabic__c+'</proc:ATTRIBUTE43>';                         
                //<!--P_JB_ZIP_AR-->    
                body+='<proc:ATTRIBUTE44></proc:ATTRIBUTE44>';                          
                //<!--OP_JB_COUNTRY_AR:-->
                body+='<proc:ATTRIBUTE45>'+jb.Country_Arabic__c+'</proc:ATTRIBUTE45>';                            
                body+='</proc:P_REQUEST_MESSAGE_ITEM>';
            }
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for Joint Buyer Request*********************************/
    webservice static void sendJBrequest(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareJBrequest(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseJBResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Joint Buyer Service';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for Joint Buyer request*********************************/
    
    public static void parseJBResponse(string body){
        
        string reqId,BUid,buyerid,status,statusmsg,stageId,doclist = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        
        List<String> BUids = new List<String>();
        Map<string,String> StatusMap = new Map<string,string>();
        Map<string,String> StatusMsgMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                                Buyerid=child5.getText();                              
                            if(child5.getName()=='PROC_STATUS')
                                status=child5.getText(); 
                            if(child5.getName()=='PROC_MESSAGE')
                                statusmsg=child5.getText(); 
                        }                          
                        Statusmap.put(buyerid,status);  
                        StatusMsgmap.put(buyerid,statusmsg);
                    }
                }
            }
        }
        try{
            List<Buyer__c> buyerlist= [select id,IPMS_Status__c,Status__c from Buyer__c where id in:StatusMap.keyset()];
            for(Buyer__c jb : buyerlist){
                if(Statusmap.get(jb.id)=='S'){
                    if(jb.Status__c=='New' ||jb.Status__c=='Updated')
                        jb.Status__c='Active';
                    else if(jb.Status__c=='Removed')
                        jb.Status__c='Inactive';
                }
                jb.IPMS_Status__c='Joint Buyer Service -'+StatusMsgMap.get(jb.id);
            }
            update buyerlist;
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+StatusMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for joint buyer service';
            insert objLog;             
        }    
        
        
    }
    /*************************************************************************************************************************/
    /****************************************Party Update Service*********************************************************/
    /**********************Preparing the request body for the part request*********************************/
    public static string preparePartyUpdate(List<id> regids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where Booking__c in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='PU-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        List<Id>SRIds = new List<Id>();
        for(Booking_Unit__c BU : BUlist){
            SRIds.add(BU.SR_Id__c);
        }
        List<string> statusval= new List<String>{'New','Updated','Removed'};
            string buyerQuery = getCreatableFieldsSOQL('Buyer__c');
        buyerQuery +=' where Primary_Buyer__c=true and Change_Count__c>0 AND  Booking__c in:regids';
        List<Buyer__c> buyerlist = database.query(buyerQuery);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>UPDATE_PARTY_DETAILS</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU: BUlist){
            for(Buyer__c PB :buyerlist){
                List<String> chglist= new List<String>();
                if(PB.Address_Changed__c)
                    chglist.add('ADDRESS_CHANGE');
                if(PB.Contact_Changed__c)
                    chglist.add('CONTACT_CHANGE'); 
                if(PB.Passport_Changed__c)
                    chglist.add('PP_CHANGE');
                if(PB.Name_Changed__c)
                    chglist.add('NAME_CHANGE');
                if(PB.Name_Passport_Changed__c)
                    chglist.add('NAME_PP_CHANGE');   
                
                //To repeat for each change type
                for(integer i=0;i<PB.Change_Count__c;i++){
                    
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                    body+='<proc:PARAM_ID>'+PB.id+'</proc:PARAM_ID>'; 
                    //PARTY ID
                    body+='<proc:ATTRIBUTE1>'+PB.Party_ID__c+'</proc:ATTRIBUTE1>';
                    //<!--Operation
                    body+='<proc:ATTRIBUTE2>'+chglist[i]+'</proc:ATTRIBUTE2>';
                    
                    String partytype='';
                    if(PB.Buyer_Type__c=='Individual')
                        partytype='PERSON';
                    else if(PB.Buyer_Type__c=='Corporate')
                        partytype='ORGANIZATION';
                    //<!--PARTY TYPE-->     
                    body+='<proc:ATTRIBUTE3>'+partytype+'</proc:ATTRIBUTE3>';
                    //<!--TITLE_EN:-->
                    body+='<proc:ATTRIBUTE4>'+PB.Title__c+'</proc:ATTRIBUTE4>';
                    //<!--First Name EN:-->
                    body+='<proc:ATTRIBUTE5>'+PB.First_Name__c+'</proc:ATTRIBUTE5>';
                    //<!--MIDDLE_NAME_EN:-->
                    body+='<proc:ATTRIBUTE6></proc:ATTRIBUTE6>';
                    //<!--LAST_NAME_EN :-->
                    body+='<proc:ATTRIBUTE7>'+PB.Last_Name__c+'</proc:ATTRIBUTE7>';
                    //Organization Name
                    body+='<proc:ATTRIBUTE8>'+PB.Organisation_Name__c+'</proc:ATTRIBUTE8>';
                    //NATIONALITY_EN-->
                    body+='<proc:ATTRIBUTE9>'+PB.NATIONALITY__c+'</proc:ATTRIBUTE9>';                               
                    //CR_NO_EN OR PASSPORT NUMBER-->
                    if(partytype=='PERSON')
                        body+='<proc:ATTRIBUTE10>'+PB.Passport_Number__c+'</proc:ATTRIBUTE10>';
                    else
                        body+='<proc:ATTRIBUTE10>'+PB.CR_Number__c+'</proc:ATTRIBUTE10>';
                    //<CR_REG_PLACE_EN OR PASSPORT ISSUE PLACE
                    if(partytype=='PERSON')
                        body+='<proc:ATTRIBUTE11>'+PB.Place_of_Issue__c+'</proc:ATTRIBUTE11>';
                    else
                        body+='<proc:ATTRIBUTE11>'+PB.CR_Registration_Place__c+'</proc:ATTRIBUTE11>';
                    String expdate='';
                    if(partytype=='PERSON'){
                        if(PB.Passport_Expiry_Date__c!=null){
                            String[] strDate = PB.Passport_Expiry_Date__c.split('/');
                            Integer myIntDate = integer.valueOf(strDate[0]);                            
                            Integer myIntMonth = integer.valueOf(strDate[1]);                           
                            Integer myIntYear = integer.valueOf(strDate[2]);                            
                            Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);                                
                            expdate=GetDatetext(d);
                            //CR_REG_DATE_EN DD_MON-YYYY  OR PASSPORT EXPIRY DATE
                            body+='<proc:ATTRIBUTE12>'+expdate+'</proc:ATTRIBUTE12>'; 
                            
                        }   
                    }   
                    else{
                        if(PB.CR_Registration_Expiry_Date__c!=null){
                            String[] strDate = PB.CR_Registration_Expiry_Date__c.split('/');
                            Integer myIntDate = integer.valueOf(strDate[0]);                            
                            Integer myIntMonth = integer.valueOf(strDate[1]);                           
                            Integer myIntYear = integer.valueOf(strDate[2]);                            
                            Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);                                
                            expdate=GetDatetext(d);
                            //CR_REG_DATE_EN DD_MON-YYYY  OR PASSPORT EXPIRY DATE
                            body+='<proc:ATTRIBUTE12>'+expdate+'</proc:ATTRIBUTE12>'; 
                            
                        }   
                    }
                    
                    //HOME_COUNTRY_CODE>';
                    body+='<proc:ATTRIBUTE13></proc:ATTRIBUTE13>';
                    //HOME_AREA_CODE>';
                    body+='<proc:ATTRIBUTE14></proc:ATTRIBUTE14>';
                    //HOME_NUMBER>';
                    body+='<proc:ATTRIBUTE15></proc:ATTRIBUTE15>';
                    //WORK_COUNTRY_CODE>';
                    body+='<proc:ATTRIBUTE16></proc:ATTRIBUTE16>';
                    //WORK_AREA_CODE>';
                    body+='<proc:ATTRIBUTE17></proc:ATTRIBUTE17>';
                    //WORK_NUMBER>';
                    body+='<proc:ATTRIBUTE18></proc:ATTRIBUTE18>';
                    List<string> codes=PB.Phone_Country_Code__c.split(': 00');                            
                    //MOBILE_COUNTRY_CODE>';  
                    body+='<proc:ATTRIBUTE19>'+codes[1]+'</proc:ATTRIBUTE19>';                          
                    //MOBILE_AREA_CODE>';
                    body+='<proc:ATTRIBUTE20></proc:ATTRIBUTE20>';
                    //MOBILE_NUMBER>';
                    body+='<proc:ATTRIBUTE21>'+PB.Phone__c+'</proc:ATTRIBUTE21>';
                    //EMAIL_EN :-->
                    body+='<proc:ATTRIBUTE22>'+PB.Email__c+'</proc:ATTRIBUTE22>';
                    /*//<!--P_JB_PASSPORT_ISSUE_DATE_EN (DD-MON-YYYY)-->
body+='<proc:ATTRIBUTE18></proc:ATTRIBUTE18>';
//<!--P_JB_PASSPORT_ISSUE_PLACE_EN-->
body+='<proc:ATTRIBUTE19>'+jb.Place_of_Issue__c+'</proc:ATTRIBUTE19>';*/
                    //ADDRESS1_EN-->
                    body+='<proc:ATTRIBUTE23>'+PB.Address_Line_1__c+'</proc:ATTRIBUTE23>';
                    //ADDRESS2_EN -->
                    body+='<proc:ATTRIBUTE24>'+PB.Address_Line_2__c+'</proc:ATTRIBUTE24>';
                    //ADDRESS3_EN -->
                    body+='<proc:ATTRIBUTE25>'+PB.Address_Line_3__c+'</proc:ATTRIBUTE25>';
                    //ADDRESS4_EN-->
                    body+='<proc:ATTRIBUTE26>'+PB.Address_Line_4__c+'</proc:ATTRIBUTE26>';
                    //CITY_EN:-->
                    body+='<proc:ATTRIBUTE27>'+PB.City__c+'</proc:ATTRIBUTE27>';
                    //STATE
                    body+='<proc:ATTRIBUTE28></proc:ATTRIBUTE28>';
                    //COUNTY
                    body+='<proc:ATTRIBUTE29></proc:ATTRIBUTE29>';
                    //PO BOX
                    body+='<proc:ATTRIBUTE30></proc:ATTRIBUTE30>';
                    //<!--P_JB_COUNTRY_EN-->
                    body+='<proc:ATTRIBUTE31>'+PB.Country__c+'</proc:ATTRIBUTE31>';
                    
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                }
            }
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for Party Update Request*********************************/
    webservice static void sendPartyUpdate(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = preparePartyUpdate(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parsePartyUpdateResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Party Update Service';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for Party Update request*********************************/
    
    public static void parsePartyUpdateResponse(string body){
        
        string reqId,BUid,buyerid,status,statusmsg,stageId,doclist = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        
        List<String> BUids = new List<String>();
        Map<string,String> StatusMap = new Map<string,string>();
        Map<string,String> StatusMsgMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                                Buyerid=child5.getText();                              
                            if(child5.getName()=='PROC_STATUS')
                                status=child5.getText(); 
                            if(child5.getName()=='PROC_MESSAGE')
                                statusmsg=child5.getText(); 
                        }                          
                        Statusmap.put(buyerid,status);  
                        StatusMsgmap.put(buyerid,statusmsg);
                    }
                }
            }
        }
        try{
            List<Buyer__c> buyerlist= [select id,Address_Changed__c,Contact_Changed__c,Name_Changed__c,Name_Passport_Changed__c,IPMS_Status__c,Passport_Changed__c,Status__c from Buyer__c where id in:StatusMap.keyset()];
            for(Buyer__c PB : buyerlist){
                if(Statusmap.get(PB.id)=='S'){
                    if(PB.Address_Changed__c)
                        PB.Address_Changed__c=false;
                    if(PB.Contact_Changed__c)
                        PB.Contact_Changed__c=false; 
                    if(PB.Passport_Changed__c)
                        PB.Passport_Changed__c=false;
                    if(PB.Name_Changed__c)
                        PB.Name_Changed__c=false;
                    if(PB.Name_Passport_Changed__c)
                        PB.Name_Passport_Changed__c=false;  
                }
                PB.IPMS_Status__c='Party Update Service -'+StatusMsgMap.get(PB.id);
            }
            update buyerlist;
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+StatusMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for Party Update service';
            insert objLog;             
        }    
        
        
    }
    
    /*************************************************************************************************************************/
    /****************************************DSR file creation Start*********************************************************/
    /**********************Preparing the request body for the DSR file request*********************************/
    public static string prepareDSRrequest(List<id> regids){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where id in :regids';
        List<Booking_Unit__c> BUlist= database.query(BUQuery); 
        
        String reqno='123456';
        if(BUlist.size()>0)
            reqno ='DSR-'+BUlist[0].name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        string body = '';
        body+= preparesoapHeader(body);            
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>GET_DSR_FILE</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';
        for(Booking_Unit__c BU :BUlist){
            body+='<proc:P_REQUEST_MESSAGE_ITEM>';
            body+='<proc:PARAM_ID>'+BU.id+'</proc:PARAM_ID>';
            body+='<proc:ATTRIBUTE1>'+BU.Registration_ID__c+'</proc:ATTRIBUTE1>';                             
            body+='</proc:P_REQUEST_MESSAGE_ITEM>';
        }
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the DSR file generation*********************************/
    webservice static void sendDSRrequest(List<id> regids){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareDSRrequest(regids);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseDSRResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For DSR Generation';
                insert objLog;             
            }   
        } 
    }
    
    /**********************Parsing the response received for DSR request*********************************/
    /* Modified this Method to parse the response for Multiple Booking units June 28 */
    public static void parseDSRResponse(string body){
        
        string BUid,status,statusmsg,reqstatusmsg,docid,docname,docurl = '';
        
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        //Map<string,String> DocMap = new Map<string,string>();
        //Map<string,String> UrlMap = new Map<string,string>();
        //List<String> doclist = new List<String>(); 
        List<String> BUids = new List<String>();       
        Map<string,String> StatusMap = new Map<string,string>();
        
        
        //
        map<string,string> docListMap = new map<string,string>();
        map<string,string> docnameMap = new map<string,string>();
        map<string,string> docurlMap = new map<string,string>();
        map<string,string> docidMap = new map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    System.debug('>>>>>>>>child3>>>>>>'+child3.getName());
                    System.debug('>>>>>>>>child3>>>>>>'+child3.getText());
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getText());
                            if(child5.getName()=='PARAM_ID'){ 
                                BUid=child5.getText();  
                                BUids.add(BUid);
                            }
                                                                                 
                            if(child5.getName()=='ATTRIBUTE1') {
                                docname= child5.getText();
                            }
                            if(child5.getName()=='ATTRIBUTE2') {
                                docurl= child5.getText();
                            }
                            if(child5.getName()=='ATTRIBUTE3') {
                                docid= child5.getText();
                            }
                            if(child5.getName()=='PROC_MESSAGE'){
                                statusmsg=child5.getText();
                            }
                            
                            docListMap.put(BUid,docid);                         
                            docnameMap.put(BUid,docname);
                            docurlMap.put(BUid,docurl);
                            docidMap.put(BUid,docid);
                            StatusMap.put(BUid,statusmsg);
                            system.debug(docListMap+'docListMap>>>>');
                            system.debug(docnameMap+'docListMap>>>>');
                            system.debug(docurlMap+'docurlMap>>>');
                            system.debug(docidMap+'docidMap>>>');
                            system.debug(StatusMap+'StatusMap>>>');
                        } 
                        
                        /*
                        doclist.add(docid);
                        DocMap.put(docid,docname); 
                        UrlMap.put(docid,docurl);
                        */
                        
                        
                    }
                    if(child3.getName()=='X_RETURN_MESSAGE')
                        reqstatusmsg=child3.getText();
                    if(child3.getName()=='X_RETURN_STATUS')
                        status=child3.getText(); 
                    
                }
            }
        }
        
        //NSIBPM__Document_Master__c DM = [select id,NSIBPM__Code__c from NSIBPM__Document_Master__c where NSIBPM__Code__c ='SOA'];
        //List<String> docs = doclist.split('*');
        
        try{
            //Booking_Unit__c BU= [select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,SOA_Request_ID__c,SOA_Stage_Id__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id =:BUids[0]];
            list<Booking_Unit__c> BUs = [select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,SOA_Request_ID__c,SOA_Stage_Id__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and id =:BUids];
            map<string,string> buMap = new map<string,string>();
            for(Booking_Unit__c BU:BUs){
                buMap.put(BU.id,BU.Booking__r.Deal_SR__c);
                BU.IPMS_Status__c='DSR File -'+StatusMap.get(BU.id);
            }
            
            for(Booking_Unit__c BU:BUs){          
                
                NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();                
                SRDoc.NSIBPM__Service_Request__c=buMap.get(BU.id);
                SRDoc.Booking_Unit__c=BU.id;                
                SRDoc.Doc_URL__c=docurlMap.get(BU.id);               
                SRDoc.name='DSR-'+docnameMap.get(BU.id); 
                SRDoc.NSIBPM__Status__c='Generated';
                SRDoc.NSIBPM__Is_Not_Required__c=true;
                SRDocList.add(SRDoc);
                
            }       
            
            
            
            if(SRDocList.size()>0){
                insert SRDocList; 
            }
            update BUs;
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+BUid+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for DSR file';
            insert objLog;             
        }    
        
    }
    
    /*************************************************************************************************************************/
    /****************************************Payment Plan Sync Start*********************************************************/
    /**********************Preparing the request body for the payment plan retrieve request*********************************/
    public static string prepareRetrievePayPlan(Id regid){
        
        string BUQuery = getCreatableFieldsSOQL('Booking_Unit__c');
        BUQuery+=' where id= :regid';
        Booking_Unit__c BU= database.query(BUQuery); 
        
        String reqno='123456';
        if(BU!=null)
            reqno ='PayP-'+BU.name+'-'+GetFormattedDateTime(system.now());
        system.debug('REQ NO==='+reqno);
        
        string body = '';
        body+= preparesoapHeader(body); 
        body=body.replace('/xxdc_process_service_ws/process/">','/xxdc_process_service_ws/retrieve/">');           
        body+='<soapenv:Body>';
        body+='<proc:InputParameters>';
        body+='<proc:P_REQUEST_NUMBER>'+reqno+'</proc:P_REQUEST_NUMBER>';
        body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
        body+='<proc:P_REQUEST_NAME>GET_REG_PAYMENT_TERMS</proc:P_REQUEST_NAME>';
        body+='<proc:P_REQUEST_MESSAGE>';                    
        body+='<proc:PARAM_ID>'+BU.Registration_ID__c+'</proc:PARAM_ID>';                                  
        body+='</proc:P_REQUEST_MESSAGE>';
        body+='</proc:InputParameters>';
        body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
        
    }
    /**********************Callout for the Retrieve Payment Plan request*********************************/
    webservice static void RetrievePayPlan(Id regid){
        
        getIPMSsetting('IPMS_webservice');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareRetrievePayPlan(regid);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        System.debug('>>>>>>>>reqXML>>>>>>>>'+reqXML);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
            try{
                HTTPResponse res = http.send(req);
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parsePayPlanResponse(res.getBody());
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex);
                Log__c objLog = new Log__c();
                objLog.Description__c ='Ids=='+regid+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice Callout For Retrieve Payment Plan';
                insert objLog;             
            }  
        }  
    }
    
    /**********************Parsing the response received for Receipt Doc request*********************************/
    
    public static void parsePayPlanResponse(string body){
        
        string Regid,termid,BUid,status,statusmsg,stageId,docurl = '';
        
        List<Payment_Terms__c> PTList = new List<Payment_Terms__c>();
        Map<string,String> PTMap = new Map<string,string>();
        Map<string,String> PTRegMap = new Map<string,string>();
        Map<String,Id> BookingMap = new Map<String,Id>();
        Map<String,Id> PPMap = new Map<String,Id>();
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        Payment_Terms__c PT = new Payment_Terms__c();
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());                                                                                  
                            if(child5.getName()=='ATTRIBUTE1') 
                                Regid= child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                                termid= child5.getText();
                            if(child5.getName()=='ATTRIBUTE3') 
                                PT.Line_ID__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE4') 
                                PT.Installment__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE5') 
                                PT.Percent_Value__c= child5.getText();
                            //if(child5.getName()=='ATTRIBUTE6') 
                            //PT.Payment_Date__c= child5.getText();
                            //if(child5.getName()=='ATTRIBUTE7') 
                            //PT.Expected_Date__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE8') 
                                PT.Milestone_Event__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE9') 
                                PT.Payment_Amount__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE10') 
                                PT.Description__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE11') 
                                PT.Event_Days__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE12') 
                                PT.Milestone_Event_Arabic__c= child5.getText();
                            if(child5.getName()=='ATTRIBUTE13') 
                                PT.Seq_No__c= child5.getText();                            
                        }  
                        PTList.add(PT);                           
                        PTMap.put(PT.Line_ID__c,termid);
                        PTRegMap.put(PT.Line_ID__c,regid);
                    }
                }
            }
        }
        System.debug('PTTMAPP=== '+ PTMap);
        System.debug('PTRegMap=== '+ PTRegMap);
        try{
            for(Booking_Unit__c BU :[select id, Booking__c,Booking__r.Deal_SR__c,Registration_ID__c,IPMS_Status__c,Unit_Location_ID__c from Booking_Unit__c where Status__c!='Removed' and Registration_ID__c in:PTRegMap.values()]){
                BookingMap.put(BU.Registration_ID__c,BU.id);
            }
            System.debug('Bookings=== '+ BookingMap);
            for(Payment_Plan__c PP :[select id,Parent_Payment_Plan__r.TERM_ID__c from Payment_Plan__c where Booking_Unit__r.Registration_ID__c in :PTRegMap.values() and Parent_Payment_Plan__r.TERM_ID__c in : PTMap.values() ]){
                PPMap.put(PP.Parent_Payment_Plan__r.TERM_ID__c,PP.id);
            }
            System.debug('Payplan=== '+ PPMap);
            
            //Getting the existing payment terms of the booking units and deleting them in Salesforce to reload the new records from IPMS resposne
            List<Payment_Terms__c> exPTList = [select id from Payment_Terms__c where Payment_Plan__r.Booking_Unit__r.Registration_ID__c in:PTRegMap.values()];
            delete exPTList;
            
            for(Payment_Terms__c PT :PTList){
                PT.Payment_Plan__c=PPMap.get(PTMap.get(PT.Line_ID__c));
            }
            System.debug('PayTerms=== '+ PTlist);
            upsert PTList;
            
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+PTRegMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for retrieve payment plan';
            insert objLog;             
        }    
    }
    /*******************************************************************************************************************************/
    //Generic method for fields for SOQL query
    public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                // if (fd.isCreateable()){ // field is creatable
                selectFields.add(fd.getName());
                //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
        
    }
    
    //Method to Get formatted date
    public static string GetDatetext(Date d){
        String dd,mm,mon,yy,dtext='';
        dd=string.valueof(d.day());
        mm=string.valueof(d.month());
        if(mm=='1')
            mon='JAN';
        else if(mm=='2')
            mon='FEB';
        else if(mm=='3')
            mon='MAR';
        else if(mm=='4')
            mon='APR';
        else if(mm=='5')
            mon='MAY';
        else if(mm=='6')
            mon='JUN';
        else if(mm=='7')
            mon='JUL';
        else if(mm=='8')
            mon='AUG';
        else if(mm=='9')
            mon='SEP';
        else if(mm=='10')
            mon='OCT';
        else if(mm=='11')
            mon='NOV';
        else if(mm=='12')
            mon='DEC';
        
        yy=string.valueof(d.year());
        dtext= dd+'-'+mon+'-'+yy;
        return dtext;
        
    }
    
    //Method to Get current time in a string
    public static string GetFormattedDateTime(DateTime dt){
        String yyyy=string.valueof(dt.year());
        String mm=string.valueof(dt.month());
        String dd=string.valueof(dt.day());
        String hh=string.valueof(dt.hour());
        String mi=string.valueof(dt.minute());
        String ss=string.valueof(dt.second());
        String ms=string.valueof(dt.millisecond());
        
        String formatdate=yyyy+mm+dd+hh+mi+ss+ms;
        return formatdate;
    }
    
    
}