public with sharing class CaseAttachmentController {
    public String selectedType {get;set;}
    public Boolean selectedAwesomeness {get;set;}
    public Boolean damacSigned {get;set;}
    public String description {get;set;}
    public Boolean needCorrection {get;set;}
    public Case objCase {get;set;}
    public SR_Attachments__c objSRAttach {get;set;}
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    public list<selectoption> lstOptions {get;set;} 
    
    public CaseAttachmentController(ApexPages.StandardController controller) { 
        this.objSRAttach = (SR_Attachments__c)controller.getRecord();
        list<SR_Attachments__c> lstSRA = [Select Id
        									   , Attachment__c
        									   , IsRequired__c
        									   , Name
        									   , isValid__c
        									   , Description__c
        									   , SR_Attachments__c.Case__c 
								   		  from SR_Attachments__c
								   		  where Id =: this.objSRAttach.Id
								   		  limit 1];
   		this.objSRAttach = lstSRA[0];
        objCase = new Case(Id = lstSRA[0].Case__c);
        lstOptions = new list<selectoption>();
        lstOptions.add(new SelectOption('true','Yes'));
        lstOptions.add(new SelectOption('false','No'));
    }
    
    public CaseAttachmentController() { 
        
    }
    
    // creates a new SR_Attachments__c record
    private Database.UpsertResult saveCustomAttachment() {
        /*
        SR_Attachments__c obj = new SR_Attachments__c (Id = objSRAttach.Id);
        obj.Case__c = objCase.Id;
        obj.description__c = description;
        obj.type__c = selectedType;
        obj.isValid__c = selectedAwesomeness;
        */
        objSRAttach.Case__c = objCase.Id;
        objSRAttach.isValid__c = selectedAwesomeness;
        objSRAttach.Signed_by_DAMAC__c = damacSigned;
        objSRAttach.Need_Correction__c = needCorrection;
        // fill out cust obj fields
        return Database.upsert(objSRAttach);
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
            Database.UpsertResult customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        	
            Database.SaveResult attachmentResult = saveStandardAttachment(objSRAttach.Id);
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));            
                return null;
            } else {
                // update the custom attachment record with some attachment info
                SR_Attachments__c customAttachment = [select id from SR_Attachments__c where id = :objSRAttach.Id];
                //customAttachment.name = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                update customAttachment;
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
       // return null;
        return new PageReference('/'+objCase.Id);
    }
    
    public PageReference back() {
        return new PageReference('/'+objCase.Id);
    }
    
    public PageReference updateDetails() {
    	Database.UpsertResult customAttachmentResult = saveCustomAttachment();
        if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
              'Could not save attachment.'));
            return null;
        }
        return new PageReference('/'+objCase.Id);
    }
}