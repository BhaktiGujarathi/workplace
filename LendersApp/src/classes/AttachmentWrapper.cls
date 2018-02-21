public with sharing class AttachmentWrapper {
    
    public Attachment record { get; set; }
    public Integer attachmentSize { get; set; }
    public Boolean isSelected { get; set; }

    
    public AttachmentWrapper(Attachment record) {

        this.record = record;
        attachmentSize = (record != null) ? (record.BodyLength / 1024) : 0;
        isSelected = false;     
    }
}