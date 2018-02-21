/*
Created By : Swapnil Gholap
Use : Controller of 'Upload Attachment' common file upload functionality
*/

public class UploadAttachmentController{
    
    public transient Blob fileBody {get;set;}
    public String fileName {get;set;}
    public Case objCase;
    public String selectedType {get;set;} 
    public string returnString {get;set;}   
    public string strAccountID {get;set;}   
    public string strDocumentType {get;set;}   
    public string strReturnPage {get;set;}   
    
    public UploadAttachmentController(ApexPages.StandardController controller) { 
        this.objCase= (Case)controller.getRecord();
        strAccountID = ApexPages.currentPage().getParameters().get('accID');
        selectedType = ApexPages.currentPage().getParameters().get('doc');
        strReturnPage = ApexPages.currentPage().getParameters().get('returnPage');
        
        if(selectedType == 'NOC'){            
            strDocumentType = 'NOC';
        }
        else if(selectedType == 'PowerOfAttorney'){
            strDocumentType = 'Power Of Attorney';
        }
        else if(selectedType == 'CRF'){
            strDocumentType = 'CRF Form';
        }
        
        System.debug('---selectedType--'+selectedType);
        if(String.isNotBlank(strAccountID ) && String.isNotBlank(selectedType) && String.isNotBlank(strReturnPage)){
            //returnString = '/apex/CRE_Refund?accID='+strAccountID+'&caseID='+objCase.id;
            returnString = '/apex/'+strReturnPage+'?accID='+strAccountID+'&caseID='+objCase.id;
        }
    }
    
    public Database.SaveResult saveCustomAttachment(){
        SR_Attachments__c obj = new SR_Attachments__c ();
        obj.Case__c = objCase.Id; 
        //obj.description__c = description;
        obj.type__c = strDocumentType;
        //obj.isValid__c = selectedAwesomeness;
        // fill out cust obj fields
        return Database.insert(obj,true);
        
    }
    // create an actual Attachment record with the SR_Attachments__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        System.debug('--parentId--'+parentId);
        
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        System.debug('--attachment.body --'+attachment.body );
        attachment.name = this.fileName;
        attachment.parentId = parentId;
        // inser the attahcment
        result = Database.insert(attachment,true);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
        
        
    }
    
    public PageReference processUpload() {
        try {
            
            if(this.fileBody != null && String.isNotBlank(this.fileName)){
                Database.SaveResult customAttachmentResult = saveCustomAttachment();
                if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                               'Could not save attachment.'));
                    return null;
                }
                Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
                System.debug('--attachmentResult--'+attachmentResult);
                if (attachmentResult == null || !attachmentResult.isSuccess()) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                               'Could not save attachment.'));            
                    return null;
                } else {
                    // update the custom attachment record with some attachment info
                    SR_Attachments__c customAttachment = [select id from SR_Attachments__c where id = :customAttachmentResult.getId()];
                    customAttachment.name = this.fileName;
                    customAttachment.Attachment__c = attachmentResult.getId();
                    update customAttachment;
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,'Please select file'));
                return null;
            }
        }
        catch(exception ex){
            ApexPages.AddMessages(ex);
            return null;
        }
        return new PageReference(returnString);
    }
    
    public PageReference back() {
        return new PageReference(returnString);
    }     
}