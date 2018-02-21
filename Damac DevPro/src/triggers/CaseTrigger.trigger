trigger CaseTrigger on Case( after insert, after update ) {
    
    /*if(trigger.isAfter && trigger.isUpdate) {
       new CaseTriggerHandler().onAfterUpdate(trigger.oldMap, trigger.new); 
    }*/
    
    if( trigger.isBefore ) {
    	
    }
    else if( trigger.isAfter ) {
    	if( trigger.isInsert ) {
            new CaseTriggerHandler().onAfterInsert( trigger.new );
    		new CallingListGenerator().onAfterInsert( trigger.new );
    		new CaseTriggerHandlerAssignment().afterInsert(trigger.new);
    	}
    	else if( trigger.isUpdate ) {
    		new CaseTriggerHandler().onAfterUpdate(trigger.oldMap, trigger.new);
    		new CallingListGenerator().onAfterUpdate( trigger.new, trigger.oldMap );
    		new CaseTriggerHandlerAssignment().afterUpdate(trigger.newMap, trigger.oldMap);
    		caseTriggerHandlerOTPVerification.afterUpdate(trigger.newMap, trigger.oldMap);
    	}
    }
}