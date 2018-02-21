public without sharing class GenerateSOAController {
	
	public static soaResponse getSOADocument(String regId){
		GenerateSOAService.COCDHttpSoap11Endpoint calloutObj = new GenerateSOAService.COCDHttpSoap11Endpoint();
		calloutObj.timeout_x = 120000;
		soaResponse resObj = new soaResponse();

		try{
			String response = calloutObj.GenCustomerStatement( String.valueOf( Datetime.now().getTime()), 'DP_SOA', 'SFDC', regId, '', '', regId );
			resObj = (soaResponse)JSON.deserialize(response, GenerateSOAController.soaResponse.class);
			system.debug('soa response === '+ resObj);
		} catch (Exception e ){
			resObj.status = 'Exception';
			resObj.url = 'https://www.google.com';
		}
		
		return resObj;
	}


	public class soaResponse{
	    public String status {get;set;}
        public String url {get;set;}
    }
}