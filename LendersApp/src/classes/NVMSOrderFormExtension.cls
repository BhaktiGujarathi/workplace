public with sharing class NVMSOrderFormExtension {
    
    public Opportunity oppObj {get;set;}
//  public String oppObj.Services__c {get;set;} 
    public Set<String> addOrderParams {get;set;}
    public Set<String> orderDetailsParams {get;set;}
    public Map<String,ServiceResponseClass> serMap {get;set;}
    public NVMSResponseClass response{get;set;}
    private Map<String,NVMS_Configuration__c> configMap {get;set;}
    
    public String getServiceBody(){
        String bodyText =   '<soap:Body>'+
                            '<ClientServicesDataSet xmlns="http://exchange2.nvms.com" />'+
                            '</soap:Body>';
        return bodyText;
    }
    public void getServiceDetails(){
        string bodyText = this.getServiceBody();
        String SOAPAction = 'ClientServicesDataSet';
        makePostCall(bodyText, SOAPAction);
    }
        
    public NVMSOrderFormExtension(ApexPages.StandardController controller) {
        
        configMap = NVMS_Configuration__c.getAll();
        NVMS_TOKEN = configMap.get('NVMS_TOKEN').value__c;
        NVMS_USER_ID = configMap.get('NVMS_USER_ID').value__c;
        END_POINT_SUFFIX = configMap.get('END_POINT_SUFFIX').value__c;
        END_POINT_URL = configMap.get('END_POINT_URL').value__c;
        CALLBACK_URL = configMap.get('CALLBACK_URL').value__c;
        
        oppObj = (Opportunity)controller.getRecord();
        response = new NVMSResponseClass();
        if(configMap.get('DEFAULT_SERVICES') != null)
            oppObj.Services__c = configMap.get('DEFAULT_SERVICES').value__c;
        if(controller.getId() != null){
            
            Set<String> fieldSet = new Set<String>();
            string queryString = 'select id,name,accountid,Services__c';
            fieldset.add('id');
            fieldset.add('name');
            fieldset.add('accountid');
            fieldset.add('services__c');
            fieldset.add('Site_Inspection_Status__c');
            for(Schema.FieldSetMember fld :SObjectType.Opportunity.fieldSets.Order_Form.getFields()) {
                if(!fieldset.contains(fld.getFieldPath())){
                    fieldset.add(fld.getFieldPath());
                    queryString += ', ' + fld.getFieldPath();
                }
            }
            queryString += ' , account.phone,(SELECT ID,ROLE,ISPRIMARY,CONTACT.EMAIL,CONTACT.HomePhone,Contact.Name from OpportunityContactRoles) from opportunity where id = \'' + oppObj.id + '\'';
            oppObj = database.query(queryString);
            
            
            for(OpportunityContactRole conObj:oppObj.OpportunityContactRoles){
                if(conObj.isPrimary){
                    oppObj.contact_name__c = conObj.contact.name;
                    oppObj.Contact_Home_Phone__c = conObj.contact.homephone;
                    oppObj.Contact_Email__c = conObj.contact.email;             
                }else if(oppObj.contact_name__c == null){
                    oppObj.contact_name__c = conObj.contact.name;
                    oppObj.Contact_Home_Phone__c = conObj.contact.homephone;
                    oppObj.Contact_Email__c = conObj.contact.email;
                }
            }
            oppObj.Work_Phone__c = oppObj.account.phone;
            if(oppObj.Services__c == null && configMap.get('DEFAULT_SERVICES') != null)
                 oppObj.Services__c = configMap.get('DEFAULT_SERVICES').value__c;
            //oppObj.Services__c = oppObj.OrderNumber__c;
        }
            serMap = new Map<String,ServiceResponseClass>();
            getServiceDetails();
            
            addOrderParams = new Set<String>{
                'PONumber',
                'FileNumber',
                'PropOwner',
                'PropAddress',
                'PropCity',
                'PropState',
                'PropZip',
                'AccContact',
                'RushStatus',
                'PONumber',
                'dbaName',
                'PropertyID',
                'BatchID',
                'PropDesc',
                'mobYear',
                'mobMake',
                'mobModel',
                'mobSerial',
                'mobLength',
                'mobWidth',
                'mobColor',
                'UnitType',
                'UnitCount',
                'HUD',
                'AccMobile',
                'AccFax',
                'AccHome',
                'AccWork',
                'AccEmail',
                'AccWeb',
                'OtherData',
                'CallbackReference',
                'AuctionDate',
                'Notes',
                'ClientHoldDate'
            };
            
            orderDetailsParams = new Set<String>{
                'OrderID',
                'ServiceID',
                'PONumber',
                'OrderPrice',
                'VendorPrice',
                'ReportHTML'
            };
        
    }
    public PageReference PopulateAddress(){
        if(oppObj.AccountId != null){
            Account accObj = [Select ID,Name,
                                        BillingStreet,
                                        BillingCity,
                                        BillingState,
                                        BillingCountry,
                                        BillingPostalCode
                                        From Account
                                        Where ID = :oppObj.AccountId];
            if(oppObj.property_address__c == null || oppObj.property_address__c.trim() == '')
                oppObj.property_address__c = accObj.billingStreet;
            if(oppObj.property_City__c == null || oppObj.property_City__c.trim() == '')
                oppObj.property_City__c = accObj.billingCity;
            if(oppObj.property_State__c == null || oppObj.property_State__c.trim() == '')
                oppObj.property_State__c = accObj.billingState;
            if(oppObj.property_Zip__c == null || oppObj.property_Zip__c.trim() == '')
                oppObj.property_Zip__c = accObj.billingPostalCode;
            if(oppObj.Contact_name__c == null || oppObj.Contact_name__c.trim() == '')
                oppObj.Contact_name__c = accObj.Name;
        }
        return null;
    }
    
    private string NVMS_TOKEN {get;set;}
    private string NVMS_USER_ID {get;set;}
    private STRING END_POINT_SUFFIX {get;set;}
    private STRING END_POINT_URL {get;set;}
    private string CALLBACK_URL {get;set;}
    
    public string getNVMSHeader(){
        String header = '<soap:Header>'+
                        '<NVMSCredentials xmlns="http://exchange2.nvms.com">'+
                            '<NVMSKey>' + NVMS_TOKEN + '</NVMSKey>'+
                        '</NVMSCredentials>' +
                    '</soap:Header>';
        return header;
    }
    public Boolean validateOrderDate(){
        response.message = null;
        if(oppObj.Services__c == null || oppObj.Services__c.trim() == '' || oppObj.Services__c.length() < 2){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Error,Label.ServiceRequiredErrorMessage));
            return false;
        }
        return true;
    }
    
    public PageReference AddOrder(){
        if(!validateOrderDate())
            return null;
        string bodyText = this.getAddOrderBody();
        String SOAPAction = 'AddNewOrder';
        
        makePostCall(bodyText, SOAPAction);
        if(response != null && (response.message == null || response.message.trim() == '')){
            return populateOpportunity();   
        }else if(response != null && (response.message != null && response.message.trim() != ''))
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Error,response.message));
        return null;
    }
    
    public PageReference populateOpportunity(){
        try{
            oppObj.StageName = Label.DefaultOpportunityStageName;
            oppObj.closeDate = System.today();
            oppObj.OrderNumber__c = response.jobId;
            oppObj.Order_Date__c = System.today();
            if(oppObj.Site_Inspection_Status__c == null)
                oppObj.Site_Inspection_Status__c = 'Pending';
            List<String> allIds=new List<String>();
            if(oppObj.Services__c != null){
                oppObj.Services__c=oppObj.Services__c.removeEnd(',');              
                allIds=oppObj.Services__c.split('\\,');
            }

            decimal totalAmount = 0;
            for(String serId:allIds){
                ServiceResponseClass serObj = serMap.get(serId);
                if(serObj.price != null)
                    totalAmount += serObj.price;
            }
            oppObj.Amount = totalAmount;
            
            upsert oppObj;
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Confirm,Label.CONFIRM_SAVE_ORDER_RECORD));
            return (new PageReference('/'+oppObj.id));
            
        }Catch(exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Error,e.getmessage()));
        }
        return null;
    }
    public PageReference AttachOrderPDFDocument(){
        Opportunity oObj = [Select id,OrderNumber__c from Opportunity where id = :oppObj.Id];
        try{
            if(oObj.OrderNumber__c == null || oObj.OrderNumber__c.trim() == ''){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Error,Label.OrderIdMissingErrorMessage));
                return null;
            }
                
            RetrieveOrderPDF(oObj.OrderNumber__c);
            if(response != null && (response.message == null || response.message.trim() == '')){
                Blob beforeblob = EncodingUtil.base64Decode(response.resultString);
                Attachment att = new Attachment();
                att.parentId = oppObj.id;
                att.name = 'Order-' + oObj.OrderNumber__c + '-' + String.valueOf(System.today()).replaceAll('-','');
                att.ContentType = 'application/pdf';
                att.Body = beforeBlob;
                insert att;
                return (new PageReference('/'+oppObj.id));
            }else if(response != null && (response.message != null && response.message.trim() != ''))
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Error,response.message));
                
        }catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Error,e.getmessage()));
        }
        return null;
    }
    public string RetrieveOrderPDF(string jobId){
        string bodyText = getRetrieveOrderPDFBody(jobId,null);
        String SOAPAction = 'RetrieveOrderPDF';
        makePostCall(bodyText, SOAPAction);
        return null;
    }
    public string getRetrieveOrderPDFBody(string jobId,string fileNumber){

        string fileNumberString = '';
        if(fileNumber != null)
            fileNumberString = '<FileNumber>' + fileNumber + '</FileNumber>';

        string bodyText = '<soap:Body>'+
                            '<RetrieveOrderPDF xmlns="http://exchange2.nvms.com">'+
                                '<NVMSJobID>' + jobId + '</NVMSJobID>'+
                                fileNumberString +      
                            '</RetrieveOrderPDF>'+
                          '</soap:Body>';
        return bodyText;
    }
    
    public class ServiceResponseClass{
        public String serviceName {get;set;}
        public String serviceId {get;set;}
        public Decimal price {get;set;}
    }
    
    public class NVMSResponseClass{
        public List<ServiceResponseClass> serList {get;set;}
        public string message {get;set;}
        public integer statusCode {get;set;}
        public string resultString {get;set;}
        public string jobId {get;set;}
    }
    
    public String getAddOrderBody(){
        
        String orderSetBody = '';
        String orderDetailsBody = '';
        Boolean isFileNumberAvailable = (configMap.get('FileNumber') != null);
        
        for(String param : addOrderParams){
            if(configMap.get(param) != null 
                        && configMap.get(param).value__c != null){
                orderSetBody += '<' + param + ' xmlns="http://exchange2.nvms.com/">' + oppObj.get(configMap.get(param).value__c) +  '</' + param + '>';
            }
        }
        /*
        for(String param:orderDetailsParams){
            if(configMap.get(param) != null 
                        && configMap.get(param).value__c != null){
                orderDetailsBody += '<' + param + ' xmlns="http://exchange2.nvms.com/">' + oppObj.get(configMap.get(param).value__c) +  '</' + param + '>';
                isFileNumberAvailable = true;
            }
        }*/
        
        List<String> allIds=new List<String>();
        if(oppObj.Services__c != null){
            oppObj.Services__c=oppObj.Services__c.removeEnd(',');              
            allIds=oppObj.Services__c.split('\\,');
        }
        for(String serId:allIds){
            orderDetailsBody += '<OrderDetails xmlns="http://exchange2.nvms.com/">'+
              '<OrderID>1</OrderID>'+
              '<ServiceID>' + serId + '</ServiceID>'+
              //'<PONumber>99802</PONumber>'+
              //'<OrderPrice>1200</OrderPrice>'+
              //'<VendorPrice>2500</VendorPrice>'+
              //'<ReportHTML></ReportHTML>'+
            '</OrderDetails>';
        }
        if(!isFileNumberAvailable){
            orderSetBody += '<FileNumber xmlns="http://exchange2.nvms.com/">ORDER_' +  System.now().getTime() + '</FileNumber>';
        //  orderDetailsBody = '<OrderDetails xmlns="http://exchange2.nvms.com/">' + orderDetailsBody + '</OrderDetails>';
        }
        orderSetBody += '<CallbackReference xmlns="http://exchange2.nvms.com/">'  + CALLBACK_URL +  '</CallbackReference>';
        String body = '<soap:Body>'+
                        '<AddNewOrder xmlns="http://exchange2.nvms.com">'+
                            '<OrderData>'+
                                '<OrderID xmlns="http://exchange2.nvms.com/">1</OrderID>'+ //Required
                                '<RushStatus xmlns="http://exchange2.nvms.com/">1</RushStatus>'+ //Required
                                '<UserID xmlns="http://exchange2.nvms.com/">' + NVMS_USER_ID + '</UserID>'+ //Required
                                orderSetBody +
                                orderDetailsBody +
                            '</OrderData>'+
                        '</AddNewOrder>'+
                      '</soap:Body>';
                      
        /*              '<FileNumber xmlns="http://exchange2.nvms.com/">'+ oppObj.OrderNumber__c + '</FileNumber>'+ //Required
                        '<PropOwner xmlns="http://exchange2.nvms.com/">' + oppObj.Property_Name__c + '</PropOwner>'+ //Required
                        '<PropAddress xmlns="http://exchange2.nvms.com/">' + oppObj.Property_Address__c + '</PropAddress>'+ //Required
                        '<PropCity xmlns="http://exchange2.nvms.com/">' + oppObj.Property_City__c + '</PropCity>'+ //Required
                        '<PropState xmlns="http://exchange2.nvms.com/">' + oppObj.Property_State__c + '</PropState>'+ //Required
                        '<PropZip xmlns="http://exchange2.nvms.com/">' + oppObj.Property_Zip__c + '</PropZip>'+ //Required
                        '<AccContact xmlns="http://exchange2.nvms.com/">' + oppObj.Property_Name__c + '</AccContact>'+ //Required
        */              /*'<PropDesc xmlns="http://exchange2.nvms.com/">string</PropDesc>'+
                        '<PropertyID xmlns="http://exchange2.nvms.com/">' + oppObj.Property_Name__c + '</PropertyID>'+
                        '<BatchID xmlns="http://exchange2.nvms.com/">string</BatchID>'+
                        '<mobYear xmlns="http://exchange2.nvms.com/">string</mobYear>'+
                        '<mobMake xmlns="http://exchange2.nvms.com/">string</mobMake>'+
                        '<mobModel xmlns="http://exchange2.nvms.com/">string</mobModel>'+
                        '<mobSerial xmlns="http://exchange2.nvms.com/">string</mobSerial>'+
                        '<mobLength xmlns="http://exchange2.nvms.com/">string</mobLength>'+
                        '<mobWidth xmlns="http://exchange2.nvms.com/">string</mobWidth>'+
                        '<mobColor xmlns="http://exchange2.nvms.com/">string</mobColor>'+
                        '<UnitType xmlns="http://exchange2.nvms.com/">string</UnitType>'+
                        '<UnitCount xmlns="http://exchange2.nvms.com/">string</UnitCount>'+
                        '<PONumber xmlns="http://exchange2.nvms.com/">string</PONumber>'+
                        '<dbaName xmlns="http://exchange2.nvms.com/">string</dbaName>'+
                        '<HUD xmlns="http://exchange2.nvms.com/">string</HUD>'+*/
                        /*'<AccMobile xmlns="http://exchange2.nvms.com/">string</AccMobile>'+
                        'AccFax xmlns="http://exchange2.nvms.com/">string</AccFax>'+
                        '<AccHome xmlns="http://exchange2.nvms.com/">string</AccHome>'+
                        '<AccWork xmlns="http://exchange2.nvms.com/">string</AccWork>'+
                        '<AccEmail xmlns="http://exchange2.nvms.com/">string</AccEmail>'+
                        '<AccWeb xmlns="http://exchange2.nvms.com/">string</AccWeb>'+
                        '<OtherData xmlns="http://exchange2.nvms.com/">string</OtherData>'+
                        'CallbackReference xmlns="http://exchange2.nvms.com/">string</CallbackReference>'+*/
                        /*'<AuctionDate xmlns="http://exchange2.nvms.com/">string</AuctionDate>'+
                        '<Notes xmlns="http://exchange2.nvms.com/">string</Notes>'+
                        '<ClientHoldDate xmlns="http://exchange2.nvms.com/">string</ClientHoldDate>'+
                        '<OrderDetails xmlns="http://exchange2.nvms.com/">'+
                          '<OrderID>int</OrderID>'+
                          '<ServiceID>int</ServiceID>'+
                          '<PONumber>string</PONumber>'+
                          '<OrderPrice>string</OrderPrice>'+
                          '<VendorPrice>string</VendorPrice>'+
                          '<ReportHTML>string</ReportHTML>'+
                        '</OrderDetails>'+
                        '<OrderDetails xmlns="http://exchange2.nvms.com/">'+
                          '<OrderID>int</OrderID>'+
                          '<ServiceID>int</ServiceID>'+
                          '<PONumber>string</PONumber>'+
                          '<OrderPrice>string</OrderPrice>'+
                          '<VendorPrice>string</VendorPrice>'+
                          '<ReportHTML>string</ReportHTML>'+
                        '</OrderDetails>'+*/
        return body;
    }
    
    public NVMSResponseClass makePostCall(String bodyText,String SOAPAction){
        try{
            String envelopSting = '<?xml version="1.0" encoding="utf-8"?>' +
                            '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://www.w3.org/2003/05/soap-envelope">';
            envelopSting += this.getNVMSHeader();
            envelopSting += bodyText;
            envelopSting += '</soap:Envelope>';
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setTimeout(120000);
            req.setEndpoint(END_POINT_URL + END_POINT_SUFFIX);
            req.setBody(envelopSting);
            req.setHeader('soapAction',END_POINT_URL + SOAPAction);
            req.setMethod('POST');
            req.setHeader('Content-Type','text/xml; charset=utf-8');
            httpresponse res;
            if(!Test.isRunningTest()){
                system.debug('=======Request Body======'+ envelopSting);
                res = http.send(req);
            }else {
                res = new HTTPResponse();
                System.debug('=========== > SOAP Action : ' + soapAction);
                if(SOAPAction == 'ClientServicesDataSet')
                    res.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope"><wsa:Action>http://exchange2.nvms.com/ClientServicesDataSetResponse</wsa:Action><wsa:MessageID>urn:uuid:ff4b2863-5533-435c-8545-da328a31622e</wsa:MessageID><wsa:RelatesTo>urn:uuid:779590c8-cff6-4ff6-9e91-8a399a40e06b</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-1573e3a6-b2c7-49a7-a590-1f033881471c"><wsu:Created>2015-12-10T09:13:49Z</wsu:Created><wsu:Expires>2015-12-10T09:18:49Z</wsu:Expires></wsu:Timestamp></wsse:Security></env:Header><soap:Body><ClientServicesDataSetResponse xmlns="http://exchange2.nvms.com"><ClientServicesDataSetResult><xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"><xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:Locale=""><xs:complexType><xs:choice minOccurs="0" maxOccurs="unbounded"><xs:element name="Table"><xs:complexType><xs:sequence><xs:element name="ServiceID" type="xs:int" minOccurs="0" /><xs:element name="ServiceName" type="xs:string" minOccurs="0" /><xs:element name="ServiceAction" type="xs:string" minOccurs="0" /><xs:element name="ShortName" type="xs:string" minOccurs="0" /><xs:element name="ServiceType" type="xs:string" minOccurs="0" /><xs:element name="Price" type="xs:decimal" minOccurs="0" /></xs:sequence></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element></xs:schema><diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1"><NewDataSet xmlns=""><Table diffgr:id="Table1" msdata:rowOrder="0"><ServiceID>2745</ServiceID><ServiceName>Merchant Site 24HR (Rush) - UNannounced</ServiceName><ServiceAction></ServiceAction><ShortName>Merchant Site 24HR</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>95.0000</Price></Table><Table diffgr:id="Table2" msdata:rowOrder="1"><ServiceID>2900</ServiceID><ServiceName>Merchant Site 24HR - Announced</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI 24HR (Appt Req)</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>95.0000</Price></Table><Table diffgr:id="Table3" msdata:rowOrder="2"><ServiceID>2901</ServiceID><ServiceName>Merchant Site 48HR - Announced</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI 48HR (Appt Req)</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>75.0000</Price></Table><Table diffgr:id="Table4" msdata:rowOrder="3"><ServiceID>2746</ServiceID><ServiceName>Merchant Site 48HR - UNannounced</ServiceName><ServiceAction></ServiceAction><ShortName>MSI 48HR-Restaurant</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>75.0000</Price></Table><Table diffgr:id="Table5" msdata:rowOrder="4"><ServiceID>2902</ServiceID><ServiceName>Merchant Site 72HR - Announced</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI 72HR (Appt Req)</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table6" msdata:rowOrder="5"><ServiceID>2811</ServiceID><ServiceName>Merchant Site 72HR - UNannounced</ServiceName><ServiceAction></ServiceAction><ShortName>Merchant Site 72HR</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table7" msdata:rowOrder="6"><ServiceID>219</ServiceID><ServiceName>Merchant Site Inspection</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>49.0000</Price></Table><Table diffgr:id="Table8" msdata:rowOrder="7"><ServiceID>1400</ServiceID><ServiceName>Merchant Site Inspection (Homebased)</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI (Homebased)</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>49.0000</Price></Table><Table diffgr:id="Table9" msdata:rowOrder="8"><ServiceID>220</ServiceID><ServiceName>Merchant Site Inspection (RUSH)</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI Rush</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table10" msdata:rowOrder="9"><ServiceID>422</ServiceID><ServiceName>Merchant Site Inspection (Unannounced)</ServiceName><ServiceAction>ApptNone</ServiceAction><ShortName>MSI (Unannounced)</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>49.0000</Price></Table><Table diffgr:id="Table11" msdata:rowOrder="10"><ServiceID>1402</ServiceID><ServiceName>Merchant Site Inspection - Rush (Unannounced)</ServiceName><ServiceAction></ServiceAction><ShortName>MSI Rush-Unannounced</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table12" msdata:rowOrder="11"><ServiceID>1401</ServiceID><ServiceName>Merchant Site Inspection RUSH (Homebased)</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI (Homebased) Rush</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table13" msdata:rowOrder="12"><ServiceID>3159</ServiceID><ServiceName>Mystery Shopper - 24hr</ServiceName><ServiceAction>None</ServiceAction><ShortName>Mystery Shopper 24hr</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>95.0000</Price></Table><Table diffgr:id="Table14" msdata:rowOrder="13"><ServiceID>3161</ServiceID><ServiceName>Mystery Shopper - 48hr</ServiceName><ServiceAction>None</ServiceAction><ShortName>Mystery Shopper 48hr</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>75.0000</Price></Table><Table diffgr:id="Table15" msdata:rowOrder="14"><ServiceID>3160</ServiceID><ServiceName>Mystery Shopper - 72hr</ServiceName><ServiceAction>None</ServiceAction><ShortName>Mystery Shopper 72hr</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table16" msdata:rowOrder="15"><ServiceID>3062</ServiceID><ServiceName>Trip Charge</ServiceName><ServiceAction></ServiceAction><ShortName>Trip Charge</ShortName><ServiceType>Fee</ServiceType><Price>35.0000</Price></Table></NewDataSet></diffgr:diffgram></ClientServicesDataSetResult></ClientServicesDataSetResponse></soap:Body></soap:Envelope>');
                else if(SOAPAction == 'AddNewOrder')
                    res.SetBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope"><wsa:Action>http://exchange2.nvms.com/AddNewOrderResponse</wsa:Action><wsa:MessageID>urn:uuid:75069bdd-1a33-47ca-9a79-870adeb2d6a8</wsa:MessageID><wsa:RelatesTo>urn:uuid:ff93081e-3113-4b90-b5e2-d5359f5b17a4</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-06889ad1-b33b-4cc5-add6-66a5b914a1ff"><wsu:Created>2015-12-09T12:42:27Z</wsu:Created><wsu:Expires>2015-12-09T12:47:27Z</wsu:Expires></wsu:Timestamp></wsse:Security></env:Header><soap:Body><AddNewOrderResponse xmlns="http://exchange2.nvms.com"><AddNewOrderResult>&lt;NewOrderResult&gt;&lt;NVMSJobID&gt;344208&lt;/NVMSJobID&gt;&lt;Message&gt;New NVMS Order Created Successfully&lt;/Message&gt;&lt;ServiceCount&gt;2&lt;/ServiceCount&gt;&lt;/NewOrderResult&gt;</AddNewOrderResult></AddNewOrderResponse></soap:Body></soap:Envelope>');
                else if(SOAPAction == 'RetrieveOrderPDF')
                    res.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope"><wsa:Action>http://exchange2.nvms.com/ClientServicesDataSetResponse</wsa:Action><wsa:MessageID>urn:uuid:7587a915-00e6-4e62-894d-31daa10c11cd</wsa:MessageID><wsa:RelatesTo>urn:uuid:daa5ebed-b920-47cc-a257-91154d744b68</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-d2b80ea3-cb51-4eca-9f5a-c0fbf545f470"><wsu:Created>2015-12-09T12:42:12Z</wsu:Created><wsu:Expires>2015-12-09T12:47:12Z</wsu:Expires></wsu:Timestamp></wsse:Security></env:Header><soap:Body><ClientServicesDataSetResponse xmlns="http://exchange2.nvms.com"><ClientServicesDataSetResult><xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"><xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:Locale=""><xs:complexType><xs:choice minOccurs="0" maxOccurs="unbounded"><xs:element name="Table"><xs:complexType><xs:sequence><xs:element name="ServiceID" type="xs:int" minOccurs="0" /><xs:element name="ServiceName" type="xs:string" minOccurs="0" /><xs:element name="ServiceAction" type="xs:string" minOccurs="0" /><xs:element name="ShortName" type="xs:string" minOccurs="0" /><xs:element name="ServiceType" type="xs:string" minOccurs="0" /><xs:element name="Price" type="xs:decimal" minOccurs="0" /></xs:sequence></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element></xs:schema><diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1"><NewDataSet xmlns=""><Table diffgr:id="Table1" msdata:rowOrder="0"><ServiceID>2745</ServiceID><ServiceName>Merchant Site 24HR (Rush) - UNannounced</ServiceName><ServiceAction></ServiceAction><ShortName>Merchant Site 24HR</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>95.0000</Price></Table><Table diffgr:id="Table2" msdata:rowOrder="1"><ServiceID>2900</ServiceID><ServiceName>Merchant Site 24HR - Announced</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI 24HR (Appt Req)</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>95.0000</Price></Table><Table diffgr:id="Table3" msdata:rowOrder="2"><ServiceID>2901</ServiceID><ServiceName>Merchant Site 48HR - Announced</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI 48HR (Appt Req)</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>75.0000</Price></Table><Table diffgr:id="Table4" msdata:rowOrder="3"><ServiceID>2746</ServiceID><ServiceName>Merchant Site 48HR - UNannounced</ServiceName><ServiceAction></ServiceAction><ShortName>MSI 48HR-Restaurant</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>75.0000</Price></Table><Table diffgr:id="Table5" msdata:rowOrder="4"><ServiceID>2902</ServiceID><ServiceName>Merchant Site 72HR - Announced</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI 72HR (Appt Req)</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table6" msdata:rowOrder="5"><ServiceID>2811</ServiceID><ServiceName>Merchant Site 72HR - UNannounced</ServiceName><ServiceAction></ServiceAction><ShortName>Merchant Site 72HR</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table7" msdata:rowOrder="6"><ServiceID>219</ServiceID><ServiceName>Merchant Site Inspection</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>49.0000</Price></Table><Table diffgr:id="Table8" msdata:rowOrder="7"><ServiceID>1400</ServiceID><ServiceName>Merchant Site Inspection (Homebased)</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI (Homebased)</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>49.0000</Price></Table><Table diffgr:id="Table9" msdata:rowOrder="8"><ServiceID>220</ServiceID><ServiceName>Merchant Site Inspection (RUSH)</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI Rush</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table10" msdata:rowOrder="9"><ServiceID>422</ServiceID><ServiceName>Merchant Site Inspection (Unannounced)</ServiceName><ServiceAction>ApptNone</ServiceAction><ShortName>MSI (Unannounced)</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>49.0000</Price></Table><Table diffgr:id="Table11" msdata:rowOrder="10"><ServiceID>1402</ServiceID><ServiceName>Merchant Site Inspection - Rush (Unannounced)</ServiceName><ServiceAction></ServiceAction><ShortName>MSI Rush-Unannounced</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table12" msdata:rowOrder="11"><ServiceID>1401</ServiceID><ServiceName>Merchant Site Inspection RUSH (Homebased)</ServiceName><ServiceAction>ApptMandatory</ServiceAction><ShortName>MSI (Homebased) Rush</ShortName><ServiceType>Inspection-Commercial</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table13" msdata:rowOrder="12"><ServiceID>3159</ServiceID><ServiceName>Mystery Shopper - 24hr</ServiceName><ServiceAction>None</ServiceAction><ShortName>Mystery Shopper 24hr</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>95.0000</Price></Table><Table diffgr:id="Table14" msdata:rowOrder="13"><ServiceID>3161</ServiceID><ServiceName>Mystery Shopper - 48hr</ServiceName><ServiceAction>None</ServiceAction><ShortName>Mystery Shopper 48hr</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>75.0000</Price></Table><Table diffgr:id="Table15" msdata:rowOrder="14"><ServiceID>3160</ServiceID><ServiceName>Mystery Shopper - 72hr</ServiceName><ServiceAction>None</ServiceAction><ShortName>Mystery Shopper 72hr</ShortName><ServiceType>Guaranteed Site Visits</ServiceType><Price>65.0000</Price></Table><Table diffgr:id="Table16" msdata:rowOrder="15"><ServiceID>3062</ServiceID><ServiceName>Trip Charge</ServiceName><ServiceAction></ServiceAction><ShortName>Trip Charge</ShortName><ServiceType>Fee</ServiceType><Price>35.0000</Price></Table></NewDataSet></diffgr:diffgram></ClientServicesDataSetResult></ClientServicesDataSetResponse></soap:Body></soap:Envelope>');
            }
            system.debug('=======Response Body======'+res.getBody());  
            if(res != null){
                parseXML(res);
                response.statusCode = res.getStatusCode(); 
            }
            
        }Catch(Exception e){
            response.message = e.getMessage();
        }
        return response;
    }
    
    public NVMSResponseClass parseXML(HTTPResponse resObj){
        XmlStreamReader reader = resObj.getXmlStreamReader();
        ServiceResponseClass serObj;
        while(reader.hasNext()){
            try{
                if (reader.getEventType() == XmlTag.START_ELEMENT){
                        if(reader.getLocalName() == 'ClientServicesDataSetResponse'){
                            response.serList = new List<ServiceResponseClass>();
                            serMap = new Map<String,ServiceResponseClass>();
                        }else if(reader.getLocalName() == 'Text') {
                            reader.next();
                            if (reader.getEventType() == XmlTag.characters){
                                response.message = reader.getText();
                                System.debug('=========== Error : ' + reader.getText());
                            }
                        }else if (reader.getLocalName() == 'Table') {
                            serObj = new ServiceResponseClass();
                            response.serList.add(serObj);
                        }else if (reader.getLocalName() == 'ServiceID') {
                        reader.next();
                        if (reader.getEventType() == XmlTag.characters){
                            serobj.serviceId = reader.getText();
                            serMap.put(serobj.serviceId,serObj);
                            System.debug('=========== Service ID: ' + reader.getText());
                        }
                      }else if (reader.getLocalName() == 'ServiceName') {
                        reader.next();
                        if (reader.getEventType() == XmlTag.characters){
                           serobj.serviceName = reader.getText();
                            System.debug('=========== Service Name: ' + reader.getText());
                        }
                      }else if (reader.getLocalName() == 'Price') {
                        reader.next();
                        if (reader.getEventType() == XmlTag.characters){
                            serobj.price = Decimal.valueOf(reader.getText());
                           // wrapObj.responseWrapper.faultstring = reader.getText();
                        }
                      }else if (reader.getLocalName() == 'RetrieveOrderPDFResult') {
                        reader.next();
                        if (reader.getEventType() == XmlTag.characters){
                            response.resultString = resObj.getBody().substringAfter('&lt;Report&gt;').subStringBefore('&lt;/Report&gt;');
                            System.debug('============= replace All : ' + response.resultString);
                        }
                      }else if (reader.getLocalName() == 'AddNewOrderResult') {
                        reader.next();
                        if (reader.getEventType() == XmlTag.characters){
                            response.resultString = reader.getText();
                           if(response.resultString != null
                                        && response.resultString.trim() != ''){
                                            
                                response.resultString = resObj.getBody().replaceAll('&lt;','<');
                                System.debug('============= replace All : ' + response.resultString);
                                response.resultString = response.resultString.replaceAll('&gt;','>');
                                System.debug('============= replace All : ' + response.resultString);
                                if(response.resultString.substringAfter('<NVMSJobID>') != null)
                                    response.jobid = response.resultString.substringAfter('<NVMSJobID>').subStringBefore('</NVMSJobID>');
                                System.debug('============= Job Id: ' + response.jobId);                
                           }
                        }
                      }
                      
                }
            }
            catch(Exception e){
                response.message = e.getMessage();
            }
            reader.next();
      }
        return response;
    }
}