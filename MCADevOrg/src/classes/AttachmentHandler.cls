/* 
 *  Apex Handler class of trigger
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         23-02-2016           Initial Draft 
 */
public with sharing class AttachmentHandler {
    public AttachmentHandler() {}
    
    //method call into trigger in after delete
    public void onAfterAttachmentDelete() {
        new AttachmentService().deleteStipAttachment(trigger.oldMap.keySet());
        new AttachmentService().updateSubmission(trigger.oldMap.keySet());
    }
    
}