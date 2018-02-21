/*
 * CallOut for TiBit to get the passport details from an uploaded image.
 */ 
public class TbitsCallout {
    public TbitsCallout(BuyerDetailsController bdcObject) { }
    
    @RemoteAction 
    public static wrapperTbitsResponse getPassportDetails(String attachmentBody, String fileName, String dealId, String requestType){
        system.debug('#### attachmentBody = '+attachmentBody);
        system.debug('#### fileName = '+fileName);
        system.debug('#### dealId = '+dealId);
        String sUrl = system.Label.Tibits_URL+requestType;
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+fileName+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';              
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        String bodyEncoded;
        while(headerEncoded.endsWith('=')){
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        if(attachmentBody.containsIgnoreCase('base64,')){
        	bodyEncoded = attachmentBody.subStringAfter('base64,');	
        }else if(attachmentBody.containsIgnoreCase('data:image/png;base64,')){
        	bodyEncoded = attachmentBody.subStringAfter('data:image/png;base64,');		
        }
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4, bodyEncoded.length());
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        }else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setEndpoint(sUrl);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res;
        if(!Test.isrunningtest())
            res = http.send(req);
        else{
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(json.serialize(new wrapperTbitsResponse()));
        }
        system.debug('#### response from webservice = '+res);
        system.debug('#### response from webservice = '+res.getBody());  
        wrapperTbitsResponse obj = new wrapperTbitsResponse();
        if(res != null && res.getStatusCode() != null && res.getStatusCode() == 200){ 
	        obj = (wrapperTbitsResponse)Json.deserialize(res.getBody(), wrapperTbitsResponse.class);
	        obj.errorCode = res.getStatusCode();
	        obj.errorDescription = new cls_errorDescription(res.getStatus());
	        system.debug('#### response after deserializing = '+obj); 
	        if(obj != null && obj.fields != null && obj.fields.size() > 0 && String.isNotBlank(dealId) && String.isNotBlank(bodyEncoded)){ 
	        	for(cls_fields thisResponse : obj.fields){
	        		if(thisResponse.name != null && 
	        			(thisResponse.name.equalsIgnoreCase('PassportNumber') || 
	        			 thisResponse.name.equalsIgnoreCase('NationalId'))){
	        			String extension = filename.contains('.') ? filename.subStringAfter('.') : '.jpg';
	        			String documentType;
	        			if(String.isNotBlank(requestType) && requestType.containsIgnoreCase('Passport')){
	        				documentType = 'Passport';	
	        			}else if(String.isNotBlank(requestType) && requestType.containsIgnoreCase('Id')){
	        				documentType = 'National Id';	
	        			}
	        			if(String.isNotBlank(thisResponse.text) && String.isNotBlank(documentType)){
		        			Attachment attachmentRecord = new Attachment();
					        attachmentRecord.body = EncodingUtil.base64Decode(bodyEncoded);
					        attachmentRecord.name = thisResponse.text+'-'+documentType+' Copy.'+extension;
					        attachmentRecord.ContentType='image/jpg';
					        attachmentRecord.ParentId = dealId;
					        insert attachmentRecord;
					        system.debug('#### attachmentRecord = '+attachmentRecord);
					        break;
	        			}
	        		}	
	        	}
	        }
        }else{
        	obj.errorCode = res.getStatusCode();
        	obj.errorDescription = new cls_errorDescription(res.getStatus());	
        }
        return obj;
    }

    public class cls_errorDescription { 
    	public String message;
    	
    	public cls_errorDescription(String message){
    		this.message = message;		
    	}
    }
    
    public class cls_fields {
        public boolean valid;
        public String text; 
        public String name; 
    }
    public class cls_ReferenceID { }
    public class wrapperTbitsResponse{
        public String result; 
        public Integer errorCode; 
        public cls_errorDescription errorDescription;
        public cls_ReferenceID ReferenceID;
        public cls_fields[] fields;
        
        public wrapperTbitsResponse(){
            result = '';
            errorCode = null;
            errorDescription = new cls_errorDescription('');
            fields= new list<cls_fields>();
            ReferenceID = new cls_ReferenceID();
        }
    }
}// End of class.