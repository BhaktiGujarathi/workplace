public with sharing class OpportunityUtility {
  
  public List<Attachment> oplist {get; set;}
  public List<Attachment> lstAttach;
  //constructor
  public OpportunityUtility() {
    oplist= new List<Attachment>();
    lstAttach = new List<Attachment>();
  }
  
  // Get all attchment 
    public void getAllAttachment() {
        
        oplist = [Select Id,
                            Name,
                            IsPrivate, 
                            CreatedById,
                            LastModifiedDate,
                            Description 
                  FROM Attachment where ParentId= :System.currentPageReference().getParameters().get('id')
                  Order by LastModifiedDate DESC]; 
    }// End getAllAttchment()
    
     //upload all attachments
    public void CollectData() {
        try {
            Attachment objAttach;
            if((Limits.getHeapSize()+(ApexPages.currentPage().getParameters().get('data')).length()+(ApexPages.currentPage().getParameters().get('data')).length())< 6000000  ) {
                
                objAttach = new Attachment();  
                objAttach.Body= EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('data').substringAfter('base64,'));
                objAttach.ParentId = ApexPages.currentPage().getParameters().get('id');
                objAttach.Name= ApexPages.currentPage().getParameters().get('name');
                try{
                    insert objAttach;
                    
                    lstAttach.add(new Attachment(id=objAttach.id));
                } catch(Exception e) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
                }
                //getAllAttachment();
            } else {
                System.debug('>>>into else>>>');
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Apex heap size too large, Please use Attach File button to upload the file.')); 
                //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'File name '+ApexPages.currentPage().getParameters().get('name')+' is too large for Drag and drop.Please use Attach File button to upload the file.'));
                
            }    
        }catch (Exception e) {
            
        }
    }
    
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
}