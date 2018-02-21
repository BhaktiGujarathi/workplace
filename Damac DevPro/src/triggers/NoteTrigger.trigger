/**************************************************************************************************
* Name               : NoteTirgger                                                          	  *
* Description        : This is a trigger on Note object.                                    *
* Created Date       : 09/05/2017                                                                 *
* Created By         : NSI                                                                        *
* Test Class		 : Describe_Sobject_Access_Test												  *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      		DATE		COMMENTS                                              *
* 1.0         NSI - Sivasankar  09/05/2017  Initial Draft                                         *
**************************************************************************************************/
trigger NoteTrigger on Note (before delete, before update) {
    Describe_Sobject_Access obj = new Describe_Sobject_Access('note','');
    obj.getAccess();
    for(Note thisNote : trigger.isUpdate ? trigger.new : trigger.oldMap.values()){
	    if(trigger.isUpdate && !obj.canEditRecord)
			thisNote.addError('You are not allowed to edit the Note.');
		if(trigger.isDelete && !obj.canDeleteRecord)
			thisNote.addError('You are not allowed to delete the Note.');
    }
}