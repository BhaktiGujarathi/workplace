@isTest  
private class MetadataServiceTest
{    
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            if(request instanceof MetadataService.readMetadata_element){
            	MetadataService.IReadResponseElement response_x;
                response.put('response_x', response_x);
            }
            
            return;
        }
    }    
        
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.updateMetadata(null);
        metaDataPort.readMetadata('CustomLabel',new List<String>{'Activity_Band_Size','Performance_Band_Size'});
    }

    
    @IsTest
    private static void coverGeneratedCodeTypes()
    {              
        // Reference types
        new MetadataService();
        new MetadataService.LogInfo();
        new MetadataService.CallOptions_element();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.CustomLabel();
        new MetadataService.Metadata();
        new MetadataService.SessionHeader_element();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.Error();
        new MetadataService.SaveResult();
        new MetadataService.updateMetadata_element();
        new MetadataService.updateMetadataResponse_element();
        new MetadataService.readMetadata_element();
        new MetadataService.ReadCustomLabelResult();
        new MetadataService.readCustomLabelResponse_element();
    }
}