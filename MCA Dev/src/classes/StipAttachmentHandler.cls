/* 
 *  Apex Handler class of trigger
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         24-02-2016           Initial Draft 
 */
public with sharing class StipAttachmentHandler {
    
    public StipAttachmentHandler() {}
    public void onAfterDelete() {
        //new AttachmentService().deleteAttatchments(trigger.old);
    }
}