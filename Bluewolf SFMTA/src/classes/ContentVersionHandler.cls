/*******************************
* Author: Pike Pullen
* Purpose : Handler class for ContentVersionTrigger.
* Version           Date
* ------------------------------------------------
* 1.0                14 Nov 2016
 CHANGE HISTORY
* =============================================================================
* Date         Name                  Description
* 2016-11-14   Pike - BW-IBM         First Successul trigger made, Unit Tests added
* =============================================================================
*/
public without sharing class ContentVersionHandler {
    public static void handleAfterInsert(Map<Id, ContentVersion> newMap){
    	system.debug('Begin ContentVersionHandler.handleAfterInsert');

    	/*
    	@description get the ContentDocumentId ids related to the ContentVersion
    	ContentVersion is the object being triggered
    	*/
    	Set<Id> contentDocumentIds = new Set<Id>();
    	for(ContentVersion cv :newMap.values()){
    		contentDocumentIds.add(cv.ContentDocumentId);
    	}

    	if(contentDocumentIds != null){
	    	/*
	    	@description get the linked entities, the records related to the content document
	    	based upon the related id in the ContentVersion records
	    	*/
	    	Set<Id> linkedEntityIds = new Set<Id>();
	    	for(ContentDocumentLink cdl :[SELECT Id, ContentDocumentId, LinkedEntityId 
	    		FROM ContentDocumentLink 
	    		WHERE ContentDocumentId IN:contentDocumentIds]){
	    		String parentType = (cdl.LinkedEntityId).getSObjectType().getDescribe().getName();
				linkedEntityIds.add(cdl.LinkedEntityId);
	    	}

	    	if(linkedEntityIds != null){
		    	/*
		    	@description update the cases
		    	*/
		    	List<Case> casesToUpdate = new List<Case>();
		    	for(Id ei : linkedEntityIds){
					String parentType = (ei).getSObjectType().getDescribe().getName();
					if(parentType.equalsIgnoreCase('Case')){
						casesToUpdate.add(new Case(Id=ei, Attachment_Uploaded__c=true));
					}
				}

				update casesToUpdate;
			}
		}
    }
}