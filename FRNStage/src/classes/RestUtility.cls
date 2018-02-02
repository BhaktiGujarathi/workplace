public with sharing class RestUtility {

    public Enum HttpMethod { GET, POST, PUT, PATCH }
    public RestUtility() 
    {

    }
    
    // Method to create HTTP request with parameters
    public static HttpRequest createHttpRequest(String endpoint, 
                                                HttpMethod method, 
                                                Map<String, String> params, 
                                                Map<String, String> headers, String body) 
    {
        HttpRequest request =  new HttpRequest();
        request.setMethod(method.name());
        request.setTimeout(ConstantUtility.SET_TIMEOUT);

        if (method == HttpMethod.GET && params != null) {
            endpoint += '?';
            for (String name : params.keySet()) {
                endpoint += name + '=' + params.get(name)+'&';
            }
        }
        endpoint = endpoint.removeEnd('&');
        request.setEndpoint(endpoint);

        if ((method == HttpMethod.POST || method == HttpMethod.PUT || method == HttpMethod.PATCH) && body!= null) {
            request.setBody(body);
        }

        if (headers != null) {
            for (String header : headers.keySet()) 
            {
                
                request.setHeader(header, headers.get(header));
               
            }
           
        }
        
        return request;
    }

    // Method to create a POST HTTP request
    public static HttpRequest createPostRequest (String endpoint, Map<String, String> headers, String body) {
        return createHttpRequest(endpoint, HttpMethod.POST, null, headers, body);
    }

    // Method to create a PUT HTTP request
    /*public static HttpRequest createPutRequest (String endpoint, Map<String, String> headers, String body) {
        return createHttpRequest(endpoint, HttpMethod.PUT, null, headers, body);
    }*/

    // Method to create a GET HTTP request
    public static HttpRequest createGetRequest (String endpoint, Map<String, String> headers, Map<String, String> params) {
        return createHttpRequest(endpoint, HttpMethod.GET, params, headers, null);
    }

    // Method to create a PATCH HTTP request
    /*public static HttpRequest createPatchRequest (String endpoint, Map<String, String> headers, String body) {
        return createHttpRequest(endpoint, HttpMethod.POST, null, headers, body);
    }*/

    // Method to get the response as String
    public static HttpResponse getResponse (HttpRequest request) {
        HttpResponse response;
        try {
            Http http = new Http();
            response = http.send(request);
        } 
        catch(System.LimitException ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ConstantUtility.MESSAGE_CALLOUT_LIMIT));
        }
        return response;
    }

}