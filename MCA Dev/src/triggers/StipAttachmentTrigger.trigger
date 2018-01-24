trigger StipAttachmentTrigger on Stips_Attachment__c (after delete) {
    if(trigger.isAfter) {
        if(trigger.isDelete) {
            //new StipAttachmentHandler().onAfterDelete();
        }
    }
}