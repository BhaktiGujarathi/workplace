public without sharing class NewInquiryController {

    public Inquiry__c inquiryObj{set;get;}
    public List<SelectOption> campaigns{get; set;}
    //public List<SelectOption> buildings{get; set;}
    //public string selProperty{get; set;}
    //public string selBuilding{get; set;}
    public boolean saveRecordFlag {get;set;}
    //public boolean showPicklist{get; set;}
    public String countryLocation {get;set;}
    public String recaptchaResponse {get;set;}
    public String captchaValidation {get;set;}
    public Boolean captchaVerified{get;set;}
    public Boolean fieldValidation {get;set;}
    private String privateKey = '6Lf91yEUAAAAAJI7vui-8-2EaJaPh-zUxEow7No5';
    public NewInquiryController() {
        countryLocation = ApexPages.CurrentPage().getParameters().get('location');

        inquiryObj = new Inquiry__c();
        campaigns = new List<SelectOption>();
        captchaVerified = false;
        //showPicklist = true;

        //List<Property__c> lstPropNames = [Select id, Campaign_Name__c FROM Campaign__c WHERE  Marketing_End_Date__c >=: TODAY() ORDER BY Campaign_Name__c];
        Date todayDate = Date.today();
        campaigns.add(new selectOption('','--None--'));
        for(Campaign__c thisCampaign: [SELECT ID,Name,Campaign_Name__c FROM Campaign__c WHERE Marketing_Start_Date__c <=:todayDate AND Marketing_End_Date__c >=: todayDate AND Marketing_Active__c = true AND Country__c =:countryLocation ORDER BY Campaign_Name__c]){
            campaigns.add(new SelectOption(thisCampaign.ID,thisCampaign.Campaign_Name__c));
        }
        saveRecordFlag = false;  
        if(String.isBlank(countryLocation) || !((Label.New_Inquiry_Locations.toUpperCase()).containsIgnoreCase(countryLocation.toUpperCase()))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Invalid URL, please provide the location.'));
        }
    }

    /*public void onPropertyChange(){
        
        buildings = new List<SelectOption>();
        buildings.add(new SelectOption('','--None--'));
        List<AggregateResult> lstBuildAggr = [Select Building_Location__r.Building_Name__c br,count(id) from Inventory__c where (Status__c='Available' or Status__c='') and Property__c =:selProperty and Building_Location__r.Building_Name__c != null group by Building_Location__r.Building_Name__c];
        for(AggregateResult ar: lstBuildAggr){
            buildings.add(new SelectOption(string.valueOf(ar.get('br')),string.valueOf(ar.get('br'))));
        }
        
        if(!buildings.isEmpty())
            showPicklist = false;
        else
            showPicklist = true;
    }*/
    
    public void recaptchaVerification(){
    	   
    	string body = 'secret=' + privateKey + '&response=' + recaptchaResponse;
        
    	HttpResponse res = null;
    	HttpRequest req = new HttpRequest();
    	req.setMethod('POST');
    	req.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
    	req.setBody(body);
    	try{
    		Http http = new Http();
    		res = http.send(req);
    		system.debug(res);
    		//system.debug(res.getBody());
            //captchaValidation = res.getBody();
            if(res != null ){
            	captchaValidation = res.getBody();
            	captchaVerified = (res.getBody().contains('true'));
	    		system.debug(captchaValidation);
	            system.debug(captchaVerified);
            }
    		
    	}catch(Exception ex){
    		System.debug(ex);
    		
    	}
    	system.debug(fieldValidation);
    	if(!fieldValidation && captchaVerified){
    		saveInquiry();
    	}
    	
    }

    public void saveInquiry(){
        String actualNumber = '';
        String trimmedNumber = '';
      Id inquiryRecordTypeId   = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get(DAMAC_Constants.INQUIRY_RT).getRecordTypeId();
      if(String.isBlank(countryLocation) || !((Label.New_Inquiry_Locations.toUpperCase()).containsIgnoreCase(countryLocation.toUpperCase()))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Invalid URL, please provide the location.'));
        }
        else{
            actualNumber = inquiryObj.Mobile_Phone_Encrypt__c;
            integer first = 0;
            integer temp = 0;
            integer offset = 9;
            integer last = actualNumber.length();
            
            if(actualNumber.length()>10){
                while((first+offset)<last){
                    system.debug(trimmedNumber);
                    system.debug('## ' + first + '## ' + offset + '## ' + last);
                    system.debug(actualNumber.substring(first,first+offset));
                    system.debug(Integer.valueOf(actualNumber.substring(first,first+offset)));
                    trimmedNumber += String.valueOf(Integer.valueOf(actualNumber.substring(first,first+offset)));
                    first+=offset;

                }
                trimmedNumber += String.valueOf(Integer.valueOf(actualNumber.substring(first, last)));
                inquiryObj.Mobile_Phone_Encrypt__c = trimmedNumber;
            }else{
                inquiryObj.Mobile_Phone_Encrypt__c = String.valueOf(Integer.valueOf(actualNumber));
            }
            system.debug(inquiryObj.Mobile_Phone_Encrypt__c);
            inquiryObj.Inquiry_Source__c = 'Call Center';
            inquiryObj.Call_Center_Location__c = countryLocation;
            inquiryObj.RecordTypeId = inquiryRecordTypeId;

          try{

            insert inquiryObj;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Inquiry created successfully.'));
                inquiryObj = new Inquiry__c(Preferred_Language__c='English');
                //selBuilding='';
                //selProperty = '';
                
                saveRecordFlag = true;
          }
            catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error ,ex.getMessage()));
            } 
        }
    }
}