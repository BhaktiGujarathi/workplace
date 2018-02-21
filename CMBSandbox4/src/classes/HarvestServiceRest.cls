public with sharing class HarvestServiceRest extends HarvestService {
	
	
	public HarvestServiceRest(String username, String password, String baseUrl) {
		this.username = username;
		this.password = password;
		this.baseUrl = baseUrl;
	}
	
	public override Dom.Document sendHttpRequest(HttpRequest req) {
		Http h = new Http();
		HttpResponse response = h.send(req);
		Dom.Document doc;
		if (req.getMethod() == 'GET') { 
			doc = response.getBodyDocument(); 
		}
		return doc;
	}
}