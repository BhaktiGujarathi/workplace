global class LeadLoanCalculatorMockCallout implements HttpCalloutMock {
	
	global HTTPResponse respond(HTTPRequest req) {
		
        System.assertEquals('GET', req.getMethod());
        
		// Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"loan_values":{"term":12,"rate":14.99,"amount":75000.0,"closing_fee":3712.5,"pay_count":252,"daily_prin_int":320.57,"daily_gfee":17.85,"daily_gfee_2":47.61}}');
        res.setStatusCode(200);
        return res;
   }
}