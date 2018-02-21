@RestResource(urlMapping='/CTIRestService2/*')
global class CTIRestService2 {
    global class RequestHandler{
        public string callingNumber {get;set;}
        public string calledNumber {get;set;}
        public String PCext {get;set;}
        public RequestHandler(){
            this.callingNumber = '';
            this.calledNumber = '';
            this.PCext = '';
        }
    }
    
    global class ResponseDataWrapper{
        public string objectId;
        public string objectName;
        public ResponseDataWrapper(){
            this.objectId = null;
            this.objectName = null;
        }
        public ResponseDataWrapper(string objectId, string objectName){
            this.objectId = objectId;
            this.objectName = objectName;
        }
    }
    
    global class ResponseHandler{
        public List<ResponseDataWrapper> objectDetails;
        public string newInquiryUrl;
        public integer errorCode;
        public String errorMessage;
        public ResponseHandler(){
            this.objectDetails = new List<ResponseDataWrapper>();
            this.newInquiryUrl = null;
            this.errorCode = 200;
            this.errorMessage = 'Successful';
        }
    }
    
    @HttpPost
    global static ResponseHandler getObjectDetail(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        ResponseHandler res = new ResponseHandler();
        try{
            RequestHandler req = (RequestHandler)JSON.deserializeStrict(request.requestBody.toString(), RequestHandler.class);
            User pcUSer;
            for(User thisPc: [SELECT Id FROM User WHERE Extension =: req.PCext]){
              pcUser = thisPc;
              break;  
            }
            system.debug('pcUser===> '+pcUser);
            if(pcUser != null){
              for(Account account : [SELECT Id, Name 
                                     FROM Account 
                                     WHERE OwnerId =: pcUser.Id AND
                                          IsPersonAccount = true AND 
                                           PersonMobilePhone != null AND 
                                           PersonMobilePhone =: req.callingNumber]){
                  system.debug(account.Id);
                  res.objectDetails.add(new ResponseDataWrapper(account.Id, account.Name));
                  system.debug(account.Name);
              }
              Id inquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
              for(Inquiry__c inquiry : [SELECT Id, Name,First_Name__c,Last_Name__c 
                                        FROM Inquiry__c 
                                        WHERE OwnerId =: pcUser.Id AND 
                                            (Inquiry_Status__c =: DAMAC_Constants.INQUIRY_ACTIVE_STATUS OR
                                               Inquiry_Status__c =: DAMAC_Constants.INQUIRY_NEW_STATUS) AND  
                                              //Inquiry_Source__c !=: DAMAC_Constants.PROSPECTING_BY_PC_SOURCE AND 
                                              //Inquiry_Source__c !=: DAMAC_Constants.AGENT_REFERAL_STATUS AND
                                              RecordTypeId =: inquiryRecordTypeId AND
                                              Duplicate__c = false AND
                                              (Mobile_Phone__c =: req.callingNumber OR 
                                               Mobile_Phone_2__c =: req.callingNumber OR 
                                               Mobile_Phone_3__c =: req.callingNumber OR 
                                               Mobile_Phone_4__c =: req.callingNumber OR 
                                               Mobile_Phone_5__c =: req.callingNumber)]){
                  res.objectDetails.add(new ResponseDataWrapper(inquiry.Id, inquiry.First_Name__c+' '+inquiry.Last_Name__c));
              }
              if(res.objectDetails.isEmpty()){
                res.errorCode = 200;
                  //res.newInquiryUrl = 'https://damacsandbox--damacdev--c.cs88.visual.force.com/apex/CustomInquiryPage';
                  res.newInquiryUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/apex/CustomInquiryPage';
                  res.errorMessage = 'Inquiry or Account does not exist. Please redirect to create new Inquiry Page';
              }  
            }else{
              res.errorCode = 400;
                res.newInquiryUrl = '';
                res.errorMessage = 'There is no consultant with the specified extension. Please check and re-try again.';  
            }
        } catch (exception ex){
            res.errorCode = 400;
            res.newInquiryUrl = '';
            res.errorMessage = ex.getMessage();
        }
        Log__c incomingRequest = new Log__c(Description__c= JSON.serialize(request.requestBody),Type__c='CTIRestService2-Request');
        Log__c outgoingResponse = new Log__c(Description__c= JSON.serialize(res),Type__c='CTIRestService2-Response');
        List<Log__c> lstLog = new List<Log__c>();
        lstLog.add(incomingRequest);
        lstLog.add(outgoingResponse);
        insert lstLog;

        System.debug('@#@# res= '+res);        
        return res;
     }
}// End of class.