public class AttachmentOnSubmissionWizardController {     
    
    OpportunityUtility utility;
    public String OppId {get; set;}
	private String retURL;
    private String accId;
    
    
    public AttachmentOnSubmissionWizardController() {  
        OppId = System.currentPagereference().getParameters().get('id');
        retURL = System.currentPagereference().getParameters().get('retURL');
        accId = System.currentPagereference().getParameters().get('accID');
		//oplist = new List<Attachment>();
        utility = new OpportunityUtility();
        
     }
	
	// Get all attchment 
    public void getAllAttachment() {
        utility.getAllAttachment();
    }// End getAllAttchment()
    
    //upload all attachments
    public void CollectData() {
    	utility.CollectData();
    }
   
}