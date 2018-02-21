global class InquiryEmailHandler implements Messaging.InboundEmailHandler {
    
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            Inquiry__c inq = new Inquiry__c();
            if(email.PlainTextBody != null && email.PlainTextBody.contains('Inq-Ref:')){
                List<String> vals = email.PlainTextBody.split('Inq-Ref:');
                System.debug('>>>>>>>>vals>>>>>>>>'+vals);
                if(vals != null && vals.size() >= 2){
                	String recordId = vals[1].substring(0,15);
	                System.debug('>>>>>>>>>>recordId>>>>>>>>>>>>>'+recordId);
	                inq = [Select id from Inquiry__c where Id=:recordId];
	                Id ICRecordTypeId = Schema.SObjectType.Email_message__c.getRecordTypeInfosByName().get('Incoming').getRecordTypeId();
	                Email_Message__c em = new Email_Message__c();
	                em.Incoming__c = true;
	                em.Subject__c = email.subject;
	                em.recordTYpeId = ICRecordTypeId;
	                em.Description__c = email.PlainTextBody;
	                em.HTML_Version__c = email.HTMLBody;
	                em.Inquiry__c = inq.Id;
	                insert em;
	          
	                System.debug('>>>>>>>>Text Attachments>>>>>>>>>>>'+email.TextAttachments);
	                System.debug('>>>>>>>>Binary Attachments>>>>>>>>>>>'+email.binaryAttachments);
	          
	                List<Attachment> lstAttach = new List<Attachment>();
	                if(email != null && email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
	                    for(Messaging.InboundEmail.BinaryAttachment ba: email.binaryAttachments){
	                        Attachment att = new Attachment();
	                        att.Name = ba.fileName;
	                        att.body =  ba.body;
	                        att.contentType = ba.mimeTypeSubType;
	                        att.parentId = em.Id;
	                        lstAttach.add(att);
	                    }
	                }
	                if(email != null && email.TextAttachments != null && !email.TextAttachments.isEmpty()){
	                    for(Messaging.InboundEmail.TextAttachment ta: email.TextAttachments){
	                        Attachment att = new Attachment();
	                        att.name = ta.fileName;
	                        att.body =  Blob.valueOf(ta.body);
	                        att.contentType = ta.mimeTypeSubType;
	                        att.parentId = em.Id;
	                        lstAttach.add(att);
	                    }
	                }
	                if(!lstAttach.isempty()){
	                    insert lstattach;
	                }	
                }
            }
        }
        catch(exception e){ }
        result.success = true;
        return result;
    }
}// End of class.