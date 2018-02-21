/*******************************
* Author: Pike Pullen
* Purpose : Trigger for ContentVersion
* Version           Date
* ------------------------------------------------
* 1.0                14 Nov 2016
 CHANGE HISTORY
* =============================================================================
* Date         Name                  Description
* 2016-11-14   Pike - BW-IBM         added trigger code for updated case upon contentversion attachment upload
* =============================================================================
*/
trigger ContentVersionTrigger on ContentVersion (before insert, before update, after insert, after update) {
	if(Trigger.isAfter){
		if(Trigger.isInsert){
			system.debug('Begin ContentVersionTrigger After Insert Trigger');
		}
		if(Trigger.isUpdate){
			system.debug('Begin ContentVersionTrigger After Update Trigger');
		}
	}
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			system.debug('Begin ContentVersionTrigger Before Insert Trigger');
		}
		if(Trigger.isUpdate){
			system.debug('Begin ContentVersionTrigger Before UpdateTrigger');
			/*
			@description while it would appear that the trigger should fire on insert, it only attaches to the User doing the insert on first pass
			There is an update that is performed after the insert to relate this record to the case.  That is the information we need.
			*/
			ContentVersionHandler.handleAfterInsert(trigger.newMap);
		}
	}
}