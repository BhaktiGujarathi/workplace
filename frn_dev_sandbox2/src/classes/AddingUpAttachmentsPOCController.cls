public Class AddingUpAttachmentsPOCController {

    String recId;
    public List<Attachment> attchmentList {get; set;}
    public Opportunity opp {get; set;}

    public AddingUpAttachmentsPOCController(ApexPages.StandardController controller) {
        recId = controller.getId();
        opp = [SELECT Id, 
                      (SELECT id, 
                              Linked_Document__c 
                         FROM Documents__r)
                 FROM Opportunity 
                WHERE Id =: recId];
                system.debug('opp------------'+opp);
        //getAttachedDocsList(recId);  
    }
    
    public String getFileId() {
        String fileId = '';
        List<Attachment> attachedFiles = [select Id from Attachment where Id = '00Pg0000005tMql'];
        if( attachedFiles != null && attachedFiles.size() > 0 ) {
            fileId = attachedFiles[0].Id;
        }
        return fileId;    
    }

    @RemoteAction
    public static List<AttachmentWrapper> getAttachedDocsList(String pParentOpportunityId) {
        system.debug('pParentOpportunityId-----'+pParentOpportunityId);
        List<AttachmentWrapper> attchmentList =  new List<AttachmentWrapper>();

        AttachmentWrapper attachmentWrapper;

        for(Attachment attachment :  [SELECT id,
                                             Body,
                                             Name,
                                             ContentType
                                        FROM Attachment
                                       WHERE ParentId IN (
                                      SELECT Linked_Document__c 
                                        FROM Document__c
                                       WHERE Opportunity__c = :pParentOpportunityId
        )]){
            attachmentWrapper = new AttachmentWrapper();
            attachmentWrapper.Name = attachment.Name;
            attachmentWrapper.ContentType = attachment.ContentType;
            attachmentWrapper.Body = EncodingUtil.base64Encode(attachment.Body);
            attchmentList.add(attachmentWrapper);
            system.debug('attachmentWrapper------------'+attachmentWrapper);
            system.debug('attchmentList------------'+attchmentList);
        }
        return attchmentList;        
    }


    public class AttachmentWrapper {
        public String Name;
        public String ContentType;
        public String Body;
    }
}