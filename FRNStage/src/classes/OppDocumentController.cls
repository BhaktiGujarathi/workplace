public class OppDocumentController{
    
    public Opportunity webContact {get;set;}
    public Account accountObj {get; set;}
    public Attachment attach = new Attachment();
    public Blob bl {get; set;}
    public String fileName {get; set;}
    public String SelectedFiletype {get; set;}
    public String SelectedCategory {get; set;}
    public Document__c documentObj{get;set;} 
    public String objectName;
    public Id parentId {get; set;}
    //public String contentType {get; set;} 
    public OppDocumentController(ApexPages.StandardController stdController){
        SObject sobjectInstance = stdController.getRecord();
        objectName = '';
        objectName = sobjectInstance.getSObjectType().getDescribe().getName();
        system.debug('>>> sobjectInstance : '+objectName);
        if(objectName.equalsIgnoreCase('Opportunity')) {
            this.webContact = (Opportunity)stdController.getRecord();
            this.accountObj = new Account();
        }
        else if(objectName.equalsIgnoreCase('Account')) {
            this.accountObj = (Account)stdController.getRecord();
            this.webContact = new Opportunity();
        }
        documentObj = new Document__c();
        attach = new Attachment();
    }

    public PageReference save(){ 
        
         String fext = '';
            if(fileName!=null && fileName!='')
            fext=getFileExtension(fileName);
            if (fext== 'exe')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This attachment file type is invalid.'));
                return null;
            } 
            if(bl!=null){
                if(objectName.equalsIgnoreCase('Opportunity')) {
                    documentObj.Opportunity__c = webContact.Id;
                }
                else if(objectName.equalsIgnoreCase('Account')) {
                    documentObj.Account__c = accountObj.Id;
                }
                documentObj.Category__c = SelectedCategory;
                insert documentObj;
                attach.OwnerId = UserInfo.getUserId();
                attach.ParentId = documentObj.Id;
                attach.Name = fileName;
                attach.Body = bl;
            }
          
           
            if(SelectedFiletype !=null && SelectedFiletype !='- None -'){
                attach.ContentType = SelectedFiletype; 
            }
            try {
                insert attach;
            } catch (DMLException e) {
            System.debug('error');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
            }  
            
            if(objectName.equalsIgnoreCase('Opportunity')) {
                parentId = webContact.Id;
            }
            else if(objectName.equalsIgnoreCase('Account')) {
                parentId = accountObj.Id;
            }
            PageReference p= new PageReference('/'+parentId);
            p.setRedirect(true);
            
            return p; 
    }
	
	public PageReference savenNew(){ 
        
         String fext = '';
            if(fileName!=null && fileName!='')
            fext=getFileExtension(fileName);
            if (fext== 'exe')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This attachment file type is invalid.'));
                return null;
            } 
            if(bl!=null){
                if(objectName.equalsIgnoreCase('Opportunity')) {
                    documentObj.Opportunity__c = webContact.Id;
                }
                else if(objectName.equalsIgnoreCase('Account')) {
                    documentObj.Account__c = accountObj.Id;
                }

                documentObj.Category__c = SelectedCategory;
                insert documentObj;
                attach.OwnerId = UserInfo.getUserId();
                attach.ParentId = documentObj.Id;
                attach.Name = fileName;
                attach.Body = bl;
            }
          
           
            if(SelectedFiletype !=null && SelectedFiletype !='- None -'){
                attach.ContentType = SelectedFiletype; 
            }
            try {
                insert attach;
            } catch (DMLException e) {
				System.debug('error');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
				return null;
            } 

            if(objectName.equalsIgnoreCase('Opportunity')) {
                parentId = webContact.Id;
            }
            else if(objectName.equalsIgnoreCase('Account')) {
                parentId = accountObj.Id;
            } 
            PageReference p= new PageReference('/apex/OppDocumentPage?id='+parentId);
            p.setRedirect(true);             
            return p; 
    }
    
    
    public List<SelectOption> getCategoryType(){
        List<SelectOption> options = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult = Document__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
 
    public PageReference Cancel(){ 
        /*if(webContact!=null){
            PageReference p= new PageReference('/'+webContact.Id);
            p.setRedirect(true); 
            return p;
        }*/

        if(objectName.equalsIgnoreCase('Opportunity')) {
            parentId = webContact.Id;
        }
        else if(objectName.equalsIgnoreCase('Account')) {
            parentId = accountObj.Id;
        } 
        PageReference p= new PageReference('/'+parentId);
        p.setRedirect(true); 
        return p;
    }
// getting FileExtension type
    public string getFileExtension(string fileName){          
        
        integer found = fileName.lastIndexOf('.') + 1;      
        return (found > 0 ? fileName.substring(found) : '');

    }
 
        
}