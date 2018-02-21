@isTest(seeAllData=true)                        
private class CalloutStaticClassTest {
    @isTest static void testCalloutWithStaticResources() {
        // Use StaticResourceCalloutMock built-in class to
        // specify fake response and include response body 
        // in a static resource.
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('achTestMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        AchWorksUtil.connectionCheck();
                
    }
}