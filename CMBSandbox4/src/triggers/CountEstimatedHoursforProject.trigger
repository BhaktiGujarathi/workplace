trigger CountEstimatedHoursforProject on Estimates__c (after delete, after insert, after update) 
{
	CountEstimatedHoursforProjectController prjController= new CountEstimatedHoursforProjectController();
	string status;
	if(Trigger.isInsert && Trigger.isAfter)
	{
		status = 'insert';
		prjController.onInsert(trigger.New,status);
    }     
    if(Trigger.isUpdate)
	{		
		prjController.onUpdate(trigger.New, trigger.oldMap);
		
    } 
    if(Trigger.isDelete && Trigger.isAfter)
	{
		status = 'delete';
		prjController.onInsert(trigger.old,status);
    } 
}