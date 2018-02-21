@RestResource(urlMapping='/DAMACEnquiry/*')
global class RestServiceToCreateEnquiry{
    
    @HttpPost
    global static ResponseHandler createEnquiry(String firstname, string lastname, string email, string title, string telephone, 
            string Source, string UTMSource, string UTMMedium, string UTMCampaign, string HeardOfDAMAC, string message, string mobileCode,string city, string nationality, string country, string campaignid){
        system.debug('Inside method');
        system.debug('F=='+firstname);
        ResponseHandler res = new ResponseHandler();
        
        try{
            Inquiry__c inq = new Inquiry__c();
            inq.First_Name__c = firstname;
            inq.Last_Name__c = lastname;
            inq.Email__c = email;
            inq.Salutation__c= title;
            //inq.Mobile_Phone__c = telephone;
            inq.Mobile_Phone_Encrypt__c=telephone;
            inq.Inquiry_source__c = Source;
            inq.UTM_Source__c = UTMSource;
            inq.UTM_medium__c = UTMMedium;
            inq.UTM_campaign__c = UTMCampaign;
            inq.Heard_Of_Damac__c = HeardOfDAMAC;
            inq.Description__c = message;
            if(mobileCode!='null')
            inq.MObile_CountryCode__c = mobileCode;
            else
            inq.MObile_CountryCode__c = 'Unknown';
            
            inq.city__c = city;
            inq.Country__c = country;
            inq.Nationality__c = nationality;
            inq.Inquiry_status__c = 'New';
            if(campaignid!='')
            inq.Campaign__c=campaignid;
            system.debug('INQQQ=='+inq);
            insert inq;
            res.status='SUCCESS'; 
        }
        catch(Exception e){
            res.status = 'ERROR';
            res.Message = e.getMessage();
            system.debug('EEE=='+res.Message);
            
            Log__c objLog = new Log__c();
            objLog.Description__c ='Inquiry Details=='+firstname+' '+lastname+'--Email-'+email+'--Phone-'+telephone+mobileCode+'--Campaign ID-'+campaignid+'-Line No===>'+e.getLineNumber()+'---Message==>'+e.getMessage();
            objLog.Type__c = 'Inquiry creation error from RestEnquiry service';
            insert objLog;
        }
        
        return res;        
    }
    
    global class ResponseHandler {
        public Boolean Success {get; set;}
        public String Status {get; set;}
        public String Message {get;set;}
    }
    
        
}