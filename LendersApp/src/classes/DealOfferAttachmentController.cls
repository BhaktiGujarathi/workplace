public with sharing class DealOfferAttachmentController {

    public Attachment attachment {get; set;}
    public AttachmentWrapper[] wrappers {get; set;}
    public Id opportunityId {get;set;}
    public Boolean showAttachments {get;set;}


	public DealOfferAttachmentController(ApexPages.StandardController controller) {

        attachment = new Attachment();

        opportunityId = (Id)controller.getRecord().Id;

        attachment.ParentId = opportunityId;

        showAttachments = true;
	}


    public PageReference insertAttachment () {

        try {

            insert attachment;
                
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.CONFIRM, ' File was succesfully attached');
            this.getAllAttachments();
            ApexPages.addMessage(message);            
        }
        catch (Exception e) {

            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(e));
            ApexPages.addMessage(message);

        }      
       
        return null;
    }


    public void getAllAttachments() {

        wrappers = new AttachmentWrapper[] {};

        Attachment[] attachments = [SELECT Id,
                                           Name,
                                           ContentType,
                                           BodyLength,
                                           Body
                                      FROM Attachment
                                     WHERE ParentId = :opportunityId];

        for (Attachment attachment :attachments) {

            wrappers.add(new AttachmentWrapper(attachment));
        }

        if (wrappers != null) {

            showAttachments = true;
        }
    }

    public PageReference selectedAttachments() {   

        if (wrappers != null) {

            for (AttachmentWrapper include : wrappers) {

                if (include.isSelected) {


                }
            }
        }

        return null;
    }

}