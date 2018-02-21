/* 
 *  Apex Stips Handler Class
 * 
 *  Version           Author                 Date                 Description 
 *  1.1               Yogesh Mahajan         24-02-2016           Added method for Before Delete on
                                                                  line no.22
 */

public with sharing class StipsHandler {
	
	public void onAfterInsert(list<Stips__c> stipsList){
		
		//For all the inserted stips pass trigger in
		StoreChildToParentHelper objHandler = new StoreChildToParentHelper();
		objHandler.copyField(stipsList);
	} 
	
	public void onAfterUpdate(){
		
	}
	
	public void onBeforeDelete() {
	    System.debug('---Into handler--->');
	    new AttachmentService().deleteStipAttachmentAndAttachment(trigger.oldMap.keySet());
	}
}