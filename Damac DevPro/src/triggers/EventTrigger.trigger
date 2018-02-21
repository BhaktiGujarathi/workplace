/**************************************************************************************************
* Name               : EventTrigger                                                               *
* Description        : This is a trigger on events object.                                        *
* Created Date       : 12/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         12/01/2017                                                              *
**************************************************************************************************/
trigger EventTrigger on Event (after insert, after update) {
	TriggerFactoryCls.createHandler(Event.sObjectType);    
}// End of trigger.