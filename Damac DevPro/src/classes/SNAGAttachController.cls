public class SNAGAttachController {
    public String selectedType {get;set;}
    public Boolean selectedAwesomeness {get;set;}
    public String description {get;set;}
    public Case objCase {get;set;} 
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    private String Id;
    
    public SNAGAttachController() { 
    	//system.debug('!!!!!!!!id'+controller.getRecord());
        //this.objCase = (Case)controller.getRecord();
        Id = ApexPages.currentPage().getParameters().get('id'); 
        system.debug('!!!!!!!!!Id'+Id);
    }   
    
    // creates a new SR_Attachments__c record
    private Database.SaveResult saveCustomAttachment() {
    	SNAGs__c obj = new SNAGs__c();
    	if (Id.startsWith('500')) {
        Case objCaseRec = [Select Id, Booking_Unit__c From Case Where Id=: Id];
        obj.Case__c = objCaseRec.Id;
        obj.Booking_Unit__c = objCaseRec.Booking_Unit__c;
    	} else if (Id.startsWith('a1S')) {    		
    		obj.Property__c = Id;
    	} else if (Id.startsWith('a1J')) {    		
    		obj.Location__c = Id;
    	}
        //obj.description__c = description;
       // obj.type__c = selectedType;
        //obj.isValid__c = selectedAwesomeness;
        // fill out cust obj fields
        return Database.insert(obj);
    }
    
    // create an actual Attachment record with the SR_Attachments__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = parentId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
    

    public PageReference processUpload() {
        try {
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));            
                return null;
            } else {
                // update the custom attachment record with some attachment info
                SNAGs__c customAttachment = [select id from SNAGs__c where id = :customAttachmentResult.getId()];
                //customAttachment.name = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                update customAttachment;
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
       // return null;
        return new PageReference('/'+Id);
    }
    
    public PageReference back() {
        return new PageReference('/'+Id);
    }     

}