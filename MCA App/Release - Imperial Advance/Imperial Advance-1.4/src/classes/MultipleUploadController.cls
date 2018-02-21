public class MultipleUploadController  {     
    //Picklist of integer values to hold file count  
    public List<SelectOption> filesCountList {get; set;} 
    public boolean ShowPreview{get; set;}
    //public List<NoteAndAttachMent> natt {get; set;}
    //public Opportunity oppt {get; set;} 
    //Selected count  
    public String FileCount {get; set;} 
    public String OppId {get; set;}
    public Blob attachmentBody {get; set;} 
    public String attachmentName {get; set;} 
    public transient List<attachment> oplist {get; set;}
    //Create list of Attachment object  
    public  List<Attachment> allFileList {get; set;} 
    
    //Private Variables
    private String retURL;
    private String accId;
    
    public MultipleUploadController(ApexPages.StandardController controller)  {  
        //Initialize    
        OppId = System.currentPagereference().getParameters().get('id');
        retURL = System.currentPagereference().getParameters().get('retURL');
        accId = System.currentPagereference().getParameters().get('accID');
        
        filesCountList = new List<SelectOption>() ;  
        FileCount = '' ;  
        allFileList = new List<Attachment>() ;  
          
        //Adding values count list - you can change this according to your need, Now it is 6
        for(Integer i = 1 ; i < 11 ; i++)  
            filesCountList.add(new SelectOption(''+i , ''+i)) ;  
        String isUpload = ApexPages.currentPage().getParameters().get('isUpload');
        if(isUpload !=null && isUpload !=''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm, ' File(s) are uploaded successfully'));    
        }
        
        oplist = new List<attachment>();
        oplist = [Select Id, IsDeleted, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, CreatedDate,
                        CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description FROM Attachment
                            where ParentId= :System.currentPageReference ().getParameters().get('id')
                                  Order by LastModifiedDate DESC]; 
                               
        }  
        
    public pagereference saveme(){
        try{
            update oplist;
        }   
        catch(Exception e){
            System.debug('Exception occurred '+String.valueOf(e));
        }
        return NULL;
    }   
      
    public pageReference SaveAttachments()  {  
        // to get id of the OppRecord from the URL

        String isSucess = 'Error';  
        // Checking Opp Record
        if(OppId == null || OppId == ''){  
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'No record is associated. Please pass record Id in parameter.'));
            return null;
        }  
        if(FileCount == null || FileCount == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please select how many files you want to upload.'));
            return null;
        }  
        
        // Create a list of attachemnt(Standard object) type
        List<Attachment> listToInsert = new List<Attachment>();
        
        //Attachment a = new Attachment(parentId = OppId , name=myfile.name, body = myfile.body);  
        for(Attachment a: allFileList)  
        {  
            // for checking attachment file name and body
            if(attachmentName != '' && attachmentBody!= null)  
                listToInsert.add(new Attachment(parentId = OppId , name = attachmentName, body = attachmentBody, description = a.Description)) ;  
        }  
          
        //Inserting attachments  
        if(listToInsert.size() > 0)  
        {  
            insert listToInsert;
            isSucess ='success';  
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, listToInsert.size() + ' file(s) are uploaded successfully'));          
            FileCount = '' ;
            
            //return null;             
        }  
        else{  
            // show error message if no file is uploaded
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please select at-least one file')); 
            return null;
        } 
        
         //Used for submission wizard to redirect to wizard on Upload
  	    if(retURL != null){
  	  		return new PageReference(retURL+'&accId='+accId);
  	  	}
  	   else{
       		//Refresh page after uploading attachment and return to same page
      		ID ContID= ApexPages.currentPage().getParameters().get('id');
      		PageReference pg=new PageReference('/'+ContID);
      		pg.getParameters().put('isUpload',isSucess);
      		return pg;
  	   }
	}  
        
        
      // count number of attachment to be uploaded
    public PageReference ChangeCount()  
    {  
        allFileList.clear() ;  
        //Adding multiple attachments instance  
        if(FileCount != Null)
        for(Integer i = 1 ; i <= Integer.valueOf(FileCount) ; i++)  
            allFileList.add(new Attachment()) ;  
        return null ;  
    } 
    
    /*Public Attachment [] getDocAttachment () {
        return [Select Id, IsDeleted, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, CreatedDate,
        CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description FROM Attachment
        where ParentId= :System.currentPageReference ().getParameters().get('id')
        Order by LastModifiedDate DESC];
       
        }*/
        
        public void CollectData() {
        String s1 = ApexPages.currentPage().getParameters().get('data');
        
        transient Blob b = EncodingUtil.base64Decode(s1.substringAfter('base64,'));
        
        Attachment a = new Attachment();  
        //a.Body = null;
        a.Body= b;
        a.ParentId = ApexPages.currentPage().getParameters().get('id');
        a.Name= ApexPages.currentPage().getParameters().get('name');
        insert a;
    }
    
    
     
}