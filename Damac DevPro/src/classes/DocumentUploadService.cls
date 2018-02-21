public with sharing class DocumentUploadService {
    public static DocumentUploadService.DocumentWrapper uploadDocument( String strBase64Encoded , 
    								   String regId , 
    								   String strEntityName , 
    								   String fileId , 
    								   String strFileName ) {
    	DocumentWrapper objDocWrapper ;
    	soapencodingTypesDatabindingAxis2Apa.Base64Binary objEncodedString = new soapencodingTypesDatabindingAxis2Apa.Base64Binary();
    	objEncodedString.base64Binary = strBase64Encoded ;
    	
    	AOPTMQClass.AOPTHttpSoap11Endpoint objDocUpload = new AOPTMQClass.AOPTHttpSoap11Endpoint();
    	String response = objDocUpload.DocumentAttachment( String.valueOf( system.now() ), 
    									 'ATTACH_DOC_IN_EBS', 
    									 'SFDC', 
    									 'SFDC',
    									 regId , 
    									 strEntityName, 
    									 'miscellaneous', 
    									 fileId ,
    									 strFileName ,
    									 '',
    									 '', 
    									 objEncodedString );
    	
    	system.debug('==reponse=='+response);
    	if( String.isNotBlank( response ) ) {
    		objDocWrapper = (DocumentWrapper)JSON.deserialize( response, DocumentUploadService.DocumentWrapper.class );
    	}
    	return objDocWrapper ;
    }
    
    public class DocumentWrapper {
    	public String PARAM_ID ;
    	public String PROC_STATUS ;
    	public String PROC_MESSAGE ;
    	public String url;
    }	
}