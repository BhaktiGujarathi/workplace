global without sharing class SFMTAMappingSubController{
    public Id testId {get;set;}
    public String generatedToken {get;set;}
    public String caseNumber {get;set;}
    public Id caseId {get;set;}
    public String fromDate {get;set;}
    public String toDate {get;set;}

    public Decimal caselat {get;set;}
    public Decimal caselong {get;set;}
    public String isAdmin {get;set;}
    public String isInternal {get;set;}

    public String geometryServer {get;set;}
    public String bikeParkingUrl {get;set;}
    public String bikeParkingUrlOAUTH {get;set;}

    public String colorCurbURL {get;set;}
    public String colorCurbURLOAUTH {get;set;}

    public String streetClosureURL {get;set;}
    public String streetClosureURLOAUTH {get;set;}

    public String tempSignsURL {get;set;}
    public String tempSignsURLOAUTH {get;set;}

    public Boolean init{
        get{
            init();
            return false;
        }
    }

    public void init(){  
        CallArcGIS();
        testId = UserInfo.getUserId();

        String caseNum      = apexpages.currentpage().getparameters().get('caseNumber');
        String userId       = apexpages.currentpage().getparameters().get('userId');
        isInternal          = apexpages.currentpage().getparameters().get('internal');  
        
        geometryServer          = MappingConstants.GEOMETRY_SERVER != null ? MappingConstants.GEOMETRY_SERVER.LayerURL__c : '';

        bikeParkingUrl          = MappingConstants.BIKE_PARKING != null ? MappingConstants.BIKE_PARKING.LayerURL__c : '';
        bikeParkingUrlOAUTH     = MappingConstants.BIKE_PARKING_OAUTH != null ? MappingConstants.BIKE_PARKING_OAUTH.LayerURL__c : '';
        //bikeParkingUrl          = MappingConstants.BIKE_PARKING.LayerURL__c;
        //bikeParkingUrlOAUTH     = MappingConstants.BIKE_PARKING_OAUTH.LayerURL__c;

        colorCurbURL            = MappingConstants.COLOR_CURB != null ? MappingConstants.COLOR_CURB.LayerURL__c : '';
        colorCurbURLOAUTH       = MappingConstants.COLOR_CURB_OAUTH != null ? MappingConstants.COLOR_CURB_OAUTH.LayerURL__c : '';
        //colorCurbURL            = MappingConstants.COLOR_CURB.LayerURL__c;
        //colorCurbURLOAUTH       = MappingConstants.COLOR_CURB_OAUTH.LayerURL__c;

        streetClosureURL        = MappingConstants.STREET_CLOSURE != null ? MappingConstants.STREET_CLOSURE.LayerURL__c : '';
        streetClosureURLOAUTH   = MappingConstants.STREET_CLOSURE_OAUTH != null ? MappingConstants.STREET_CLOSURE_OAUTH.LayerURL__c : '';
        //streetClosureURL        = MappingConstants.STREET_CLOSURE.LayerURL__c;
        //streetClosureURLOAUTH   = MappingConstants.STREET_CLOSURE_OAUTH.LayerURL__c;

        tempSignsURL            = MappingConstants.TEMP_SIGNS != null ? MappingConstants.TEMP_SIGNS.LayerURL__c : '';
        tempSignsURLOAUTH       = MappingConstants.TEMP_SIGNS_OAUTH != null ? MappingConstants.TEMP_SIGNS_OAUTH.LayerURL__c : '';
        //tempSignsURL            = MappingConstants.TEMP_SIGNS.LayerURL__c;
        //tempSignsURLOAUTH       = MappingConstants.TEMP_SIGNS_OAUTH.LayerURL__c;

        if(string.isNotBlank(caseNum) && string.isNotBlank(userId)){ 
            User currentUser    = UserServices.GetUserById(userId);
            this.isAdmin        = (currentUser.Profile.Name == 'System Administrator') ? 'true': 'false';

            Case currentCase    = GetCaseByCaseNumber(caseNum);

            this.caseId         = currentCase.Id;   
            this.caseNumber     = currentCase.CaseNumber;     
            this.fromDate       = String.valueOf(currentCase.Event_Start__c);
            this.toDate         = String.valueOf(currentCase.Event_End__c);

            if(currentCase.Case_Location__Latitude__s == null || currentCase.Case_Location__Longitude__s == null){
                this.caselat    = 37.7749;  
                this.caselong   = -122.4194;
            }
            else{
                this.caselong   = currentCase.Case_Location__Longitude__s;
                this.caselat    = currentCase.Case_Location__Latitude__s;  
            }
        }
    }

    public void CallArcGIS(){
        if(MappingConstants.MAPPING_CREDENTIALS != null){
            String clientId     = MappingConstants.MAPPING_CREDENTIALS.ClientId__c;
            String clientSecret = MappingConstants.MAPPING_CREDENTIALS.ClientSecret__c;
            String loginUri     = 'https://www.arcgis.com/sharing/oauth2/token';

            if (!Test.isRunningTest()){
                HttpRequest req = new HttpRequest(); 
                req.setMethod('POST');
                req.setEndpoint(loginUri);
                req.setBody('grant_type=client_credentials' +
                    '&client_id=' + clientId +
                    '&client_secret=' + clientSecret);
            
                Http http = new Http();
          
                HTTPResponse res = http.send(req);

                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                        parser.nextToken();
                        generatedToken = parser.getText();
                    }
                }
            }
        }
    }

    public static Case GetCaseByCaseNumber(String caseNumber){
        Case results = new Case();
        for(Case cs :[SELECT Id, CaseNumber, 
            Install_Date__c, Uninstall_Date__c, Event_Start__c, Event_End__c,
            Case_Location__Longitude__s, Case_Location__Latitude__s, RecordType.Name  
            FROM Case 
            WHERE CaseNumber = :caseNumber 
            limit 1]){

            results = cs;
        }
        return results;
    }    
}