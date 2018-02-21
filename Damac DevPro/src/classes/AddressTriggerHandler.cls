global class AddressTriggerHandler implements TriggerFactoryInterface {
    
    
    public void executeBeforeInsertTrigger(list<sObject> lstNewRecords){
        
    }
    
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
         
    }

    
    public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords,map<Id,sObject> mapOldRecords){
        map<Id,Account> mapOldSRRecords = new map<Id,Account>();
        if(mapOldRecords != null)
            mapOldSRRecords = (map<Id,Account>)mapOldRecords;
    }
    
    
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
        
        for(Sobject sobj: mapNewRecords.values()){
            AddressTriggerHandler.getLocation(string.valueOf(sobj.get('Id')));    
        }
        
    }
    
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        
        for(Sobject sobj: mapNewRecords.values()){
            Address__c add = (Address__c) sobj;
            if(add.Latitude__c == null || add.Longitude__c == null)
                AddressTriggerHandler.getLocation(add.Id);    
        }
        
    }
    
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
    @future (callout=true)
    webservice static void getLocation(string addressId){
        
            
    	Address__c a = [Select id, ADDRESS_LINE1__c, ADDRESS_LINE2__c, ADDRESS_LINE3__c, ADDRESS_LINE4__c, City__c, State__c, Country__c from Address__c where Id=:addressId];
    
    	String address = '';
    	if (a.ADDRESS_LINE1__c != null)
    		address += a.ADDRESS_LINE1__c +', ';
		if (a.City__c != null)
    		address += a.City__c +', ';
    	if (a.State__c != null)
    		address += a.State__c +', ';
    	if (a.Country__c != null){
    	    if(a.Country__c == 'AE')
    	        address += 'United Arab Emirates';
    	    else if(a.Country__c == 'QA')
    	        address += 'QATAR';
    	    else if(a.Country__c == 'JO')
    	        address += 'JORDAN';
    	    else if(a.Country__c == 'LB')
    	        address += 'Lebanon';
    	    else if(a.Country__c == 'SA')
    	        address += 'Saudi Arabia';
    	    
    	    else
    	        address += a.Country__c;
    	}	
    		
    	address = EncodingUtil.urlEncode(address, 'UTF-8');
        
        
    	Http h = new Http();
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
    	req.setMethod('GET');
    	req.setTimeout(60000);
        string body = '';
        
        if(!test.isRunningTest()){
    		HttpResponse res = h.send(req);
    		System.debug('>>>>>>>>>>>>>>>>>>>>'+res.getBody());
    		System.debug('>>>>>>>>>>>>>>>>>>>>'+'http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
    		body = res.getbody();
        }
        else
            body = '{"results":[{"address_components":[{"long_name":"Dubai","short_name":"Dubai","types":["administrative_area_level_1","political"]},{"long_name":"United Arab Emirates","short_name":"AE","types":["country","political"]}],"formatted_address":"Cluster E,Jumeirah Lake Towers - Dubai - United Arab Emirates","geometry":{"location":{"lat":25.0720693,"lng":55.14142039999999},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":25.0734182802915,"lng":55.14276938029149},"southwest":{"lat":25.0707203197085,"lng":55.1400714197085}}},"place_id":"ChIJiW6YFKxsXz4RQgNwqRzxsdM","types":["establishment","point_of_interest","premise"]}],"status":"OK"}';
		JSONParser parser = JSON.createParser(body);
		double lat = null;
		double lon = null;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
				(parser.getText() == 'location')){
				   parser.nextToken(); // object start
				   while (parser.nextToken() != JSONToken.END_OBJECT){
					   String txt = parser.getText();
					   parser.nextToken();
					   if (txt == 'lat')
						   lat = parser.getDoubleValue();
					   else if (txt == 'lng')
						   lon = parser.getDoubleValue();
				   }
			}
		}
		System.debug('>>>>>>latitude>>>>>>>>>>>>>>'+lat+'>>>>>>>longitude>>>>>>>>>>>>'+lon);
		if (lat != null){
			a.Latitude__c = string.valueOf(lat);
			a.Longitude__c = string.valueOf(lon);
			update a;
		}
    		
    	  
    }
    
}