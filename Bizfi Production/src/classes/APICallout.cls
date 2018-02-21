global with sharing class APICallout {

	private static String method = 'POST';
	private static String key = 'Content-Type';
	private static String value = 'application/json;charset=UTF-8';
	/*
	public Submission() {
		this.method = method;
		this.endpoint = endpoint;
		this.key = key;
		this.value = value;
	}
	*/
	global static HttpResponse PostCall(String endpoint, String body){

		// Prepare http callout
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod(method);
		request.setHeader(key, value);
		request.setBody(body);

		Http http = new Http();
		HttpResponse res = new HttpResponse();

			
		//Send the request to MCC endpoint and catch any errors that might occur 		
		try{
			res = http.send(request);
			System.debug('Sending message to external endpoint');
		} catch(CalloutException ce) {
			System.debug('Callout Error:  ' + ce.getMessage());
		} catch(Exception e) {
			System.debug('There was and error:  ' + e.getMessage());
		}

		return res;
	}

}