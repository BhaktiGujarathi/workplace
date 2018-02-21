trigger CallingListTrigger on Calling_List__c ( before update, after update ) {
    system.debug('=== Trigger of calling list called===');
    if( trigger.isBefore ) {
    	if( trigger.isUpdate ) {
    		system.debug('=== Inside onBeforeUpdate ===');
    		CallingListHandler.onBeforeUpdate( trigger.newMap, trigger.oldMap );
    	}
    }
    else if( trigger.isAfter ) {
    	/*if( trigger.isUpdate ) {
    		system.debug('=== Inside onAfterUpdate ===');
    		CallingListHandler.onAfterUpdate( trigger.newMap, trigger.oldMap );
    	}*/
    }
}