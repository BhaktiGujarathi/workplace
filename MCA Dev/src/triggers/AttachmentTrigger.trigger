/* 
 *  Attachment trigger
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         23-02-2016           Initial Draft 
 */
trigger AttachmentTrigger on Attachment (after delete, before delete) {
    
    if(trigger.isDelete) {
        if(trigger.isAfter) {
            new AttachmentHandler().onAfterAttachmentDelete();
            
        }
        
        /*if(trigger.isBefore) {
            new AttachmentService().updateSubmission(trigger.oldMap.keySet());
            System.debug('>>Into b4 Trigger Attachment>>>');
        }*/
    }
}