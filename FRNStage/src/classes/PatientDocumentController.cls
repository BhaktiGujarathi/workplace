public class PatientDocumentController{
    
    public Contact webContact{get;set;}
    public Attachment attach = new Attachment();
    public Blob bl {get; set;}
    public String fileName {get; set;}
    public String SelectedFiletype {get; set;}
    public Document__c documentObj{get;set;}                                                                                //public String contentType {get; set;} 
    public PatientDocumentController(ApexPages.StandardController stdController){
        this.webContact = (Contact)stdController.getRecord();
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
        documentObj.Patient__c = webContact.Id;
        insert documentObj;
        
        attach.OwnerId = UserInfo.getUserId();
        attach.ParentId = documentObj.Id;
        attach.Name = fileName;
        attach.Body = bl;
       
        if(SelectedFiletype !=null && SelectedFiletype !='- None -'){
            attach.ContentType = SelectedFiletype;
        
        }
        System.debug('SelectedFiletype>>'+SelectedFiletype);         
        System.debug('fext>>'+fext);                                              
        System.debug('attach>>'+attach);
        System.debug('fileName>>'+fileName); 
        try {
            insert attach;
        System.debug('attach inserted >>'+attach);
        System.debug('attach content >>'+attach.contenttype);
        } catch (DMLException e) {
        System.debug('error');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            System.debug('error at line'+e.getLinenumber());
            System.debug('error msg'+e.getMessage());
        return null;
        }  
        PageReference p= new PageReference('/'+webContact.Id);
        p.setRedirect(true);
        
        return p;
    }
    
    public PageReference Cancel(){ 
        if(webContact!=null){
            PageReference p= new PageReference('/'+webContact.Id);
            p.setRedirect(true); 
            return p;
        }
        return null;
    }
// getting FileExtension type
    public string getFileExtension(string fileName){          
        
        integer found = fileName.lastIndexOf('.') + 1;
        System.debug('found>>>>>>>>>>>>>'+found);        
        return (found > 0 ? fileName.substring(found) : '');

        }
 
        
}