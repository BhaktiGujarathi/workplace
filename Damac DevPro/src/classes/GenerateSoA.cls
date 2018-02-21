public without sharing class GenerateSoA {
    public Id unitId;
    public string strSoAURL {get;set;}
    
    public GenerateSoA(){
        unitId = ApexPages.currentPage().getParameters().get('id');
    }
    public pagereference genSoA(){
        PageReference  pg;
        list<Booking_Unit__c> lstUnit = [Select Id, Registration_ID__c from Booking_Unit__c where Id=:unitId limit 1];
        if(lstUnit != null && !lstUnit.isEmpty()
        && lstUnit[0].Registration_ID__c != null){
	        GenerateSOAController.soaResponse strResponse = GenerateSOAController.getSOADocument(lstUnit[0].Registration_ID__c);
	        system.debug('SOA generated status '+strResponse.status);
	        system.debug('SOA generated url'+strResponse.url);
	        strSoAURL = strResponse.url;
	        system.debug('strSoAURL**************'+strSoAURL);
	        if(!String.isBlank(strSoAURL)){
		        pg = new PageReference (strSoAURL);
		        pg.setRedirect(true);
	        }
	        
        }
        return pg;
    }
}