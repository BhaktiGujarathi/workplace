/* 
 *  Attachment trigger
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         23-02-2016           Initial Draft 
 */
trigger AttachmentTrigger on Attachment (after delete) {
    if(trigger.isAfter) {
        if(trigger.isDelete) {
            new AttachmentHandler().onAfterAttachmentDelete();
        }
    }
}