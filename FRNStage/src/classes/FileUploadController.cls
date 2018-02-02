global with sharing class FileUploadController {
    
    @RemoteAction
    global static String attachBlob(string parentID,String lgId,String scrId,String attachmentId, String fileName, String contentType, String base64BlobValue){
              system.debug('>>>>>>>'+parentID); 
              system.debug('>>>>>>>'+attachmentId); 
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
			Document__c doc = new Document__c();
			  doc.Patient__c = parentID;
			  doc.Description__c = 'TIER ID: ' +lgId+ ', Screening ID: '+scrId;
			  doc.Category__c = 'Historical Screening';
			  insert doc;
            Attachment att = new Attachment(
                ParentId = doc.Id,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert att;
            
            //Return the new attachment Id
            return att.Id;
            
        }else{
			 system.debug('>>>>>>>'+attachmentId); 
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }
}