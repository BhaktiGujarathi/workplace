@isTest
private class APIServiceTest{
    
    static testmethod void TestAPIService(){
        
        QBF_Connect_Settings__c qbfConnect = new QBF_Connect_Settings__c(APIKey__c='jvf3FfkEvUyCX+VUJNP1mw==',
                                                    ClientSecret__c='MzY6NDQ1Mjc6anZmM0Zma0V2VXlDWCtWVUpOUDFtdz09',
                                                    EndPoint__c='https://connect.quickbridgefunding.com/QBFConnectDev/QBFConnectRest.svc');
        insert qbfConnect;
        
        Document doc = new Document(Name='Test.txt',Body=Blob.valueOf('Hello'),folderId=UserInfo.getUserId()); 
        insert doc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Map<String, Object> data = APIService.accessToken();
        System.debug(data);
        
        
        AccessTokenResult token = new AccessTokenResult();                                
        token.ErrorMessage = (String)data.get('ErrorMessage');
        token.StatusCode= (Integer)data.get('StatusCode');
        token.AccessToken = (String)data.get('AccessToken');
        
        
        String due = (String)data.get('ExpiresOn');
        //
        //String secs = due.split('\\(')[1].split('\\-')[0];
        Datetime dt = Datetime.newInstance(Long.valueOf(due));
        //
        token.ExpiresOn = dt.date();

        System.assertEquals(token ,token);
        
        DealSubmission deal = new DealSubmission();
        

        Map<String, Object> dealData = APIService.submitDeal(token,deal);
        DealSubmissionResult dealResult = new DealSubmissionResult();
        due = (String)dealData.get('ProcessedOn');
        //
        String secs = due.split('\\(')[1].split('\\-')[0];
        dt = Datetime.newInstance(Long.valueOf(secs));
        //
        dealResult.ProcessedOn = dt;
        dealResult.DealID = (Integer)dealData.get('DealID');
        dealResult.ExternalDealID = (String)dealData.get('ExternalDealID');
        
        System.assertEquals(dealResult,dealResult); 
        
        
        ConnectResult connectResult = APIService.uploadDocument(token,dealResult.DealID,doc.Body,doc.Name);
        System.assertEquals(ConnectResult,connectResult); 
        
        connectResult = APIService.uploadDocumentFromUrl(token,dealResult.DealID,'http://isr.uci.edu/tech_reports/UCI-ISR-02-7.pdf');
        System.assertEquals(ConnectResult,connectResult); 

        Test.stopTest();
    }
}