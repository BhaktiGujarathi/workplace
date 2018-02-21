public  with sharing class CaseServices {
    public static void UpdateGeoCodes(List<Case> triggerNew, Map<id, Case> triggerOldMap){
        List<Id> caseList = new List<Id>();
        Boolean isInsert = (triggerOldMap == null ? true : false);
        
        for(Case newCase: triggerNew)
        {
            if(isInsert == true || newCase.Street_Address__c != triggerOldMap.get(newCase.id).Street_Address__c ||  newCase.Street_Name__c != triggerOldMap.get(newCase.id).Street_Name__c){
                caseList.add(newCase.id);                
            }
        }
        
        if(caseList.size() > 0 && !Test.isRunningTest() && !System.isFuture()){
            RetrieveGeoCodes(caseList);
        }
    }

    @future(callout = true)
    public static void RetrieveGeoCodes(List<Id> caseList){
        GeoCodingApi__c customSetting = GeoCodingApi__c.getValues('GeocodingDetails');
        List<Case> updatedCaseList = new List<Case>();
        String geoCodeApiKey = customSetting.Key__c;
        String geoCodeApiURL =customSetting.URL__c;
        try{
        List<Case> cases = [SELECT Id, Street_Name__c, Street_Address__c FROM Case WHERE id IN :caseList];
        for (Case caseVal : cases){
            geoCodeApiURL += 'address=';
            string streetAddress;
            if(caseVal.Street_Address__c != null || caseVal.Street_Address__c != ''){
                streetAddress = caseVal.Street_Address__c + ' ' + caseVal.Street_Name__c;
            }
            else{
                streetAddress = caseVal.Street_Name__c;
            }
            geoCodeApiURL += EncodingUtil.urlEncode(streetAddress+' ' + 'San'+' ' + 'Francisco' + ' ' + 'CA','UTF-8')+'&key='+geoCodeApiKey;
            Http h = new Http(); 
            HttpRequest req = new HttpRequest();

            req.setHeader('Content-type', 'application/x-www-form-urlencoded'); 
            req.setHeader('Content-length', '0'); 
            req.setEndpoint(geoCodeApiURL); 
            req.setMethod('POST');
            
            HttpResponse res = h.send(req); 
           
            // Parse JSON response to get all the field values.
        	JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null){
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')){
                    parser.nextToken();
                    parser.nextToken();
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'lat')) {
                            parser.nextToken();
                            caseVal.Case_Location__Latitude__s = Decimal.valueOf(parser.getText());
                    }
                    parser.nextToken();
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'lng')) {
                        parser.nextToken();
                        caseVal.Case_Location__Longitude__s = Decimal.valueOf(parser.getText());
                    }   
                    break;
                } 
            }
            updatedCaseList.add(caseVal);
        } 
        upsert updatedCaseList;
        }
        catch(System.Exception ex){
            LogExceptions(ex);
        }
    }
    
    //Insert exceptions into Custom object
    public static void LogExceptions(Exception ex){
        Error_Log__c log = new Error_Log__c();
        log.Trace__c = 'Type: ' + ex.getTypeName() + '\n' + 'Cause: ' + ex.getCause() + '\n' + 'Message: ' + ex.getMessage();
        insert log;  
    }

    /*
    //moved to controller for sharing reasons
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
    */
}