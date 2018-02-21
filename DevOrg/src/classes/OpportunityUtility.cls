public with sharing class OpportunityUtility {
	
	public List<Attachment> oplist {get; set;}
	
	//constructor
	public OpportunityUtility() {
		oplist= new List<Attachment>();
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
    	String s1 = ApexPages.currentPage().getParameters().get('data');
        transient Blob blobValue = EncodingUtil.base64Decode(s1.substringAfter('base64,'));
        Attachment attach = new Attachment();  
        attach.Body= blobValue;
        attach.ParentId = ApexPages.currentPage().getParameters().get('id');
        attach.Name= ApexPages.currentPage().getParameters().get('name');
        try{
            insert attach;
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please select how many files you want to upload.'));
        }
        getAllAttachment();  
    }
    
    public string getbaseUrlOrg(){
        return MCAStringConstant.baseUrlOrg;
    }
}